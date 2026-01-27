// ignore_for_file: unnecessary_overrides, deprecated_member_use
import 'dart:developer';

// ignore_for_file: depend_on_referenced_packages
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:driver/app/models/driver_user_model.dart';
import 'package:driver/app/models/intercity_model.dart';
import 'package:driver/constant/booking_status.dart';
import 'package:driver/constant/collection_name.dart';
import 'package:driver/constant/constant.dart';
import 'package:driver/theme/app_them_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_map/flutter_map.dart' as osm;
import 'package:latlong2/latlong.dart' as latlang;

class AskForOtpInterCityController extends GetxController {
  /// ================= GOOGLE MAP =================
  GoogleMapController? mapController;

  RxMap<MarkerId, Marker> markers = <MarkerId, Marker>{}.obs;
  RxMap<PolylineId, Polyline> polyLines = <PolylineId, Polyline>{}.obs;

  /// ================= OSM MAP =================
  osm.MapController osmMapController = osm.MapController();
  RxList<latlang.LatLng> osmRoute = <latlang.LatLng>[].obs;
  RxList<osm.Marker> osmMarkers = <osm.Marker>[].obs;

  /// ================= DATA =================
  Rx<DriverUserModel> driverUserModel = DriverUserModel().obs;
  Rx<IntercityModel> interCityModel = IntercityModel().obs;

  RxBool isLoading = true.obs;

  /// ================= ICONS =================
  BitmapDescriptor? departureIcon;
  BitmapDescriptor? destinationIcon;
  BitmapDescriptor? driverIcon;
  BitmapDescriptor? stopIcon;

  PolylinePoints polylinePoints = PolylinePoints(apiKey: Constant.mapAPIKey);

  @override
  void onInit() {
    super.onInit();
    addMarkerSetup();
    getArgument();
  }

  /// ================= GET ARGUMENT & LIVE STREAM =================
  Future<void> getArgument() async {
    dynamic argumentData = Get.arguments;
    if (argumentData == null) return;

    interCityModel.value = argumentData['intercity'];

    FirebaseFirestore.instance.collection(CollectionName.interCityRide).doc(interCityModel.value.id).snapshots().listen((event) {
      if (event.data() == null) return;

      interCityModel.value = IntercityModel.fromJson(event.data()!);

      FirebaseFirestore.instance.collection(CollectionName.drivers).doc(interCityModel.value.driverId).snapshots().listen((driverSnap) {
        if (driverSnap.data() == null) return;

        driverUserModel.value = DriverUserModel.fromJson(driverSnap.data()!);

        _handleLiveTracking();
      });

      if (interCityModel.value.bookingStatus == BookingStatus.bookingCompleted) {
        Get.back();
      }
    });

    isLoading.value = false;
  }

  /// ================= MAIN LIVE TRACK HANDLER =================
  void _handleLiveTracking() {
    final driverLat = driverUserModel.value.location?.latitude;
    final driverLng = driverUserModel.value.location?.longitude;

    final destLat =
        interCityModel.value.bookingStatus == BookingStatus.bookingOngoing ? interCityModel.value.dropLocation?.latitude : interCityModel.value.pickUpLocation?.latitude;

    final destLng =
        interCityModel.value.bookingStatus == BookingStatus.bookingOngoing ? interCityModel.value.dropLocation?.longitude : interCityModel.value.pickUpLocation?.longitude;

    if (driverLat == null || driverLng == null || destLat == null || destLng == null) return;

    if (Constant.selectedMap == "Google Map") {
      getGooglePolyline(
        sourceLat: driverLat,
        sourceLng: driverLng,
        destLat: destLat,
        destLng: destLng,
      );
    } else {
      getOsmPolyline(
        sourceLat: driverLat,
        sourceLng: driverLng,
        destLat: destLat,
        destLng: destLng,
      );
    }
  }

  /// ================= GOOGLE MAP POLYLINE =================
  Future<void> getGooglePolyline({
    required double sourceLat,
    required double sourceLng,
    required double destLat,
    required double destLng,
  }) async {
    List<LatLng> polylineCoordinates = [];

    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      request: PolylineRequest(
        origin: PointLatLng(sourceLat, sourceLng),
        destination: PointLatLng(destLat, destLng),
        mode: TravelMode.driving,
      ),
    );

    if (result.points.isEmpty) {
      log(result.errorMessage.toString());
      return;
    }

    for (var p in result.points) {
      polylineCoordinates.add(LatLng(p.latitude, p.longitude));
    }

    markers.clear();

    addGoogleMarker(
      id: "pickup",
      lat: interCityModel.value.pickUpLocation!.latitude!,
      lng: interCityModel.value.pickUpLocation!.longitude!,
      icon: departureIcon!,
    );

    addGoogleMarker(
      id: "drop",
      lat: interCityModel.value.dropLocation!.latitude!,
      lng: interCityModel.value.dropLocation!.longitude!,
      icon: destinationIcon!,
    );

    addGoogleMarker(
      id: "driver",
      lat: sourceLat,
      lng: sourceLng,
      icon: driverIcon!,
      rotation: driverUserModel.value.rotation ?? 0,
    );

    _addGooglePolyline(polylineCoordinates);
  }

  void addGoogleMarker({
    required String id,
    required double lat,
    required double lng,
    required BitmapDescriptor icon,
    double rotation = 0,
  }) {
    markers[MarkerId(id)] = Marker(
      markerId: MarkerId(id),
      position: LatLng(lat, lng),
      icon: icon,
      rotation: rotation,
      anchor: const Offset(0.5, 0.5),
    );
  }

  void _addGooglePolyline(List<LatLng> points) {
    polyLines.clear();

    polyLines[const PolylineId("route")] = Polyline(
      polylineId: const PolylineId("route"),
      points: points,
      color: AppThemData.primary500,
      width: 6,
    );

    updateCameraLocation(points.first, points.last);
  }

  Future<void> updateCameraLocation(LatLng source, LatLng destination) async {
    if (mapController == null) return;

    LatLngBounds bounds = LatLngBounds(
      southwest: LatLng(
        source.latitude < destination.latitude ? source.latitude : destination.latitude,
        source.longitude < destination.longitude ? source.longitude : destination.longitude,
      ),
      northeast: LatLng(
        source.latitude > destination.latitude ? source.latitude : destination.latitude,
        source.longitude > destination.longitude ? source.longitude : destination.longitude,
      ),
    );

    mapController!.animateCamera(CameraUpdate.newLatLngBounds(bounds, 50));
  }

  /// ================= OSM POLYLINE + LIVE MARKER =================
  Future<void> getOsmPolyline({
    required double sourceLat,
    required double sourceLng,
    required double destLat,
    required double destLng,
  }) async {
    osmRoute.clear();
    osmMarkers.clear();

    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      request: PolylineRequest(
        origin: PointLatLng(sourceLat, sourceLng),
        destination: PointLatLng(destLat, destLng),
        mode: TravelMode.driving,
      ),
    );

    if (result.points.isEmpty) return;

    for (var p in result.points) {
      osmRoute.add(latlang.LatLng(p.latitude, p.longitude));
    }

    /// Pickup
    osmMarkers.add(_osmMarker(
      lat: interCityModel.value.pickUpLocation!.latitude!,
      lng: interCityModel.value.pickUpLocation!.longitude!,
      asset: 'assets/icon/ic_pick_up_map.png',
    ));

    /// Drop
    osmMarkers.add(_osmMarker(
      lat: interCityModel.value.dropLocation!.latitude!,
      lng: interCityModel.value.dropLocation!.longitude!,
      asset: 'assets/icon/ic_drop_in_map.png',
    ));

    /// Driver (LIVE)
    osmMarkers.add(
      osm.Marker(
        width: 40,
        height: 40,
        rotate: true,
        point: latlang.LatLng(sourceLat, sourceLng),
        child: Transform.rotate(
          angle: (driverUserModel.value.rotation ?? 0) * 0.0174533,
          child: Image.asset('assets/icon/ic_car.png'),
        ),
      ),
    );

    fitOsmBounds();
  }

  osm.Marker _osmMarker({
    required double lat,
    required double lng,
    required String asset,
  }) {
    return osm.Marker(
      width: 40,
      height: 40,
      point: latlang.LatLng(lat, lng),
      child: Image.asset(asset),
    );
  }

  void fitOsmBounds() {
    if (osmRoute.isEmpty) return;

    final bounds = osm.LatLngBounds.fromPoints(osmRoute);
    osmMapController.fitCamera(
      osm.CameraFit.bounds(
        bounds: bounds,
        padding: const EdgeInsets.all(40),
      ),
    );
  }

  /// ================= LOAD ICONS =================
  Future<void> addMarkerSetup() async {
    departureIcon = BitmapDescriptor.fromBytes(await Constant().getBytesFromAsset('assets/icon/ic_pick_up_map.png', 100));

    destinationIcon = BitmapDescriptor.fromBytes(await Constant().getBytesFromAsset('assets/icon/ic_drop_in_map.png', 100));

    driverIcon = BitmapDescriptor.fromBytes(await Constant().getBytesFromAsset('assets/icon/ic_car.png', 60));

    stopIcon = BitmapDescriptor.fromBytes(await Constant().getBytesFromAsset('assets/icon/ic_stop_icon_map.png', 80));
  }
// @override
// void onInit() {
//   addMarkerSetup();
//   getArgument();
//   // playSound();
//   super.onInit();
// }
//
// Rx<DriverUserModel> driverUserModel = DriverUserModel().obs;
// Rx<IntercityModel> interCityModel = IntercityModel().obs;
//
// RxBool isLoading = true.obs;
// RxString type = "".obs;
//
// Future<void> getArgument() async {
//   dynamic argumentData = Get.arguments;
//   if (argumentData != null) {
//     interCityModel.value = argumentData['intercity'];
//
//     FirebaseFirestore.instance.collection(CollectionName.interCityRide).doc(interCityModel.value.id).snapshots().listen((event) {
//       if (event.data() != null) {
//         IntercityModel orderModelStream = IntercityModel.fromJson(event.data()!);
//         interCityModel.value = orderModelStream;
//         FirebaseFirestore.instance.collection(CollectionName.drivers).doc(interCityModel.value.driverId).snapshots().listen((event) {
//           if (event.data() != null) {
//             driverUserModel.value = DriverUserModel.fromJson(event.data()!);
//             if (interCityModel.value.bookingStatus == BookingStatus.bookingOngoing) {
//               getPolyline(
//                   sourceLatitude: driverUserModel.value.location!.latitude,
//                   sourceLongitude: driverUserModel.value.location!.longitude,
//                   destinationLatitude: interCityModel.value.dropLocation!.latitude,
//                   destinationLongitude: interCityModel.value.dropLocation!.longitude);
//             } else {
//               getPolyline(
//                   sourceLatitude: driverUserModel.value.location!.latitude,
//                   sourceLongitude: driverUserModel.value.location!.longitude,
//                   destinationLatitude: interCityModel.value.pickUpLocation!.latitude,
//                   destinationLongitude: interCityModel.value.pickUpLocation!.longitude);
//             }
//           }
//         });
//
//         if (interCityModel.value.bookingStatus == BookingStatus.bookingCompleted) {
//           Get.back();
//         }
//       }
//     });
//   }
//   isLoading.value = false;
//   update();
// }
//
// BitmapDescriptor? departureIcon;
// BitmapDescriptor? destinationIcon;
// BitmapDescriptor? driverIcon;
// BitmapDescriptor? stopIcon;
//
// void getPolyline({required double? sourceLatitude, required double? sourceLongitude, required double? destinationLatitude, required double? destinationLongitude}) async {
//   if (sourceLatitude != null && sourceLongitude != null && destinationLatitude != null && destinationLongitude != null) {
//     List<LatLng> polylineCoordinates = [];
//
//     // List<PolylineWayPoint> wayPoints = [];
//     // if (interCityModel.value.stops != null && interCityModel.value.stops!.isNotEmpty) {
//     //   wayPoints = interCityModel.value.stops!
//     //       .map((stop) => PolylineWayPoint(
//     //             location: "${stop.location!.latitude},${stop.location!.longitude}",
//     //           ))
//     //       .toList();
//     // }
//     PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
//       request: PolylineRequest(
//           origin: PointLatLng(sourceLatitude, sourceLongitude),
//           destination: PointLatLng(destinationLatitude, destinationLongitude),
//           mode: TravelMode.driving,
//           optimizeWaypoints: true),
//     );
//     if (result.points.isNotEmpty) {
//       for (var point in result.points) {
//         polylineCoordinates.add(LatLng(point.latitude, point.longitude));
//       }
//     } else {
//       log(result.errorMessage.toString());
//     }
//
//     addMarker(
//         latitude: interCityModel.value.pickUpLocation!.latitude,
//         longitude: interCityModel.value.pickUpLocation!.longitude,
//         id: "Departure",
//         descriptor: departureIcon!,
//         rotation: 0.0);
//     addMarker(
//         latitude: interCityModel.value.dropLocation!.latitude,
//         longitude: interCityModel.value.dropLocation!.longitude,
//         id: "Destination",
//         descriptor: destinationIcon!,
//         rotation: 0.0);
//     addMarker(
//         latitude: driverUserModel.value.location!.latitude,
//         longitude: driverUserModel.value.location!.longitude,
//         id: "Driver",
//         descriptor: driverIcon!,
//         rotation: driverUserModel.value.rotation);
//
//     if (interCityModel.value.stops != null && interCityModel.value.stops!.isNotEmpty) {
//       for (int i = 0; i < interCityModel.value.stops!.length; i++) {
//         var stop = interCityModel.value.stops![i];
//         addMarker(
//           latitude: stop.location!.latitude,
//           longitude: stop.location!.longitude,
//           id: "Stop_$i",
//           descriptor: stopIcon!,
//           // You can create a custom stopIcon
//           rotation: 0.0,
//         );
//       }
//     }
//     _addPolyLine(polylineCoordinates);
//   }
// }
//
// RxMap<MarkerId, Marker> markers = <MarkerId, Marker>{}.obs;
//
// void addMarker({required double? latitude, required double? longitude, required String id, required BitmapDescriptor descriptor, required double? rotation}) {
//   MarkerId markerId = MarkerId(id);
//   Marker marker = Marker(markerId: markerId, icon: descriptor, position: LatLng(latitude ?? 0.0, longitude ?? 0.0), rotation: rotation ?? 0.0);
//   markers[markerId] = marker;
// }
//
// Future<void> addMarkerSetup() async {
//   final Uint8List departure = await Constant().getBytesFromAsset('assets/icon/ic_pick_up_map.png', 100);
//   final Uint8List destination = await Constant().getBytesFromAsset('assets/icon/ic_drop_in_map.png', 100);
//   final Uint8List driver = await Constant().getBytesFromAsset('assets/icon/ic_car.png', 50);
//   final Uint8List stops = await Constant().getBytesFromAsset('assets/icon/ic_stop_icon_map.png', 100);
//
//   departureIcon = BitmapDescriptor.fromBytes(departure);
//   destinationIcon = BitmapDescriptor.fromBytes(destination);
//   driverIcon = BitmapDescriptor.fromBytes(driver);
//   stopIcon = BitmapDescriptor.fromBytes(stops);
// }
//
// RxMap<PolylineId, Polyline> polyLines = <PolylineId, Polyline>{}.obs;
// PolylinePoints polylinePoints = PolylinePoints(apiKey: Constant.mapAPIKey);
//
// void _addPolyLine(List<LatLng> polylineCoordinates) {
//   PolylineId id = const PolylineId("poly");
//   Polyline polyline = Polyline(polylineId: id, points: polylineCoordinates, consumeTapEvents: true, startCap: Cap.roundCap, width: 6, color: AppThemData.primary500);
//   polyLines[id] = polyline;
//   updateCameraLocation(polylineCoordinates.first, polylineCoordinates.last, mapController);
// }
//
// Future<void> updateCameraLocation(
//   LatLng source,
//   LatLng destination,
//   GoogleMapController? mapController,
// ) async {
//   if (mapController == null) return;
//
//   LatLngBounds bounds;
//
//   if (source.latitude > destination.latitude && source.longitude > destination.longitude) {
//     bounds = LatLngBounds(southwest: destination, northeast: source);
//   } else if (source.longitude > destination.longitude) {
//     bounds = LatLngBounds(southwest: LatLng(source.latitude, destination.longitude), northeast: LatLng(destination.latitude, source.longitude));
//   } else if (source.latitude > destination.latitude) {
//     bounds = LatLngBounds(southwest: LatLng(destination.latitude, source.longitude), northeast: LatLng(source.latitude, destination.longitude));
//   } else {
//     bounds = LatLngBounds(southwest: source, northeast: destination);
//   }
//
//   CameraUpdate cameraUpdate = CameraUpdate.newLatLngBounds(bounds, 10);
//
//   return checkCameraLocation(cameraUpdate, mapController);
// }
//
// Future<void> checkCameraLocation(CameraUpdate cameraUpdate, GoogleMapController mapController) async {
//   mapController.animateCamera(cameraUpdate);
//   LatLngBounds l1 = await mapController.getVisibleRegion();
//   LatLngBounds l2 = await mapController.getVisibleRegion();
//
//   if (l1.southwest.latitude == -90 || l2.southwest.latitude == -90) {
//     return checkCameraLocation(cameraUpdate, mapController);
//   }
// }
}
