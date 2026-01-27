// ignore_for_file: unnecessary_overrides, depend_on_referenced_packages

import 'dart:async';
import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:driver/app/models/booking_model.dart';
import 'package:driver/app/models/rental_booking_model.dart';
import 'package:driver/app/models/driver_user_model.dart';
import 'package:driver/app/models/location_lat_lng.dart';
import 'package:driver/app/models/positions_model.dart';
import 'package:driver/app/models/review_customer_model.dart';
import 'package:driver/app/modules/home/views/widgets/cab_rides_widget.dart';
import 'package:driver/app/modules/intercity_ride_for_home/views/intercity_ride_for_home_view.dart';
import 'package:driver/app/modules/home/views/widgets/rental_rides_widget.dart';
import 'package:driver/app/modules/login/views/login_view.dart';
import 'package:driver/app/modules/parcel_ride_for_home/views/parcel_ride_for_home_view.dart';
import 'package:driver/constant/booking_status.dart';
import 'package:driver/constant/collection_name.dart';
import 'package:driver/constant/constant.dart';
import 'package:driver/theme/app_them_data.dart';
import 'package:driver/utils/fire_store_utils.dart';
import 'package:driver/utils/notification_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:geoflutterfire2/geoflutterfire2.dart';
import 'package:location/location.dart';
import 'package:location/location.dart' as loc;

class HomeController extends GetxController with GetTickerProviderStateMixin {
  // ===== Observables =====
  RxBool isOnline = false.obs;
  RxBool isLoading = true.obs;
  RxBool isLocationLoading = false.obs;
  RxString profilePic = Constant.profileConstant.obs;
  RxString name = ''.obs;
  RxString phoneNumber = ''.obs;
  RxInt drawerIndex = 0.obs;
  RxInt totalRides = 0.obs;
  RxString otp = ''.obs;

  RxMap<String, double> dataMap = <String, double>{
    "New": 0,
    "Ongoing": 0,
    "Completed": 0,
    "Rejected": 0,
    "Cancelled": 0,
  }.obs;

  List<Color> colorList = [
    AppThemData.bookingNew,
    AppThemData.bookingOngoing,
    AppThemData.bookingCompleted,
    AppThemData.bookingRejected,
    AppThemData.bookingCancelled
  ];

  RxList<Color> color = <Color>[
    AppThemData.secondary50,
    AppThemData.success50,
    AppThemData.danger50,
    AppThemData.info50,
  ].obs;

  RxList colorDark = [
    AppThemData.secondary950,
    AppThemData.success950,
    AppThemData.danger950,
    AppThemData.info950
  ].obs;

  Rx<DriverUserModel> userModel = DriverUserModel().obs;
  Rx<BookingModel> bookingModel = BookingModel().obs;
  RxList<ReviewModel> reviewList = <ReviewModel>[].obs;
  RxList<RentalBookingModel> rentalRideList = <RentalBookingModel>[].obs;
  Rx<TextEditingController> currentReadingController =
      TextEditingController().obs;

  late TabController tabController;
  final List<Map<String, dynamic>> rideTabs = [];

  Location location = Location();

  @override
  void onInit() {
    getData();
    super.onInit();
  }

  @override
  void onClose() {
    tabController.dispose();
    super.onClose();
  }

  void tabInitate() {
    getRideTabs();
    tabController = TabController(length: rideTabs.length, vsync: this);
  }

  Future<void> getData() async {
    isLoading.value = true;
    tabInitate();
    getUserData();
    if (userModel.value.isVerified == true) {
      checkActiveStatus();
    }
    updateCurrentLocation();

    unawaited(getReviews());
    unawaited(getFcm());
    unawaited(getChartData());

    isLoading.value = false;
    update();
  }

  void getUserData() async {
    FireStoreUtils.fireStore
        .collection(CollectionName.drivers)
        .doc(FireStoreUtils.getCurrentUid())
        .snapshots()
        .listen((event) {
      if (!event.exists) return;

      userModel.value = DriverUserModel.fromJson(event.data()!);
      Constant.userModel = userModel.value;

      isOnline.value = userModel.value.isOnline ?? false;
      profilePic.value = (userModel.value.profilePic ?? "").isNotEmpty
          ? userModel.value.profilePic!
          : Constant.profileConstant;
      name.value = userModel.value.fullName ?? '';
      phoneNumber.value = (userModel.value.countryCode ?? '') +
          (userModel.value.phoneNumber ?? '');
      if (userModel.value.bookingId != null &&
          userModel.value.bookingId!.isNotEmpty) {
        _listenBooking();
      }

      getRentalRide();
    });
  }

  void _listenBooking() {
    FireStoreUtils.fireStore
        .collection(CollectionName.bookings)
        .where("id", isEqualTo: userModel.value.bookingId)
        .where('bookingStatus', whereIn: [
          BookingStatus.bookingAccepted,
          BookingStatus.bookingPlaced,
          BookingStatus.bookingOngoing,
          BookingStatus.driverAssigned,
          BookingStatus.bookingOnHold
        ])
        .snapshots()
        .listen((querySnapshot) {
          if (querySnapshot.docs.isEmpty) {
            bookingModel.value = BookingModel();
            return;
          }

          bookingModel.value =
              BookingModel.fromJson(querySnapshot.docs.first.data());
        });
  }

  // ===== Reviews =====
  Future<void> getReviews() async {
    log("=======> Get Reviews");
    final value = await FireStoreUtils.getReviewList();
    if (value != null) reviewList.value = value;
  }

  Future<void> checkActiveStatus() async {
    if (userModel.value.isActive == false) {
      Get.defaultDialog(
        titlePadding: const EdgeInsets.only(top: 16),
        title: "Account Disabled".tr,
        middleText:
            "Your account has been disabled. Please contact the administrator."
                .tr,
        titleStyle:
            GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700),
        barrierDismissible: false,
        onWillPop: () async {
          await FirebaseAuth.instance.signOut();
          Get.offAll(const LoginView());
          return false;
        },
      );
    }
  }

  Future<void> getChartData() async {
    try {
      final results = await Future.wait([
        FireStoreUtils.getNewRide(),
        FireStoreUtils.getOngoingRide(),
        FireStoreUtils.getCompletedRide(),
        FireStoreUtils.getRejectedRide(),
        FireStoreUtils.getCancelledRide(),
      ]);

      int newRide = int.parse(results[0].toString());
      int onGoingRide = int.parse(results[1].toString());
      int completedRide = int.parse(results[2].toString());
      int rejectedRide = int.parse(results[3].toString());
      int cancelledRide = int.parse(results[4].toString());

      totalRides.value =
          newRide + onGoingRide + completedRide + rejectedRide + cancelledRide;

      dataMap.value = {
        "New": newRide.toDouble(),
        "Ongoing": onGoingRide.toDouble(),
        "Completed": completedRide.toDouble(),
        "Rejected": rejectedRide.toDouble(),
        "Cancelled": cancelledRide.toDouble(),
      };

      log("=======> Get Chart Data");
    } catch (e) {
      log("Error in getChartData: $e");
    }
  }

  Future<void> getFcm() async {
    final token = await NotificationService.getToken();
    if (userModel.value.id?.isNotEmpty == true &&
        userModel.value.fcmToken != token) {
      userModel.value.fcmToken = token;
      await FireStoreUtils.updateDriverUser(userModel.value);
      log("FCM Token updated: $token");
    } else {
      log("Skipped FCM update - userModel not loaded or token unchanged");
    }
  }

  DateTime _lastFirestoreUpdate = DateTime.fromMillisecondsSinceEpoch(0);

// 🔥 PRODUCTION VALUES
  final Duration firestoreThrottle = const Duration(seconds: 8);

  Future<void> updateCurrentLocation() async {
    loc.PermissionStatus permission = await location.hasPermission();
    if (permission != loc.PermissionStatus.granted) {
      permission = await location.requestPermission();
    }
    if (permission != loc.PermissionStatus.granted) return;
    location.enableBackgroundMode(enable: true);

    await location.changeSettings(
      accuracy: loc.LocationAccuracy.high,
      interval: 5000,
      distanceFilter: double.parse(Constant.driverLocationUpdate.toString()),
    );

    location.onLocationChanged.listen((data) async {
      if (data.latitude == null || data.longitude == null) return;

      await updateDriverFirestore(data);
    });
  }

  Future<void> updateDriverFirestore(loc.LocationData data) async {
    if (DateTime.now().difference(_lastFirestoreUpdate) < firestoreThrottle) {
      return;
    }
    _lastFirestoreUpdate = DateTime.now();

    final driver = await FireStoreUtils.getDriverUserProfile(
        FireStoreUtils.getCurrentUid());
    if (driver == null || driver.isOnline != true) return;

    driver.location =
        LocationLatLng(latitude: data.latitude!, longitude: data.longitude!);
    final GeoFirePoint geo = GeoFlutterFire()
        .point(latitude: data.latitude!, longitude: data.longitude!);
    driver.position = Positions(geoPoint: geo.geoPoint, geohash: geo.hash);
    driver.rotation = data.heading;

    await FireStoreUtils.updateDriverUser(driver);
  }

  // ===== Rental Rides =====
  void getRentalRide() {
    if (userModel.value.driverVehicleDetails?.vehicleTypeId == null ||
        userModel.value.location == null) {
      log("Missing data for getRentalRide");
      return;
    }

    final isFemaleDriver =
        Constant.userModel!.gender?.toLowerCase() == 'female';
    Query query = FirebaseFirestore.instance
        .collection(CollectionName.rentalRide)
        .where('bookingStatus', whereIn: [
      BookingStatus.bookingPlaced,
      BookingStatus.bookingAccepted,
      BookingStatus.bookingOngoing
    ]).where('rentalPackage.vehicleId',
            isEqualTo: userModel.value.driverVehicleDetails!.vehicleTypeId);

    // Current location
    GeoFirePoint center = GeoFlutterFire().point(
      latitude: userModel.value.location!.latitude!,
      longitude: userModel.value.location!.longitude!,
    );

    GeoFlutterFire()
        .collection(collectionRef: query)
        .within(
          center: center,
          radius: double.tryParse(Constant.radius) ?? 10.0, // default radius
          field: 'position',
          strictMode: false,
        )
        .listen((List<DocumentSnapshot> documents) {
      rentalRideList.clear();

      for (var doc in documents) {
        try {
          RentalBookingModel rentalBookingModel =
              RentalBookingModel.fromJson(doc.data() as Map<String, dynamic>);

          if ((rentalBookingModel.rejectedDriverId ?? [])
              .contains(FireStoreUtils.getCurrentUid())) {
            continue;
          }

          if (rentalBookingModel.bookingStatus == BookingStatus.bookingPlaced) {
            if (rentalBookingModel.isOnlyForFemale == true && !isFemaleDriver) {
              log("Skipping ${rentalBookingModel.id} — female-only ride and current driver is not female.");
              continue;
            }
          }

          // Add only valid rides
          if (rentalBookingModel.bookingStatus == BookingStatus.bookingPlaced ||
              ((rentalBookingModel.bookingStatus ==
                          BookingStatus.bookingAccepted ||
                      rentalBookingModel.bookingStatus ==
                          BookingStatus.bookingOngoing) &&
                  rentalBookingModel.driverId ==
                      FireStoreUtils.getCurrentUid())) {
            rentalRideList.add(rentalBookingModel);
          }
        } catch (e) {
          log("Error parsing rental ride: $e");
        }
      }
    }, onError: (error) {
      log("Error in rental ride stream: $error");
    });
  }

  // ===== Ride Tabs =====
  void getRideTabs() {
    rideTabs.clear();
    if (Constant.isCabAvailable) {
      rideTabs.add({'title': 'Cab', 'widget': CabRidesWidget()});
    }

    if (Constant.intercitySharingDocuments.first.isAvailable ||
        Constant.intercityPersonalDocuments.first.isAvailable) {
      rideTabs
          .add({'title': 'Intercity', 'widget': IntercityRideForHomeView()});
    }

    if (Constant.parcelDocuments.isNotEmpty &&
        Constant.parcelDocuments.first.isAvailable) {
      rideTabs.add({'title': 'Parcel', 'widget': ParcelRideForHomeView()});
    }

    if (Constant.isRentalAvailable == true) {
      rideTabs.add({'title': 'Rental', 'widget': RentalRidesWidget()});
    }
  }

  // ===== Delete Account =====
  Future<void> deleteUserAccount() async {
    try {
      FireStoreUtils.fireStore
          .collection(CollectionName.referral)
          .where('userId', isEqualTo: FireStoreUtils.getCurrentUid())
          .get()
          .then((value) {
        for (var doc in value.docs) {
          doc.reference.delete();
        }
      });
      await FirebaseFirestore.instance
          .collection(CollectionName.drivers)
          .doc(FireStoreUtils.getCurrentUid())
          .delete();

      await FirebaseAuth.instance.currentUser!.delete();
    } on FirebaseAuthException catch (e) {
      log("FirebaseAuth Exception :: $e");
    } catch (error) {
      log("Error in delete user :: $error");
    }
  }
}
