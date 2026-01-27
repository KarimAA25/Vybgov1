// ignore_for_file: unnecessary_overrides, depend_on_referenced_packages, deprecated_member_use

import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:math' as math;

import 'package:customer/app/models/banner_model.dart';
import 'package:customer/app/models/booking_model.dart';
import 'package:customer/app/models/driver_user_model.dart';
import 'package:customer/app/models/location_lat_lng.dart';
import 'package:customer/app/models/time_slots_charges_model.dart';
import 'package:customer/app/models/user_model.dart';
import 'package:customer/constant/booking_status.dart';
import 'package:customer/constant/collection_name.dart';
import 'package:customer/constant/constant.dart';
import 'package:customer/constant_widgets/custom_dialog_box.dart';
import 'package:customer/constant_widgets/show_toast_dialog.dart';
import 'package:customer/theme/app_them_data.dart';
import 'package:customer/utils/fire_store_utils.dart';
import 'package:customer/utils/notification_service.dart';
import 'package:customer/utils/utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:location/location.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_map/flutter_map.dart' as osm;
import 'package:latlong2/latlong.dart' as latlang;

class HomeController extends GetxController {
  final count = 0.obs;
  RxString profilePic = "https://firebasestorage.googleapis.com/v0/b/mytaxi-a8627.appspot.com/o/constant_assets%2F59.png?alt=media&token=a0b1aebd-9c01-45f6-9569-240c4bc08e23".obs;
  RxString name = ''.obs;
  RxString phoneNumber = ''.obs;
  RxList<BannerModel> bannerList = <BannerModel>[].obs;
  RxList<BookingModel> bookingList = <BookingModel>[].obs;
  PageController pageController = PageController();
  RxInt curPage = 0.obs;
  RxInt drawerIndex = 0.obs;
  RxBool isLoading = false.obs;

  LocationLatLng? currentLocation;

  RxList<TimeSlotsChargesModel> parcelDocuments = <TimeSlotsChargesModel>[].obs;
  RxList<TimeSlotsChargesModel> intercitySharingDocuments = <TimeSlotsChargesModel>[].obs;
  RxList<TimeSlotsChargesModel> intercityPersonalDocuments = <TimeSlotsChargesModel>[].obs;

  Rx<BookingModel> bookingModel = BookingModel().obs;
  Rx<DriverUserModel> driverUserModel = DriverUserModel().obs;
  Rx<UserModel> userModel = UserModel().obs;

  BitmapDescriptor? departureIcon;
  BitmapDescriptor? destinationIcon;
  BitmapDescriptor? driverIcon;
  BitmapDescriptor? stopIcon;

  /// Google Map
  GoogleMapController? googleMapController;
  RxMap<PolylineId, Polyline> googlePolylines = <PolylineId, Polyline>{}.obs;
  List<LatLng> _activeGoogleRoutePoints = [];
  Rx<PolylinePoints> googlePolylinePoints = PolylinePoints(apiKey: Constant.mapAPIKey).obs;
  RxMap<String, Marker> googleMarkers = <String, Marker>{}.obs;

  /// OSM MAP
  osm.MapController osmMapController = osm.MapController();
  RxList<osm.Marker> osmMarkers = <osm.Marker>[].obs;
  RxList<latlang.LatLng> osmRoute = <latlang.LatLng>[].obs;
  final Duration osmCameraFollowThrottle = const Duration(milliseconds: 200);
  List<latlang.LatLng> _activeOSMRoutePoints = [];

  final double deviationDistance = 120;
  final Duration rerouteCooldown = const Duration(minutes: 2);

  // ------------------ ETA CALCULATION ------------------
  RxInt etaInMinutes = 0.obs;
  LatLng? lastDriverLocationGoogle;
  latlang.LatLng? lastDriverLocationOSM;
  DateTime? lastUpdateTimeGoogle;
  DateTime? lastUpdateTimeOSM;

  final Duration etaUpdateThrottle = const Duration(seconds: 5);

  double googleTotalRouteDistance = 0; // meters
  double osmTotalRouteDistance = 0; // meters

  String? _lastBookingStatus;
  DateTime _lastRerouteTime = DateTime.fromMillisecondsSinceEpoch(0);
  LatLng? _lastDriverPos;
  int _markerAnimId = 0;
  String? _cachedRouteHash;
  DateTime? _cachedRouteTime;
  List<LatLng>? _cachedPolylineCoordinates;
  final Duration cachedRouteTTL = const Duration(minutes: 20);

  final double osmDeviationDistance = 120;
  DateTime _lastOSMReroute = DateTime.fromMillisecondsSinceEpoch(0);
  final Duration osmRerouteCooldown = const Duration(seconds: 20);
  DateTime _lastCameraMove = DateTime.fromMillisecondsSinceEpoch(0);
  final Duration cameraThrottle = const Duration(milliseconds: 300);

  DateTime _lastCameraFollow = DateTime.fromMillisecondsSinceEpoch(0);
  final Duration cameraFollowThrottle = const Duration(milliseconds: 250);

  StreamSubscription? _userSub;
  StreamSubscription? _bookingSub;
  StreamSubscription? _driverSub;

  bool get hasActiveRide {
    return Constant.userModel!.activeRideId != null &&
        Constant.userModel!.activeRideId!.isNotEmpty &&
        (bookingModel.value.bookingStatus == BookingStatus.bookingPlaced ||
            bookingModel.value.bookingStatus == BookingStatus.driverAssigned ||
            bookingModel.value.bookingStatus == BookingStatus.bookingAccepted ||
            bookingModel.value.bookingStatus == BookingStatus.bookingOngoing ||
            bookingModel.value.bookingStatus == BookingStatus.bookingOnHold);
  }

  @override
  void onInit() {
    getUserData();
    addMarkerSetup();
    super.onInit();
  }

  Future<void> getUserData() async {
    isLoading.value = true;
    final fcmFuture = NotificationService.getToken();
    FireStoreUtils.fireStore.collection(CollectionName.users).doc(FireStoreUtils.getCurrentUid()).snapshots().listen(
      (event) async {
        if (!event.exists) return;
        userModel.value = UserModel.fromJson(event.data()!);
        profilePic.value = (userModel.value.profilePic ?? "").isNotEmpty
            ? userModel.value.profilePic ??
                "https://firebasestorage.googleapis.com/v0/b/mytaxi-a8627.appspot.com/o/constant_assets%2F59.png?alt=media&token=a0b1aebd-9c01-45f6-9569-240c4bc08e23"
            : "https://firebasestorage.googleapis.com/v0/b/mytaxi-a8627.appspot.com/o/constant_assets%2F59.png?alt=media&token=a0b1aebd-9c01-45f6-9569-240c4bc08e23";
        name.value = userModel.value.fullName ?? '';
        phoneNumber.value = (userModel.value.countryCode ?? '') + (userModel.value.phoneNumber ?? '');
        final fcmToken = await fcmFuture;
        userModel.value.fcmToken = fcmToken;
        await FireStoreUtils.updateUser(userModel.value);
      },
    );
    await checkActiveStatus();
    final results = await Future.wait([
      FireStoreUtils.getBannerList(),
      FireStoreUtils.fetchIntercityService(),
    ]);
    final banners = results[0] as List<BannerModel>?;
    bannerList.value = banners ?? [];
    final intercityMap = results[1] as Map<String, List<TimeSlotsChargesModel>>;
    intercityPersonalDocuments.value = intercityMap["intercity"] ?? [];
    intercitySharingDocuments.value = intercityMap["intercity_sharing"] ?? [];
    parcelDocuments.value = intercityMap["parcel"] ?? [];
    if (Constant.isHomeFeatureEnable == true) {
      updateCurrentLocation();
      getActiveRide();
    }
    getOngoingBooking();
    isLoading.value = false;
  }

  void getActiveRide() {
    // 🔥 Cancel old listeners
    _userSub?.cancel();
    _bookingSub?.cancel();
    _driverSub?.cancel();

    _userSub = FireStoreUtils.fireStore.collection(CollectionName.users).doc(FireStoreUtils.getCurrentUid()).snapshots().listen((userSnap) {
      if (!userSnap.exists) return;

      userModel.value = UserModel.fromJson(userSnap.data()!);

      final activeRideId = userModel.value.activeRideId;
      if (activeRideId == null || activeRideId.isEmpty) return;

      // ---------------- BOOKING LISTENER ----------------
      _bookingSub?.cancel();
      _bookingSub = FirebaseFirestore.instance.collection(CollectionName.bookings).doc(activeRideId).snapshots().listen((bookingSnap) async {
        if (!bookingSnap.exists) return;

        bookingModel.value = BookingModel.fromJson(bookingSnap.data()!);

        // ---------------- STATUS CHANGE RESET ----------------
        final statusChanged = _lastBookingStatus != bookingModel.value.bookingStatus;

        if (statusChanged) {
          _lastBookingStatus = bookingModel.value.bookingStatus;

          if (Constant.selectedMap == "Google Map") {
            _activeGoogleRoutePoints.clear();
            googlePolylines.clear();
          } else {
            osmMarkers.clear();
            osmRoute.clear();
            _activeOSMRoutePoints.clear();
            _lastOSMReroute = DateTime.fromMillisecondsSinceEpoch(0);
          }
          update();
        }

        // ---------------- RIDE COMPLETED ----------------
        if (bookingModel.value.bookingStatus == BookingStatus.bookingCompleted) {
          _driverSub?.cancel();
          resetMapAfterRideEnd();
          update();
          return;
        }

        final driverId = bookingModel.value.driverId;
        if (driverId == null || driverId.isEmpty) return;

        // ---------------- DRIVER LISTENER ----------------
        _driverSub?.cancel();
        _driverSub = FirebaseFirestore.instance.collection(CollectionName.drivers).doc(driverId).snapshots().listen((driverSnap) async {
          print("driversanp");
          if (!driverSnap.exists) return;

          driverUserModel.value = DriverUserModel.fromJson(driverSnap.data()!);

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
              googlePolylines.clear();
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
        });
      });
    });
  }

  void getOngoingBooking() {
    FireStoreUtils.fireStore
        .collection(CollectionName.bookings)
        .where('bookingStatus',
            whereIn: [BookingStatus.bookingAccepted, BookingStatus.bookingPlaced, BookingStatus.bookingOngoing, BookingStatus.driverAssigned, BookingStatus.bookingOnHold])
        .where("customerId", isEqualTo: FireStoreUtils.getCurrentUid())
        .orderBy("createAt", descending: true)
        .snapshots()
        .listen((event) {
          bookingList.clear();
          bookingList.value = event.docs.map((doc) => BookingModel.fromJson(doc.data())).toList();
        });
  }

  Future<void> checkActiveStatus() async {
    if (userModel.value.isActive == false) {
      Get.defaultDialog(
        titlePadding: const EdgeInsets.only(top: 16),
        title: "Account Disabled".tr,
        middleText: "Your account has been disabled. Please contact the administrator.".tr,
        titleStyle: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
        barrierDismissible: false,
        onWillPop: () async {
          SystemNavigator.pop();
          return false;
        },
      );
    }
  }

  Location location = Location();

  Future<void> updateCurrentLocation() async {
    // final permissionStatus = await location.hasPermission();
    // if (permissionStatus == PermissionStatus.granted) {
    //   location.enableBackgroundMode(enable: false);
    //   location.changeSettings(
    //     accuracy: LocationAccuracy.high,
    //     distanceFilter: double.parse(Constant.driverLocationUpdate.toString()),
    //     interval: 10000,
    //   );
    //   location.onLocationChanged.listen((locationData) {
    //     developer.log("------>");
    //     developer.log(locationData.toString());
    //     Constant.currentLocation = LocationLatLng(latitude: locationData.latitude, longitude: locationData.longitude);
    //   });
    // } else {
    //   location.requestPermission().then((permissionStatus) {
    //     if (permissionStatus == PermissionStatus.granted) {
    //       location.enableBackgroundMode(enable: false);
    //       location.changeSettings(accuracy: LocationAccuracy.high, distanceFilter: double.parse(Constant.driverLocationUpdate.toString()), interval: 10000);
    //       location.onLocationChanged.listen((locationData) async {
    //         Constant.currentLocation = LocationLatLng(latitude: locationData.latitude, longitude: locationData.longitude);
    //       });
    //     }
    //   });
    // }

    final position = await Utils.getCurrentLocation();

    if (position != null) {
      currentLocation = LocationLatLng(
        latitude: position.latitude,
        longitude: position.longitude,
      );

      // If map already created → move camera
      if (Constant.selectedMap == " Google Map") {
        if (googleMapController != null) {
          googleMapController!.animateCamera(
            CameraUpdate.newCameraPosition(
              CameraPosition(
                target: LatLng(currentLocation!.latitude!, currentLocation!.longitude!),
                zoom: 16,
              ),
            ),
          );
        }
      } else {
        osmMapController.move(
          latlang.LatLng(currentLocation!.latitude!, currentLocation!.longitude!),
          16,
        );
      }
    }

    update();
  }

  /// Marker Setup
  Future<void> addMarkerSetup() async {
    try {
      final departure = await Constant().getBytesFromAsset('assets/icon/ic_pick_up_map.png', 100);
      final destination = await Constant().getBytesFromAsset('assets/icon/ic_drop_in_map.png', 100);
      final driver = await Constant().getBytesFromAsset('assets/icon/ic_car.png', 60);
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

  /// Google-Map
  void addPolyLine(List<LatLng> polylineCoordinates) {
    if (polylineCoordinates.length < 2) return;

    final id = const PolylineId("poly");

    googlePolylines[id] = Polyline(
      polylineId: id,
      color: AppThemData.primary500,
      width: 5,
      geodesic: true,
      points: List<LatLng>.from(polylineCoordinates), // IMPORTANT
    );

    update();
  }

  Future<void> getDirections({bool forceReroute = false}) async {
    try {
      if (bookingModel.value.id == null) return;
      final driver = driverUserModel.value.location;
      final pickup = bookingModel.value.pickUpLocation;
      final drop = bookingModel.value.dropLocation;
      List stops = [];
      if (bookingModel.value.bookingStatus != BookingStatus.bookingAccepted) {
        stops = bookingModel.value.stops ?? [];
      }

      if (driver == null || pickup == null || drop == null) return;

      late PointLatLng origin;
      late PointLatLng destination;

      if (bookingModel.value.bookingStatus == BookingStatus.bookingPlaced || bookingModel.value.bookingStatus == BookingStatus.driverAssigned) {
        origin = PointLatLng(pickup.latitude!, pickup.longitude!);
        destination = PointLatLng(drop.latitude!, drop.longitude!);
      } else if (bookingModel.value.bookingStatus == BookingStatus.bookingAccepted) {
        origin = PointLatLng(driver.latitude!, driver.longitude!);
        destination = PointLatLng(pickup.latitude!, pickup.longitude!);
      } else if (bookingModel.value.bookingStatus == BookingStatus.bookingOngoing || bookingModel.value.bookingStatus == BookingStatus.bookingOnHold) {
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

      final result = await googlePolylinePoints.value.getRouteBetweenCoordinates(
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

  void _updateGoogleMarkers(LocationLatLng pickup, LocationLatLng drop, LocationLatLng? driver) {
    googleMarkers.clear();

    if (bookingModel.value.bookingStatus == BookingStatus.bookingPlaced ||
        bookingModel.value.bookingStatus == BookingStatus.driverAssigned ||
        bookingModel.value.bookingStatus == BookingStatus.bookingAccepted) {
      googleMarkers['pickup'] = Marker(
        markerId: const MarkerId('pickup'),
        position: LatLng(pickup.latitude!, pickup.longitude!),
        icon: departureIcon!,
      );
    }

    if (bookingModel.value.bookingStatus == BookingStatus.bookingPlaced ||
        bookingModel.value.bookingStatus == BookingStatus.driverAssigned ||
        bookingModel.value.bookingStatus == BookingStatus.bookingOngoing ||
        bookingModel.value.bookingStatus == BookingStatus.bookingOnHold) {
      googleMarkers['drop'] = Marker(
        markerId: const MarkerId('drop'),
        position: LatLng(drop.latitude!, drop.longitude!),
        icon: destinationIcon!,
      );
    }

    if (driver != null) {
      googleMarkers['driver'] = Marker(
        markerId: const MarkerId('driver'),
        position: LatLng(driver.latitude!, driver.longitude!),
        icon: driverIcon!,
        anchor: const Offset(0.5, 0.5),
      );
    }
    final stops = bookingModel.value.stops ?? [];
    for (int i = 0; i < stops.length; i++) {
      final stop = stops[i].location;
      if (stop == null) continue;

      googleMarkers['stop_$i'] = Marker(
        markerId: MarkerId('stop_$i'),
        position: LatLng(stop.latitude!, stop.longitude!),
        icon: stopIcon!,
      );
    }

    update();
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

      googlePolylines[id] = Polyline(
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

  void updateGoogleDriverMarker(LatLng pos) {
    final LatLng from = _lastDriverPos ?? pos;
    if (_lastDriverPos == null) {
      googleMarkers['driver'] = Marker(
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
        googleMarkers['driver'] = Marker(markerId: const MarkerId('driver'), position: pos, icon: driverIcon ?? BitmapDescriptor.defaultMarker, anchor: const Offset(0.5, 0.5));
        _lastDriverPos = pos;
        update();
      } else {
        _animateGoogleDriverMarker(from, pos, steps: (distance > 50 ? 20 : 8), duration: const Duration(milliseconds: 600));
      }
    }

    if (DateTime.now().difference(_lastCameraFollow) > cameraFollowThrottle) {
      _lastCameraFollow = DateTime.now();
      final zoom = _calculateZoomForRoute(pos);
      googleMapController?.animateCamera(CameraUpdate.newLatLngZoom(pos, zoom));
    }
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
      googleMarkers['driver'] = Marker(markerId: const MarkerId('driver'), position: pos, icon: driverIcon ?? BitmapDescriptor.defaultMarker, anchor: const Offset(0.5, 0.5));
      update();
      await Future.delayed(Duration(milliseconds: stepDelay));
    }

    _lastDriverPos = to;
  }

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

  /// OSM-Map
  Future<void> _getOsmDirections() async {
    try {
      final driverLoc = driverUserModel.value.location;
      final pickup = bookingModel.value.pickUpLocation;
      final drop = bookingModel.value.dropLocation;

      List stops = [];
      if (bookingModel.value.bookingStatus != BookingStatus.bookingAccepted) {
        stops = bookingModel.value.stops ?? [];
      }

      if (pickup == null || drop == null) return;

      late latlang.LatLng origin;
      late latlang.LatLng destination;

      /// ---------------- STATUS HANDLING ----------------
      if (bookingModel.value.bookingStatus == BookingStatus.bookingPlaced || bookingModel.value.bookingStatus == BookingStatus.driverAssigned) {
        origin = latlang.LatLng(pickup.latitude!, pickup.longitude!);
        destination = latlang.LatLng(drop.latitude!, drop.longitude!);
      } else if (bookingModel.value.bookingStatus == BookingStatus.bookingAccepted) {
        if (driverLoc == null) return;
        origin = latlang.LatLng(driverLoc.latitude!, driverLoc.longitude!);
        destination = latlang.LatLng(pickup.latitude!, pickup.longitude!);
      } else if (bookingModel.value.bookingStatus == BookingStatus.bookingOngoing || bookingModel.value.bookingStatus == BookingStatus.bookingOnHold) {
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

  void _updateOsmMarkers(LocationLatLng pickup, LocationLatLng drop, LocationLatLng? driverLocation) {
    osmMarkers.clear();

    if (driverLocation != null) {
      osmMarkers.add(osm.Marker(
        point: latlang.LatLng(driverLocation.latitude!, driverLocation.longitude!),
        width: 50,
        height: 50,
        child: Transform.rotate(
          angle: _osmRotationRadians(),
          child: Image.asset('assets/icon/ic_car.png'),
        ),
      ));
    }

    if (bookingModel.value.bookingStatus == BookingStatus.bookingPlaced ||
        bookingModel.value.bookingStatus == BookingStatus.driverAssigned ||
        bookingModel.value.bookingStatus == BookingStatus.bookingAccepted) {
      osmMarkers.add(osm.Marker(
        point: latlang.LatLng(pickup.latitude!, pickup.longitude!),
        width: 40,
        height: 40,
        child: Image.asset('assets/icon/ic_pick_up_map.png'),
      ));
    }

    if (bookingModel.value.bookingStatus == BookingStatus.bookingPlaced ||
        bookingModel.value.bookingStatus == BookingStatus.driverAssigned ||
        bookingModel.value.bookingStatus == BookingStatus.bookingOngoing ||
        bookingModel.value.bookingStatus == BookingStatus.bookingOnHold) {
      osmMarkers.add(osm.Marker(
        point: latlang.LatLng(drop.latitude!, drop.longitude!),
        width: 40,
        height: 40,
        child: Image.asset(
          'assets/icon/ic_drop_in_map.png',
        ),
      ));
    }

    if (bookingModel.value.stops != null) {
      for (var stop in bookingModel.value.stops!) {
        if (stop.location != null) {
          osmMarkers.add(osm.Marker(
            point: latlang.LatLng(stop.location!.latitude!, stop.location!.longitude!),
            width: 40,
            height: 40,
            child: Image.asset('assets/icon/ic_stop_icon_map.png'),
          ));
        }
      }
    }

    update();
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

  bool isDriverDeviatedFromOSMRoute(latlang.LatLng driverPos) {
    double minDist = double.infinity;
    for (final p in _activeOSMRoutePoints) {
      final d = const latlang.Distance().as(latlang.LengthUnit.Meter, driverPos, p);
      if (d < minDist) minDist = d;
    }
    return minDist > osmDeviationDistance;
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

  double calculateDistanceMeters(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const double R = 6371000;
    final dLat = _deg2rad(lat2 - lat1);
    final dLon = _deg2rad(lon2 - lon1);

    final a = math.sin(dLat / 2) * math.sin(dLat / 2) + math.cos(_deg2rad(lat1)) * math.cos(_deg2rad(lat2)) * math.sin(dLon / 2) * math.sin(dLon / 2);

    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return R * c;
  }

  double _deg2rad(double deg) => deg * (math.pi / 180);

  void resetMapAfterRideEnd() {
    /// -------- GOOGLE MAP --------
    googlePolylines.clear();
    googleMarkers.clear();

    /// -------- OSM MAP --------
    osmMarkers.clear();
    osmRoute.clear();

    /// -------- ETA --------
    etaInMinutes.value = 0;
    lastDriverLocationGoogle = null;
    lastDriverLocationOSM = null;
    lastUpdateTimeGoogle = null;
    lastUpdateTimeOSM = null;
    update();
  }

  /// Other
  Future<void> deleteUserAccount() async {
    try {
      FireStoreUtils.fireStore.collection(CollectionName.referral).where('userId', isEqualTo: FireStoreUtils.getCurrentUid()).get().then((value) {
        for (var doc in value.docs) {
          doc.reference.delete();
        }
      });

      await FirebaseFirestore.instance.collection(CollectionName.users).doc(FireStoreUtils.getCurrentUid()).delete();

      await FirebaseAuth.instance.currentUser!.delete();
    } on FirebaseAuthException catch (error) {
      developer.log("Firebase Auth Exception : $error");
    } catch (error) {
      developer.log("Error : $error");
    }
  }

  Future showActiveRideDialog(BuildContext context, themeChange) {
    return showDialog(
        context: context,
        builder: (context) {
          return Dialog(
            child: ActiveRideDialog(
              themeChange: themeChange,
            ),
          );
        });
  }

  @override
  void onClose() {
    _userSub?.cancel();
    _bookingSub?.cancel();
    _driverSub?.cancel();
    super.onClose();
  }
}
