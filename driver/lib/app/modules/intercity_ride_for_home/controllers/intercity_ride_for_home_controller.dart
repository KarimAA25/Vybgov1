// ignore_for_file: depend_on_referenced_packages

import 'dart:developer';

import 'package:driver/app/models/driver_user_model.dart';
import 'package:driver/app/models/intercity_model.dart';
import 'package:driver/app/models/loyalty_point_transaction_model.dart';
import 'package:driver/app/models/time_slots_charge_model.dart';
import 'package:driver/app/models/user_model.dart';
import 'package:driver/app/models/vehicle_type_model.dart';
import 'package:driver/constant/booking_status.dart';
import 'package:driver/constant/constant.dart';
import 'package:driver/constant/send_notification.dart';
import 'package:driver/constant_widgets/show_toast_dialog.dart';
import 'package:driver/services/email_template_service.dart';
import 'package:driver/utils/fire_store_utils.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class IntercityRideForHomeController extends GetxController {
  RxList<IntercityModel> intercityRideList = <IntercityModel>[].obs;

  @override
  void onInit() {
    getIntercityRides();
    super.onInit();
  }

  Future<void> getIntercityRides() async {
    FireStoreUtils.getInterCityOngoingRides((List<IntercityModel> updatedList) {
      intercityRideList.value = updatedList;
    });
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
          "drop_location": bookingModel.dropLocationAddress.toString(),
          "amount": Constant.calculateInterCityFinalAmount(bookingModel).toString(),
          "booking_time": "${Constant.timestampToDate(bookingModel.createAt!)} ${Constant.timestampToTime12Hour(bookingModel.createAt)}"
        },
      );
    }
    return isStarted;
  }

  Future<void> calculateHoldCharge(IntercityModel intercity) async {
    if (intercity.holdTiming != null && intercity.holdTiming!.isNotEmpty) {
      intercity.holdTiming!.last.endTime = Timestamp.now();
    }
    intercity.bookingStatus = BookingStatus.bookingOngoing;
    if (intercity.holdTiming == null || intercity.holdTiming!.isEmpty) return;

    List<TimeSlotsChargesModel> documentList = intercity.isPersonalRide == true ? Constant.intercityPersonalDocuments : Constant.intercitySharingDocuments;

    TimeSlotsChargesModel rideDoc = documentList.first;

    ZoneChargesModel? currentZoneCharge = rideDoc.zoneCharges.firstWhere(
      (zc) => zc.zoneId == intercity.zoneModel!.id,
      orElse: () => rideDoc.zoneCharges.first,
    );

    double holdChargePerMinute = double.tryParse(currentZoneCharge.charges!.holdCharge ?? '0') ?? 0;

    double totalHoldCharge = 0.0;

    for (var hold in intercity.holdTiming!) {
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
    intercity.holdCharges = totalHoldCharge.toStringAsFixed(2);
    intercity.updateAt = Timestamp.now();
    await FireStoreUtils.setInterCityBooking(intercity);
    ShowToastDialog.showToast("Ride resumed".tr);
  }
}
