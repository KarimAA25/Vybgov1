// ignore_for_file: deprecated_member_use, depend_on_referenced_packages

import 'dart:developer';

import 'package:customer/constant_widgets/place_picker/selected_location_model.dart';
import 'package:customer/utils/utils.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter/material.dart';

class LocationController extends GetxController {
  GoogleMapController? mapController;
  var selectedLocation = Rxn<LatLng>();
  var selectedPlaceAddress = Rxn<Placemark>();
  var address = "Move the map to select a location".obs;
  TextEditingController searchController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    getCurrentLocation();
    searchController.addListener(() {
      if (searchController.text.trim().isEmpty) {
        getCurrentLocation();
      }
    });
  }

  Future<void> getCurrentLocation() async {
    Position? position = await Utils.getCurrentLocation();

    if (position != null) {
      selectedLocation.value = LatLng(position.latitude, position.longitude);
    }

    mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: selectedLocation.value!, zoom: 15),
      ),
    );

    getAddressFromLatLng(selectedLocation.value!);
  }

  Future<void> getAddressFromLatLng(LatLng latLng) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        latLng.latitude,
        latLng.longitude,
      );

      if (placemarks.isEmpty) return;

      final Placemark place = placemarks.first;
      selectedPlaceAddress.value = place;

      // ✅ Build clean formatted address
      final List<String> addressParts = [];

      if (place.name != null && place.name!.isNotEmpty) {
        addressParts.add(place.name!);
      }

      if (place.subLocality != null && place.subLocality!.isNotEmpty && place.subLocality != place.name) {
        addressParts.add(place.subLocality!);
      }

      if (place.locality != null && place.locality!.isNotEmpty) {
        addressParts.add(place.locality!);
      }

      if (place.administrativeArea != null && place.administrativeArea!.isNotEmpty) {
        addressParts.add(place.administrativeArea!);
      }

      if (place.country != null && place.country!.isNotEmpty) {
        addressParts.add(place.country!);
      }

      address.value = addressParts.join(", ");
    } catch (e) {
      if (kDebugMode) {
        print("Address error: $e");
      }
      address.value = "Unable to fetch address";
    }
  }

  void onMapMoved(CameraPosition position) {
    selectedLocation.value = position.target;
  }

  void confirmLocation() {
    if (selectedLocation.value != null) {
      SelectedLocationModel selectedLocationModel = SelectedLocationModel(address: selectedPlaceAddress.value, latLng: selectedLocation.value);

      log("Selected location model: ${selectedLocationModel.toJson()}");
      Get.back(result: selectedLocationModel);
    }
  }

  void moveCameraTo(LatLng target) {
    selectedLocation.value = target;
    mapController?.animateCamera(CameraUpdate.newLatLng(target));
    getAddressFromLatLng(target);
  }
}
