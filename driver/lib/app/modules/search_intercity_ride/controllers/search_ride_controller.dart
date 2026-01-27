// ignore_for_file: library_prefixes

import 'dart:developer' as developer;

import 'package:driver/app/models/intercity_model.dart';
import 'package:driver/app/models/map_model.dart';
import 'package:driver/app/models/parcel_model.dart';
import 'package:driver/constant/constant.dart';
import 'package:driver/utils/fire_store_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_map_math/flutter_geo_math.dart' as fmp;
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;
import 'package:latlong2/latlong.dart' as latLng;
import 'package:latlong2/latlong.dart' as latlang;

class SearchRideController extends GetxController {
  RxBool isLoading = false.obs;
  RxBool isParcel = true.obs;
  RxBool isSearchInterCity = false.obs;
  RxBool isSearchParcelCity = false.obs;
  RxBool isFetchingDropLatLng = false.obs;

  Rx<DateTime?> selectedDate = DateTime.now().obs;
  Rx<DateTime?> selectedParcelDate = DateTime.now().obs;
  TextEditingController dropLocationController = TextEditingController();
  TextEditingController pickupLocationController = TextEditingController();

  gmaps.LatLng? sourceLocation;
  gmaps.LatLng? destination;
  Position? currentLocationPosition;
  Rx<MapModel?> mapModel = MapModel().obs;

  FocusNode pickUpFocusNode = FocusNode();
  FocusNode dropFocusNode = FocusNode();

  RxList<IntercityModel> intercityBookingList = <IntercityModel>[].obs;
  RxList<ParcelModel> parcelBookingList = <ParcelModel>[].obs;
  RxList<IntercityModel> searchIntercityList = <IntercityModel>[].obs;
  RxList<ParcelModel> searchParcelList = <ParcelModel>[].obs;

  /// OSM MAP
  latlang.LatLng? osmSourceLocation;
  latlang.LatLng? osmDestination;

  @override
  Future<void> onInit() async {
    getData();
    super.onInit();
  }

  Future<void> getData() async {
    isLoading.value = false;
  }

  Future<void> fetchNearestIntercityRide() async {
    try {
      final src = activeSourceLocation;
      final dest = activeDestination;

      if (src == null) {
        developer.log("❌ Pickup location is required");
        return;
      }

      isSearchInterCity.value = true;
      final isFemaleUser = Constant.userModel?.gender?.toLowerCase() == 'female';
      List<IntercityModel> bookings = await FireStoreUtils.getNearestIntercityRide(
        srcLat: src.latitude,
        srcLng: src.longitude,
        date: selectedDate.value!,
      );

      searchIntercityList.assignAll(bookings.where((ride) {
        if (ride.dropLocation == null || ride.pickUpLocation == null) {
          return false;
        }

        if (ride.isOnlyForFemale == true && !isFemaleUser) {
          return false;
        }
        if (dest == null) return true;
        latLng.LatLng pickupPoint = latLng.LatLng(src.latitude, src.longitude);
        latLng.LatLng destinationPoint = latLng.LatLng(dest.latitude, dest.longitude);
        latLng.LatLng rideDrop = latLng.LatLng(
          ride.dropLocation!.latitude!,
          ride.dropLocation!.longitude!,
        );
        return isRideOnTheWay(
          pickup: pickupPoint,
          destination: destinationPoint,
          rideDrop: rideDrop,
        );
      }).toList());

      developer.log('✅ Filtered Intercity Rides: ${searchIntercityList.length}');
      isSearchInterCity.value = false;
    } catch (e, st) {
      isSearchInterCity.value = false;
      developer.log('❌ Error fetching intercity rides: $e');
      developer.log('$st');
    }
  }

  bool isRideOnTheWay({
    required latLng.LatLng pickup,
    required latLng.LatLng destination,
    required latLng.LatLng rideDrop,
  }) {
    // Bearing from pickup → destination
    double bearingToDestination = fmp.FlutterMapMath.bearingBetween(
      pickup.latitude,
      pickup.longitude,
      destination.latitude,
      destination.longitude,
    );

    // Bearing from pickup → rideDrop
    double bearingToRideDrop = fmp.FlutterMapMath.bearingBetween(
      pickup.latitude,
      pickup.longitude,
      rideDrop.latitude,
      rideDrop.longitude,
    );

    // Allow ~±30° tolerance
    double diff = (bearingToDestination - bearingToRideDrop).abs();
    if (diff > 180) diff = 360 - diff;

    return diff <= 30; // ✅ within corridor
  }

  Future<void> fetchNearestParcelRide() async {
    try {
      final src = activeSourceLocation;
      final dest = activeDestination;

      if (src == null) {
        developer.log("❌ Pickup location is required");
        return;
      }
      isSearchParcelCity.value = true;
      List<ParcelModel> bookings = await FireStoreUtils.getNearestParcelRide(
        srcLat: src.latitude,
        srcLng: src.longitude,
        date: selectedParcelDate.value!,
      );
      searchParcelList.assignAll(bookings.where((ride) {
        if (ride.dropLocation == null || ride.pickUpLocation == null) {
          return false;
        }
        if (dest == null) return true;
        latLng.LatLng pickupPoint = latLng.LatLng(src.latitude, src.longitude);
        latLng.LatLng destinationPoint = latLng.LatLng(dest.latitude, dest.longitude);
        latLng.LatLng rideDrop = latLng.LatLng(
          ride.dropLocation!.latitude!,
          ride.dropLocation!.longitude!,
        );
        return isRideOnTheWay(
          pickup: pickupPoint,
          destination: destinationPoint,
          rideDrop: rideDrop,
        );
      }).toList());
      developer.log('✅ Filtered Parcel Rides: ${searchParcelList.length}');
      isSearchParcelCity.value = false;
    } catch (e, st) {
      isSearchParcelCity.value = false;
      developer.log('❌ Error fetching parcel rides: $e');
      developer.log('$st');
    }
  }

  gmaps.LatLng? get activeSourceLocation {
    if (Constant.selectedMap == "Google Map") {
      return sourceLocation;
    } else {
      if (osmSourceLocation == null) return null;
      return gmaps.LatLng(
        osmSourceLocation!.latitude,
        osmSourceLocation!.longitude,
      );
    }
  }

  gmaps.LatLng? get activeDestination {
    if (Constant.selectedMap == "Google Map") {
      return destination;
    } else {
      if (osmDestination == null) return null;
      return gmaps.LatLng(
        osmDestination!.latitude,
        osmDestination!.longitude,
      );
    }
  }
}
