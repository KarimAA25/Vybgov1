import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:math' as math;

// ignore_for_file: depend_on_referenced_packages
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:driver/app/models/driver_user_model.dart';
import 'package:driver/app/models/intercity_model.dart';
import 'package:driver/app/models/location_lat_lng.dart';
import 'package:driver/constant/booking_status.dart';
import 'package:driver/constant/collection_name.dart';
import 'package:driver/constant/constant.dart';
import 'package:driver/constant_widgets/show_toast_dialog.dart';
import 'package:driver/theme/app_them_data.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_map/flutter_map.dart' as osm;
import 'package:latlong2/latlong.dart' as latlang;
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

// ignore_for_file: deprecated_member_use

class TrackInterCityRideScreenController extends GetxController {
  // ================= MAP CONTROLLERS =================
  GoogleMapController? mapController;
  osm.MapController osmMapController = osm.MapController();

  // ================= MAP DATA =================
  RxMap<PolylineId, Polyline> polyLines = <PolylineId, Polyline>{}.obs;
  RxMap<String, Marker> markers = <String, Marker>{}.obs;
  List<LatLng> _activeGoogleRoutePoints = [];

  RxList<latlang.LatLng> osmRoute = <latlang.LatLng>[].obs;
  RxList<osm.Marker> osmMarkers = <osm.Marker>[].obs;
  List<latlang.LatLng> _activeOSMRoutePoints = [];

  // ================= MODELS =================
  Rx<DriverUserModel> driverUserModel = DriverUserModel().obs;
  Rx<IntercityModel> intercityModel = IntercityModel().obs;

  // ================= ICONS =================
  BitmapDescriptor? departureIcon;
  BitmapDescriptor? destinationIcon;
  BitmapDescriptor? driverIcon;
  BitmapDescriptor? stopIcon;

  // ================= POLYLINE =================
  Rx<PolylinePoints> polylinePoints = PolylinePoints(apiKey: Constant.mapAPIKey).obs;

  // ================= STATE =================
  RxBool isLoading = true.obs;
  RxInt etaInMinutes = 0.obs;

  final double deviationDistance = 400;
  final Duration rerouteCooldown = const Duration(minutes: 2);

  // ================= CAMERA THROTTLE =================
  DateTime _lastCameraFollow = DateTime.fromMillisecondsSinceEpoch(0);
  final Duration cameraFollowThrottle = const Duration(milliseconds: 250);

  // ================= ETA CACHE =================
  DateTime? lastUpdateTimeGoogle;
  DateTime? lastUpdateTimeOSM;
  final Duration etaUpdateThrottle = const Duration(seconds: 5);

  String? _lastBookingStatus;
  DateTime _lastRerouteTime = DateTime.fromMillisecondsSinceEpoch(0);

  LatLng? _lastDriverPos;
  int _markerAnimId = 0;
  String? _cachedRouteHash;
  DateTime? _cachedRouteTime;
  List<LatLng>? _cachedPolylineCoordinates;
  final Duration cachedRouteTTL = const Duration(minutes: 20);

  final double osmDeviationDistance = 400;
  DateTime _lastOSMReroute = DateTime.fromMillisecondsSinceEpoch(0);
  final Duration osmRerouteCooldown = const Duration(seconds: 20);
  DateTime _lastCameraMove = DateTime.fromMillisecondsSinceEpoch(0);
  final Duration cameraThrottle = const Duration(milliseconds: 300);

  @override
  void onInit() {
    addMarkerSetup();
    getArgument();
    super.onInit();
  }

  StreamSubscription<DocumentSnapshot>? _bookingSub;
  StreamSubscription<DocumentSnapshot>? _driverSub;
  String? _listeningDriverId;

  void getArgument() {
    final args = Get.arguments;
    if (args == null || args is! Map || args['interCityModel'] == null) {
      developer.log("Missing interCityModel arguments in TrackInterCityRideScreenController");
      ShowToastDialog.showToast("Ride not found".tr);
      Get.back();
      return;
    }

    intercityModel.value = args['interCityModel'];

    _bookingSub?.cancel();
    _bookingSub = FirebaseFirestore.instance.collection(CollectionName.interCityRide).doc(intercityModel.value.id).snapshots().listen((bookingSnap) {
      if (!bookingSnap.exists) return;

      intercityModel.value = IntercityModel.fromJson(bookingSnap.data()!);

      // ---------- STATUS CHANGE HANDLING ----------
      final bool statusChanged = _lastBookingStatus != intercityModel.value.bookingStatus;

      if (statusChanged) {
        _lastBookingStatus = intercityModel.value.bookingStatus;

        if (Constant.selectedMap == "Google Map") {
          _activeGoogleRoutePoints.clear();
          polyLines.clear();
        } else {
          osmMarkers.clear();
          osmRoute.clear();
          _activeOSMRoutePoints.clear();
          _lastOSMReroute = DateTime.fromMillisecondsSinceEpoch(0);
        }
        update();
      }

      if (intercityModel.value.bookingStatus == BookingStatus.bookingCompleted) {
        _driverSub?.cancel();
        Get.back();
        return;
      }

      final driverId = intercityModel.value.driverId;
      if (driverId == null || driverId.isEmpty) return;

      // ---------- PREVENT MULTIPLE DRIVER LISTENERS ----------
      if (_listeningDriverId == driverId && _driverSub != null) return;

      _listeningDriverId = driverId;
      _driverSub?.cancel();

      _driverSub = FirebaseFirestore.instance.collection(CollectionName.drivers).doc(driverId).snapshots().listen(_onDriverUpdate);
    });

    isLoading.value = false;
  }

  Future<void> _onDriverUpdate(DocumentSnapshot driverSnap) async {
    if (!driverSnap.exists) return;

    driverUserModel.value = DriverUserModel.fromJson(driverSnap.data() as Map<String, dynamic>);

    final loc = driverUserModel.value.location;
    if (loc == null) return;

    final driverLatLng = LatLng(loc.latitude!, loc.longitude!);

    if (Constant.selectedMap == "Google Map") {
      // First route build
      if (_activeGoogleRoutePoints.isEmpty) {
        await getDirections(forceReroute: true);
      }
      // Deviated
      else if (isDriverDeviated(driverLatLng)) {
        _activeGoogleRoutePoints.clear();
        polyLines.clear();
        await getDirections(forceReroute: true);
      }
      // Normal movement
      else {
        trimGooglePolylineByDriver(driverLatLng);
      }

      updateGoogleDriverMarker(driverLatLng);
    } else {
      _getOsmDirections();
    }
  }

  Future<void> getDirections({bool forceReroute = false}) async {
    try {
      if (intercityModel.value.id == null) return;
      final driver = driverUserModel.value.location;
      final pickup = intercityModel.value.pickUpLocation;
      final drop = intercityModel.value.dropLocation;
      List stops = [];
      if (intercityModel.value.bookingStatus != BookingStatus.bookingAccepted) {
        stops = intercityModel.value.stops ?? [];
      }

      if (driver == null || pickup == null || drop == null) return;

      late PointLatLng origin;
      late PointLatLng destination;

      if (intercityModel.value.bookingStatus == BookingStatus.bookingPlaced || intercityModel.value.bookingStatus == BookingStatus.driverAssigned) {
        origin = PointLatLng(pickup.latitude!, pickup.longitude!);
        destination = PointLatLng(drop.latitude!, drop.longitude!);
      } else if (intercityModel.value.bookingStatus == BookingStatus.bookingAccepted) {
        origin = PointLatLng(driver.latitude!, driver.longitude!);
        destination = PointLatLng(pickup.latitude!, pickup.longitude!);
      } else if (intercityModel.value.bookingStatus == BookingStatus.bookingOngoing || intercityModel.value.bookingStatus == BookingStatus.bookingOnHold) {
        origin = PointLatLng(driver.latitude!, driver.longitude!);
        destination = PointLatLng(drop.latitude!, drop.longitude!);
      } else {
        return;
      }

      if (!forceReroute && _activeGoogleRoutePoints.isNotEmpty && DateTime.now().difference(_lastRerouteTime) < rerouteCooldown) {
        return;
      }

      if (!forceReroute && DateTime.now().difference(_lastRerouteTime) < rerouteCooldown) {
        return;
      }

      _lastRerouteTime = DateTime.now();
      final wayPoints = stops.where((s) => s.location != null).map((s) => PolylineWayPoint(location: '${s.location!.latitude},${s.location!.longitude}')).toList();

      final result = await polylinePoints.value.getRouteBetweenCoordinates(
        request: PolylineRequest(origin: origin, destination: destination, mode: TravelMode.driving, optimizeWaypoints: true, wayPoints: wayPoints),
      );

      if (result.points.isEmpty) return;

      final polylineCoordinates = result.points.map((p) => LatLng(p.latitude, p.longitude)).toList();

      final routeHash = '${origin.latitude},${origin.longitude}-${destination.latitude},${destination.longitude}';

      if (!forceReroute &&
          _cachedRouteHash == routeHash &&
          _cachedPolylineCoordinates != null &&
          _cachedRouteTime != null &&
          DateTime.now().difference(_cachedRouteTime!) < cachedRouteTTL) {
        _activeGoogleRoutePoints = List.from(_cachedPolylineCoordinates!);
        addPolyLine(_activeGoogleRoutePoints);
      } else {
        final simplified = _rdpSimplify(polylineCoordinates, 6.0);
        final densified = _densify(simplified, 12.0);

        _cachedRouteHash = routeHash;
        _cachedRouteTime = DateTime.now();
        _cachedPolylineCoordinates = List.from(densified);

        _activeGoogleRoutePoints = List.from(densified);
        addPolyLine(_activeGoogleRoutePoints);
      }
      _updateGoogleMarkers(
        pickup,
        drop,
        LocationLatLng(latitude: driver.latitude!, longitude: driver.longitude!),
      );

      updateEtaGoogleMap();
    } catch (e, stack) {
      developer.log("getDirections error", error: e, stackTrace: stack);
    }
  }

  void trimGooglePolylineByDriver(LatLng driverPos) {
    if (_activeGoogleRoutePoints.length < 2) return;

    int nearestIndex = -1;
    double minDistance = double.infinity;

    for (int i = 0; i < _activeGoogleRoutePoints.length; i++) {
      final p = _activeGoogleRoutePoints[i];
      final d = calculateDistanceMeters(
        driverPos.latitude,
        driverPos.longitude,
        p.latitude,
        p.longitude,
      );

      if (d < minDistance) {
        minDistance = d;
        nearestIndex = i;
      }
    }

    // Trim only if driver is near route
    if (nearestIndex > 0 && minDistance < 80) {
      _activeGoogleRoutePoints = List<LatLng>.from(_activeGoogleRoutePoints.sublist(nearestIndex));

      final id = const PolylineId("poly");

      polyLines[id] = Polyline(
        polylineId: id,
        color: AppThemData.primary500,
        width: 5,
        geodesic: true,
        points: List<LatLng>.from(_activeGoogleRoutePoints),
      );

      developer.log(
        "✂️ Polyline trimmed → ${_activeGoogleRoutePoints.length} points",
      );

      update();
    }
  }

  bool isDriverDeviated(LatLng driverPos) {
    if (_activeGoogleRoutePoints.isEmpty) return false;

    double closestDistance = double.infinity;
    for (final p in _activeGoogleRoutePoints) {
      final d = calculateDistanceMeters(driverPos.latitude, driverPos.longitude, p.latitude, p.longitude);
      if (d < closestDistance) closestDistance = d;
    }
    return closestDistance > deviationDistance;
  }

  // -------------------- Marker Setup --------------------
  Future<void> addMarkerSetup() async {
    try {
      final departure = await Constant().getBytesFromAsset('assets/icon/ic_pick_up_map.png', 100);
      final destination = await Constant().getBytesFromAsset('assets/icon/ic_drop_in_map.png', 100);
      final driver = await Constant().getBytesFromAsset('assets/icon/ic_car.png', 50);
      final stops = await Constant().getBytesFromAsset('assets/icon/ic_stop_icon_map.png', 100);

      departureIcon = BitmapDescriptor.fromBytes(departure);
      destinationIcon = BitmapDescriptor.fromBytes(destination);
      driverIcon = BitmapDescriptor.fromBytes(driver);
      stopIcon = BitmapDescriptor.fromBytes(stops);
    } catch (e, stack) {
      developer.log("Error in addMarkerSetup", error: e, stackTrace: stack);
      ShowToastDialog.showToast("${"Failed to load marker icons:".tr} $e");
    }
  }

  // -------------------- Google Map Helpers --------------------
  void _updateGoogleMarkers(LocationLatLng pickup, LocationLatLng drop, LocationLatLng? driver) {
    markers.clear();
    if (intercityModel.value.bookingStatus == BookingStatus.bookingPlaced ||
        intercityModel.value.bookingStatus == BookingStatus.driverAssigned ||
        intercityModel.value.bookingStatus == BookingStatus.bookingAccepted) {
      markers['pickup'] = Marker(
        markerId: const MarkerId('pickup'),
        position: LatLng(pickup.latitude!, pickup.longitude!),
        icon: departureIcon!,
      );
    }

    if (intercityModel.value.bookingStatus == BookingStatus.bookingPlaced ||
        intercityModel.value.bookingStatus == BookingStatus.driverAssigned ||
        intercityModel.value.bookingStatus == BookingStatus.bookingOngoing ||
        intercityModel.value.bookingStatus == BookingStatus.bookingOnHold) {
      markers['drop'] = Marker(
        markerId: const MarkerId('drop'),
        position: LatLng(drop.latitude!, drop.longitude!),
        icon: destinationIcon!,
      );
    }

    if (driver != null) {
      markers['driver'] = Marker(
        markerId: const MarkerId('driver'),
        position: LatLng(driver.latitude!, driver.longitude!),
        icon: driverIcon!,
        anchor: const Offset(0.5, 0.5),
      );
    }
    final stops = intercityModel.value.stops ?? [];
    for (int i = 0; i < stops.length; i++) {
      final stop = stops[i].location;
      if (stop == null) continue;

      markers['stop_$i'] = Marker(
        markerId: MarkerId('stop_$i'),
        position: LatLng(stop.latitude!, stop.longitude!),
        icon: stopIcon!,
      );
    }

    update();
  }

  void addPolyLine(List<LatLng> polylineCoordinates) {
    if (polylineCoordinates.length < 2) return;

    final id = const PolylineId("poly");

    polyLines[id] = Polyline(
      polylineId: id,
      color: AppThemData.primary500,
      width: 5,
      geodesic: true,
      points: List<LatLng>.from(polylineCoordinates), // IMPORTANT
    );

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

  Future<void> _animateGoogleDriverMarker(LatLng from, LatLng to, {int steps = 8, Duration duration = const Duration(milliseconds: 600)}) async {
    _markerAnimId++;
    final int animId = _markerAnimId;
    final double latStep = (to.latitude - from.latitude) / steps;
    final double lngStep = (to.longitude - from.longitude) / steps;
    final int stepDelay = (duration.inMilliseconds / steps).round();

    for (int i = 1; i <= steps; i++) {
      if (animId != _markerAnimId) return;
      final LatLng pos = LatLng(from.latitude + latStep * i, from.longitude + lngStep * i);
      markers['driver'] = Marker(markerId: const MarkerId('driver'), position: pos, icon: driverIcon ?? BitmapDescriptor.defaultMarker, anchor: const Offset(0.5, 0.5));
      update();
      await Future.delayed(Duration(milliseconds: stepDelay));
    }

    _lastDriverPos = to;
  }

  void updateGoogleDriverMarker(LatLng pos) {
    final LatLng from = _lastDriverPos ?? pos;
    if (_lastDriverPos == null) {
      markers['driver'] = Marker(
        markerId: const MarkerId('driver'),
        position: pos,
        icon: driverIcon ?? BitmapDescriptor.defaultMarker,
        anchor: const Offset(0.5, 0.5),
      );
      _lastDriverPos = pos;
      update();
    } else {
      final distance = calculateDistanceMeters(from.latitude, from.longitude, pos.latitude, pos.longitude);
      if (distance < 2.0) {
        markers['driver'] = Marker(markerId: const MarkerId('driver'), position: pos, icon: driverIcon ?? BitmapDescriptor.defaultMarker, anchor: const Offset(0.5, 0.5));
        _lastDriverPos = pos;
        update();
      } else {
        _animateGoogleDriverMarker(from, pos, steps: (distance > 50 ? 20 : 8), duration: const Duration(milliseconds: 600));
      }
    }

    if (DateTime.now().difference(_lastCameraFollow) > cameraFollowThrottle) {
      _lastCameraFollow = DateTime.now();
      final zoom = _calculateZoomForRoute(pos);
      mapController?.animateCamera(CameraUpdate.newLatLngZoom(pos, zoom));
    }
  }

  double _calculateZoomForRoute(LatLng center) {
    if (_activeGoogleRoutePoints.length < 2) return 16.0;
    final first = _activeGoogleRoutePoints.first;
    final last = _activeGoogleRoutePoints.last;
    final dist = calculateDistanceMeters(first.latitude, first.longitude, last.latitude, last.longitude);

    if (dist > 50000) return 8.5;
    if (dist > 20000) return 10.5;
    if (dist > 10000) return 11.5;
    if (dist > 5000) return 12.5;
    if (dist > 2000) return 13.5;
    if (dist > 1000) return 14.5;
    if (dist > 500) return 15.5;
    return 16.5;
  }

  // -------------------- OSM Helpers --------------------
  void _updateOsmMarkers(LocationLatLng pickup, LocationLatLng drop, LocationLatLng? driverLocation) {
    osmMarkers.clear();

    // DRIVER
    if (driverLocation != null) {
      _setOSMMarker(
          key: ValueKey('driver'),
          point: latlang.LatLng(driverLocation.latitude!, driverLocation.longitude!),
          size: 50,
          child: Transform.rotate(
            angle: _osmRotationRadians(),
            child: Image.asset('assets/icon/ic_car.png'),
          ));
    }

    // PICKUP only before ride start
    if (intercityModel.value.bookingStatus == BookingStatus.bookingPlaced ||
        intercityModel.value.bookingStatus == BookingStatus.driverAssigned ||
        intercityModel.value.bookingStatus == BookingStatus.bookingAccepted) {
      _setOSMMarker(key: ValueKey('pickup'), point: latlang.LatLng(pickup.latitude!, pickup.longitude!), size: 40, child: Image.asset('assets/icon/ic_pick_up_map.png'));
    }

    // DROP only after ride starts
    if (intercityModel.value.bookingStatus == BookingStatus.bookingPlaced ||
        intercityModel.value.bookingStatus == BookingStatus.driverAssigned ||
        intercityModel.value.bookingStatus == BookingStatus.bookingOngoing ||
        intercityModel.value.bookingStatus == BookingStatus.bookingOnHold) {
      _setOSMMarker(key: ValueKey('drop'), point: latlang.LatLng(drop.latitude!, drop.longitude!), size: 40, child: Image.asset('assets/icon/ic_drop_in_map.png'));
    }

    final stops = intercityModel.value.stops ?? [];
    for (int i = 0; i < stops.length; i++) {
      final stop = stops[i].location;
      if (stop == null) continue;
      _setOSMMarker(key: ValueKey('stop_$i'), point: latlang.LatLng(stop.latitude!, stop.longitude!), size: 40, child: Image.asset('assets/icon/ic_stop_icon_map.png'));
    }
    update();
  }

  void _setOSMMarker({required ValueKey key, required latlang.LatLng point, required Widget child, double size = 30}) {
    final index = osmMarkers.indexWhere((m) => m.key == key);
    final marker = osm.Marker(key: key, point: point, width: size, height: size, child: child);
    if (index == -1) {
      osmMarkers.add(marker);
    } else {
      osmMarkers[index] = marker;
    }
  }

  double _osmRotationRadians() {
    final rotation = driverUserModel.value.rotation ?? 0.0;
    return rotation * (math.pi / 180);
  }

  Future<void> fetchOsmRoute(latlang.LatLng start, latlang.LatLng end, List<latlang.LatLng> waypoints) async {
    try {
      final waypointsStr = waypoints.map((e) => '${e.longitude},${e.latitude}').join(';');

      final url = 'https://router.project-osrm.org/route/v1/driving/'
          '${start.longitude},${start.latitude};'
          '${waypointsStr.isNotEmpty ? '$waypointsStr;' : ''}'
          '${end.longitude},${end.latitude}'
          '?overview=full&geometries=geojson';

      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final coords = data['routes'][0]['geometry']['coordinates'];

        final points = coords.map<latlang.LatLng>((c) => latlang.LatLng(c[1], c[0])).toList();

        osmRoute.value = points;
        _activeOSMRoutePoints = List.from(points);
      }
    } catch (e) {
      developer.log("get OSM Polyline error: $e");
      osmRoute.clear();
    }
  }

  Future<void> _getOsmDirections() async {
    try {
      final driverLoc = driverUserModel.value.location;
      final pickup = intercityModel.value.pickUpLocation;
      final drop = intercityModel.value.dropLocation;
      List stops = [];
      if (intercityModel.value.bookingStatus != BookingStatus.bookingAccepted) {
        stops = intercityModel.value.stops ?? [];
      }

      if (pickup == null || drop == null) return;

      late latlang.LatLng origin;
      late latlang.LatLng destination;

      /// ---------------- STATUS HANDLING ----------------
      if (intercityModel.value.bookingStatus == BookingStatus.bookingPlaced || intercityModel.value.bookingStatus == BookingStatus.driverAssigned) {
        origin = latlang.LatLng(pickup.latitude!, pickup.longitude!);
        destination = latlang.LatLng(drop.latitude!, drop.longitude!);
      } else if (intercityModel.value.bookingStatus == BookingStatus.bookingAccepted) {
        if (driverLoc == null) return;
        origin = latlang.LatLng(driverLoc.latitude!, driverLoc.longitude!);
        destination = latlang.LatLng(pickup.latitude!, pickup.longitude!);
      } else if (intercityModel.value.bookingStatus == BookingStatus.bookingOngoing || intercityModel.value.bookingStatus == BookingStatus.bookingOnHold) {
        if (driverLoc == null) return;

        origin = latlang.LatLng(driverLoc.latitude!, driverLoc.longitude!);
        destination = latlang.LatLng(drop.latitude!, drop.longitude!);
      } else {
        return;
      }
      _updateOsmMarkers(pickup, drop, driverLoc);

      if (_activeOSMRoutePoints.isNotEmpty) {
        final deviated = isDriverDeviatedFromOSMRoute(latlang.LatLng(driverLoc!.latitude!, driverLoc.longitude!));

        if (deviated && DateTime.now().difference(_lastOSMReroute) > osmRerouteCooldown) {
          _lastOSMReroute = DateTime.now();
          await fetchOsmRoute(origin, destination, stops.map((e) => latlang.LatLng(e.location!.latitude!, e.location!.longitude!)).toList());
        } else {
          trimOSMPolylineByDriver(latlang.LatLng(driverLoc.latitude!, driverLoc.longitude!));
        }
      } else {
        await fetchOsmRoute(origin, destination, stops.map((e) => latlang.LatLng(e.location!.latitude!, e.location!.longitude!)).toList());
      }

      if (DateTime.now().difference(_lastCameraMove) > cameraThrottle) {
        _lastCameraMove = DateTime.now();
        osmMapController.move(origin, osmMapController.camera.zoom);
      }
      updateEtaOsmMap();
      update();
    } catch (e) {
      if (kDebugMode) {
        print("❌ OSM direction error: $e");
      }
    }
  }

  bool isDriverDeviatedFromOSMRoute(latlang.LatLng driverPos) {
    double minDist = double.infinity;
    for (final p in _activeOSMRoutePoints) {
      final d = const latlang.Distance().as(latlang.LengthUnit.Meter, driverPos, p);
      if (d < minDist) minDist = d;
    }
    return minDist > osmDeviationDistance;
  }

  void trimOSMPolylineByDriver(latlang.LatLng driverPos) {
    if (_activeOSMRoutePoints.length < 2) return;

    int nearestIndex = 0;
    double minDist = double.infinity;

    for (int i = 0; i < _activeOSMRoutePoints.length; i++) {
      final d = const latlang.Distance().as(latlang.LengthUnit.Meter, driverPos, _activeOSMRoutePoints[i]);
      if (d < minDist) {
        minDist = d;
        nearestIndex = i;
      }
    }

    if (nearestIndex > 0 && minDist < 70) {
      _activeOSMRoutePoints = _activeOSMRoutePoints.sublist(nearestIndex);
      osmRoute.value = List.from(_activeOSMRoutePoints);
    }
  }

  double _deg2rad(double deg) => deg * (math.pi / 180);

  double calculateDistanceMeters(double lat1, double lon1, double lat2, double lon2) {
    const double R = 6371000;
    final double dLat = _deg2rad(lat2 - lat1);
    final double dLon = _deg2rad(lon2 - lon1);
    final double a = math.sin(dLat / 2) * math.sin(dLat / 2) + math.cos(_deg2rad(lat1)) * math.cos(_deg2rad(lat2)) * math.sin(dLon / 2) * math.sin(dLon / 2);
    final double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    final double d = R * c;
    return d;
  }

  List<LatLng> _rdpSimplify(List<LatLng> points, double epsilonMeters) {
    if (points.length < 3) return points;

    int index = -1;
    double maxDist = 0.0;

    for (int i = 1; i < points.length - 1; i++) {
      final d = _perpendicularDistanceMeters(points[i], points.first, points.last);
      if (d > maxDist) {
        index = i;
        maxDist = d;
      }
    }

    if (maxDist > epsilonMeters) {
      final List<LatLng> res1 = _rdpSimplify(points.sublist(0, index + 1), epsilonMeters);
      final List<LatLng> res2 = _rdpSimplify(points.sublist(index, points.length), epsilonMeters);
      return [...res1.sublist(0, res1.length - 1), ...res2];
    } else {
      return [points.first, points.last];
    }
  }

  List<LatLng> _densify(List<LatLng> points, double maxSegmentLengthMeters) {
    if (points.length < 2) return points;
    final List<LatLng> out = [];

    for (int i = 0; i < points.length - 1; i++) {
      final a = points[i];
      final b = points[i + 1];
      out.add(a);
      final dist = calculateDistanceMeters(a.latitude, a.longitude, b.latitude, b.longitude);
      if (dist > maxSegmentLengthMeters) {
        final int steps = (dist / maxSegmentLengthMeters).ceil();
        for (int s = 1; s < steps; s++) {
          final double t = s / steps;
          final double lat = a.latitude + (b.latitude - a.latitude) * t;
          final double lng = a.longitude + (b.longitude - a.longitude) * t;
          out.add(LatLng(lat, lng));
        }
      }
    }
    out.add(points.last);
    return out;
  }

  double _perpendicularDistanceMeters(LatLng p, LatLng a, LatLng b) {
    if (a.latitude == b.latitude && a.longitude == b.longitude) {
      return calculateDistanceMeters(p.latitude, p.longitude, a.latitude, a.longitude);
    }

    final double A = p.latitude - a.latitude;
    final double B = p.longitude - a.longitude;
    final double C = b.latitude - a.latitude;
    final double D = b.longitude - a.longitude;

    final double dot = A * C + B * D;
    final double lenSq = C * C + D * D;
    final double param = lenSq != 0 ? (dot / lenSq) : -1.0;

    double xx, yy;

    if (param < 0) {
      xx = a.latitude;
      yy = a.longitude;
    } else if (param > 1) {
      xx = b.latitude;
      yy = b.longitude;
    } else {
      xx = a.latitude + param * C;
      yy = a.longitude + param * D;
    }

    return calculateDistanceMeters(p.latitude, p.longitude, xx, yy);
  }

// ------------------ ETA UPDATES ------------------
  void updateEtaGoogleMap() {
    if (_activeGoogleRoutePoints.length < 2) return;

    final now = DateTime.now();
    if (lastUpdateTimeGoogle != null && now.difference(lastUpdateTimeGoogle!) < etaUpdateThrottle) {
      return;
    }
    lastUpdateTimeGoogle = now;

    double remainingDistance = 0;

    for (int i = 0; i < _activeGoogleRoutePoints.length - 1; i++) {
      remainingDistance += calculateDistanceMeters(
        _activeGoogleRoutePoints[i].latitude,
        _activeGoogleRoutePoints[i].longitude,
        _activeGoogleRoutePoints[i + 1].latitude,
        _activeGoogleRoutePoints[i + 1].longitude,
      );
    }

    if (remainingDistance < 30) {
      etaInMinutes.value = 1;
      return;
    }

    final newEta = calculateUniversalEta(remainingDistance);

    etaInMinutes.value = etaInMinutes.value == 0 ? newEta : smoothEta(etaInMinutes.value, newEta);

    developer.log(
      "🟢 GOOGLE ETA | ${(remainingDistance / 1000).toStringAsFixed(2)} km | ${etaInMinutes.value} min",
    );
  }

  void updateEtaOsmMap() {
    if (_activeOSMRoutePoints.length < 2) return;

    final now = DateTime.now();
    if (lastUpdateTimeOSM != null && now.difference(lastUpdateTimeOSM!) < etaUpdateThrottle) {
      return;
    }
    lastUpdateTimeOSM = now;

    double remainingDistance = 0;

    for (int i = 0; i < _activeOSMRoutePoints.length - 1; i++) {
      remainingDistance += const latlang.Distance().as(
        latlang.LengthUnit.Meter,
        _activeOSMRoutePoints[i],
        _activeOSMRoutePoints[i + 1],
      );
    }

    if (remainingDistance < 30) {
      etaInMinutes.value = 1;
      return;
    }

    final newEta = calculateUniversalEta(remainingDistance);

    etaInMinutes.value = etaInMinutes.value == 0 ? newEta : smoothEta(etaInMinutes.value, newEta);
  }

  int calculateUniversalEta(double distanceMeters) {
    final km = distanceMeters / 1000;

    double speedKmh;
    if (km >= 20) {
      speedKmh = 42;
    } else if (km >= 10) {
      speedKmh = 32;
    } else if (km >= 5) {
      speedKmh = 24;
    } else {
      speedKmh = 18;
    }

    final hour = DateTime.now().hour;
    double traffic = 1.15;

    if (hour >= 8 && hour <= 10) traffic = 1.35;
    if (hour >= 17 && hour <= 20) traffic = 1.40;
    if (hour >= 22 || hour <= 5) traffic = 0.85;

    final eta = (km / (speedKmh / traffic) * 60).round();
    return eta.clamp(1, 180);
  }

  int smoothEta(int oldEta, int newEta) {
    if (oldEta == 0) return newEta;

    if ((newEta - oldEta).abs() > 3) {
      return oldEta + (newEta > oldEta ? 1 : -1);
    }
    return newEta;
  }

  Future<void> openGoogleMap() async {
    ShowToastDialog.showLoader('Please Wait..'.tr);
    try {
      String googleMapsUrl = "";

      if (intercityModel.value.bookingStatus == BookingStatus.bookingPlaced ||
          intercityModel.value.bookingStatus == BookingStatus.bookingAccepted ||
          intercityModel.value.bookingStatus == BookingStatus.driverAssigned) {
        googleMapsUrl =
            "https://www.google.com/maps/dir/?api=1&origin=${driverUserModel.value.location!.latitude},${driverUserModel.value.location!.longitude}&destination=${intercityModel.value.pickUpLocation!.latitude},${intercityModel.value.pickUpLocation!.longitude}&travelmode=driving";
      } else if (intercityModel.value.bookingStatus == BookingStatus.bookingOngoing || intercityModel.value.bookingStatus == BookingStatus.bookingOnHold) {
        googleMapsUrl =
            "https://www.google.com/maps/dir/?api=1&origin=${driverUserModel.value.location!.latitude},${driverUserModel.value.location!.longitude}&destination=${intercityModel.value.dropLocation!.latitude},${intercityModel.value.dropLocation!.longitude}&travelmode=driving";
      }

      final uri = Uri.parse(googleMapsUrl);
      if (await canLaunchUrl(uri)) {
        ShowToastDialog.closeLoader();
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        throw 'Could not launch $googleMapsUrl';
      }
    } catch (e, stack) {
      developer.log("Error in openGoogleMaps", error: e, stackTrace: stack);
      ShowToastDialog.closeLoader();
    }
  }

  @override
  void onClose() {
    _bookingSub?.cancel();
    _driverSub?.cancel();
    super.onClose();
  }
}
