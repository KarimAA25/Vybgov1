// ignore_for_file: depend_on_referenced_packages

import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:driver/constant_widgets/osm_place_picker/location_suggestion_model.dart';
import 'package:driver/constant_widgets/osm_place_picker/osm_selected_location_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class OsmLocationPickerController extends GetxController {
  RxList<LocationSuggestion> suggestions = <LocationSuggestion>[].obs;
  final MapController mapController = MapController();
  RxList<LatLng> route = <LatLng>[].obs;
  var currentLocation = Rxn<LatLng>();
  var destination = Rxn<LatLng>();
  var selectedLocation = Rxn<LatLng>();
  var selectedPlaceAddress = Rxn<Placemark>();
  RxString address = ''.obs;
  RxBool isLoading = true.obs;
  StreamSubscription<Position>? positionStream;
  final locationController = TextEditingController();
  RxString selectedAddress = ''.obs;
  TextEditingController searchController = TextEditingController();
  Timer? _debounce;
  final int debounceDurationMs = 300;

  @override
  void onInit() {
    super.onInit();

    getCurrentLocation();
  }

  @override
  void onClose() {
    _debounce?.cancel();
    locationController.dispose();
    super.onClose();
  }

  void onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) {
      _debounce!.cancel();
    }

    _debounce = Timer(Duration(milliseconds: debounceDurationMs), () {
      // Only call the network function if the user has paused typing
      fetchLocationSuggestions(query);
    });
  }

  Future<void> fetchLocationSuggestions(String query) async {
    query = query.trim();
    suggestions.clear();

    // Minimum 2 characters
    if (query.length < 2) return;

    // Build the OSM Nominatim URL
    final Uri url = Uri.https(
      'nominatim.openstreetmap.org',
      '/search',
      {
        'q': query, // search query
        'format': 'json', // JSON output
        'addressdetails': '1', // detailed address
        'namedetails': '1', // detailed names
        'limit': '20', // increase limit for more results
        'dedupe': '1', // remove duplicates
        'accept-language': 'en', // language
      },
    );

    try {
      final response = await http.get(
        url,
        headers: {
          'User-Agent': 'FlutterOSMApp/1.0 (support@yourapp.com)', // required by OSM
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        // Map OSM results to your model
        final List<LocationSuggestion> parsed = data.map((e) => LocationSuggestion.fromJson(e)).where((e) => e.displayName.trim().isNotEmpty).toList();

        // Remove duplicates (case-insensitive)
        final seen = <String>{};
        final uniqueList = <LocationSuggestion>[];

        for (final item in parsed) {
          final key = item.displayName.toLowerCase();
          if (seen.add(key)) {
            uniqueList.add(item);
          }
        }

        // Assign to observable
        suggestions.value = uniqueList;
      } else {
        debugPrint("OSM error: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("fetchLocationSuggestions error: $e");
    }
  }

  void selectSuggestion(LocationSuggestion suggestion) {
    selectedLocation.value = LatLng(suggestion.lat, suggestion.lon);
    locationController.text = suggestion.displayName;
    getAddressFromLatLng(selectedLocation.value!); // Assuming this function exists
    mapController.move(selectedLocation.value!, 16);
    suggestions.clear(); // Hide suggestions immediately
  }

  Future<void> getCurrentLocation() async {
    isLoading.value = true;
    try {
      Position position = await Geolocator.getCurrentPosition(locationSettings: LocationSettings(accuracy: LocationAccuracy.high));

      currentLocation.value = LatLng(position.latitude, position.longitude);
      log("Current location: ${currentLocation.value}");

      // Move map after frame is rendered
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (selectedLocation.value != null) {
          mapController.move(selectedLocation.value!, 16);
        }
      });

      // Get proper address
      await getAddressFromLatLng(currentLocation.value!);
      log("current Address: ${address.value}");
    } catch (e) {
      log("Error getCurrentLocation: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> getAddressFromLatLng(LatLng latLng) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(latLng.latitude, latLng.longitude);

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        selectedPlaceAddress.value = place;
        address.value = "${place.street}, ${place.subLocality}, ${place.locality}, ${place.administrativeArea}, ${place.country}";
      }
      log('Address: ${address.value}');
    } catch (e) {
      log("Error getAddressFromLatLng: $e");
    }
  }

  void onMapMoved(LatLng center) {
    selectedLocation.value = center;
    getAddressFromLatLng(center); // Assuming this function exists
    // Clear search box and suggestions when map is manually moved
    suggestions.clear();
    locationController.text = '';
  }

  Future<void> confirmLocation() async {
    final LatLng? point = selectedLocation.value ?? currentLocation.value;
    if (point == null) {
      debugPrint("No location selected");
      Get.back(result: null);
      return;
    }

    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(point.latitude, point.longitude);

      if (placemarks.isNotEmpty) {
        final Placemark place = placemarks.first;
        selectedPlaceAddress.value = place;

        address.value = [place.street, place.subLocality, place.locality, place.administrativeArea, place.country].where((e) => e != null && e.isNotEmpty).join(', ');

        OsmSelectedLocationModel model = OsmSelectedLocationModel(address: place, latLng: point);

        log("Latitude: ${point.latitude}");
        log("Longitude: ${point.longitude}");
        log("Address: ${address.value}");
        log("Model: ${model.toJson()}");

        Get.back(result: model);
      } else {
        address.value = "Address not found";
        Get.back(result: null);
      }

      log('Address on confirm: ${address.value}');
    } catch (e) {
      debugPrint("Error confirming location: $e");
      address.value = "Unable to fetch address";
      Get.back(result: null);
    }
  }

  Future<void> fetchCoordinatesPoints(String location) async {
    final url = Uri.parse('https://nominatim.openstreetmap.org/search?q=$location&format=json&limit=1');

    try {
      final response = await http.get(url, headers: {'User-Agent': 'FlutterOSMApp/1.0 (myemail@example.com)'});

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data.isNotEmpty) {
          final lat = double.parse(data[0]['lat']);
          final lon = double.parse(data[0]['lon']);
          destination.value = LatLng(lat, lon);
          selectedLocation.value = destination.value;
          mapController.move(destination.value!, 16);

          // Draw route if current location exists
          if (currentLocation.value != null) getRoute(currentLocation.value!, destination.value!);
        } else {
          Get.snackbar("Not Found", "Location not found");
        }
      }
    } catch (e) {
      Get.snackbar("Error", "$e");
    }
  }

  Future<void> getRoute(LatLng start, LatLng end) async {
    final url = Uri.parse('http://router.project-osrm.org/route/v1/driving/${start.longitude},${start.latitude};${end.longitude},${end.latitude}?geometries=geojson');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final coords = data['routes'][0]['geometry']['coordinates'] as List;
        route.value = coords.map((c) => LatLng(c[1], c[0])).toList();
      }
    } catch (e) {
      debugPrint("Error fetching route: $e");
    }
  }

  void resetMap() async {
    // Clear search text
    locationController.clear();
    // suggestions.clear();
    selectedLocation.value = null;

    if (currentLocation.value != null) {
      selectedLocation.value = currentLocation.value;
      mapController.move(currentLocation.value!, 16);
      getAddressFromLatLng(currentLocation.value!);
    }
  }
}
