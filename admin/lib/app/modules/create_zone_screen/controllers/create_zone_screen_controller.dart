// ignore_for_file: depend_on_referenced_packages, body_might_complete_normally_catch_error, use_build_context_synchronously, avoid_web_libraries_in_flutter, unused_local_variable, invalid_use_of_protected_member
import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:js' as js;
import 'dart:html' as html;
import 'package:admin/app/constant/collection_name.dart';
import 'package:admin/app/constant/show_toast.dart';
import 'package:admin/app/models/zone_model.dart';
import 'package:admin/app/utils/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_map/flutter_map.dart' as osm;
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart' as osmLatLng;
import '../../../constant/constants.dart';
import '../../../utils/fire_store_utils.dart';

class CreateZoneScreenController extends GetxController {
  RxString title = 'Draw Business Zone'.tr.obs;
  RxBool isLoading = false.obs;
  RxBool isActive = false.obs;
  RxString editingId = "".obs;
  Rx<TextEditingController> zoneController = TextEditingController().obs;
  Rx<TextEditingController> placeController = TextEditingController().obs;
  GoogleMapController? googleMapController;

  Rx<ZoneModel> zoneModel = ZoneModel().obs;
  RxList<LatLng> polygonCoords = <LatLng>[].obs;

  late final osm.MapController osmMapController = osm.MapController();
  RxList<osmLatLng.LatLng> osmPolygonCoords = <osmLatLng.LatLng>[].obs;
  RxBool isOsmMapReady = false.obs;
  RxBool isPolygonLoaded = false.obs;

  RxSet<Polygon> polygons = <Polygon>{}.obs;
  RxSet<Marker> markers = <Marker>{}.obs;

  var selectedLocation = Rxn<LatLng>();
  var predictions = <Map<String, dynamic>>[].obs;
  var address = "Move the map to select a location".obs;

  TextEditingController searchController = TextEditingController();

  osmLatLng.LatLng toOsm(LatLng g) => osmLatLng.LatLng(g.latitude, g.longitude);

  @override
  Future<void> onInit() async {
    resetSearchState();
    getLocation();
    getArgument();
    if (Constant.selectedMap == "OSM Map") {
      everAll([isOsmMapReady, isPolygonLoaded], (_) {
        if (isOsmMapReady.value && isPolygonLoaded.value) {
          Future.delayed(const Duration(milliseconds: 300), () {
            moveCameraToPolygonOSM();
          });
        }
      });
    }
    super.onInit();
  }

  Future<void> getLocation() async {
    Constant.currentPosition = await Utils.getCurrentLocation();
  }

  Future<void> getArgument() async {
    isLoading.value = true;
    try {
      String? zoneId = Get.parameters['zoneId'];

      if (zoneId == null || zoneId.isEmpty) {
        // Add mode
        setDefaultData();
        isLoading.value = false;
        return;
      }

      // Edit mode
      final value = await FireStoreUtils.getZoneByZoneId(zoneId);
      if (value != null) {
        zoneModel.value = value;
        editingId.value = zoneModel.value.id!;
        zoneController.value.text = zoneModel.value.name!;
        isActive.value = zoneModel.value.status!;

        if (zoneModel.value.area != null) {
          polygonCoords.clear();
          osmPolygonCoords.clear();

          for (var geo in zoneModel.value.area!) {
            if (geo is GeoPoint) {
              polygonCoords.add(LatLng(geo.latitude, geo.longitude));
              osmPolygonCoords.add(toOsm(LatLng(geo.latitude, geo.longitude)));
            }
          }

          if (polygonCoords.isNotEmpty) {
            polygons.value = {
              Polygon(
                polygonId: const PolygonId("zone"),
                points: polygonCoords,
                strokeColor: Colors.black,
                fillColor: Colors.black.withOpacity(0.2),
                strokeWidth: 3,
              )
            };
            isPolygonLoaded.value = true; // 🔥 IMPORTANT
          }
        }
      }
      isLoading.value = false;
    } catch (e) {
      isLoading.value = false;
      developer.log("Error in getArgument: $e");
    }
  }

  void addPolygon(LatLng position) {
    polygonCoords.add(position);
    osmPolygonCoords.add(toOsm(position));

    polygons.clear();
    final polygon =
        Polygon(polygonId: const PolygonId("zone"), points: polygonCoords, strokeColor: Colors.black, fillColor: Colors.black.withOpacity(0.2), strokeWidth: 3, geodesic: true);
    polygons.value = {polygon};
    markers.clear();
    for (int i = 0; i < polygonCoords.length; i++) {
      markers.add(
        Marker(
          markerId: MarkerId("point_$i"),
          position: polygonCoords[i],
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow),
        ),
      );
    }
  }

  void addPolygonOSM(osmLatLng.LatLng point) {
    addPolygon(
      LatLng(point.latitude, point.longitude),
    );
  }

  Future<void> addZone() async {
    if (polygonCoords.length < 3) {
      ShowToastDialog.errorToast("Please draw a polygon with at least 3 points.".tr);
      return;
    }

    Constant.waitingLoader();
    zoneModel.value.status = isActive.value;
    zoneModel.value.name = zoneController.value.text;
    zoneModel.value.area = polygonCoords.map((latLng) => GeoPoint(latLng.latitude, latLng.longitude)).toList();
    zoneModel.value.createdAt = Timestamp.now();

    try {
      if (editingId.value.isNotEmpty) {
        // ----- Update existing zone -----
        zoneModel.value.id = editingId.value;
        bool updated = await FireStoreUtils.updateZone(zoneModel.value);
        if (updated) {
          ShowToastDialog.successToast("Zone Updated Successfully".tr);
        } else {
          ShowToastDialog.errorToast("Something went wrong, Please try later!".tr);
        }
      } else {
        // ----- Create new zone -----
        zoneModel.value.id = Constant.getRandomString(20);
        bool isSaved = await FireStoreUtils.addZones(zoneModel.value);
        if (isSaved) {
          Map<String, dynamic> defaultCharges = {
            "fareMinimumCharges": "0",
            "fareMinimumChargesWithinKm": "0",
            "farePerKm": "0",
            "holdCharge": "0",
            "incrementOfNightCharge": "0",
            "minuteCharge": "0",
            "farMinimumCharges": "0",
          };

          Map<String, dynamic> newZoneCharge = {
            "zoneId": zoneModel.value.id,
            "zoneName": zoneModel.value.name,
            "charges": defaultCharges,
          };

          // --- Update all vehicleType docs ---
          final vehicleTypes = await FirebaseFirestore.instance.collection(CollectionName.vehicleType).get();
          for (var doc in vehicleTypes.docs) {
            List<dynamic> existing = doc.data()['zoneCharges'] ?? [];
            bool alreadyExists = existing.any((zc) => zc['zoneId'] == zoneModel.value.id);
            if (!alreadyExists) {
              existing.add(newZoneCharge);
              await doc.reference.update({"zoneCharges": existing});
            }
          }

          // --- Update all intercity_service docs ---
          final interCityTypes = await FirebaseFirestore.instance.collection("intercity_service").get();
          for (var doc in interCityTypes.docs) {
            List<dynamic> existing = doc.data()['zoneCharges'] ?? [];
            bool alreadyExists = existing.any((zc) => zc['zoneId'] == zoneModel.value.id);
            if (!alreadyExists) {
              existing.add(newZoneCharge);
              await doc.reference.update({"zoneCharges": existing});
            }
          }

          ShowToastDialog.successToast("Zone Created Successfully".tr);
        } else {
          ShowToastDialog.errorToast("Something went wrong, Please try later!".tr);
        }
      }

      Get.back();
      Get.back(result: true);
      setDefaultData();
    } catch (e) {
      ShowToastDialog.errorToast("Error while saving zone: $e");
    }

    isLoading.value = false;
  }

  void clearPolygon() {
    polygonCoords.clear();
    osmPolygonCoords.clear();
    polygons.clear();
    markers.clear();
  }

  void moveCameraToPolygon() {
    if (polygonCoords.isEmpty || googleMapController == null) return;
    LatLngBounds bounds = _getBounds(polygonCoords);

    googleMapController!.animateCamera(
      CameraUpdate.newLatLngBounds(bounds, 50), // 50 is padding
    );
  }

  LatLngBounds _getBounds(List<LatLng> points) {
    double south = points.first.latitude;
    double north = points.first.latitude;
    double west = points.first.longitude;
    double east = points.first.longitude;

    for (LatLng point in points) {
      if (point.latitude < south) south = point.latitude;
      if (point.latitude > north) north = point.latitude;
      if (point.longitude < west) west = point.longitude;
      if (point.longitude > east) east = point.longitude;
    }

    return LatLngBounds(
      southwest: LatLng(south, west),
      northeast: LatLng(north, east),
    );
  }

  void moveCameraToPolygonOSM() {
    if (osmPolygonCoords.isEmpty) return;

    final center = _getOsmCenter(osmPolygonCoords);
    osmMapController.move(center, 15);
  }

  osmLatLng.LatLng _getOsmCenter(List<osmLatLng.LatLng> pts) {
    double lat = 0, lng = 0;
    for (final p in pts) {
      lat += p.latitude;
      lng += p.longitude;
    }
    return osmLatLng.LatLng(lat / pts.length, lng / pts.length);
  }

  void setDefaultData() {
    placeController.value.text = "";
    zoneController.value.text = "";
    isActive.value = true;
    polygonCoords.clear();
    polygons.clear();
    markers.clear();
    searchController.text = "";
    predictions.clear();
    selectedLocation.value = null;
  }

  void fetchPredictions(String input) {
    if (!kIsWeb || input.isEmpty) {
      predictions.clear();
      return;
    }

    final service = js.JsObject(
      js.context['google']['maps']['places']['AutocompleteService'],
    );

    service.callMethod('getPlacePredictions', [
      js.JsObject.jsify({
        'input': input,
        'types': ['(cities)'], // 🔴 only cities
      }),
      (result, status) {
        if (result != null) {
          final list = <Map<String, dynamic>>[];
          for (var item in result) {
            list.add({
              'description': item['description'],
              'place_id': item['place_id'],
            });
          }
          predictions.value = list;
        } else {
          predictions.clear();
        }
      }
    ]);
  }

  void selectPrediction(Map<String, dynamic> prediction) {
    final placeId = prediction['place_id'];
    final description = prediction['description'];

    final mapDiv = html.DivElement();
    final service = js.JsObject(js.context['google']['maps']['places']['PlacesService'], [mapDiv]);
    service.callMethod('getDetails', [
      js.JsObject.jsify({'placeId': placeId}),
      (placeResult, status) {
        if (placeResult != null) {
          final lat = placeResult['geometry']['location'].callMethod('lat');
          final lng = placeResult['geometry']['location'].callMethod('lng');
          selectedLocation.value = LatLng(lat, lng);
          searchController.text = description;
          moveCameraTo(LatLng(lat, lng));
          predictions.clear(); // hide dropdown
        }
      }
    ]);
  }

  void moveCameraTo(LatLng target) {
    selectedLocation.value = target;
    if (Constant.selectedMap == "Google Map") {
      googleMapController?.animateCamera(
        CameraUpdate.newLatLngZoom(target, 15),
      );
    } else {
      osmMapController!.move(toOsm(target), 15);
    }
    getAddressFromLatLng(target);
  }

  void resetSearchState() {
    searchController.clear();
    predictions.clear();
    selectedLocation.value = const LatLng(0, 0);
  }

  Future<void> getAddressFromLatLng(LatLng latLng) async {
    try {
      if (Constant.selectedMap == "Google Map" && kIsWeb) {
        /// GOOGLE (PAID)
        final url = Uri.parse(
          "https://maps.googleapis.com/maps/api/geocode/json"
          "?latlng=${latLng.latitude},${latLng.longitude}"
          "&key=${Constant.googleMapKey}",
        );

        final res = await http.get(url);
        final data = json.decode(res.body);

        address.value = data['results']?[0]?['formatted_address'] ?? "Address not found";
      } else {
        /// OSM – NOMINATIM (FREE)
        final url = Uri.parse(
          "https://nominatim.openstreetmap.org/reverse"
          "?format=json"
          "&lat=${latLng.latitude}"
          "&lon=${latLng.longitude}",
        );

        final res = await http.get(
          url,
          headers: {'User-Agent': 'admin-panel'},
        );

        final data = json.decode(res.body);
        address.value = data['display_name'] ?? "Address not found";
      }
    } catch (e) {
      address.value = "Unable to fetch address";
    }
  }

  @override
  void onClose() {
    setDefaultData();
    super.onClose();
  }
}
