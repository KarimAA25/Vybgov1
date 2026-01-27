// ignore_for_file: depend_on_referenced_packages, deprecated_member_use

import 'dart:core';
import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:math';
import 'package:customer/app/models/driver_user_model.dart';
import 'package:customer/app/models/zone_model.dart';
import 'package:customer/constant/collection_name.dart';
import 'package:customer/constant_widgets/osm_place_picker/osm_selected_location_model.dart';
import 'package:customer/constant_widgets/place_picker/selected_location_model.dart';
import 'package:customer/services/recent_location_search.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_map/flutter_map.dart' as osm;
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart' as latlang;
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geoflutterfire2/geoflutterfire2.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:customer/app/models/booking_model.dart';
import 'package:customer/app/models/coupon_model.dart';
import 'package:customer/app/models/distance_model.dart';
import 'package:customer/app/models/location_lat_lng.dart';
import 'package:customer/app/models/map_model.dart' as map;
import 'package:customer/app/models/positions.dart';
import 'package:customer/app/models/tax_model.dart';
import 'package:customer/app/models/vehicle_type_model.dart';
import 'package:customer/constant/booking_status.dart';
import 'package:customer/constant/constant.dart';
import 'package:customer/constant_widgets/show_toast_dialog.dart';
import 'package:customer/theme/app_them_data.dart';
import 'package:customer/utils/fire_store_utils.dart';
import 'package:customer/utils/utils.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SelectLocationController extends GetxController {
  FocusNode pickUpFocusNode = FocusNode();
  FocusNode dropFocusNode = FocusNode();
  TextEditingController dropLocationController = TextEditingController();
  TextEditingController pickupLocationController = TextEditingController(text: 'Current Location');
  RxList<TextEditingController> stopControllers = <TextEditingController>[].obs;
  RxList<LatLng?> stopsLatLng = <LatLng?>[].obs;
  RxList<FocusNode> stopFocusNodes = <FocusNode>[].obs;
  Position? currentLocationPosition;
  Rx<BookingModel> bookingModel = BookingModel().obs;

  StreamSubscription<DocumentSnapshot>? bookingSub;
  StreamSubscription<DocumentSnapshot>? driverSub;

  RxList<SelectedLocationModel> googleRecentSearches = <SelectedLocationModel>[].obs;
  RxList<OsmSelectedLocationModel> osmRecentSearches = <OsmSelectedLocationModel>[].obs;

  // ================= GOOGLE MAP =================
  GoogleMapController? mapController;
  RxMap<MarkerId, Marker> markers = <MarkerId, Marker>{}.obs;
  RxMap<PolylineId, Polyline> polyLines = <PolylineId, Polyline>{}.obs;

  PolylinePoints polylinePoints = PolylinePoints(apiKey: Constant.mapAPIKey);

  LatLng? sourceLocation;
  LatLng? destination;

  List<LatLng> _activeGoogleRoutePoints = [];
  bool _isGoogleRouteReady = false;
  bool _isFetchingGoogleRoute = false;

  DateTime _lastCameraFollow = DateTime.fromMillisecondsSinceEpoch(0);
  final Duration cameraFollowThrottle = const Duration(milliseconds: 250);

  DateTime _lastRouteBuild = DateTime.fromMillisecondsSinceEpoch(0);
  final Duration routeThrottle = const Duration(seconds: 30);
  final double routeDeviationThreshold = 120;

  // ================= OSM =================
  osm.MapController osmMapController = osm.MapController();
  RxList<osm.Marker> osmMarkers = <osm.Marker>[].obs;
  RxList<latlang.LatLng> osmRoute = <latlang.LatLng>[].obs;
  RxList<latlang.LatLng> osmPolyline = <latlang.LatLng>[].obs;

  latlang.LatLng? osmSourceLocation;
  latlang.LatLng? osmDestination;
  RxList<latlang.LatLng?> osmStopsLatLng = <latlang.LatLng?>[].obs;

  double osmTotalRouteDistance = 0;
  double googleTotalRouteDistance = 0;

  DateTime _lastOsmCameraFollow = DateTime.fromMillisecondsSinceEpoch(0);
  final Duration osmCameraFollowThrottle = const Duration(milliseconds: 250);

  // ================= ETA =================
  RxInt etaInMinutes = 0.obs;
  DateTime _lastEtaUpdate = DateTime.fromMillisecondsSinceEpoch(0);
  final Duration etaUpdateThrottle = const Duration(seconds: 5);

  BitmapDescriptor? pickUpIcon;
  BitmapDescriptor? dropIcon;
  BitmapDescriptor? stopIcon;
  BitmapDescriptor? driverIcon;

  RxBool isLoading = true.obs;
  RxInt popupIndex = 0.obs;
  Rx<map.MapModel> mapModel = map.MapModel().obs;
  Rx<DistanceModel> distanceOfKm = DistanceModel().obs;

  // RxDouble estimatePrice = 0.0.obs;

  RxString selectedPaymentMethod = 'Cash'.obs;
  RxString couponCode = "".obs;
  Rx<CouponModel> selectedCouponModel = CouponModel().obs;
  Rx<TextEditingController> couponCodeController = TextEditingController().obs;

  RxList<TaxModel> taxList = (Constant.taxList ?? []).obs;

  RxBool isCabAvailable = false.obs;

  RxList<VehicleTypeModel> vehicleTypeList = <VehicleTypeModel>[].obs;
  Rx<VehicleTypeModel> selectVehicleType = VehicleTypeModel().obs;

  RxList<ZoneModel> zoneList = <ZoneModel>[].obs;
  Rx<ZoneModel> selectedZone = ZoneModel().obs;

  RxBool isForFemale = false.obs;

  void changeVehicleType(VehicleTypeModel vehicle) {
    // CabTimeSlotModel? selectedCab;
    selectVehicleType.value = vehicle;
    calculateTotalAmount();
  }

  @override
  void onInit() {
    getData();
    getRecentSearches();
    pickupLocationController.addListener(() {
      getRecentSearches();
      update();
    });
    dropLocationController.addListener(() {
      getRecentSearches();
      update();
    });
    super.onInit();
  }

  Future<void> getRecentSearches() async {
    if (Constant.selectedMap == "Google Map") {
      googleRecentSearches.value = await RecentSearchLocation.getLocationFromHistory();
      developer.log("Google Recent Searches: ${googleRecentSearches.length}");
    } else {
      osmRecentSearches.value = await RecentSearchLocation.getOSMLocationFromHistory();
      developer.log("OSM Recent Searches: ${osmRecentSearches.length}");
    }
  }

  Future<void> getTax() async {
    await FireStoreUtils().getTaxList().then((value) {
      if (value != null) {
        Constant.taxList = value;
        taxList.value = value;
      }
    });
  }

  Future<void> getData() async {
    await FireStoreUtils.fetchAllCabServices().then(
      (value) {
        vehicleTypeList.value = value;
        if (vehicleTypeList.isNotEmpty) {
          selectVehicleType.value = vehicleTypeList.first;
          calculateTotalAmount();
        }
      },
    );

    await FireStoreUtils.getActiveZones().then(
      (value) {
        if (value != null) {
          zoneList.value = value;
        }
      },
    );
    currentLocationPosition = await Utils.getCurrentLocation();
    Constant.country = (await placemarkFromCoordinates(currentLocationPosition!.latitude, currentLocationPosition!.longitude))[0].country ?? 'Unknown';
    getTax();
    if (Constant.selectedMap == "Google Map") {
      sourceLocation = LatLng(currentLocationPosition!.latitude, currentLocationPosition!.longitude);
    } else {
      osmSourceLocation = latlang.LatLng(currentLocationPosition!.latitude, currentLocationPosition!.longitude);
      if (osmSourceLocation == null) return;
      osmMarkers.value = [
        osm.Marker(
          point: osmSourceLocation!,
          width: 40,
          height: 40,
          child: Image.asset('assets/icon/ic_pick_up_map.png'),
        ),
      ];
    }

    await addMarkerSetup();
    if (destination != null && sourceLocation != null) {
      getPolyline(
          sourceLatitude: sourceLocation!.latitude,
          sourceLongitude: sourceLocation!.longitude,
          destinationLatitude: destination!.latitude,
          destinationLongitude: destination!.longitude);
    } else {
      if (destination != null) {
        addMarker(latitude: destination!.latitude, longitude: destination!.longitude, id: "drop", descriptor: dropIcon!, rotation: 0.0);
        updateCameraLocation(destination!, destination!, mapController);
      } else {
        MarkerId markerId = const MarkerId("drop");
        if (markers.containsKey(markerId)) {
          markers.removeWhere((key, value) => key == markerId);
        }
        developer.log("==> ${markers.containsKey(markerId)}");
      }
      if (sourceLocation != null) {
        addMarker(latitude: sourceLocation!.latitude, longitude: sourceLocation!.longitude, id: "pickUp", descriptor: pickUpIcon!, rotation: 0.0);
        updateCameraLocation(sourceLocation!, sourceLocation!, mapController);
      } else {
        MarkerId markerId = const MarkerId("pickUp");
        if (markers.containsKey(markerId)) {
          markers.removeWhere((key, value) => key == markerId);
          updateCameraLocation(sourceLocation!, sourceLocation!, mapController);
        }
        developer.log("==> ${markers.containsKey(markerId)}");
      }
    }
    dropFocusNode.requestFocus();
    if (sourceLocation != null) {
      findZone();
    }
    isLoading.value = false;
  }

  void findZone() {
    for (final zone in zoneList) {
      if (isPointInPolygon(
        LatLng(sourceLocation!.latitude, sourceLocation!.longitude),
        zone.area!,
      )) {
        selectedZone.value = zone;
        return;
      }
    }
  }

  RxDouble subTotal = 0.0.obs;
  RxDouble discountAmount = 0.0.obs;
  RxDouble totalAmount = 0.0.obs;
  RxDouble nightCharges = 0.0.obs;

  void calculateTotalAmount() {
    double taxAmount = 0.0;
    subTotal.value = double.parse(getVehiclePrice(selectVehicleType.value));
    nightCharges.value = getNightCharge(selectVehicleType.value, subTotal.value);

    if (selectedCouponModel.value.id != null) {
      if (selectedCouponModel.value.isFix == true) {
        discountAmount.value = double.parse(selectedCouponModel.value.amount.toString());
      } else {
        discountAmount.value = (subTotal + nightCharges.value) * double.parse(selectedCouponModel.value.amount.toString()) / 100;
      }
    }
    for (var element in taxList) {
      taxAmount = taxAmount + Constant.calculateTax(amount: ((subTotal.value + nightCharges.value) - discountAmount.value).toString(), taxModel: element);
    }

    totalAmount.value = ((subTotal.value + nightCharges.value) - discountAmount.value) + taxAmount;
  }

  Rx<DriverUserModel> driverModel = DriverUserModel().obs;
  bool _googleRouteInitialized = false;
  bool _osmRouteInitialized = false;

  void getBooking(String bookingId) {
    if (bookingId.isEmpty) return;
    bookingSub?.cancel();

    bookingSub = FirebaseFirestore.instance.collection(CollectionName.bookings).doc(bookingId).snapshots().listen((event) {
      if (!event.exists) return;

      bookingModel.value = BookingModel.fromJson(event.data()!);

      if (bookingModel.value.bookingStatus == BookingStatus.bookingOngoing) {
        ShowToastDialog.showToast("Your ride started...".tr);
        Get.back();
      }
      if (bookingModel.value.driverId != null && bookingModel.value.bookingStatus == BookingStatus.bookingAccepted) {
        _listenDriver(bookingModel.value.driverId!);
        resetRouteState();
      }

      if (bookingModel.value.bookingStatus == BookingStatus.bookingCompleted || bookingModel.value.bookingStatus == BookingStatus.bookingCancelled) {
        stopLiveTracking();
        Get.back();
      }
    });
  }

  void _listenDriver(String driverId) {
    driverSub?.cancel();

    driverSub = FirebaseFirestore.instance.collection(CollectionName.drivers).doc(driverId).snapshots().listen(
      (driverSnap) {
        if (!driverSnap.exists) {
          return;
        }

        final data = driverSnap.data();
        driverModel.value = DriverUserModel.fromJson(data!);

        if (driverModel.value.location == null) {
          return;
        }

        developer.log(
            "${driverModel.value.location!.latitude}, "
            "${driverModel.value.location!.longitude}",
            name: "DRIVER");

        _handleDriverUpdate();
      },
      onError: (e) {
        developer.log("🔥 Driver listener error: $e", name: "DRIVER");
      },
    );
  }

  void _handleDriverUpdate() {
    final loc = driverModel.value.location;

    if (loc == null) {
      return;
    }

    final driverLatLng = LatLng(loc.latitude!, loc.longitude!);

    if (Constant.selectedMap == "Google Map") {
      _handleGoogleDriver(driverLatLng);
    } else {
      _handleOsmDriver(driverLatLng);
    }
  }

  Future<void> confirmBooking() async {
    ShowToastDialog.showLoader("Please wait...");

    // Initialize booking model
    BookingModel bookingModel = BookingModel();
    bookingModel.id = Constant.getUuid();
    bookingModel.createAt = Timestamp.now();
    bookingModel.updateAt = Timestamp.now();
    bookingModel.bookingTime = Timestamp.now();
    bookingModel.customerId = FireStoreUtils.getCurrentUid();
    bookingModel.bookingStatus = BookingStatus.bookingPlaced;

    // Map-specific source, destination, and stops
    LatLng? source;
    LatLng? dest;
    List<LatLng?> stops = [];

    if (Constant.selectedMap == "Google Map") {
      if (kDebugMode) {
        print("Google map Booking::::");
      }
      source = sourceLocation;
      dest = destination;
      stops = stopsLatLng;
      bookingModel.pickUpLocationAddress = pickupLocationController.value.text;
      bookingModel.dropLocationAddress = dropLocationController.value.text;
    } else {
      // OSM Map
      if (kDebugMode) {
        print("OSM map Booking::::");
      }

      if (osmSourceLocation != null && osmDestination != null) {
        source = LatLng(osmSourceLocation!.latitude, osmSourceLocation!.longitude);
        dest = LatLng(osmDestination!.latitude, osmDestination!.longitude);

        stops = osmStopsLatLng.map((e) => e != null ? LatLng(e.latitude, e.longitude) : null).toList();
        bookingModel.pickUpLocationAddress = await getOSMAddress(osmSourceLocation!);
        bookingModel.dropLocationAddress = dropLocationController.value.text;
      }
    }

    // Safety check
    if (source == null || dest == null) {
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast("Please select both source and destination locations");
      return;
    }

    // Set locations
    bookingModel.pickUpLocation = LocationLatLng(latitude: source.latitude, longitude: source.longitude);
    bookingModel.dropLocation = LocationLatLng(latitude: dest.latitude, longitude: dest.longitude);

    GeoFirePoint position = GeoFlutterFire().point(latitude: source.latitude, longitude: source.longitude);
    bookingModel.position = Positions(geoPoint: position.geoPoint, geohash: position.hash);

    bookingModel.distance = DistanceModel(
      distance: distanceCalculate(mapModel.value),
      distanceType: Constant.distanceType,
    );
    bookingModel.vehicleType = selectVehicleType.value;
    bookingModel.subTotal = subTotal.value.toString();
    bookingModel.nightCharge = nightCharges.value.toString();
    bookingModel.minuteCharges = getMinuteCharge(selectVehicleType.value);
    bookingModel.discount = discountAmount.value.toString();
    bookingModel.coupon = selectedCouponModel.value;
    bookingModel.otp = Constant.isOtpFeatureEnable == true ? Constant.getOTPCode() : "";
    bookingModel.isOnlyForFemale = isForFemale.value;
    bookingModel.paymentType = selectedPaymentMethod.value;
    bookingModel.paymentStatus = false;
    bookingModel.taxList = taxList;
    bookingModel.adminCommission = Constant.adminCommission;
    bookingModel.zoneModel = selectedZone.value;
    bookingModel.stops = [];
    for (int i = 0; i < stops.length; i++) {
      if (stops[i] != null && stopControllers[i].text.isNotEmpty) {
        bookingModel.stops!.add(
          StopModel(
            location: LocationLatLng(
              latitude: stops[i]!.latitude,
              longitude: stops[i]!.longitude,
            ),
            address: stopControllers[i].text,
          ),
        );
      }
    }

    await FireStoreUtils.setBooking(bookingModel).then((value) {
      ShowToastDialog.showToast("Ride Placed successfully".tr);
      ShowToastDialog.closeLoader();
      popupIndex.value = 2;
    });
    getBooking(bookingModel.id.toString());
    Constant.userModel!.activeRideId = bookingModel.id.toString();
    await FireStoreUtils.updateUser(Constant.userModel!);
  }

  Future<void> getCoupon() async {
    final code = couponCodeController.value.text;
    if (code.isEmpty) return;
    ShowToastDialog.showLoader("Please wait..".tr);
    try {
      final query = await FireStoreUtils.fireStore
          .collection(CollectionName.coupon)
          .where('code', isEqualTo: code)
          .where('active', isEqualTo: true)
          .where('expireAt', isGreaterThanOrEqualTo: Timestamp.now())
          .limit(1)
          .get();
      ShowToastDialog.closeLoader();
      if (query.docs.isNotEmpty) {
        selectedCouponModel.value = CouponModel.fromJson(query.docs.first.data());
        couponCodeController.value.text = selectedCouponModel.value.code!;
        calculateTotalAmount();
      } else {
        selectedCouponModel.value = CouponModel();
        ShowToastDialog.toast("Invalid or expired coupon code".tr);
      }
    } catch (e) {
      ShowToastDialog.closeLoader();
      ShowToastDialog.toast("Error fetching coupon".tr);
      developer.log(e.toString());
    }
    FocusScope.of(Get.context!).unfocus();
  }

  String getVehiclePrice(VehicleTypeModel model) {
    if (model.zoneCharges == null || model.zoneCharges!.isEmpty) {
      return "0.0";
    }

    ZoneChargesModel currentZoneCharge = model.zoneCharges!.firstWhere(
      (e) => e.zoneId == selectedZone.value.id,
      orElse: () => model.zoneCharges!.first,
    );

    Charges? charges = currentZoneCharge.charges;
    if (charges == null) return "0.0";

    final element = mapModel.value.rows?.first.elements?.first;
    if (element?.distance?.value == null) return "0.0";

    double meters = element!.distance!.value!.toDouble();

    double distance = Constant.distanceType == "Km" ? meters / 1000 : meters / 1609.34;

    double minimumDistance = double.tryParse(charges.fareMinimumChargesWithinKm ?? "0") ?? 0;

    double minimumFare = double.tryParse(charges.farMinimumCharges ?? "0") ?? 0;

    double perDistanceCharge = double.tryParse(charges.farePerKm ?? "0") ?? 0;

    double baseFare;

    if (distance <= minimumDistance) {
      baseFare = minimumFare;
    } else {
      baseFare = minimumFare + ((distance - minimumDistance) * perDistanceCharge);
    }

    double minuteCharge = double.parse(getMinuteCharge(model));

    double finalPrice = baseFare + minuteCharge;

    return finalPrice.toStringAsFixed(Constant.currencyModel!.decimalDigits!);
  }

  double getNightCharge(VehicleTypeModel model, double baseFare) {
    ZoneChargesModel? currentZoneCharge = model.zoneCharges!.firstWhere(
      (element) => element.zoneId == selectedZone.value.id,
      orElse: () => model.zoneCharges!.first,
    );

    Charges? charges = currentZoneCharge.charges;
    if (charges == null) return 0.0;

    // Get Night Timing from Constant
    final nightTiming = Constant.nightTimingModel;
    if (nightTiming == null) return 0.0;

    try {
      List<String> startParts = nightTiming.startTime!.split(":");
      List<String> endParts = nightTiming.endTime!.split(":");

      int nightStart = int.parse(startParts[0]) * 60 + int.parse(startParts[1]);
      int nightEnd = int.parse(endParts[0]) * 60 + int.parse(endParts[1]);

      DateTime now = DateTime.now();
      int currentMinutes = now.hour * 60 + now.minute;

      bool isNight;
      if (nightStart < nightEnd) {
        isNight = currentMinutes >= nightStart && currentMinutes < nightEnd;
      } else {
        isNight = currentMinutes >= nightStart || currentMinutes < nightEnd;
      }

      if (isNight && charges.incrementOfNightCharge != null) {
        double nightPercentage = double.tryParse(charges.incrementOfNightCharge!) ?? 0;
        return baseFare * (nightPercentage / 100);
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error parsing night timing: $e");
      }
    }

    return 0.0;
  }

  String getMinuteCharge(VehicleTypeModel model) {
    if (model.zoneCharges == null || model.zoneCharges!.isEmpty) {
      return "0.0";
    }

    ZoneChargesModel? currentZoneCharge = model.zoneCharges!.firstWhere(
      (element) => element.zoneId == selectedZone.value.id,
      orElse: () => model.zoneCharges!.first,
    );

    Charges? charges = currentZoneCharge.charges;
    if (charges == null) return "0.0";

    if (mapModel.value.rows == null ||
        mapModel.value.rows!.isEmpty ||
        mapModel.value.rows!.first.elements == null ||
        mapModel.value.rows!.first.elements!.isEmpty ||
        mapModel.value.rows!.first.elements!.first.duration == null ||
        mapModel.value.rows!.first.elements!.first.duration!.value == null) {
      if (kDebugMode) print("⚠️ No duration data available in mapModel yet.");
      return "0.0";
    }

    int durationInSeconds = mapModel.value.rows!.first.elements!.first.duration!.value!;
    double durationInMinutes = durationInSeconds / 60.0;

    // ✅ Calculate minute charge (per minute * total minutes)
    double minuteChargeRate = double.tryParse(charges.minuteCharge ?? "0") ?? 0.0;
    double totalMinuteCharge = minuteChargeRate * durationInMinutes;

    return totalMinuteCharge.toStringAsFixed(Constant.currencyModel!.decimalDigits!);
  }

  void getPolyline(
      {required double? sourceLatitude,
      required double? sourceLongitude,
      required double? destinationLatitude,
      required double? destinationLongitude,
      List<LatLng> wayPoints = const []}) async {
    if (sourceLatitude != null && sourceLongitude != null && destinationLatitude != null && destinationLongitude != null) {
      List<LatLng> polylineCoordinates = [];

      // Convert waypoints into PolylineWayPoint
      List<PolylineWayPoint> polylineWayPoints = wayPoints.map((stop) => PolylineWayPoint(location: "${stop.latitude},${stop.longitude}")).toList();
      PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        request: PolylineRequest(
            origin: PointLatLng(sourceLatitude, sourceLongitude),
            destination: PointLatLng(destinationLatitude, destinationLongitude),
            mode: TravelMode.driving,
            wayPoints: polylineWayPoints),
      );
      if (result.points.isNotEmpty) {
        for (var point in result.points) {
          polylineCoordinates.add(LatLng(point.latitude, point.longitude));
        }
      } else {
        developer.log(result.errorMessage.toString());
      }

      addMarker(latitude: sourceLatitude, longitude: sourceLongitude, id: "pickUp", descriptor: pickUpIcon!, rotation: 0.0);
      addMarker(latitude: destinationLatitude, longitude: destinationLongitude, id: "drop", descriptor: dropIcon!, rotation: 0.0);
      for (int i = 0; i < wayPoints.length; i++) {
        addMarker(
          latitude: wayPoints[i].latitude,
          longitude: wayPoints[i].longitude,
          id: "stop_$i",
          descriptor: stopIcon!,
          // you can use another marker icon for stops
          rotation: 0.0,
        );
      }
      addPolyLine(polylineCoordinates);
    }
  }

  void addMarker({required double? latitude, required double? longitude, required String id, required BitmapDescriptor descriptor, required double? rotation}) {
    MarkerId markerId = MarkerId(id);
    Marker marker = Marker(markerId: markerId, icon: descriptor, position: LatLng(latitude ?? 0.0, longitude ?? 0.0), rotation: rotation ?? 0.0);
    markers[markerId] = marker;
  }

  Future<void> addMarkerSetup() async {
    final Uint8List pickUpUint8List = await Constant().getBytesFromAsset('assets/icon/ic_pick_up_map.png', 100);
    final Uint8List dropUint8List = await Constant().getBytesFromAsset('assets/icon/ic_drop_in_map.png', 100);
    final Uint8List stopUint8List = await Constant().getBytesFromAsset('assets/icon/ic_stop_icon_map.png', 100);
    final Uint8List driverUint8List = await Constant().getBytesFromAsset('assets/icon/ic_car.png', 70);
    pickUpIcon = BitmapDescriptor.fromBytes(pickUpUint8List);
    dropIcon = BitmapDescriptor.fromBytes(dropUint8List);
    stopIcon = BitmapDescriptor.fromBytes(stopUint8List);
    driverIcon = BitmapDescriptor.fromBytes(driverUint8List);
  }

  void addPolyLine(List<LatLng> polylineCoordinates) {
    if (polylineCoordinates.length < 2) return;

    const polylineId = PolylineId("poly");

    // ✅ ONLY UPDATE POINTS, DO NOT RECREATE
    if (polyLines.containsKey(polylineId)) {
      polyLines[polylineId] = polyLines[polylineId]!.copyWith(pointsParam: polylineCoordinates);
    } else {
      polyLines[polylineId] = Polyline(
        polylineId: polylineId,
        color: AppThemData.primary500,
        width: 5,
        points: polylineCoordinates,
        geodesic: true,
      );
    }

    update();
  }

  Future<void> updateCameraLocation(LatLng? source, LatLng? destination, GoogleMapController? mapController) async {
    if (mapController == null) return;

    if (source != null && destination != null) {
      LatLngBounds bounds;

      if (source.latitude > destination.latitude && source.longitude > destination.longitude) {
        bounds = LatLngBounds(southwest: destination, northeast: source);
      } else if (source.longitude > destination.longitude) {
        bounds = LatLngBounds(
          southwest: LatLng(source.latitude, destination.longitude),
          northeast: LatLng(destination.latitude, source.longitude),
        );
      } else if (source.latitude > destination.latitude) {
        bounds = LatLngBounds(
          southwest: LatLng(destination.latitude, source.longitude),
          northeast: LatLng(source.latitude, destination.longitude),
        );
      } else {
        bounds = LatLngBounds(southwest: source, northeast: destination);
      }

      CameraUpdate cameraUpdate = CameraUpdate.newLatLngBounds(bounds, 40);
      return checkCameraLocation(cameraUpdate, mapController);
    } else if (source != null) {
      // Zoom to source only
      CameraUpdate cameraUpdate = CameraUpdate.newCameraPosition(
        CameraPosition(target: source, zoom: 10),
      );
      mapController.animateCamera(cameraUpdate);
    }
  }

  Future<void> checkCameraLocation(CameraUpdate cameraUpdate, GoogleMapController mapController) async {
    mapController.animateCamera(cameraUpdate);
    LatLngBounds l1 = await mapController.getVisibleRegion();
    LatLngBounds l2 = await mapController.getVisibleRegion();

    if (l1.southwest.latitude == -90 || l2.southwest.latitude == -90) {
      return checkCameraLocation(cameraUpdate, mapController);
    }
  }

  String distanceCalculate(map.MapModel? value) {
    if (Constant.distanceType == "Km") {
      return (value!.rows!.first.elements!.first.distance!.value!.toInt() / 1000).toStringAsFixed(2);
    } else {
      return (value!.rows!.first.elements!.first.distance!.value!.toInt() / 1609.34).toStringAsFixed(2);
    }
  }

  static const int maxStops = 5;

  void addStop() {
    if (stopControllers.length >= maxStops) {
      ShowToastDialog.showToast("You can add maximum $maxStops stops only");
      return;
    }
    stopControllers.add(TextEditingController());
    stopFocusNodes.add(FocusNode());
    stopsLatLng.add(null);
    osmStopsLatLng.add(null);
    update();
  }

  void removeStop(int index) {
    if (index < 0 || index >= stopControllers.length) return;
    stopControllers.removeAt(index);
    stopFocusNodes.removeAt(index);
    stopsLatLng.removeAt(index);
    if (index < 0 || index >= osmStopsLatLng.length) return;
    osmStopsLatLng.removeAt(index);
    update();
    updateData();
  }

  /// =========================
  /// GET CURRENT ZONE
  /// =========================
  Future<ZoneModel?> getCurrentZone(LatLng userLatLng) async {
    for (ZoneModel zone in zoneList) {
      if (zone.area != null && zone.area!.isNotEmpty) {
        List<GeoPoint> polygon = zone.area!.map((e) => e).toList();
        if (isPointInPolygon(userLatLng, polygon)) return zone;
      }
    }
    return null;
  }

  bool isPointInPolygon(LatLng point, List<GeoPoint> polygon) {
    int crossings = 0;
    for (int i = 0; i < polygon.length; i++) {
      int next = (i + 1) % polygon.length;
      if (polygon[i].latitude <= point.latitude && polygon[next].latitude > point.latitude || polygon[i].latitude > point.latitude && polygon[next].latitude <= point.latitude) {
        double edgeLong = polygon[next].longitude - polygon[i].longitude;
        double edgeLat = polygon[next].latitude - polygon[i].latitude;
        double interpol = (point.latitude - polygon[i].latitude) / edgeLat;
        if (point.longitude < polygon[i].longitude + interpol * edgeLong) crossings++;
      }
    }
    return crossings % 2 != 0;
  }

  Future<void> updateData() async {
    if (Constant.selectedMap == "Google Map") {
      await _updateGoogleMapData();
    } else {
      await _updateOSMMapData();
    }
  }

  map.MapModel? cachedRouteModel;
  LatLng? lastRouteSource;
  LatLng? lastRouteDestination;
  DateTime? lastDriverRouteTime;

  /// Google-Map
  Future<void> _handleGoogleDriver(LatLng driver) async {
    _updateGoogleMarkers(
      bookingModel.value.pickUpLocation,
      bookingModel.value.dropLocation,
      driverModel.value.location,
    );

    // 1️⃣ First time → build route ONCE
    if (_activeGoogleRoutePoints.isEmpty) {
      await getDirections(forceReroute: true);
    }
    // Deviated
    else if (_isGoogleDriverOffRoute(driver)) {
      _activeGoogleRoutePoints.clear();
      polyLines.clear();
      await getDirections(forceReroute: true);
    }
    // Normal movement
    else {
      trimGooglePolylineByDriver(driver);
    }

    _updateEtaGoogleMap();
  }

  void _updateGoogleMarkers(
    LocationLatLng? pickup,
    LocationLatLng? drop,
    LocationLatLng? driver,
  ) {
    final Map<MarkerId, Marker> updated = {};

    // 🚗 DRIVER
    if (driver != null) {
      updated[const MarkerId('driver')] = Marker(
        markerId: const MarkerId('driver'),
        position: LatLng(driver.latitude!, driver.longitude!),
        icon: driverIcon!,
        rotation: driverModel.value.rotation,
        anchor: const Offset(0.5, 0.5),
      );
    }

    // 📍 PICKUP
    if (pickup != null) {
      updated[const MarkerId('pickUp')] = Marker(
        markerId: const MarkerId('pickUp'),
        position: LatLng(pickup.latitude!, pickup.longitude!),
        icon: pickUpIcon!,
      );
    }

    // 🎯 DROP
    if (drop != null) {
      updated[const MarkerId('drop')] = Marker(
        markerId: const MarkerId('drop'),
        position: LatLng(drop.latitude!, drop.longitude!),
        icon: dropIcon!,
      );
    }

    if (bookingModel.value.bookingStatus != BookingStatus.bookingAccepted) {
      final activeStops = getActiveGoogleStops();
      for (int i = 0; i < activeStops.length; i++) {
        updated[MarkerId('stop_$i')] = Marker(
          markerId: MarkerId('stop_$i'),
          position: activeStops[i],
          icon: stopIcon!,
        );
      }
    }

    markers
      ..clear()
      ..addAll(updated);

    update();
  }

  bool _isGoogleDriverOffRoute(LatLng driver) {
    double minDist = double.infinity;
    for (final p in _activeGoogleRoutePoints) {
      final d = calculateDistanceInMeters(
        driver.latitude,
        driver.longitude,
        p.latitude,
        p.longitude,
      );
      minDist = min(minDist, d);
    }
    return minDist > routeDeviationThreshold;
  }

  Future<void> getDirections({bool forceReroute = false}) async {
    developer.log("==================> :: 🧭 getDirections called | status=${bookingModel.value.bookingStatus}", name: "ROUTE");
    if (_isFetchingGoogleRoute) return;
    if (!forceReroute && _isGoogleRouteReady) return;

    final driver = driverModel.value.location;
    final pickup = bookingModel.value.pickUpLocation;
    final drop = bookingModel.value.dropLocation;

    if (driver == null || pickup == null || drop == null) return;

    final activeStops = getActiveGoogleStops();

    final waypoints = activeStops
        .map(
          (e) => PolylineWayPoint(
            location: "${e.latitude},${e.longitude}",
          ),
        )
        .toList();

    late PointLatLng origin;
    late PointLatLng destination;

    if (bookingModel.value.bookingStatus == BookingStatus.bookingAccepted) {
      origin = PointLatLng(driver.latitude!, driver.longitude!);
      destination = PointLatLng(pickup.latitude!, pickup.longitude!);
    } else {
      origin = PointLatLng(driver.latitude!, driver.longitude!);
      destination = PointLatLng(drop.latitude!, drop.longitude!);
    }

    _isFetchingGoogleRoute = true;

    try {
      final result = await polylinePoints.getRouteBetweenCoordinates(
        request: PolylineRequest(
          origin: origin,
          destination: destination,
          wayPoints: waypoints,
          mode: TravelMode.driving,
        ),
      );

      if (result.points.isEmpty) return;

      _activeGoogleRoutePoints = result.points.map((e) => LatLng(e.latitude, e.longitude)).toList();

      addPolyLine(_activeGoogleRoutePoints);

      _lastRouteBuild = DateTime.now();
      _isGoogleRouteReady = true;
      developer.log("==================> :: ✅ Google route built | points=${_activeGoogleRoutePoints.length}", name: "ROUTE");

      _updateEtaGoogleMap();
    } finally {
      _isFetchingGoogleRoute = false;
    }
  }

  /// Returns stops based on booking state (Google)
  List<LatLng> getActiveGoogleStops() {
    // ✅ Before booking placed
    if (bookingModel.value.id == null || bookingModel.value.id!.isEmpty) {
      return stopsLatLng.whereType<LatLng>().toList();
    }

    // ✅ After booking placed (but not accepted)
    return bookingModel.value.stops
            ?.where((e) => e.location != null)
            .map((e) => LatLng(
                  e.location!.latitude!,
                  e.location!.longitude!,
                ))
            .toList() ??
        [];
  }

  void trimGooglePolylineByDriver(LatLng driver) {
    if (_activeGoogleRoutePoints.length < 5) return;

    int index = 0;
    double minDist = double.infinity;

    for (int i = 0; i < _activeGoogleRoutePoints.length; i++) {
      final d = calculateDistanceInMeters(
        driver.latitude,
        driver.longitude,
        _activeGoogleRoutePoints[i].latitude,
        _activeGoogleRoutePoints[i].longitude,
      );
      if (d < minDist) {
        minDist = d;
        index = i;
      }
    }

    if (index > 0 && minDist < 80) {
      _activeGoogleRoutePoints = _activeGoogleRoutePoints.sublist(index);
      polyLines[const PolylineId("poly")] = polyLines[const PolylineId("poly")]!.copyWith(pointsParam: _activeGoogleRoutePoints);
      update();
    }
  }

  Future<void> animateDriverMarkerGoogle(LatLng newPos, {bool followCamera = true}) async {
    addMarker(latitude: newPos.latitude, longitude: newPos.longitude, id: 'driver', descriptor: driverIcon!, rotation: driverModel.value.rotation);

    if (followCamera && DateTime.now().difference(_lastCameraFollow) > cameraFollowThrottle) {
      _lastCameraFollow = DateTime.now();
      mapController?.animateCamera(CameraUpdate.newLatLng(newPos));
    }
    update();
  }

  void _updateEtaGoogleMap() {
    if (_activeGoogleRoutePoints.length < 2) return;
    if (DateTime.now().difference(_lastEtaUpdate) < etaUpdateThrottle) return;

    _lastEtaUpdate = DateTime.now();

    double meters = 0;
    for (int i = 0; i < _activeGoogleRoutePoints.length - 1; i++) {
      meters += calculateDistanceInMeters(
        _activeGoogleRoutePoints[i].latitude,
        _activeGoogleRoutePoints[i].longitude,
        _activeGoogleRoutePoints[i + 1].latitude,
        _activeGoogleRoutePoints[i + 1].longitude,
      );
    }

    etaInMinutes.value = calculateUniversalEta(meters);
  }

  Future<void> _updateGoogleMapData() async {
    if (bookingModel.value.id != null && bookingModel.value.id!.isNotEmpty) {
      // 🚫 Booking already placed → do NOT recalc fare route
      return;
    }
    if (sourceLocation != null && destination != null) {
      bool isSameRoute = lastRouteSource == sourceLocation && lastRouteDestination == destination && cachedRouteModel != null;

      ShowToastDialog.showLoader("Please wait".tr);

      if (!isSameRoute) {
        final value = await Constant.getDurationDistance(sourceLocation!, destination!);

        if (value != null) {
          cachedRouteModel = value;
          lastRouteSource = sourceLocation;
          lastRouteDestination = destination;
          mapModel.value = value;
        }
      } else {
        mapModel.value = cachedRouteModel!;
      }

      pickupLocationController.text = mapModel.value.originAddresses!.first;
      dropLocationController.text = mapModel.value.destinationAddresses!.first;

      calculateTotalAmount();

      distanceOfKm.value = DistanceModel(
        distance: distanceCalculate(mapModel.value),
        distanceType: Constant.distanceType,
      );

      // 🔹 Polyline only once
      getPolyline(
        sourceLatitude: sourceLocation!.latitude,
        sourceLongitude: sourceLocation!.longitude,
        destinationLatitude: destination!.latitude,
        destinationLongitude: destination!.longitude,
        wayPoints: getActiveGoogleStops(),
      );

      ShowToastDialog.closeLoader();
      popupIndex.value = 1;
    } else {
      _handleGoogleMarkers();
    }
  }

  void _handleGoogleMarkers() {
    if (destination != null) {
      addMarker(
        latitude: destination!.latitude,
        longitude: destination!.longitude,
        id: "drop",
        descriptor: dropIcon!,
        rotation: 0,
      );
      updateCameraLocation(destination!, destination!, mapController);
    }

    if (sourceLocation != null) {
      addMarker(
        latitude: sourceLocation!.latitude,
        longitude: sourceLocation!.longitude,
        id: "pickUp",
        descriptor: pickUpIcon!,
        rotation: 0,
      );
      updateCameraLocation(sourceLocation!, sourceLocation!, mapController);
    }
  }

  ///OSM - Map
  List<latlang.LatLng> getActiveOsmStops() {
    if (bookingModel.value.bookingStatus == BookingStatus.bookingAccepted) {
      return [];
    }

    if (bookingModel.value.id == null || bookingModel.value.id!.isEmpty) {
      return osmStopsLatLng.whereType<latlang.LatLng>().toList();
    }

    return bookingModel.value.stops
            ?.where((e) => e.location != null)
            .map((e) => latlang.LatLng(
                  e.location!.latitude!,
                  e.location!.longitude!,
                ))
            .toList() ??
        [];
  }

  void _handleOsmDriver(LatLng driver) {
    final driverPos = latlang.LatLng(driver.latitude, driver.longitude);

    // 🎯 Decide destination based on booking status
    final latlang.LatLng target = bookingModel.value.bookingStatus == BookingStatus.bookingAccepted
        ? latlang.LatLng(
            bookingModel.value.pickUpLocation!.latitude!,
            bookingModel.value.pickUpLocation!.longitude!,
          )
        : latlang.LatLng(
            bookingModel.value.dropLocation!.latitude!,
            bookingModel.value.dropLocation!.longitude!,
          );

    // 🔹 Build route ONLY when needed
    if (!_osmRouteInitialized || _isOsmDriverOffRoute(driverPos)) {
      _drawOSMCustomerRoute(driverPos, target, []);
      _osmRouteInitialized = true;
      return;
    }

    // 🔹 Normal movement
    trimOsmPolyline(driverPos);

    _updateOsmMarkers(
      bookingModel.value.pickUpLocation,
      bookingModel.value.dropLocation,
      driverModel.value.location,
    );

    if (DateTime.now().difference(_lastOsmCameraFollow) > osmCameraFollowThrottle) {
      _lastOsmCameraFollow = DateTime.now();
      osmMapController.move(driverPos, 16);
    }
  }

  void _updateOsmMarkers(LocationLatLng? pickup, LocationLatLng? drop, LocationLatLng? driver) {
    final List<osm.Marker> list = [];

    // 🚗 Driver (after accept)
    if (driver != null) {
      list.add(
        osm.Marker(
          point: latlang.LatLng(driver.latitude!, driver.longitude!),
          width: 45,
          height: 45,
          child: Transform.rotate(
            angle: (driverModel.value.rotation ?? 0) * pi / 180,
            child: Image.asset('assets/icon/ic_car.png'),
          ),
        ),
      );
    }

    // 📍 Pickup
    if (pickup != null) {
      list.add(
        osm.Marker(
          point: latlang.LatLng(pickup.latitude!, pickup.longitude!),
          child: Image.asset('assets/icon/ic_pick_up_map.png'),
        ),
      );
    }

    // 🎯 Drop
    if (drop != null) {
      list.add(
        osm.Marker(
          point: latlang.LatLng(drop.latitude!, drop.longitude!),
          child: Image.asset('assets/icon/ic_drop_in_map.png'),
        ),
      );
    }

    // 🔹 STOP MARKERS (BEFORE & AFTER BOOKING)
    if (bookingModel.value.bookingStatus != BookingStatus.bookingAccepted) {
      final activeStops = getActiveOsmStops();
      for (int i = 0; i < activeStops.length; i++) {
        list.add(osm.Marker(point: latlang.LatLng(activeStops[i].latitude, activeStops[i].longitude), child: Image.asset('assets/icon/ic_stop_icon_map.png')));
      }
    }

    osmMarkers.value = list;
    update();
  }

  void trimOsmPolyline(latlang.LatLng driver) {
    if (osmRoute.isEmpty) return;

    int index = 0;
    double minDist = double.infinity;

    for (int i = 0; i < osmRoute.length; i++) {
      final d = calculateDistanceInMeters(
        driver.latitude,
        driver.longitude,
        osmRoute[i].latitude,
        osmRoute[i].longitude,
      );
      if (d < minDist) {
        minDist = d;
        index = i;
      }
    }

    if (index > 0 && minDist < 80) {
      osmRoute.value = osmRoute.sublist(index);
      update();
    }
  }

  bool _isOsmDriverOffRoute(latlang.LatLng driver) {
    double minDist = double.infinity;

    for (final p in osmRoute) {
      final d = calculateDistanceInMeters(
        driver.latitude,
        driver.longitude,
        p.latitude,
        p.longitude,
      );
      minDist = min(minDist, d);
    }

    return minDist > routeDeviationThreshold;
  }

  Future<void> animateDriverMarkerOsm(latlang.LatLng pos, {bool followCamera = true}) async {
    if (osmRoute.isNotEmpty) {
      trimOsmPolyline(pos);
    }

    _updateOsmMarkers(
      bookingModel.value.pickUpLocation,
      bookingModel.value.dropLocation,
      driverModel.value.location,
    );

    if (followCamera && DateTime.now().difference(_lastOsmCameraFollow) > osmCameraFollowThrottle) {
      _lastOsmCameraFollow = DateTime.now();
      osmMapController.move(pos, 16);
    }
  }

  void updateEtaOsmMap() {
    if (osmTotalRouteDistance <= 0) return;

    if (DateTime.now().difference(_lastEtaUpdate) < etaUpdateThrottle) return;
    _lastEtaUpdate = DateTime.now();

    final newEta = calculateUniversalEta(osmTotalRouteDistance);

    if (etaInMinutes.value == 0) {
      etaInMinutes.value = newEta;
    } else {
      etaInMinutes.value = smoothEta(etaInMinutes.value, newEta);
    }
  }

  Future<void> _updateOSMMapData() async {
    if (bookingModel.value.id != null && bookingModel.value.id!.isNotEmpty) {
      return;
    }
    if (osmSourceLocation == null || osmDestination == null) return;

    ShowToastDialog.showLoader("Please wait".tr);

    List<latlang.LatLng> waypoints = getActiveOsmStops();
    final result = await _drawOSMCustomerRoute(
      osmSourceLocation!,
      osmDestination!,
      waypoints,
    );

    if (result == null) {
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast("Route not found");
      return;
    }

    _updateOsmMarkers(
      LocationLatLng(
        latitude: osmSourceLocation!.latitude,
        longitude: osmSourceLocation!.longitude,
      ),
      LocationLatLng(
        latitude: osmDestination!.latitude,
        longitude: osmDestination!.longitude,
      ),
      null, // ❌ no driver before booking
    );
    etaInMinutes.value = calculateGoogleLikeEtaFromOSRM(result.durationSeconds);

    /// ✅ IMPORTANT: Fill MapModel EXACTLY like Google
    mapModel.value = map.MapModel(
      status: "OK",
      originAddresses: ["Pickup Location"],
      destinationAddresses: ["Drop Location"],
      rows: [
        map.Rows(
          elements: [
            map.Elements(
              status: "OK",
              distance: map.Distance(
                value: result.distanceMeters,
                text: Constant.distanceType == "Km" ? "${(result.distanceMeters / 1000).toStringAsFixed(2)} km" : "${(result.distanceMeters / 1609.34).toStringAsFixed(2)} mi",
              ),
              duration: map.Duration(
                value: etaInMinutes.value * 60,
                text: "${etaInMinutes.value} mins",
              ),
            ),
          ],
        ),
      ],
    );
    // pickupLocationController.text = "Pickup Location";
    // dropLocationController.text = "Drop Location";

    /// ✅ THIS MAKES YOUR UI + FARE WORK
    distanceOfKm.value = DistanceModel(
      distance: distanceCalculate(mapModel.value),
      distanceType: Constant.distanceType,
    );

    calculateTotalAmount();

    ShowToastDialog.closeLoader();
    popupIndex.value = 1;
    update();
  }

  Future<OSMRouteResult?> _drawOSMCustomerRoute(latlang.LatLng source, latlang.LatLng destination, List<latlang.LatLng> waypoints) async {
    try {
      final result = await getOSRMRoadPolyline(source, destination, waypoints);

      osmPolyline
        ..clear()
        ..addAll(result.polyline);

      // ✅ CRITICAL: update distance for ETA
      osmTotalRouteDistance = result.distanceMeters.toDouble();

      // ✅ ETA BASED ON CURRENT ROUTE (driver→pickup OR driver→drop)
      etaInMinutes.value = calculateUniversalEta(osmTotalRouteDistance);

      _updateOsmMarkers(
        bookingModel.value.pickUpLocation,
        bookingModel.value.dropLocation,
        driverModel.value.location,
      );

      update();
      return result;
    } catch (e) {
      developer.log("❌ OSM route error: $e", name: "OSM_ROUTE");
      return null;
    }
  }

  Future<String> getOSMAddress(latlang.LatLng location) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(location.latitude, location.longitude);

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        return "${place.street}, ${place.subLocality}, ${place.locality}, ${place.administrativeArea}, ${place.country}";
      }
    } catch (e) {
      developer.log("Unable to fetch Address :: $e");
    }
    return "";
  }

  void moveCameraToOSMRoute(List<latlang.LatLng> points) {
    if (points.isEmpty) return;

    double minLat = points.first.latitude;
    double maxLat = points.first.latitude;
    double minLng = points.first.longitude;
    double maxLng = points.first.longitude;

    for (final p in points) {
      minLat = min(minLat, p.latitude);
      maxLat = max(maxLat, p.latitude);
      minLng = min(minLng, p.longitude);
      maxLng = max(maxLng, p.longitude);
    }

    final center = latlang.LatLng(
      (minLat + maxLat) / 2,
      (minLng + maxLng) / 2,
    );

    osmMapController.move(center, 13); // zoom adjust as needed
  }

  Future<OSMRouteResult> getOSRMRoadPolyline(latlang.LatLng source, latlang.LatLng destination, List<latlang.LatLng> waypoints) async {
    final waypointsStr = waypoints.map((e) => '${e.longitude},${e.latitude}').join(';');

    final url = 'https://router.project-osrm.org/route/v1/driving/'
        '${source.longitude},${source.latitude};'
        '${waypointsStr.isNotEmpty ? '$waypointsStr;' : ''}'
        '${destination.longitude},${destination.latitude}'
        '?overview=full&geometries=geojson';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode != 200) {
      throw Exception("OSRM route failed");
    }

    final data = jsonDecode(response.body);
    final route = data['routes'][0];

    final coords = route['geometry']['coordinates'] as List;

    return OSMRouteResult(
      polyline: coords.map<latlang.LatLng>((c) => latlang.LatLng(c[1], c[0])).toList(),
      distanceMeters: (route['distance'] as num).toInt(),
      durationSeconds: (route['duration'] as num).toInt(),
    );
  }

  int calculateGoogleLikeEtaFromOSRM(int osrmDurationSeconds) {
    double etaSeconds = osrmDurationSeconds.toDouble();

    const double cityFactor = 1.35;

    const double trafficFactor = 1.30;

    const double signalFactor = 1.10;

    etaSeconds = etaSeconds * cityFactor * trafficFactor * signalFactor;

    return max(1, (etaSeconds / 60).ceil());
  }

  double calculateDistanceInMeters(double lat1, double lon1, double lat2, double lon2) {
    const R = 6371000;
    final dLat = _degToRad(lat2 - lat1);
    final dLon = _degToRad(lon2 - lon1);
    final a = sin(dLat / 2) * sin(dLat / 2) + cos(_degToRad(lat1)) * cos(_degToRad(lat2)) * sin(dLon / 2) * sin(dLon / 2);
    return R * 2 * atan2(sqrt(a), sqrt(1 - a));
  }

  double _degToRad(double deg) => deg * pi / 180;

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

  void resetRouteState() {
    _activeGoogleRoutePoints.clear();
    _isGoogleRouteReady = false;
    _googleRouteInitialized = false;

    osmRoute.clear();
    osmPolyline.clear();
    _osmRouteInitialized = false;

    polyLines.clear();
  }

  void stopLiveTracking() {
    bookingSub?.cancel();
    driverSub?.cancel();

    bookingSub = null;
    driverSub = null;

    resetRouteState();
  }

  @override
  void onClose() {
    resetRouteState();
    bookingSub?.cancel();
    driverSub?.cancel();
    super.onClose();
  }

  @override
  void dispose() {
    resetRouteState();
    super.dispose();
  }
}

class OSMRouteResult {
  final List<latlang.LatLng> polyline;
  final int distanceMeters;
  final int durationSeconds;

  OSMRouteResult({
    required this.polyline,
    required this.distanceMeters,
    required this.durationSeconds,
  });
}
