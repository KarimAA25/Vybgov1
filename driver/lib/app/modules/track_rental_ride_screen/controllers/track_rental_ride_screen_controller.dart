// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:math' as math;

// ignore_for_file: depend_on_referenced_packages
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:driver/app/models/driver_user_model.dart';
import 'package:driver/app/models/location_lat_lng.dart';
import 'package:driver/app/models/rental_booking_model.dart';
import 'package:driver/constant/booking_status.dart';
import 'package:driver/constant/collection_name.dart';
import 'package:driver/constant/constant.dart';
import 'package:driver/constant_widgets/show_toast_dialog.dart';
import 'package:driver/theme/app_them_data.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_map/flutter_map.dart' as osm;
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart' as latlang;

class TrackRentalRideScreenController extends GetxController {
  RxBool isLoading = true.obs;
  GoogleMapController? mapController;

  Rx<DriverUserModel> driverUserModel = DriverUserModel().obs;
  Rx<RentalBookingModel> rentalModel = RentalBookingModel().obs;

  BitmapDescriptor? departureIcon;
  BitmapDescriptor? destinationIcon;
  BitmapDescriptor? driverIcon;
  BitmapDescriptor? stopIcon;

  Rx<PolylinePoints> polylinePoints = PolylinePoints(apiKey: Constant.mapAPIKey).obs;
  RxMap<PolylineId, Polyline> polyLines = <PolylineId, Polyline>{}.obs;
  RxMap<String, Marker> markers = <String, Marker>{}.obs;
  String? _lastPolylineStatus;
  DateTime _lastCameraFollow = DateTime.fromMillisecondsSinceEpoch(0);
  final Duration cameraFollowThrottle = const Duration(milliseconds: 200);
  LatLng? _oldGooglePos;
  final double snapThresholdMeters = 0.8;

  // OSM
  osm.MapController osmMapController = osm.MapController();
  RxList<latlang.LatLng> osmRoute = <latlang.LatLng>[].obs;
  RxList<osm.Marker> osmMarkers = <osm.Marker>[].obs;
  latlang.LatLng? _oldOsmPos;
  final Duration osmAnimDuration = const Duration(milliseconds: 500);
  final int osmAnimSteps = 20;
  RxBool osmMapReady = false.obs;
  final double osmReRouteThreshold = 30; // meters deviation threshold

  StreamSubscription<DocumentSnapshot>? _bookingSub;
  StreamSubscription<DocumentSnapshot>? _driverSub;

  @override
  void onInit() {
    addMarkerSetup();
    getArgument();
    super.onInit();
  }

  Future<void> getArgument() async {
    final argumentData = Get.arguments;
    if (argumentData == null) {
      isLoading.value = false;
      return;
    }

    rentalModel.value = argumentData['rentalModel'];
    log("---------------------------> ${rentalModel.value.toJson()}");

    /// 🔹 Booking listener (only ONE)
    _bookingSub?.cancel();
    _bookingSub = FirebaseFirestore.instance.collection(CollectionName.rentalRide).doc(rentalModel.value.id).snapshots().listen((bookingEvent) {
      final data = bookingEvent.data();
      if (data == null) return;

      final updatedBooking = RentalBookingModel.fromJson(data);
      rentalModel.value = updatedBooking;

      /// ✅ Stop tracking if completed
      if (updatedBooking.bookingStatus == BookingStatus.bookingCompleted) {
        Get.back();
        return;
      }

      /// 🔹 Start driver listener ONLY ONCE
      _startDriverListener();
    });

    isLoading.value = false;
    update();
  }

  void _startDriverListener() {
    if (_driverSub != null) return; // ✅ prevents duplicates

    _driverSub = FirebaseFirestore.instance
        .collection(CollectionName.drivers)
        .doc(rentalModel.value.driverId)
        .snapshots()
        .distinct(
          (prev, next) => prev.data()?['location'] == next.data()?['location'],
        )
        .listen((driverEvent) {
      final data = driverEvent.data();
      if (data == null) return;

      driverUserModel.value = DriverUserModel.fromJson(data);

      /// ✅ Call Directions API ONLY when status changes
      if (_lastPolylineStatus != rentalModel.value.bookingStatus) {
        _lastPolylineStatus = rentalModel.value.bookingStatus;
        getDirections();
      }

      final loc = driverUserModel.value.location;
      if (loc == null) return;

      if (Constant.selectedMap == "Google Map") {
        animateDriverMarkerGoogle(
          LatLng(loc.latitude!, loc.longitude!),
          newRotation: double.tryParse(driverUserModel.value.rotation.toString()) ?? 0.0,
        );
      } else {
        animateDriverMarkerOsm(
          latlang.LatLng(loc.latitude!, loc.longitude!),
        );
      }
    });
  }

  Future<void> getDirections() async {
    try {
      final pickup = rentalModel.value.pickUpLocation;
      final driver = driverUserModel.value.location;

      if (pickup == null || driver == null) return;

      final origin = PointLatLng(driver.latitude!, driver.longitude!);
      final destination = PointLatLng(pickup.latitude!, pickup.longitude!);

      final result = await polylinePoints.value.getRouteBetweenCoordinates(
        request: PolylineRequest(
          origin: origin,
          destination: destination,
          mode: TravelMode.driving,
        ),
      );

      final polylineCoordinates = result.points.map((e) => LatLng(e.latitude, e.longitude)).toList();

      if (Constant.selectedMap == "Google Map") {
        _updateGoogleMarkers(pickup, driver);
        addPolyLine(polylineCoordinates);
      } else {
        _updateOsmMarkers(pickup, driver);
        updateOsmPolyline(polylineCoordinates.map((e) => latlang.LatLng(e.latitude, e.longitude)).toList());
      }
    } catch (e) {
      if (kDebugMode) print("getDirections error: $e");
    }
  }

  // -------------------- Marker Setup --------------------
  Future<void> addMarkerSetup() async {
    try {
      final departure = await Constant().getBytesFromAsset('assets/icon/ic_pick_up_map.png', 100);
      final destination = await Constant().getBytesFromAsset('assets/icon/ic_drop_in_map.png', 100);
      final driver = await Constant().getBytesFromAsset('assets/icon/ic_car.png', 50);

      departureIcon = BitmapDescriptor.fromBytes(departure);
      destinationIcon = BitmapDescriptor.fromBytes(destination);
      driverIcon = BitmapDescriptor.fromBytes(driver);
    } catch (e, stack) {
      log("Error in addMarkerSetup", error: e, stackTrace: stack);
      ShowToastDialog.showToast("${"Failed to load marker icons:".tr} $e");
    }
  }

  // -------------------- Google Map Helpers --------------------
  void _updateGoogleMarkers(LocationLatLng pickup, LocationLatLng driver) {
    markers.clear();

    markers['Pickup'] = Marker(
      markerId: const MarkerId('Pickup'),
      position: LatLng(pickup.latitude!, pickup.longitude!),
      icon: departureIcon ?? BitmapDescriptor.defaultMarker,
    );

    markers['Driver'] = Marker(
      markerId: const MarkerId('Driver'),
      position: LatLng(driver.latitude!, driver.longitude!),
      icon: driverIcon ?? BitmapDescriptor.defaultMarker,
      anchor: const Offset(0.5, 0.5),
    );

    update();
  }

  void addPolyLine(List<LatLng> polylineCoordinates) {
    PolylineId id = const PolylineId("poly");
    polyLines[id] = Polyline(
      polylineId: id,
      color: AppThemData.primary500,
      points: polylineCoordinates,
      width: 4,
      geodesic: true,
    );

    if (polylineCoordinates.isNotEmpty) {
      updateCameraLocation(polylineCoordinates.first, mapController);
    }
    update();
  }

  Future<void> updateCameraLocation(LatLng source, GoogleMapController? mapController) async {
    if (mapController == null) return;
    try {
      await mapController.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(driverUserModel.value.location!.latitude ?? 0.0, driverUserModel.value.location!.longitude ?? 0.0),
            zoom: 16,
            bearing: double.parse('${driverUserModel.value.rotation ?? '0.0'}'),
          ),
        ),
      );
    } catch (e) {
      if (kDebugMode) print("updateCameraLocation error: $e");
    }
  }

  Future<void> animateDriverMarkerGoogle(
    LatLng newPos, {
    double? newRotation,
    Duration duration = const Duration(milliseconds: 450),
    bool followCamera = true,
  }) async {
    final LatLng start = _oldGooglePos ?? newPos;
    final LatLng end = newPos;

    final controller = AnimationController(
      vsync: Get.find<TickerProvider>(),
      duration: duration,
    );

    final animation = Tween<double>(begin: 0, end: 1).animate(controller);

    animation.addListener(() {
      final lat = start.latitude + (end.latitude - start.latitude) * animation.value;
      final lng = start.longitude + (end.longitude - start.longitude) * animation.value;

      markers['Driver'] = Marker(
        markerId: const MarkerId('Driver'),
        position: LatLng(lat, lng),
        icon: driverIcon ?? BitmapDescriptor.defaultMarker,
        rotation: newRotation ?? 0,
        anchor: const Offset(0.5, 0.5),
      );
      if (followCamera && DateTime.now().difference(_lastCameraFollow) > cameraFollowThrottle) {
        _lastCameraFollow = DateTime.now();
        mapController?.animateCamera(CameraUpdate.newLatLng(LatLng(lat, lng)));
      }
      update();
    });
    controller.forward();
    _oldGooglePos = newPos;
  }

  // -------------------- OSM Helpers --------------------
  void _updateOsmMarkers(LocationLatLng pickup, LocationLatLng driver) {
    osmMarkers.clear();

    osmMarkers.add(osm.Marker(
      point: latlang.LatLng(driver.latitude!, driver.longitude!),
      child: Image.asset('assets/icon/ic_car.png'),
    ));

    osmMarkers.add(osm.Marker(
      point: latlang.LatLng(pickup.latitude!, pickup.longitude!),
      child: Image.asset('assets/icon/ic_pick_up_map.png'),
    ));

    update();
  }

  void updateOsmPolyline(List<latlang.LatLng> points) {
    osmRoute.value = points;
    update();
  }

  void followDriverCameraOsm(latlang.LatLng pos) {
    if (!osmMapReady.value) return;

    osmMapController.move(
      pos,
      osmMapController.camera.zoom < 15 ? 16 : osmMapController.camera.zoom,
    );
  }

// Trim polyline behind driver
  void trimOsmPolyline(latlang.LatLng driverPos) {
    if (osmRoute.isEmpty) return;

    int closestIndex = 0;
    double minDist = double.infinity;

    for (int i = 0; i < osmRoute.length; i++) {
      final d = _calculateDistanceMeters(
        driverPos.latitude,
        driverPos.longitude,
        osmRoute[i].latitude,
        osmRoute[i].longitude,
      );
      if (d < minDist) {
        minDist = d;
        closestIndex = i;
      }
    }

    osmRoute.value = osmRoute.sublist(closestIndex);
    update();
  }

// Recalculate polyline if driver deviates
  Future<void> recalcOsmPolylineIfNeeded() async {
    if (driverUserModel.value.location == null) return;

    final driverPos = latlang.LatLng(driverUserModel.value.location!.latitude!, driverUserModel.value.location!.longitude!);

    if (osmRoute.isEmpty) return;

    // Distance from the start of the current route
    final distanceFromRoute = _calculateDistanceMeters(driverPos.latitude, driverPos.longitude, osmRoute.first.latitude, osmRoute.first.longitude);

    if (distanceFromRoute > osmReRouteThreshold) {
      // Re-fetch route from current driver location to pickup
      final pickup = rentalModel.value.pickUpLocation!;
      final newRoute = await fetchOsmRoute(
        start: driverPos,
        end: latlang.LatLng(pickup.latitude!, pickup.longitude!),
      );

      if (newRoute.isNotEmpty) {
        osmRoute.value = newRoute;
        _updateOsmMarkers(pickup, driverUserModel.value.location!);
        update();
      }
    } else {
      // Just trim the polyline behind the driver
      trimOsmPolyline(driverPos);
    }
  }

  Future<List<latlang.LatLng>> fetchOsmRoute({
    required latlang.LatLng start,
    required latlang.LatLng end,
  }) async {
    final url = 'https://router.project-osrm.org/route/v1/driving/'
        '${start.longitude},${start.latitude};'
        '${end.longitude},${end.latitude}'
        '?overview=full&geometries=geojson';

    final response = await http.get(Uri.parse(url));
    if (response.statusCode != 200) return [];

    final data = json.decode(response.body);
    final List coords = data['routes'][0]['geometry']['coordinates'];

    return coords.map<latlang.LatLng>((e) => latlang.LatLng(e[1], e[0])).toList();
  }

  Future<void> animateDriverMarkerOsm(latlang.LatLng newPos) async {
    if (!osmMapReady.value) return;

    final start = _oldOsmPos ?? newPos;
    final end = newPos;

    for (int i = 1; i <= osmAnimSteps; i++) {
      final t = i / osmAnimSteps;
      final lat = start.latitude + (end.latitude - start.latitude) * t;
      final lng = start.longitude + (end.longitude - start.longitude) * t;
      final animatedPos = latlang.LatLng(lat, lng);

      _updateOsmMarkers(rentalModel.value.pickUpLocation!, LocationLatLng(latitude: lat, longitude: lng));
      followDriverCameraOsm(animatedPos);

      trimOsmPolyline(animatedPos); // trim behind the driver

      await Future.delayed(Duration(milliseconds: osmAnimDuration.inMilliseconds ~/ osmAnimSteps));
    }

    _oldOsmPos = newPos;

    await recalcOsmPolylineIfNeeded(); // check deviation & recalc if needed
  }

  double _deg2rad(double deg) => deg * (math.pi / 180);

  double _calculateDistanceMeters(double lat1, double lon1, double lat2, double lon2) {
    const double R = 6371000;
    final dLat = _deg2rad(lat2 - lat1);
    final dLon = _deg2rad(lon2 - lon1);
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) + math.cos(_deg2rad(lat1)) * math.cos(_deg2rad(lat2)) * math.sin(dLon / 2) * math.sin(dLon / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return R * c;
  }

  @override
  void onClose() {
    _bookingSub?.cancel();
    _driverSub?.cancel();
    super.onClose();
  }
}
