// ignore_for_file: depend_on_referenced_packages, deprecated_member_use, use_build_context_synchronously

import 'dart:async';
import 'dart:developer';
import 'dart:developer' as developer;
import 'package:customer/app/models/rental_booking_model.dart';
import 'package:customer/app/models/rental_package_model.dart';
import 'package:customer/constant/collection_name.dart';
import 'package:customer/constant_widgets/osm_place_picker/osm_selected_location_model.dart';
import 'package:customer/constant_widgets/place_picker/selected_location_model.dart';
import 'package:customer/services/recent_location_search.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geoflutterfire2/geoflutterfire2.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:customer/app/models/coupon_model.dart';
import 'package:customer/app/models/location_lat_lng.dart';
import 'package:customer/app/models/map_model.dart';
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
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:latlong2/latlong.dart' as latlang;
import 'package:flutter_map/flutter_map.dart' as osm;

class RentalSelectLocationController extends GetxController {
  FocusNode pickUpFocusNode = FocusNode();
  TextEditingController pickupLocationController = TextEditingController(text: 'Current Location');
  Rx<TextEditingController> pickupDateController = TextEditingController().obs;
  Position? currentLocationPosition;
  RxBool isLoading = false.obs;
  RxInt popupIndex = 0.obs;
  RxInt selectVehicleTypeIndex = 0.obs;

  RxList<RentalPackageModel> rentalPackages = <RentalPackageModel>[].obs;
  Rx<RentalPackageModel> selectedRentalPackage = RentalPackageModel().obs;

  Rx<MapModel?> mapModel = MapModel().obs;
  Rx<TextEditingController> couponCodeController = TextEditingController().obs;
  RxString selectedPaymentMethod = 'Cash'.obs;
  RxString couponCode = "Enter coupon code".obs;
  Rx<CouponModel> selectedCouponModel = CouponModel().obs;
  RxList<TaxModel> taxList = (Constant.taxList ?? []).obs;

  RxList<VehicleTypeModel> vehicleTypeList = <VehicleTypeModel>[].obs;
  Rx<VehicleTypeModel> selectVehicleType = VehicleTypeModel().obs;
  RxString bookingId = "".obs;
  final Rx<DateTime?> selectedPickupDateTime = Rx<DateTime?>(null);

  RxBool isForFemale = false.obs;

  /// ================= GOOGLE MAP =================
  GoogleMapController? googleMapController;
  LatLng? googleSourceLocation;
  LatLng? googleDestinationLocation;
  RxMap<MarkerId, Marker> googleMarkers = <MarkerId, Marker>{}.obs;
  RxMap<PolylineId, Polyline> googlePolylines = <PolylineId, Polyline>{}.obs;
  RxList<SelectedLocationModel> googleRecentSearches = <SelectedLocationModel>[].obs;
  BitmapDescriptor? pickUpIcon;
  BitmapDescriptor? dropIcon;
  PolylinePoints googlePolylinePoints = PolylinePoints(apiKey: Constant.mapAPIKey);

  /// ================= OSM MAP =================
  osm.MapController osmMapController = osm.MapController();
  latlang.LatLng? osmSourceLocation;
  latlang.LatLng? osmDestinationLocation;
  RxList<osm.Marker> osmMarkers = <osm.Marker>[].obs;
  RxList<latlang.LatLng> osmPolylinePoints = <latlang.LatLng>[].obs;
  RxList<latlang.LatLng?> osmStopsLatLng = <latlang.LatLng?>[].obs;
  RxList<OsmSelectedLocationModel> osmRecentSearches = <OsmSelectedLocationModel>[].obs;

  void changeVehicleType(VehicleTypeModel vehicle) {
    selectVehicleType.value = vehicle;
    // calculateTotalAmount();
  }

  @override
  void onInit() {
    getData();
    pickupLocationController.addListener(() {
      getRecentSearches();
      update();
    });

    super.onInit();
  }

  Future<void> getRecentSearches() async {
    if (Constant.selectedMap == "Google Map") {
      googleRecentSearches.value = await RecentSearchLocation.getLocationFromHistory();
      log("Google Recent Searches: ${googleRecentSearches.length}");
    } else {
      osmRecentSearches.value = await RecentSearchLocation.getOSMLocationFromHistory();
      log("OSM Recent Searches: ${osmRecentSearches.length}");
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

  Future<void> getVehicle() async {
    await FireStoreUtils.fetchAllCabServices().then(
      (value) {
        vehicleTypeList.value = value;
        if (vehicleTypeList.isNotEmpty) {
          changeVehicleType(vehicleTypeList.first);
        }
      },
    );
  }

  Future<void> getRentalPackage() async {
    final value = await FireStoreUtils().getRentalPackages(selectVehicleType.value.id.toString());
    if (value != null && value.isNotEmpty) {
      rentalPackages.value = value;
      if (rentalPackages.isNotEmpty) {
        selectedRentalPackage.value = value.first;
        calculateTotalAmount();
      }
    } else {
      log("No rental packages returned for vehicle ID: ${selectVehicleType.value.id.toString()}");
    }
  }

  Future<void> getData() async {
    currentLocationPosition = await Utils.getCurrentLocation();
    Constant.country = (await placemarkFromCoordinates(currentLocationPosition!.latitude, currentLocationPosition!.longitude))[0].country ?? 'Unknown';
    if (Constant.selectedMap == "Google Map") {
      googleSourceLocation = LatLng(currentLocationPosition!.latitude, currentLocationPosition!.longitude);
    } else {
      osmSourceLocation = latlang.LatLng(currentLocationPosition!.latitude, currentLocationPosition!.longitude);
    }
    await getTax();
    await getVehicle();
    if (Constant.selectedMap == "Google Map") {
      await addMarkerSetup(); // Google Map
    } else {
      await addOsmMarkerSetup(); // OSM Map
    }
    pickUpFocusNode.requestFocus();
    isLoading.value = false;
  }

  Future<void> confirmRentalBooking() async {
    ShowToastDialog.showLoader("Please wait...".tr);
    RentalBookingModel rentalBookingModel = RentalBookingModel();
    rentalBookingModel.id = Constant.getUuid();
    rentalBookingModel.customerId = FireStoreUtils.getCurrentUid();
    rentalBookingModel.bookingStatus = BookingStatus.bookingPlaced;
    double latitude;
    double longitude;
    if (Constant.selectedMap == "Google Map") {
      if (googleSourceLocation == null) {
        ShowToastDialog.closeLoader();
        ShowToastDialog.showToast("Please select pickup location".tr);
        return;
      }

      latitude = googleSourceLocation!.latitude;
      longitude = googleSourceLocation!.longitude;

      rentalBookingModel.pickUpLocationAddress = await getAddressFromLatLng(googleSourceLocation!);
    } else {
      if (osmSourceLocation == null) {
        ShowToastDialog.closeLoader();
        ShowToastDialog.showToast("Please select pickup location".tr);
        return;
      }
      latitude = osmSourceLocation!.latitude;
      longitude = osmSourceLocation!.longitude;

      rentalBookingModel.pickUpLocationAddress = await getAddressFromLatLng(osmSourceLocation!);
    }
    rentalBookingModel.pickUpLocation = LocationLatLng(latitude: latitude, longitude: longitude);
    final position = GeoFlutterFire().point(latitude: latitude, longitude: longitude);
    rentalBookingModel.position = Positions(
      geoPoint: position.geoPoint,
      geohash: position.hash,
    );

    rentalBookingModel.vehicleType = selectVehicleType.value;
    rentalBookingModel.rentalPackage = selectedRentalPackage.value;
    rentalBookingModel.subTotal = selectedRentalPackage.value.baseFare;
    rentalBookingModel.pickupTime = selectedPickupDateTime.value != null ? Timestamp.fromDate(selectedPickupDateTime.value!) : Timestamp.now();
    rentalBookingModel.otp = Constant.isOtpFeatureEnable == true ? Constant.getOTPCode() : "";
    rentalBookingModel.paymentType = selectedPaymentMethod.value;
    rentalBookingModel.paymentStatus = false;
    rentalBookingModel.taxList = taxList;
    rentalBookingModel.adminCommission = Constant.adminCommission;
    rentalBookingModel.coupon = selectedCouponModel.value;
    rentalBookingModel.discount = discountAmount.value.toString();
    rentalBookingModel.isOnlyForFemale = isForFemale.value;
    rentalBookingModel.createAt = Timestamp.now();
    rentalBookingModel.updateAt = Timestamp.now();
    rentalBookingModel.bookingTime = Timestamp.now();

    await FireStoreUtils.setRentalRide(rentalBookingModel).then((value) {
      ShowToastDialog.showToast("Ride Booked successfully".tr);
      ShowToastDialog.closeLoader();
      Get.back();
    });
  }

  Future<String> getAddressFromLatLng(dynamic location) async {
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

  RxDouble subTotal = 0.0.obs;
  RxDouble discountAmount = 0.0.obs;
  RxDouble totalAmount = 0.0.obs;
  RxDouble extraHourCharge = 0.0.obs;
  RxDouble extraKmCharge = 0.0.obs;

  void calculateTotalAmount() {
    subTotal.value = double.parse(selectedRentalPackage.value.baseFare.toString());
    double taxAmount = 0.0;

    if (selectedCouponModel.value.id != null) {
      if (selectedCouponModel.value.isFix == true) {
        discountAmount.value = double.parse(selectedCouponModel.value.amount.toString());
      } else {
        discountAmount.value = subTotal * double.parse(selectedCouponModel.value.amount.toString()) / 100;
      }
    }
    for (var element in taxList) {
      taxAmount = taxAmount +
          Constant.calculateTax(
              amount: (((double.parse(subTotal.value.toString())) + double.parse(extraHourCharge.value.toString()) + double.parse(extraKmCharge.value.toString())) -
                      (double.parse(discountAmount.value.toString())))
                  .toString(),
              taxModel: element);
    }
    totalAmount.value = (subTotal.value - discountAmount.value) + taxAmount;
  }

  Future<void> updateData() async {
    if (pickupLocationController.text.trim().isEmpty) {
      ShowToastDialog.showToast("Please select Pickup Location".tr);
      return;
    }

    if (Constant.selectedMap == "Google Map") {
      if (googleSourceLocation != null) {
        ShowToastDialog.showLoader("Please wait".tr);

        addMarker(
          latitude: googleSourceLocation!.latitude,
          longitude: googleSourceLocation!.longitude,
          id: "pickUp",
          descriptor: pickUpIcon!,
          rotation: 0.0,
        );

        updateCameraLocation(googleSourceLocation!, googleSourceLocation!, googleMapController);
        ShowToastDialog.closeLoader();
        popupIndex.value = 1;
      } else {
        ShowToastDialog.showToast("Please select Pickup Location".tr);
      }
    } else {
      if (osmSourceLocation != null) {
        ShowToastDialog.showLoader("Please wait".tr);

        osmMarkers.clear();
        osmMarkers.add(osm.Marker(point: osmSourceLocation!, width: 40, height: 40, child: Image.asset("assets/icon/ic_pick_up_map.png", height: 40, width: 40)));
        osmMapController.move(osmSourceLocation!, 15);

        ShowToastDialog.closeLoader();
        popupIndex.value = 1;
        update();
      } else {
        ShowToastDialog.showToast("Please select Pickup Location".tr);
      }
    }
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
      log(e.toString());
    }
    FocusScope.of(Get.context!).unfocus();
  }

  Future<void> selectPickupDateTime(BuildContext context, themeChange) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              surface: themeChange.isDarkTheme() ? AppThemData.black : AppThemData.white,
              primary: AppThemData.primary600,
              onPrimary: AppThemData.black,
              onSurface: themeChange.isDarkTheme() ? AppThemData.white : AppThemData.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: themeChange.isDarkTheme() ? AppThemData.white : AppThemData.black, // button text color
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate == null) return;

    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              surface: themeChange.isDarkTheme() ? AppThemData.black : AppThemData.white,
              primary: AppThemData.primary600,
              onPrimary: AppThemData.black,
              onSurface: themeChange.isDarkTheme() ? AppThemData.white : AppThemData.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: themeChange.isDarkTheme() ? AppThemData.white : AppThemData.black,
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedTime == null) return;

    DateTime fullDateTime = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );

    selectedPickupDateTime.value = fullDateTime;

    pickupDateController.value.text = DateFormat("d MMM, yyyy hh:mm a").format(fullDateTime);
  }

  void getPolyline({required double? sourceLatitude, required double? sourceLongitude, required double? destinationLatitude, required double? destinationLongitude}) async {
    if (sourceLatitude != null && sourceLongitude != null && destinationLatitude != null && destinationLongitude != null) {
      List<LatLng> polylineCoordinates = [];
      PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        request: PolylineRequest(
          origin: PointLatLng(sourceLatitude, sourceLongitude),
          destination: PointLatLng(destinationLatitude, destinationLongitude),
          mode: TravelMode.driving,
          // wayPoints: [PolylineWayPoint(location: "Sabo, Yaba Lagos Nigeria")],
        ),
      );
      if (result.points.isNotEmpty) {
        for (var point in result.points) {
          polylineCoordinates.add(LatLng(point.latitude, point.longitude));
        }
      } else {
        log(result.errorMessage.toString());
      }

      addMarker(latitude: sourceLatitude, longitude: sourceLongitude, id: "pickUp", descriptor: pickUpIcon!, rotation: 0.0);
      addMarker(latitude: destinationLatitude, longitude: destinationLongitude, id: "drop", descriptor: dropIcon!, rotation: 0.0);
      _addPolyLine(polylineCoordinates);
    }
  }

  void addMarker({required double? latitude, required double? longitude, required String id, required BitmapDescriptor descriptor, required double? rotation}) {
    MarkerId markerId = MarkerId(id);
    Marker marker = Marker(markerId: markerId, icon: descriptor, position: LatLng(latitude ?? 0.0, longitude ?? 0.0), rotation: rotation ?? 0.0);
    googleMarkers[markerId] = marker;
  }

  Future<void> addMarkerSetup() async {
    final Uint8List pickUpUint8List = await Constant().getBytesFromAsset('assets/icon/ic_pick_up_map.png', 100);
    final Uint8List dropUint8List = await Constant().getBytesFromAsset('assets/icon/ic_drop_in_map.png', 100);
    pickUpIcon = BitmapDescriptor.fromBytes(pickUpUint8List);
    dropIcon = BitmapDescriptor.fromBytes(dropUint8List);
  }

  Future<void> addOsmMarkerSetup() async {
    osmMarkers.clear();
    if (osmSourceLocation != null) {
      // Pickup marker
      osmMarkers.add(
        osm.Marker(
          point: osmSourceLocation!,
          width: 40,
          height: 40,
          child: Image.asset(
            'assets/icon/ic_pick_up_map.png',
            width: 40,
            height: 40,
          ),
        ),
      );
    }

    if (osmDestinationLocation != null) {
      // Drop marker
      osmMarkers.add(
        osm.Marker(
          point: osmDestinationLocation!,
          width: 40,
          height: 40,
          child: Image.asset(
            'assets/icon/ic_drop_in_map.png',
            width: 40,
            height: 40,
          ),
        ),
      );
    }
  }

  RxMap<PolylineId, Polyline> polyLines = <PolylineId, Polyline>{}.obs;
  PolylinePoints polylinePoints = PolylinePoints(apiKey: Constant.mapAPIKey);

  Future<void> _addPolyLine(List<LatLng> polylineCoordinates) async {
    PolylineId id = const PolylineId("poly");
    Polyline polyline = Polyline(
      polylineId: id,
      points: polylineCoordinates,
      consumeTapEvents: true,
      color: AppThemData.primary500,
      startCap: Cap.roundCap,
      width: 4,
    );
    polyLines[id] = polyline;
    updateCameraLocation(polylineCoordinates.first, polylineCoordinates.last, googleMapController);
  }

  Future<void> updateCameraLocation(
    LatLng? source,
    LatLng? destination,
    GoogleMapController? googleMapController,
  ) async {
    if (googleMapController == null) return;

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
      return checkCameraLocation(cameraUpdate, googleMapController);
    } else if (source != null) {
      // Zoom to source only
      CameraUpdate cameraUpdate = CameraUpdate.newCameraPosition(
        CameraPosition(target: source, zoom: 10),
      );
      googleMapController.animateCamera(cameraUpdate);
    }
  }

  Future<void> checkCameraLocation(CameraUpdate cameraUpdate, GoogleMapController googleMapController) async {
    googleMapController.animateCamera(cameraUpdate);
    LatLngBounds l1 = await googleMapController.getVisibleRegion();
    LatLngBounds l2 = await googleMapController.getVisibleRegion();

    if (l1.southwest.latitude == -90 || l2.southwest.latitude == -90) {
      return checkCameraLocation(cameraUpdate, googleMapController);
    }
  }
}
