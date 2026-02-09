// ignore_for_file: unnecessary_overrides, deprecated_member_use
import 'dart:async';
import 'dart:math';

// ignore_for_file: depend_on_referenced_packages
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:driver/app/models/booking_model.dart';
import 'package:driver/app/models/driver_user_model.dart';
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

class AskForOtpController extends GetxController {
  /// ================= GOOGLE MAP =================
  GoogleMapController? mapController;
  RxMap<MarkerId, Marker> markers = <MarkerId, Marker>{}.obs;
  RxMap<PolylineId, Polyline> polyLines = <PolylineId, Polyline>{}.obs;
  PolylinePoints polylinePoints = PolylinePoints(apiKey: Constant.mapAPIKey);

  BitmapDescriptor? departureIcon;
  BitmapDescriptor? destinationIcon;
  BitmapDescriptor? driverIcon;
  BitmapDescriptor? stopIcon;

  /// ================= OSM MAP =================
  osm.MapController osmMapController = osm.MapController();
  RxList<latlang.LatLng> osmRoute = <latlang.LatLng>[].obs;
  RxList<osm.Marker> osmMarkers = <osm.Marker>[].obs;

  /// ================= DATA =================
  Rx<DriverUserModel> driverUserModel = DriverUserModel().obs;
  Rx<BookingModel> bookingModel = BookingModel().obs;
  RxBool isLoading = true.obs;

  StreamSubscription<DocumentSnapshot>? _bookingSub;
  StreamSubscription<DocumentSnapshot>? _driverSub;
  String? _listeningDriverId;

  @override
  void onInit() {
    addMarkerSetup();
    getArgument();
    super.onInit();
  }

  /// ================= GET ARGUMENT + LIVE LISTENER =================
  Future<void> getArgument() async {
    dynamic argumentData = Get.arguments;
    if (argumentData == null || argumentData is! Map || argumentData['bookingModel'] == null) {
      isLoading.value = false;
      Get.back();
      return;
    }

    bookingModel.value = argumentData['bookingModel'];

    _bookingSub?.cancel();
    _bookingSub = FirebaseFirestore.instance.collection(CollectionName.bookings).doc(bookingModel.value.id).snapshots().listen((bookingSnap) {
      if (bookingSnap.data() == null) return;

      bookingModel.value = BookingModel.fromJson(bookingSnap.data()!);

      final driverId = bookingModel.value.driverId;
      if (driverId != null && driverId.isNotEmpty) {
        if (_listeningDriverId != driverId || _driverSub == null) {
          _listeningDriverId = driverId;
          _driverSub?.cancel();
          _driverSub = FirebaseFirestore.instance.collection(CollectionName.drivers).doc(driverId).snapshots().listen((driverSnap) {
            if (driverSnap.data() == null) return;

            driverUserModel.value = DriverUserModel.fromJson(driverSnap.data()!);
            _updateTracking();
          });
        }
      }

      if (bookingModel.value.bookingStatus == BookingStatus.bookingCompleted) {
        Get.back();
      }
    });

    isLoading.value = false;
  }

  /// ================= MAIN TRACKING HANDLER =================
  void _updateTracking() {
    final driverLat = driverUserModel.value.location?.latitude;
    final driverLng = driverUserModel.value.location?.longitude;
    final pickupLat = bookingModel.value.pickUpLocation?.latitude;
    final pickupLng = bookingModel.value.pickUpLocation?.longitude;
    final dropLat = bookingModel.value.dropLocation?.latitude;
    final dropLng = bookingModel.value.dropLocation?.longitude;

    if (driverLat == null || driverLng == null || pickupLat == null || pickupLng == null || dropLat == null || dropLng == null) return;

    final bool isOngoing = bookingModel.value.bookingStatus == BookingStatus.bookingOngoing;

    /// ================= GOOGLE MAP =================
    if (Constant.selectedMap == "Google Map") {
      getPolyline(
        sourceLatitude: driverLat,
        sourceLongitude: driverLng,
        destinationLatitude: isOngoing ? dropLat : pickupLat,
        destinationLongitude: isOngoing ? dropLng : pickupLng,
      );
    }

    /// ================= OSM MAP =================
    else {
      _updateOsmTracking(
        driver: latlang.LatLng(driverLat, driverLng),
        pickup: latlang.LatLng(pickupLat, pickupLng),
        drop: latlang.LatLng(dropLat, dropLng),
        destination: isOngoing ? latlang.LatLng(dropLat, dropLng) : latlang.LatLng(pickupLat, pickupLng),
      );
    }
  }

  /// ================= GOOGLE POLYLINE =================
  Future<void> getPolyline({
    required double sourceLatitude,
    required double sourceLongitude,
    required double destinationLatitude,
    required double destinationLongitude,
  }) async {
    markers.clear();
    polyLines.clear();

    List<LatLng> polylineCoordinates = [];

    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      request: PolylineRequest(
        origin: PointLatLng(sourceLatitude, sourceLongitude),
        destination: PointLatLng(destinationLatitude, destinationLongitude),
        mode: TravelMode.driving,
      ),
    );

    for (var p in result.points) {
      polylineCoordinates.add(LatLng(p.latitude, p.longitude));
    }

    addMarker(
        latitude: bookingModel.value.pickUpLocation!.latitude!, longitude: bookingModel.value.pickUpLocation!.longitude!, id: "pickup", descriptor: departureIcon!, rotation: 0);

    addMarker(latitude: bookingModel.value.dropLocation!.latitude!, longitude: bookingModel.value.dropLocation!.longitude!, id: "drop", descriptor: destinationIcon!, rotation: 0);

    addMarker(
        latitude: driverUserModel.value.location!.latitude!,
        longitude: driverUserModel.value.location!.longitude!,
        id: "driver",
        descriptor: driverIcon!,
        rotation: driverUserModel.value.rotation);

    _addPolyLine(polylineCoordinates);
  }

  void addMarker({
    required double latitude,
    required double longitude,
    required String id,
    required BitmapDescriptor descriptor,
    required double rotation,
  }) {
    markers[MarkerId(id)] = Marker(
      markerId: MarkerId(id),
      position: LatLng(latitude, longitude),
      icon: descriptor,
      rotation: rotation,
      anchor: const Offset(0.5, 0.5),
    );
  }

  /// ================= OSM TRACKING =================
  void _updateOsmTracking({
    required latlang.LatLng driver,
    required latlang.LatLng pickup,
    required latlang.LatLng drop,
    required latlang.LatLng destination,
  }) {
    osmMarkers.clear();
    osmRoute.clear();

    osmMarkers.addAll([
      _osmMarker("driver", driver, Icons.directions_car, Colors.black),
      _osmMarker("pickup", pickup, Icons.location_pin, Colors.green),
      _osmMarker("drop", drop, Icons.location_pin, Colors.red),
    ]);

    osmRoute.addAll([driver, destination]);

    osmMapController.move(driver, osmMapController.camera.zoom);
  }

  osm.Marker _osmMarker(
    String id,
    latlang.LatLng point,
    IconData icon,
    Color color,
  ) {
    return osm.Marker(
      key: Key(id),
      point: point,
      width: 40,
      height: 40,
      child: Icon(icon, color: color, size: 36),
    );
  }

  /// ================= MARKER ICON SETUP =================
  Future<void> addMarkerSetup() async {
    departureIcon = BitmapDescriptor.fromBytes(await Constant().getBytesFromAsset('assets/icon/ic_pick_up_map.png', 100));
    destinationIcon = BitmapDescriptor.fromBytes(await Constant().getBytesFromAsset('assets/icon/ic_drop_in_map.png', 100));
    driverIcon = BitmapDescriptor.fromBytes(await Constant().getBytesFromAsset('assets/icon/ic_car.png', 60));
    stopIcon = BitmapDescriptor.fromBytes(await Constant().getBytesFromAsset('assets/icon/ic_stop_icon_map.png', 80));
  }

  void _addPolyLine(List<LatLng> points) {
    polyLines[const PolylineId("route")] = Polyline(
      polylineId: const PolylineId("route"),
      points: points,
      width: 6,
      color: AppThemData.primary500,
    );

    updateCameraLocation(points.first, points.last, mapController);
  }

  Future<void> updateCameraLocation(LatLng source, LatLng destination, GoogleMapController? controller) async {
    if (controller == null) return;

    final bounds = LatLngBounds(
      southwest: LatLng(
        min(source.latitude, destination.latitude),
        min(source.longitude, destination.longitude),
      ),
      northeast: LatLng(
        max(source.latitude, destination.latitude),
        max(source.longitude, destination.longitude),
      ),
    );

    controller.animateCamera(CameraUpdate.newLatLngBounds(bounds, 50));
  }

// @override
// void onInit() {
//   addMarkerSetup();
//   getArgument();
//   super.onInit();
// }

//
// Rx<DriverUserModel> driverUserModel = DriverUserModel().obs;
// Rx<BookingModel> bookingModel = BookingModel().obs;
//
// RxBool isLoading = true.obs;
// RxString type = "".obs;
//
// Future<void> getArgument() async {
//   dynamic argumentData = Get.arguments;
//   if (argumentData != null) {
//     bookingModel.value = argumentData['bookingModel'];
//
//     FirebaseFirestore.instance.collection(CollectionName.bookings).doc(bookingModel.value.id).snapshots().listen((event) {
//       if (event.data() != null) {
//         BookingModel orderModelStream = BookingModel.fromJson(event.data()!);
//         bookingModel.value = orderModelStream;
//         FirebaseFirestore.instance.collection(CollectionName.drivers).doc(bookingModel.value.driverId).snapshots().listen((event) {
//           if (event.data() != null) {
//             driverUserModel.value = DriverUserModel.fromJson(event.data()!);
//             if (bookingModel.value.bookingStatus == BookingStatus.bookingOngoing) {
//               getPolyline(
//                   sourceLatitude: driverUserModel.value.location!.latitude,
//                   sourceLongitude: driverUserModel.value.location!.longitude,
//                   destinationLatitude: bookingModel.value.dropLocation!.latitude,
//                   destinationLongitude: bookingModel.value.dropLocation!.longitude);
//             } else {
//               getPolyline(
//                   sourceLatitude: driverUserModel.value.location!.latitude,
//                   sourceLongitude: driverUserModel.value.location!.longitude,
//                   destinationLatitude: bookingModel.value.pickUpLocation!.latitude,
//                   destinationLongitude: bookingModel.value.pickUpLocation!.longitude);
//             }
//           }
//         });
//
//         if (bookingModel.value.bookingStatus == BookingStatus.bookingCompleted) {
//           Get.back();
//         }
//       }
//     });
//   }
//   isLoading.value = false;
//   update();
// }
//
// void getPolyline({required double? sourceLatitude, required double? sourceLongitude, required double? destinationLatitude, required double? destinationLongitude}) async {
//   if (sourceLatitude != null && sourceLongitude != null && destinationLatitude != null && destinationLongitude != null) {
//     List<LatLng> polylineCoordinates = [];
//     PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
//       request: PolylineRequest(
//           origin: PointLatLng(sourceLatitude, sourceLongitude),
//           destination: PointLatLng(destinationLatitude, destinationLongitude),
//           mode: TravelMode.driving,
//           // wayPoints: wayPoints,
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
//         latitude: bookingModel.value.pickUpLocation!.latitude,
//         longitude: bookingModel.value.pickUpLocation!.longitude,
//         id: "Departure",
//         descriptor: departureIcon!,
//         rotation: 0.0);
//     addMarker(
//         latitude: bookingModel.value.dropLocation!.latitude,
//         longitude: bookingModel.value.dropLocation!.longitude,
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
//     if (bookingModel.value.stops != null && bookingModel.value.stops!.isNotEmpty) {
//       for (int i = 0; i < bookingModel.value.stops!.length; i++) {
//         var stop = bookingModel.value.stops![i];
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
//   departureIcon = BitmapDescriptor.fromBytes(departure);
//   destinationIcon = BitmapDescriptor.fromBytes(destination);
//   driverIcon = BitmapDescriptor.fromBytes(driver);
//   stopIcon = BitmapDescriptor.fromBytes(stops);
// }
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
//   CameraUpdate cameraUpdate = CameraUpdate.newLatLngBounds(bounds, 40);
//
//   return checkCameraLocation(cameraUpdate, mapController);
// }
//
// Future<void> checkCameraLocation(CameraUpdate cameraUpdate, GoogleMapController mapController) async {
//   mapController.animateCamera(cameraUpdate);
//
//   // Retry until the visible region is valid
//   for (int i = 0; i < 5; i++) {
//     try {
//       LatLngBounds bounds = await mapController.getVisibleRegion();
//       if (bounds.southwest.latitude != -90) {
//         return; // Map is ready
//       }
//     } catch (e) {
//       log("Google Maps not ready yet, retrying...");
//     }
//     await Future.delayed(const Duration(milliseconds: 300));
//   }
//   log("Failed to get visible region after retries.");
// }

  @override
  void onClose() {
    _bookingSub?.cancel();
    _driverSub?.cancel();
    super.onClose();
  }
}
