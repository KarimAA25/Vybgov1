// ignore_for_file: unnecessary_overrides, deprecated_member_use
import 'dart:math';

// ignore_for_file: depend_on_referenced_packages
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:driver/app/models/driver_user_model.dart';
import 'package:driver/app/models/parcel_model.dart';
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

class AskForOtpParcelController extends GetxController {
  GoogleMapController? mapController;

  // =================== OSM ===================
  osm.MapController osmMapController = osm.MapController();
  RxList<latlang.LatLng> osmRoute = <latlang.LatLng>[].obs;
  RxList<osm.Marker> osmMarkers = <osm.Marker>[].obs;

  // =================== DATA ===================
  Rx<DriverUserModel> driverUserModel = DriverUserModel().obs;
  Rx<ParcelModel> parcelModel = ParcelModel().obs;

  RxBool isLoading = true.obs;
  RxString type = "".obs;

  // =================== ICONS ===================
  BitmapDescriptor? departureIcon;
  BitmapDescriptor? destinationIcon;
  BitmapDescriptor? driverIcon;

  // =================== POLYLINE ===================
  RxMap<PolylineId, Polyline> polyLines = <PolylineId, Polyline>{}.obs;
  PolylinePoints polylinePoints = PolylinePoints(apiKey: Constant.mapAPIKey);

  @override
  void onInit() {
    addMarkerSetup();
    getArgument();
    super.onInit();
  }

  // =================== ARGUMENT + LIVE LISTENER ===================
  Future<void> getArgument() async {
    dynamic argumentData = Get.arguments;
    if (argumentData != null) {
      parcelModel.value = argumentData['bookingModel'];

      FirebaseFirestore.instance.collection(CollectionName.parcelRide).doc(parcelModel.value.id).snapshots().listen((parcelEvent) {
        if (parcelEvent.data() == null) return;

        parcelModel.value = ParcelModel.fromJson(parcelEvent.data()!);

        FirebaseFirestore.instance.collection(CollectionName.drivers).doc(parcelModel.value.driverId).snapshots().listen((driverEvent) {
          if (driverEvent.data() == null) return;

          driverUserModel.value = DriverUserModel.fromJson(driverEvent.data()!);

          final bool isOngoing = parcelModel.value.bookingStatus == BookingStatus.bookingOngoing;

          final double sourceLat = driverUserModel.value.location!.latitude!;
          final double sourceLng = driverUserModel.value.location!.longitude!;

          final double destLat = isOngoing ? parcelModel.value.dropLocation!.latitude! : parcelModel.value.pickUpLocation!.latitude!;

          final double destLng = isOngoing ? parcelModel.value.dropLocation!.longitude! : parcelModel.value.pickUpLocation!.longitude!;

          // ================= GOOGLE MAP =================
          getPolyline(
            sourceLatitude: sourceLat,
            sourceLongitude: sourceLng,
            destinationLatitude: destLat,
            destinationLongitude: destLng,
          );

          // ================= OSM MAP =================
          updateOSMRouteAndMarkers(
            sourceLat: sourceLat,
            sourceLng: sourceLng,
            destLat: destLat,
            destLng: destLng,
          );
        });

        if (parcelModel.value.bookingStatus == BookingStatus.bookingCompleted) {
          Get.back();
        }
      });
    }

    isLoading.value = false;
    update();
  }

  // =================== GOOGLE MAP POLYLINE ===================
  void getPolyline({
    required double? sourceLatitude,
    required double? sourceLongitude,
    required double? destinationLatitude,
    required double? destinationLongitude,
  }) async {
    if (sourceLatitude == null || sourceLongitude == null || destinationLatitude == null || destinationLongitude == null) return;

    List<LatLng> polylineCoordinates = [];

    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      request: PolylineRequest(
        origin: PointLatLng(sourceLatitude, sourceLongitude),
        destination: PointLatLng(destinationLatitude, destinationLongitude),
        mode: TravelMode.driving,
      ),
    );

    if (result.points.isNotEmpty) {
      for (var point in result.points) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      }
    }

    addMarker(
      latitude: parcelModel.value.pickUpLocation!.latitude,
      longitude: parcelModel.value.pickUpLocation!.longitude,
      id: "Departure",
      descriptor: departureIcon!,
      rotation: 0,
    );

    addMarker(
      latitude: parcelModel.value.dropLocation!.latitude,
      longitude: parcelModel.value.dropLocation!.longitude,
      id: "Destination",
      descriptor: destinationIcon!,
      rotation: 0,
    );

    addMarker(
      latitude: driverUserModel.value.location!.latitude,
      longitude: driverUserModel.value.location!.longitude,
      id: "Driver",
      descriptor: driverIcon!,
      rotation: driverUserModel.value.rotation,
    );

    _addPolyLine(polylineCoordinates);
  }

  // =================== GOOGLE MAP MARKERS ===================
  RxMap<MarkerId, Marker> markers = <MarkerId, Marker>{}.obs;

  void addMarker({
    required double? latitude,
    required double? longitude,
    required String id,
    required BitmapDescriptor descriptor,
    required double? rotation,
  }) {
    markers[MarkerId(id)] = Marker(
      markerId: MarkerId(id),
      position: LatLng(latitude ?? 0, longitude ?? 0),
      icon: descriptor,
      rotation: rotation ?? 0,
    );
  }

  // =================== ICON SETUP ===================
  Future<void> addMarkerSetup() async {
    departureIcon = BitmapDescriptor.fromBytes(await Constant().getBytesFromAsset('assets/icon/ic_pick_up_map.png', 100));

    destinationIcon = BitmapDescriptor.fromBytes(await Constant().getBytesFromAsset('assets/icon/ic_drop_in_map.png', 100));

    driverIcon = BitmapDescriptor.fromBytes(await Constant().getBytesFromAsset('assets/icon/ic_car.png', 50));
  }

  // =================== POLYLINE DRAW ===================
  void _addPolyLine(List<LatLng> polylineCoordinates) {
    polyLines.clear();

    PolylineId id = const PolylineId("poly");
    polyLines[id] = Polyline(
      polylineId: id,
      points: polylineCoordinates,
      width: 6,
      color: AppThemData.primary500,
      startCap: Cap.roundCap,
    );

    updateCameraLocation(
      polylineCoordinates.first,
      polylineCoordinates.last,
      mapController,
    );
  }

  // =================== CAMERA ===================
  Future<void> updateCameraLocation(
    LatLng source,
    LatLng destination,
    GoogleMapController? mapController,
  ) async {
    if (mapController == null) return;

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

    await mapController.animateCamera(
      CameraUpdate.newLatLngBounds(bounds, 50),
    );
  }

  // =================== OSM LOGIC ===================
  void updateOSMRouteAndMarkers({
    required double sourceLat,
    required double sourceLng,
    required double destLat,
    required double destLng,
  }) {
    osmRoute
      ..clear()
      ..addAll([
        latlang.LatLng(sourceLat, sourceLng),
        latlang.LatLng(destLat, destLng),
      ]);

    osmMarkers
      ..clear()
      ..addAll([
        _osmMarker(
          parcelModel.value.pickUpLocation!.latitude!,
          parcelModel.value.pickUpLocation!.longitude!,
          'assets/icon/ic_pick_up_map.png',
          40,
        ),
        _osmMarker(
          parcelModel.value.dropLocation!.latitude!,
          parcelModel.value.dropLocation!.longitude!,
          'assets/icon/ic_drop_in_map.png',
          40,
        ),
        _osmMarker(
          sourceLat,
          sourceLng,
          'assets/icon/ic_car.png',
          35,
          rotation: driverUserModel.value.rotation,
        ),
      ]);

    osmMapController.move(
      latlang.LatLng(sourceLat, sourceLng),
      osmMapController.camera.zoom,
    );
  }

  osm.Marker _osmMarker(
    double lat,
    double lng,
    String asset,
    double size, {
    double? rotation,
  }) {
    return osm.Marker(
      point: latlang.LatLng(lat, lng),
      width: size,
      height: size,
      child: rotation != null
          ? Transform.rotate(
              angle: rotation * 0.0174533,
              child: Image.asset(asset),
            )
          : Image.asset(asset),
    );
  }
// @override
// void onInit() {
//   addMarkerSetup();
//   getArgument();
//   // playSound();
//   super.onInit();
// }
//
// Future<void> getArgument() async {
//   dynamic argumentData = Get.arguments;
//   if (argumentData != null) {
//     parcelModel.value = argumentData['bookingModel'];
//
//     FirebaseFirestore.instance.collection(CollectionName.parcelRide).doc(parcelModel.value.id).snapshots().listen((event) {
//       if (event.data() != null) {
//         ParcelModel orderModelStream = ParcelModel.fromJson(event.data()!);
//         parcelModel.value = orderModelStream;
//         FirebaseFirestore.instance.collection(CollectionName.drivers).doc(parcelModel.value.driverId).snapshots().listen((event) {
//           if (event.data() != null) {
//             driverUserModel.value = DriverUserModel.fromJson(event.data()!);
//             if (parcelModel.value.bookingStatus == BookingStatus.bookingOngoing) {
//               getPolyline(
//                   sourceLatitude: driverUserModel.value.location!.latitude,
//                   sourceLongitude: driverUserModel.value.location!.longitude,
//                   destinationLatitude: parcelModel.value.dropLocation!.latitude,
//                   destinationLongitude: parcelModel.value.dropLocation!.longitude);
//             } else {
//               getPolyline(
//                   sourceLatitude: driverUserModel.value.location!.latitude,
//                   sourceLongitude: driverUserModel.value.location!.longitude,
//                   destinationLatitude: parcelModel.value.pickUpLocation!.latitude,
//                   destinationLongitude: parcelModel.value.pickUpLocation!.longitude);
//             }
//           }
//         });
//
//         if (parcelModel.value.bookingStatus == BookingStatus.bookingCompleted) {
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
//
//     PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
//       request: PolylineRequest(
//         origin: PointLatLng(sourceLatitude, sourceLongitude),
//         destination: PointLatLng(destinationLatitude, destinationLongitude),
//         mode: TravelMode.driving,
//         // wayPoints: [PolylineWayPoint(location: "Sabo, Yaba Lagos Nigeria")],
//       ),
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
//         latitude: parcelModel.value.pickUpLocation!.latitude,
//         longitude: parcelModel.value.pickUpLocation!.longitude,
//         id: "Departure",
//         descriptor: departureIcon!,
//         rotation: 0.0);
//     addMarker(
//         latitude: parcelModel.value.dropLocation!.latitude,
//         longitude: parcelModel.value.dropLocation!.longitude,
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
//   departureIcon = BitmapDescriptor.fromBytes(departure);
//   destinationIcon = BitmapDescriptor.fromBytes(destination);
//   driverIcon = BitmapDescriptor.fromBytes(driver);
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
