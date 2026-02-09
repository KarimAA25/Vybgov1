// ignore_for_file: unnecessary_overrides
import 'dart:async';
import 'dart:developer';

// ignore_for_file: depend_on_referenced_packages
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:driver/app/models/driver_user_model.dart';
import 'package:driver/app/models/emergency_number_model.dart';
import 'package:driver/app/models/intercity_model.dart';
import 'package:driver/app/models/location_lat_lng.dart';
import 'package:driver/app/models/loyalty_point_transaction_model.dart';
import 'package:driver/app/models/review_customer_model.dart';
import 'package:driver/app/models/sos_alerts_model.dart';
import 'package:driver/app/models/time_slots_charge_model.dart';
import 'package:driver/app/models/vehicle_type_model.dart';
import 'package:driver/app/modules/search_intercity_ride/controllers/search_ride_controller.dart';
import 'package:driver/constant/collection_name.dart';
import 'package:driver/services/email_template_service.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:driver/app/models/user_model.dart';
import 'package:driver/constant/booking_status.dart';
import 'package:driver/constant/constant.dart';
import 'package:driver/constant/send_notification.dart';
import 'package:driver/constant_widgets/show_toast_dialog.dart';
import 'package:driver/utils/fire_store_utils.dart';
import 'package:url_launcher/url_launcher.dart';

class InterCityBookingDetailsController extends GetxController {
  RxString bookingId = ''.obs;
  RxList<ReviewModel> reviewList = <ReviewModel>[].obs;
  Rx<IntercityModel> interCityModel = IntercityModel().obs;
  Rx<GlobalKey<FormState>> formKey = GlobalKey<FormState>().obs;
  TextEditingController enterBidAmountController = TextEditingController();
  RxBool isLoading = true.obs;
  RxBool isSearch = false.obs;

  Rx<ReviewModel> driverToCustomerReview = ReviewModel().obs;
  Rx<ReviewModel> customerToDriverReview = ReviewModel().obs;

  RxList<String> selectedEmergencyContactIds = <String>[].obs;
  RxList<EmergencyContactModel> totalEmergencyContacts = <EmergencyContactModel>[].obs;
  Rx<EmergencyContactModel> contactModel = EmergencyContactModel().obs;
  Rx<SOSAlertsModel> sosAlertsModel = SOSAlertsModel().obs;
  RxBool canShowSOS = false.obs;

  StreamSubscription<IntercityModel?>? _bookingSub;
  StreamSubscription? _emergencySub;

  @override
  void onInit() {
    super.onInit();
    getBookingDetails();
    getEmergencyContacts();
    if (interCityModel.value.bookingStatus == BookingStatus.bookingOngoing) {
      checkSOSAvailability();
    }
    getReview();
  }

  Future<void> getReview() async {
    final snapshot = await FirebaseFirestore.instance.collection(CollectionName.review).get();
    reviewList.value = snapshot.docs.map((doc) => ReviewModel.fromJson(doc.data())).toList();

    try {
      customerToDriverReview.value = reviewList.firstWhere((r) => r.bookingId == interCityModel.value.id && r.type == Constant.typeDriver);
    } catch (_) {
      customerToDriverReview.value = ReviewModel();
    }

    try {
      driverToCustomerReview.value = reviewList.firstWhere((r) => r.bookingId == interCityModel.value.id && r.type == Constant.typeCustomer);
    } catch (_) {
      driverToCustomerReview.value = ReviewModel();
    }
  }

  Future<void> getBookingDetails() async {
    isLoading.value = true;
    final args = Get.arguments;
    if (args == null || args is! Map || args["bookingId"] == null) {
      isLoading.value = false;
      Get.back();
      return;
    }

    bookingId.value = args["bookingId"];
    isSearch.value = args["isSearch"] ?? false;

    try {
      _bookingSub?.cancel();
      _bookingSub = FireStoreUtils.getInterCityRideDetails(bookingId.value).listen((IntercityModel? model) {
        if (model != null) {
          interCityModel.value = model;
        } else {
          log("⚠️ No booking details found for ID: ${bookingId.value}");
        }
        isLoading.value = false;
      });
    } catch (error) {
      log(" Error fetching booking details: $error");
      isLoading.value = false;
    }
  }

  Future<bool> completeInterCityBooking(IntercityModel bookingModel) async {
    if (Constant.loyaltyProgram != null) {
      LoyaltyPointTransactionModel pointTransaction = LoyaltyPointTransactionModel(
        id: Constant.getUuid(),
        note: "Loyalty Point earned for Intercity Ride #${bookingModel.id!.substring(0, 5)}",
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
    bool? isStarted = await FireStoreUtils.setInterCityBooking(bookingModel);
    ShowToastDialog.showToast("Your ride is completed....".tr);

    DriverUserModel? driverModel = await FireStoreUtils.getDriverUserProfile(bookingModel.driverId.toString());
    await EmailTemplateService.sendEmail(
      type: "booking_completed",
      toEmail: driverModel!.email.toString(),
      variables: {
        "name": driverModel.fullName.toString(),
        "booking_id": bookingModel.id.toString(),
        "pickup_location": bookingModel.pickUpLocationAddress.toString(),
        "drop_location": bookingModel.dropLocationAddress.toString(),
        "amount": Constant.calculateInterCityFinalAmount(bookingModel).toString(),
        "booking_time": "${Constant.timestampToDate(bookingModel.createAt!)} ${Constant.timestampToTime12Hour(bookingModel.createAt)}"
      },
    );

    if (isStarted == true) {
      UserModel? receiverUserModel = await FireStoreUtils.getUserProfile(bookingModel.customerId.toString());
      if (receiverUserModel != null && receiverUserModel.fcmToken != null && receiverUserModel.fcmToken!.isNotEmpty) {
        Map<String, dynamic> playLoad = <String, dynamic>{"bookingId": bookingModel.id};
        await SendNotification.sendOneNotification(
          type: "order",
          token: receiverUserModel.fcmToken!,
          title: 'Your Ride is Completed',
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
          "amount": Constant.calculateInterCityFinalAmount(bookingModel).toString(),
          "booking_time": "${Constant.timestampToDate(bookingModel.createAt!)} ${Constant.timestampToTime12Hour(bookingModel.createAt)}"
        },
      );
    }
    return isStarted;
  }

  Future<void> saveBidDetail() async {
    ShowToastDialog.showLoader('Please Wait..'.tr);

    BidModel bidModel = BidModel();

    bidModel.driverID = FireStoreUtils.getCurrentUid();
    bidModel.bidStatus = 'pending';
    bidModel.amount = enterBidAmountController.value.text;
    bidModel.id = Constant.getUuid();
    bidModel.createAt = Timestamp.now();
    interCityModel.value.driverBidIdList!.add(FireStoreUtils.getCurrentUid());
    interCityModel.value.bidList!.add(bidModel);

    await FireStoreUtils.setInterCityBooking(interCityModel.value);

    if (isSearch.value == true) {
      SearchRideController searchController = Get.put(SearchRideController());
      searchController.searchIntercityList.removeWhere((parcel) => parcel.id == interCityModel.value.id);
      searchController.intercityBookingList.removeWhere((parcel) => parcel.id == interCityModel.value.id);
      ShowToastDialog.closeLoader();
    }

    ShowToastDialog.closeLoader();
  }

  Future<void> calculateHoldCharge() async {
    if (interCityModel.value.holdTiming != null && interCityModel.value.holdTiming!.isNotEmpty) {
      interCityModel.value.holdTiming!.last.endTime = Timestamp.now();
    }
    interCityModel.value.bookingStatus = BookingStatus.bookingOngoing;
    if (interCityModel.value.holdTiming == null || interCityModel.value.holdTiming!.isEmpty) return;

    List<TimeSlotsChargesModel> documentList = interCityModel.value.isPersonalRide == true ? Constant.intercityPersonalDocuments : Constant.intercitySharingDocuments;

    TimeSlotsChargesModel rideDoc = documentList.first;

    ZoneChargesModel? currentZoneCharge = rideDoc.zoneCharges.firstWhere(
      (zc) => zc.zoneId == interCityModel.value.zoneModel!.id,
      orElse: () => rideDoc.zoneCharges.first,
    );

    double holdChargePerMinute = double.tryParse(currentZoneCharge.charges!.holdCharge ?? '0') ?? 0;

    double totalHoldCharge = 0.0;

    for (var hold in interCityModel.value.holdTiming!) {
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
    interCityModel.value.holdCharges = totalHoldCharge.toStringAsFixed(2);
    interCityModel.value.updateAt = Timestamp.now();
    await FireStoreUtils.setInterCityBooking(interCityModel.value);
    ShowToastDialog.showToast("Ride resumed".tr);
  }

  Future<void> checkSOSAvailability() async {
    FirebaseFirestore.instance
        .collection(CollectionName.sosAlerts)
        .where('bookingId', isEqualTo: interCityModel.value.id)
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
      sosAlertsModel.value.bookingId = interCityModel.value.id;
      sosAlertsModel.value.customerId = interCityModel.value.customerId;
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
      sosAlertsModel.value.bookingId = interCityModel.value.id;
      sosAlertsModel.value.customerId = interCityModel.value.customerId;
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
      final String message = "🚨 EMERGENCY ALERT 🚨\n"
          "I am the driver and need immediate assistance.\n\n"
          "Booking ID: ${interCityModel.value.id.toString()}\n\n"
          "My current location:\n"
          "https://maps.google.com/?q=${position.latitude},${position.longitude}\n\n"
          "Please contact emergency services or notify the passenger if possible.";

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
