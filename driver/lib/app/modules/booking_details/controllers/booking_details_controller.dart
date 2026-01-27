// ignore_for_file: unnecessary_overrides

// ignore_for_file: depend_on_referenced_packages
import 'dart:async';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:driver/app/models/driver_user_model.dart';
import 'package:driver/app/models/emergency_number_model.dart';
import 'package:driver/app/models/location_lat_lng.dart';
import 'package:driver/app/models/loyalty_point_transaction_model.dart';
import 'package:driver/app/models/review_customer_model.dart';
import 'package:driver/app/models/sos_alerts_model.dart';
import 'package:driver/app/models/vehicle_type_model.dart';
import 'package:driver/constant/collection_name.dart';
import 'package:driver/services/email_template_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:driver/app/models/booking_model.dart';
import 'package:driver/app/models/map_model.dart';
import 'package:driver/app/models/user_model.dart';
import 'package:driver/constant/booking_status.dart';
import 'package:driver/constant/constant.dart';
import 'package:driver/constant/send_notification.dart';
import 'package:driver/constant_widgets/show_toast_dialog.dart';
import 'package:driver/utils/fire_store_utils.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class BookingDetailsController extends GetxController {
  RxBool isLoading = true.obs;
  Rx<BookingModel> bookingModel = BookingModel().obs;
  RxList<ReviewModel> reviewList = <ReviewModel>[].obs;
  Rx<ReviewModel> driverToCustomerReview = ReviewModel().obs;
  Rx<ReviewModel> customerToDriverReview = ReviewModel().obs;

  RxList<String> selectedEmergencyContactIds = <String>[].obs;
  RxList<EmergencyContactModel> totalEmergencyContacts = <EmergencyContactModel>[].obs;
  Rx<EmergencyContactModel> contactModel = EmergencyContactModel().obs;
  Rx<SOSAlertsModel> sosAlertsModel = SOSAlertsModel().obs;
  RxBool canShowSOS = false.obs;

  @override
  void onInit() {
    getArguments();
    super.onInit();
  }

  Future<void> getArguments() async {
    if (Get.arguments != null) {
      bookingModel.value = Get.arguments['bookingModel'];
      log("+++++++++> ${bookingModel.toJson()}");
      getBookingDetails();
      getReview();
      getEmergencyContacts();
      if (bookingModel.value.bookingStatus == BookingStatus.bookingOngoing) {
        checkSOSAvailability();
      }
    }
    isLoading.value = false;
    update();
  }

  Future<void> getReview() async {
    final snapshot = await FirebaseFirestore.instance.collection(CollectionName.review).get();
    reviewList.value = snapshot.docs.map((doc) => ReviewModel.fromJson(doc.data())).toList();

    try {
      customerToDriverReview.value = reviewList.firstWhere((r) => r.bookingId == bookingModel.value.id && r.type == Constant.typeDriver);
    } catch (_) {
      customerToDriverReview.value = ReviewModel();
    }

    try {
      driverToCustomerReview.value = reviewList.firstWhere((r) => r.bookingId == bookingModel.value.id && r.type == Constant.typeCustomer);
    } catch (_) {
      driverToCustomerReview.value = ReviewModel();
    }
  }

  void getBookingDetails() {
    FireStoreUtils.fireStore.collection(CollectionName.bookings).doc(bookingModel.value.id).snapshots().listen((value) {
      if (value.exists) {
        bookingModel.value = BookingModel.fromJson(value.data()!);
        update();
      }
    });
  }

  @override
  void onClose() {
    super.onClose();
  }

  Future<String> getDistanceInKm() async {
    String km = '';
    LatLng departureLatLong = LatLng(bookingModel.value.pickUpLocation!.latitude ?? 0.0, bookingModel.value.pickUpLocation!.longitude ?? 0.0);
    LatLng destinationLatLong = LatLng(bookingModel.value.dropLocation!.latitude ?? 0.0, bookingModel.value.dropLocation!.longitude ?? 0.0);
    MapModel? mapModel = await Constant.getDurationDistance(departureLatLong, destinationLatLong);
    if (mapModel != null) {
      km = mapModel.rows!.first.elements!.first.distance!.text!;
    }
    return km;
  }

  Future<bool> completeBooking(BookingModel bookingModel) async {
    UserModel? userModel = await FireStoreUtils.getUserProfile(bookingModel.customerId ?? "");
    if (userModel != null) {
      userModel.activeRideId = "";
    }
    if (Constant.loyaltyProgram != null) {
      LoyaltyPointTransactionModel pointTransaction = LoyaltyPointTransactionModel(
        id: Constant.getUuid(),
        note: "Loyalty Point earned for Cab Ride #${bookingModel.id!.substring(0, 5)}",
        customerId: bookingModel.customerId,
        transactionId: bookingModel.id,
        points: Constant.loyaltyProgram!.points ?? "0",
        isCredit: true,
        createdAt: Timestamp.now(),
      );

      await FireStoreUtils.setLoyaltyPointTransaction(pointTransaction);
      if (userModel != null) {
        int newCredits = int.parse(userModel.loyaltyCredits ?? "0") + int.parse(Constant.loyaltyProgram!.points ?? "0");
        userModel.loyaltyCredits = newCredits.toString();
      }
    }
    if (userModel != null) {
      await FireStoreUtils.updateUser(userModel);
    }
    bookingModel.bookingStatus = BookingStatus.bookingCompleted;
    bookingModel.updateAt = Timestamp.now();
    bookingModel.dropTime = Timestamp.now();
    bool? isStarted = await FireStoreUtils.setBooking(bookingModel);

    DriverUserModel? driverModel = await FireStoreUtils.getDriverUserProfile(bookingModel.driverId.toString());
    if (driverModel != null) {
      driverModel.bookingId = "";
      driverModel.status = "free";
      await FireStoreUtils.updateDriverUser(driverModel);
    }

    ShowToastDialog.showToast("Your ride is completed....".tr);

    await EmailTemplateService.sendEmail(
      type: "booking_completed",
      toEmail: driverModel!.email.toString(),
      variables: {
        "name": driverModel.fullName.toString(),
        "booking_id": bookingModel.id.toString(),
        "pickup_location": bookingModel.pickUpLocationAddress.toString(),
        "drop_location": bookingModel.dropLocationAddress.toString(),
        "amount": Constant.calculateFinalAmount(bookingModel).toString(),
        "booking_time": "${Constant.timestampToDate(bookingModel.createAt!)} ${Constant.timestampToTime12Hour(bookingModel.createAt)}"
      },
    );

    // Fetch user profile and send notification only if booking update succeeded
    if (isStarted == true) {
      UserModel? receiverUserModel = await FireStoreUtils.getUserProfile(bookingModel.customerId.toString());
      if (receiverUserModel != null && receiverUserModel.fcmToken != null && receiverUserModel.fcmToken!.isNotEmpty) {
        Map<String, dynamic> playLoad = {"bookingId": bookingModel.id};
        await SendNotification.sendOneNotification(
          type: "order",
          token: receiverUserModel.fcmToken!,
          title: "Your Ride is Completed".tr,
          customerId: receiverUserModel.id,
          senderId: FireStoreUtils.getCurrentUid(),
          bookingId: bookingModel.id.toString(),
          driverId: bookingModel.driverId.toString(),
          body: 'Your ride has been successfully completed. Please take a moment to review your experience.',
          payload: playLoad,isBooking: false
        );
      }

      await EmailTemplateService.sendEmail(
        type: "booking_completed",
        toEmail: receiverUserModel!.email.toString(),
        variables: {
          "name": receiverUserModel.fullName.toString(),
          "booking_id": bookingModel.id.toString(),
          "pickup_location": bookingModel.pickUpLocationAddress.toString(),
          "drop_location": bookingModel.dropLocationAddress.toString(),
          "amount": Constant.calculateFinalAmount(bookingModel).toString(),
          "booking_time": "${Constant.timestampToDate(bookingModel.createAt!)} ${Constant.timestampToTime12Hour(bookingModel.createAt)}"
        },
      );
    }
    return isStarted;
  }

  Future<void> calculateHoldCharges() async {
    if (bookingModel.value.holdTiming != null && bookingModel.value.holdTiming!.isNotEmpty) {
      bookingModel.value.holdTiming!.last.endTime = Timestamp.now();
    }
    bookingModel.value.bookingStatus = BookingStatus.bookingOngoing;
    if (bookingModel.value.holdTiming == null || bookingModel.value.holdTiming!.isEmpty) return;

    // Find zone charges for the booked vehicle
    ZoneChargesModel? currentZoneCharge = bookingModel.value.vehicleType!.zoneCharges?.firstWhere(
      (zc) => zc.zoneId == bookingModel.value.zoneModel!.id,
      orElse: () => bookingModel.value.vehicleType!.zoneCharges!.first,
    );

    if (currentZoneCharge == null) return;

    // Parse hold charge per minute
    double holdChargePerMinute = double.tryParse(currentZoneCharge.charges!.holdCharge ?? '0') ?? 0;

    double totalHoldCharge = 0.0;

    for (var hold in bookingModel.value.holdTiming!) {
      if (hold.endTime != null) {
        // Duration in minutes for each hold period
        final seconds = hold.endTime!.seconds - hold.startTime!.seconds;
        final minutes = seconds / 60.0;
        log("==========> Total Minutes: $minutes");

        // Add hold charge for this period
        totalHoldCharge += holdChargePerMinute * minutes;
      }
      log("==========> Hold Charge: $totalHoldCharge");
    }

    // Set holdCharges directly (do NOT add old hold charge)
    bookingModel.value.holdCharges = totalHoldCharge.toStringAsFixed(2);
    bookingModel.value.updateAt = Timestamp.now();
    await FireStoreUtils.setBooking(bookingModel.value);
    ShowToastDialog.showToast("Ride resumed".tr);

    UserModel? receiverUserModel = await FireStoreUtils.getUserProfile(bookingModel.value.customerId.toString());
    Map<String, dynamic> playLoad = <String, dynamic>{"bookingId": bookingModel.value.id};

    await SendNotification.sendOneNotification(
        type: "order",
        token: receiverUserModel!.fcmToken.toString(),
        title: "Your Ride has Resumed".tr,
        customerId: receiverUserModel.id,
        senderId: FireStoreUtils.getCurrentUid(),
        bookingId: bookingModel.value.id.toString(),
        driverId: bookingModel.value.driverId.toString(),
        body: 'Your ride #${bookingModel.value.id.toString().substring(0, 4)} has Resumed',
        payload: playLoad,isBooking: false);
  }

  Future<void> checkSOSAvailability() async {
    FirebaseFirestore.instance
        .collection(CollectionName.sosAlerts)
        .where('bookingId', isEqualTo: bookingModel.value.id)
        .where('driverId', isEqualTo: FireStoreUtils.getCurrentUid())
        .where('type', isEqualTo: 'driver')
        .limit(1)
        .snapshots()
        .listen(
      (event) {
        canShowSOS.value = event.docs.isEmpty;
      },
    );
  }

  Future<void> callOnHelpline() async {
    try {
      ShowToastDialog.showLoader("Sending SOS...".tr);
      final Position position = await Geolocator.getCurrentPosition(locationSettings: LocationSettings(accuracy: LocationAccuracy.high));

      sosAlertsModel.value.id = Constant.getUuid();
      sosAlertsModel.value.userId = FireStoreUtils.getCurrentUid();
      sosAlertsModel.value.bookingId = bookingModel.value.id;
      sosAlertsModel.value.customerId = bookingModel.value.customerId;
      sosAlertsModel.value.createdAt = Timestamp.now();
      sosAlertsModel.value.location = LocationLatLng(
        latitude: position.latitude,
        longitude: position.longitude,
      );
      sosAlertsModel.value.emergencyType = "call${Constant.sosAlertNumber}";
      sosAlertsModel.value.type = Constant.typeDriver;
      sosAlertsModel.value.status = "pending";

      await FireStoreUtils.addSOSAlerts(sosAlertsModel.value);
      ShowToastDialog.closeLoader();

      final Uri uri = Uri(scheme: 'tel', path: Constant.sosAlertNumber);

      if (await canLaunchUrl(uri)) {
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
      }
    } catch (e) {
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast("Unable to initiate SOS".tr);
      log("call911 error: $e");
    }
  }

  void getEmergencyContacts() {
    FireStoreUtils.getEmergencyContacts((updatedList) {
      final uniquePersons = <String, EmergencyContactModel>{};

      for (final person in updatedList) {
        final id = person.id;
        if (id != null && id.isNotEmpty) {
          uniquePersons[id] = person;
        }
      }

      totalEmergencyContacts.value = uniquePersons.values.toList();

      log('Updated emergency contact list: ${totalEmergencyContacts.length}');
      update();
    });
  }

  Future<void> notifySelectedContacts() async {
    ShowToastDialog.showLoader("Please Wait..".tr);
    if (selectedEmergencyContactIds.isEmpty) {
      ShowToastDialog.showToast("Please select at least one contact".tr);
      ShowToastDialog.closeLoader();
      return;
    }
    try {
      final Position position = await Geolocator.getCurrentPosition(locationSettings: LocationSettings(accuracy: LocationAccuracy.high));
      final selectedContacts = totalEmergencyContacts.where((c) => selectedEmergencyContactIds.contains(c.id)).toList();

      sosAlertsModel.value.id = Constant.getUuid();
      sosAlertsModel.value.userId = FireStoreUtils.getCurrentUid();
      sosAlertsModel.value.bookingId = bookingModel.value.id;
      sosAlertsModel.value.customerId = bookingModel.value.customerId;
      sosAlertsModel.value.contactIds = selectedEmergencyContactIds;
      sosAlertsModel.value.createdAt = Timestamp.now();
      sosAlertsModel.value.location = LocationLatLng(latitude: position.latitude, longitude: position.longitude);
      sosAlertsModel.value.emergencyType = "contacts";
      sosAlertsModel.value.type = Constant.typeDriver;
      sosAlertsModel.value.status = "pending";

      await FireStoreUtils.addSOSAlerts(sosAlertsModel.value).then(
        (value) {
          ShowToastDialog.closeLoader();
        },
      );
      final String message = "🚨 DRIVER EMERGENCY SOS 🚨\n\n"
          "I am the driver and I need immediate help during an active ride.\n\n"
          "Booking ID: ${bookingModel.value.id}\n"
          "Ride Status: ${bookingModel.value.bookingStatus}\n\n"
          "Live Location:\n"
          "https://maps.google.com/?q=${position.latitude},${position.longitude}\n\n"
          "Please respond urgently.";

      for (final contact in selectedContacts) {
        final phone = "${contact.countryCode}${contact.phoneNumber}".replaceAll(" ", "");

        final Uri smsUri = Uri(
          scheme: 'sms',
          path: phone,
          queryParameters: {'body': message},
        );

        if (await canLaunchUrl(smsUri)) {
          await launchUrl(
            smsUri,
            mode: LaunchMode.externalApplication,
          );
        }
      }
      Get.back();
      ShowToastDialog.showToast("Emergency contacts notified".tr);
    } catch (e) {
      log('Error notifying contacts: $e');
    }
  }
}
