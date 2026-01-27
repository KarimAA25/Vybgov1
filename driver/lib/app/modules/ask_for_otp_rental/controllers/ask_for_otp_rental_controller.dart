// ignore_for_file: unnecessary_overrides, deprecated_member_use
import 'dart:math';

// ignore_for_file: depend_on_referenced_packages
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:driver/app/models/driver_user_model.dart';
import 'package:driver/app/models/rental_booking_model.dart';
import 'package:driver/constant/booking_status.dart';
import 'package:driver/constant/collection_name.dart';
import 'package:driver/constant/constant.dart';
import 'package:driver/theme/app_them_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart' as latlang;
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_map/flutter_map.dart' as osm;
import 'package:latlong2/latlong.dart' as latlang;

class AskForOtpRentalController extends GetxController {
  /// ================= GOOGLE MAP =================
  GoogleMapController? mapController;
  RxMap<MarkerId, Marker> markers = <MarkerId, Marker>{}.obs;
  RxMap<PolylineId, Polyline> polyLines = <PolylineId, Polyline>{}.obs;
  PolylinePoints polylinePoints = PolylinePoints(apiKey: Constant.mapAPIKey);

  BitmapDescriptor? departureIcon;
  BitmapDescriptor? destinationIcon;
  BitmapDescriptor? driverIcon;

  /// ================= OSM MAP =================
  osm.MapController osmMapController = osm.MapController();
  RxList<latlang.LatLng> osmRoute = <latlang.LatLng>[].obs;
  RxList<osm.Marker> osmMarkers = <osm.Marker>[].obs;

  /// ================= DATA =================
  Rx<DriverUserModel> driverUserModel = DriverUserModel().obs;
  Rx<RentalBookingModel> rentalModel = RentalBookingModel().obs;

  RxBool isLoading = true.obs;

  // @override
  // void onInit() {
  //   addMarkerSetup();
  //   getArgument();
  //   super.onInit();
  // }

  /// ================= INIT =================
  @override
  void onInit() {
    super.onInit();
    addMarkerSetup();
    getArgument();
  }

  /// ================= ARGUMENT & FIRESTORE =================
  Future<void> getArgument() async {
    final args = Get.arguments;
    if (args == null) return;

    rentalModel.value = args['rentalBookingModel'];

    FirebaseFirestore.instance.collection(CollectionName.rentalRide).doc(rentalModel.value.id).snapshots().listen((event) {
      if (event.data() == null) return;

      rentalModel.value = RentalBookingModel.fromJson(event.data()!);

      if (rentalModel.value.bookingStatus == BookingStatus.bookingCompleted) {
        Get.back();
      }

      if (rentalModel.value.driverId != null && rentalModel.value.driverId!.isNotEmpty) {
        _listenDriver(rentalModel.value.driverId!);
      }
    });

    isLoading.value = false;
  }

  void _listenDriver(String driverId) {
    FirebaseFirestore.instance.collection(CollectionName.drivers).doc(driverId).snapshots().listen((driverEvent) {
      if (driverEvent.data() == null) return;

      driverUserModel.value = DriverUserModel.fromJson(driverEvent.data()!);

      if (driverUserModel.value.location != null && rentalModel.value.pickUpLocation != null) {
        getPolyline(
          sourceLatitude: driverUserModel.value.location!.latitude,
          sourceLongitude: driverUserModel.value.location!.longitude,
          destinationLatitude: rentalModel.value.pickUpLocation!.latitude,
          destinationLongitude: rentalModel.value.pickUpLocation!.longitude,
        );
      }
    });
  }

  /// ================= MAIN ROUTE HANDLER =================
  Future<void> getPolyline({
    required double? sourceLatitude,
    required double? sourceLongitude,
    required double? destinationLatitude,
    required double? destinationLongitude,
  }) async {
    if (sourceLatitude == null || sourceLongitude == null || destinationLatitude == null || destinationLongitude == null) return;

    if (Constant.selectedMap == "Google Map") {
      await _googleRoute(
        sourceLatitude,
        sourceLongitude,
        destinationLatitude,
        destinationLongitude,
      );
    } else {
      await _osmRoute(
        sourceLatitude,
        sourceLongitude,
        destinationLatitude,
        destinationLongitude,
      );
    }
  }

  /// ================= GOOGLE MAP =================
  Future<void> _googleRoute(
    double sLat,
    double sLng,
    double dLat,
    double dLng,
  ) async {
    markers.clear();
    polyLines.clear();

    final result = await polylinePoints.getRouteBetweenCoordinates(
      request: PolylineRequest(
        origin: PointLatLng(sLat, sLng),
        destination: PointLatLng(dLat, dLng),
        mode: TravelMode.driving,
      ),
    );

    List<LatLng> points = result.points.map((e) => LatLng(e.latitude, e.longitude)).toList();

    addMarker(
      latitude: dLat,
      longitude: dLng,
      id: "Pickup",
      descriptor: departureIcon!,
      rotation: 0,
    );

    addMarker(
      latitude: sLat,
      longitude: sLng,
      id: "Driver",
      descriptor: driverIcon!,
      rotation: driverUserModel.value.rotation,
    );

    _addPolyLine(points);
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
    );
  }

  void _addPolyLine(List<LatLng> points) {
    final polyId = const PolylineId("route");

    polyLines[polyId] = Polyline(
      polylineId: polyId,
      points: points,
      width: 6,
      color: AppThemData.primary500,
      startCap: Cap.roundCap,
      endCap: Cap.roundCap,
    );

    updateCameraLocation(points.first, points.last);
  }

  Future<void> updateCameraLocation(LatLng source, LatLng destination) async {
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

    mapController!.animateCamera(CameraUpdate.newLatLngBounds(bounds, 60));
  }

  /// ================= OSM MAP =================
  Future<void> _osmRoute(
    double sLat,
    double sLng,
    double dLat,
    double dLng,
  ) async {
    osmMarkers.clear();
    osmRoute.clear();

    osmMarkers.addAll([
      osm.Marker(
        point: latlang.LatLng(sLat, sLng),
        width: 40,
        height: 40,
        child: Image.asset('assets/icon/ic_car.png'),
      ),
      osm.Marker(
        point: latlang.LatLng(dLat, dLng),
        width: 40,
        height: 40,
        child: Image.asset('assets/icon/ic_pick_up_map.png'),
      ),
    ]);

    osmRoute.addAll([
      latlang.LatLng(sLat, sLng),
      latlang.LatLng(dLat, dLng),
    ]);

    osmMapController.fitCamera(
      osm.CameraFit.bounds(
        bounds: latlang.LatLngBounds(
          latlang.LatLng(sLat, sLng),
          latlang.LatLng(dLat, dLng),
        ),
        padding: const EdgeInsets.all(50),
      ),
    );

    update();
  }

  /// ================= ICON SETUP =================
  Future<void> addMarkerSetup() async {
    departureIcon = BitmapDescriptor.fromBytes(
      await Constant().getBytesFromAsset('assets/icon/ic_pick_up_map.png', 100),
    );
    destinationIcon = BitmapDescriptor.fromBytes(
      await Constant().getBytesFromAsset('assets/icon/ic_drop_in_map.png', 100),
    );
    driverIcon = BitmapDescriptor.fromBytes(
      await Constant().getBytesFromAsset('assets/icon/ic_car.png', 50),
    );
  }

// Future<void> getArgument() async {
//   dynamic argumentData = Get.arguments;
//   if (argumentData != null) {
//     rentalModel.value = argumentData['rentalBookingModel'];
//
//     FirebaseFirestore.instance.collection(CollectionName.rentalRide).doc(rentalModel.value.id).snapshots().listen((event) {
//       if (event.data() != null) {
//         RentalBookingModel orderModelStream = RentalBookingModel.fromJson(event.data()!);
//         rentalModel.value = orderModelStream;
//
//         if (rentalModel.value.driverId != null && rentalModel.value.driverId!.isNotEmpty) {
//           FirebaseFirestore.instance.collection(CollectionName.drivers).doc(rentalModel.value.driverId).snapshots().listen((driverEvent) {
//             if (driverEvent.data() != null) {
//               driverUserModel.value = DriverUserModel.fromJson(driverEvent.data()!);
//
//               if (driverUserModel.value.location != null && rentalModel.value.pickUpLocation != null) {
//                 getPolyline(
//                   sourceLatitude: driverUserModel.value.location!.latitude,
//                   sourceLongitude: driverUserModel.value.location!.longitude,
//                   destinationLatitude: rentalModel.value.pickUpLocation!.latitude,
//                   destinationLongitude: rentalModel.value.pickUpLocation!.longitude,
//                 );
//               }
//             }
//           });
//         }
//
//         if (rentalModel.value.bookingStatus == BookingStatus.bookingCompleted) {
//           Get.back();
//         }
//       }
//     });
//   }
//   isLoading.value = false;
//   update();
// }
//
// void getPolyline({
//   required double? sourceLatitude,
//   required double? sourceLongitude,
//   required double? destinationLatitude,
//   required double? destinationLongitude,
// }) async {
//   if (sourceLatitude != null && sourceLongitude != null && destinationLatitude != null && destinationLongitude != null) {
//     List<LatLng> polylineCoordinates = [];
//
//     PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
//       request: PolylineRequest(
//         origin: PointLatLng(sourceLatitude, sourceLongitude),
//         destination: PointLatLng(destinationLatitude, destinationLongitude),
//         mode: TravelMode.driving,
//       ),
//     );
//
//     if (result.points.isNotEmpty) {
//       for (var point in result.points) {
//         polylineCoordinates.add(LatLng(point.latitude, point.longitude));
//       }
//     } else {
//       log(result.errorMessage.toString());
//     }
//
//     // Add pickup marker only
//     if (departureIcon != null) {
//       addMarker(
//         latitude: rentalModel.value.pickUpLocation!.latitude,
//         longitude: rentalModel.value.pickUpLocation!.longitude,
//         id: "Pickup",
//         descriptor: departureIcon!,
//         rotation: 0.0,
//       );
//     }
//
//     // Add driver marker
//     if (driverIcon != null) {
//       addMarker(
//         latitude: driverUserModel.value.location!.latitude,
//         longitude: driverUserModel.value.location!.longitude,
//         id: "Driver",
//         descriptor: driverIcon!,
//         rotation: driverUserModel.value.rotation,
//       );
//     }
//
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
