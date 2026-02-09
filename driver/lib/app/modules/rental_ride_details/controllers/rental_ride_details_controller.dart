// ignore_for_file: depend_on_referenced_packages

import 'dart:async';
import 'dart:developer';

import 'package:driver/app/models/driver_user_model.dart';
import 'package:driver/app/models/emergency_number_model.dart';
import 'package:driver/app/models/location_lat_lng.dart';
import 'package:driver/app/models/loyalty_point_transaction_model.dart';
import 'package:driver/app/models/rental_booking_model.dart';
import 'package:driver/app/models/review_customer_model.dart';
import 'package:driver/app/models/sos_alerts_model.dart';
import 'package:driver/app/models/user_model.dart';
import 'package:driver/constant/booking_status.dart';
import 'package:driver/constant/collection_name.dart';
import 'package:driver/constant/constant.dart';
import 'package:driver/constant/send_notification.dart';
import 'package:driver/constant_widgets/show_toast_dialog.dart';
import 'package:driver/services/email_template_service.dart';
import 'package:driver/utils/fire_store_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

class RentalRideDetailsController extends GetxController {
  RxBool isLoading = true.obs;
  Rx<RentalBookingModel> rentalModel = RentalBookingModel().obs;
  RxList<ReviewModel> reviewList = <ReviewModel>[].obs;
  Rx<TextEditingController> completedReadingController = TextEditingController().obs;
  Rx<TextEditingController> currentReadingController = TextEditingController().obs;

  RxDouble extraKm = 0.0.obs;
  RxInt extraHours = 0.obs;

  Rx<ReviewModel> driverToCustomerReview = ReviewModel().obs;
  Rx<ReviewModel> customerToDriverReview = ReviewModel().obs;

  RxList<String> selectedEmergencyContactIds = <String>[].obs;
  RxList<EmergencyContactModel> totalEmergencyContacts = <EmergencyContactModel>[].obs;
  Rx<EmergencyContactModel> contactModel = EmergencyContactModel().obs;
  Rx<SOSAlertsModel> sosAlertsModel = SOSAlertsModel().obs;
  RxBool canShowSOS = false.obs;

  StreamSubscription<DocumentSnapshot>? _bookingSub;
  StreamSubscription? _emergencySub;

  @override
  void onInit() {
    getArguments();
    calculateExtraKmAndHours();
    super.onInit();
  }

  void getArguments() {
    dynamic arguments = Get.arguments;
    if (arguments == null || arguments is! Map || arguments['rentalBookingModel'] == null) {
      isLoading.value = false;
      Get.back();
      return;
    }

    rentalModel.value = arguments['rentalBookingModel'];
    getBookingDetails();
    getEmergencyContacts();
    if (rentalModel.value.bookingStatus == BookingStatus.bookingOngoing) {
      checkSOSAvailability();
    }
    getReview();
    isLoading.value = false;
  }

  Future<void> getBookingDetails() async {
    _bookingSub?.cancel();
    _bookingSub = FireStoreUtils.fireStore.collection(CollectionName.rentalRide).doc(rentalModel.value.id).snapshots().listen((value) {
      if (value.exists) {
        rentalModel.value = RentalBookingModel.fromJson(value.data()!);
        update();
      }
    });
  }

  Future<void> getReview() async {
    final snapshot = await FirebaseFirestore.instance.collection(CollectionName.review).get();
    reviewList.value = snapshot.docs.map((doc) => ReviewModel.fromJson(doc.data())).toList();

    try {
      customerToDriverReview.value = reviewList.firstWhere((r) => r.bookingId == rentalModel.value.id && r.type == Constant.typeDriver);
    } catch (_) {
      customerToDriverReview.value = ReviewModel();
    }

    try {
      driverToCustomerReview.value = reviewList.firstWhere((r) => r.bookingId == rentalModel.value.id && r.type == Constant.typeCustomer);
    } catch (_) {
      driverToCustomerReview.value = ReviewModel();
    }
  }

  Future<bool> completeBooking(RentalBookingModel bookingModel) async {
    if (Constant.loyaltyProgram != null) {
      LoyaltyPointTransactionModel pointTransaction = LoyaltyPointTransactionModel(
        id: Constant.getUuid(),
        note: "Loyalty Point earned for Rental Rides #${bookingModel.id!.substring(0, 5)}",
        customerId: bookingModel.customerId,
        transactionId: bookingModel.id,
        points: Constant.loyaltyProgram!.points ?? "0",
        isCredit: true,
        createdAt: Timestamp.now(),
      );

      await FireStoreUtils.setLoyaltyPointTransaction(pointTransaction);

      UserModel? userModel = await FireStoreUtils.getUserProfile(bookingModel.customerId ?? "");
      if (userModel != null) {
        int newCredits = int.parse(userModel.loyaltyCredits ?? "0") + int.parse(Constant.loyaltyProgram!.points ?? "0");
        userModel.loyaltyCredits = newCredits.toString();

        await FireStoreUtils.updateUser(userModel);
      }
    }

    bookingModel.bookingStatus = BookingStatus.bookingCompleted;
    bookingModel.updateAt = Timestamp.now();
    bookingModel.dropTime = Timestamp.now();
    bool? isStarted = await FireStoreUtils.setRentalRide(bookingModel);
    ShowToastDialog.showToast("Your ride is completed....".tr);

    DriverUserModel? driverModel = await FireStoreUtils.getDriverUserProfile(bookingModel.driverId.toString());
    await EmailTemplateService.sendEmail(
      type: "booking_completed",
      toEmail: driverModel!.email.toString(),
      variables: {
        "name": driverModel.fullName.toString(),
        "booking_id": bookingModel.id.toString(),
        "pickup_location": bookingModel.pickUpLocationAddress.toString(),
        "drop_location": "",
        "amount": Constant.calculateFinalRentalRideAmount(bookingModel).toString(),
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
          title: 'Your Ride is Completed',
          customerId: receiverUserModel.id,
          senderId: FireStoreUtils.getCurrentUid(),
          bookingId: bookingModel.id.toString(),
          driverId: bookingModel.driverId.toString(),isBooking: false,
          body: 'Your ride has been successfully completed. Please take a moment to review your experience.',
          payload: playLoad,
        );
      }
      await EmailTemplateService.sendEmail(
        type: "booking_completed",
        toEmail: receiverUserModel!.email.toString(),
        variables: {
          "name": receiverUserModel.fullName.toString(),
          "booking_id": bookingModel.id.toString(),
          "pickup_location": bookingModel.pickUpLocationAddress.toString(),
          "drop_location": "",
          "amount": Constant.calculateFinalRentalRideAmount(bookingModel).toString(),
          "booking_time": "${Constant.timestampToDate(bookingModel.createAt!)} ${Constant.timestampToTime12Hour(bookingModel.createAt)}"
        },
      );
    }
    return isStarted;
  }

  void calculateExtraKmAndHours() {
    try {
      // Get completed and current KM
      double completedKM = double.tryParse(rentalModel.value.completedKM ?? '0.0') ?? 0.0;
      double currentKM = double.tryParse(rentalModel.value.currentKM ?? '0.0') ?? 0.0;

      double includedDistance = double.tryParse(rentalModel.value.rentalPackage?.includedDistance ?? '0.0') ?? 0.0;
      double extraKmTemp = completedKM - currentKM;

      if (extraKmTemp > includedDistance) {
        double overKm = extraKmTemp - includedDistance;
        extraKm.value = overKm;
      } else {
        extraKm.value = 0;
      }

      // Hours calculation
      if (rentalModel.value.pickupTime != null) {
        DateTime pickupTime = rentalModel.value.pickupTime!.toDate();

        // Use dropTime if set, otherwise fall back to current time
        DateTime endTime;
        if (rentalModel.value.dropTime != null) {
          endTime = rentalModel.value.dropTime!.toDate();
        } else {
          endTime = DateTime.now();
        }

        Duration totalDuration = endTime.difference(pickupTime);

        double includedHours = double.tryParse(rentalModel.value.rentalPackage?.includedHours ?? '0') ?? 0.0;
        double usedHours = totalDuration.inMinutes / 60.0;

        if (usedHours > includedHours) {
          extraHours.value = (usedHours - includedHours).ceil();
        } else {
          extraHours.value = 0;
        }
      } else {
        extraHours.value = 0;
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error calculating extra values for display: $e");
      }
      extraKm.value = 0;
      extraHours.value = 0;
    }
  }

  Future<void> checkSOSAvailability() async {
    FirebaseFirestore.instance
        .collection(CollectionName.sosAlerts)
        .where('bookingId', isEqualTo: rentalModel.value.id)
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
      sosAlertsModel.value.bookingId = rentalModel.value.id;
      sosAlertsModel.value.customerId = rentalModel.value.customerId;
      sosAlertsModel.value.createdAt = Timestamp.now();
      sosAlertsModel.value.location = LocationLatLng(
        latitude: position.latitude,
        longitude: position.longitude,
      );
      sosAlertsModel.value.emergencyType = "call${Constant.sosAlertNumber}";
      sosAlertsModel.value.type = Constant.typeCustomer;
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
    _emergencySub?.cancel();
    _emergencySub = FireStoreUtils.getEmergencyContacts((updatedList) {
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
      sosAlertsModel.value.bookingId = rentalModel.value.id;
      sosAlertsModel.value.customerId = rentalModel.value.customerId;
      sosAlertsModel.value.contactIds = selectedEmergencyContactIds;
      sosAlertsModel.value.createdAt = Timestamp.now();
      sosAlertsModel.value.location = LocationLatLng(latitude: position.latitude, longitude: position.longitude);
      sosAlertsModel.value.emergencyType = "contacts";
      sosAlertsModel.value.type = Constant.typeCustomer;
      sosAlertsModel.value.status = "pending";

      await FireStoreUtils.addSOSAlerts(sosAlertsModel.value).then(
        (value) {
          ShowToastDialog.closeLoader();
        },
      );
      final String message = "🚨 EMERGENCY ALERT – RENTAL RIDE 🚨\n\n"
          "I am a driver facing an emergency during an active rental ride.\n"
          "Immediate assistance is required.\n\n"
          "Booking ID: ${rentalModel.value.id}\n\n"
          "Live Location:\n"
          "https://maps.google.com/?q=${position.latitude},${position.longitude}";

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

  @override
  void onClose() {
    _bookingSub?.cancel();
    _emergencySub?.cancel();
    super.onClose();
  }
}
