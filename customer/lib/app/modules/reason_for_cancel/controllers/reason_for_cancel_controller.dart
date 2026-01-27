// ignore_for_file: unnecessary_overrides, depend_on_referenced_packages

import 'dart:developer';

import 'package:customer/app/models/booking_model.dart';
import 'package:customer/app/models/driver_user_model.dart';
import 'package:customer/app/models/wallet_transaction_model.dart';
import 'package:customer/constant/booking_status.dart';
import 'package:customer/constant/constant.dart';
import 'package:customer/constant/send_notification.dart';
import 'package:customer/constant_widgets/show_toast_dialog.dart';
import 'package:customer/utils/fire_store_utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ReasonForCancelController extends GetxController {
  Rx<BookingModel> bookingModel = BookingModel().obs;
  Rx<TextEditingController> otherReasonController = TextEditingController().obs;

  @override
  void onInit() {
    getArgument();
    super.onInit();
  }

  void getArgument() {
    dynamic argumentData = Get.arguments;
    if (argumentData != null) {
      bookingModel.value = argumentData['bookingModel'];
    }
  }

  RxInt selectedIndex = 0.obs;

  List<dynamic> reasons = Constant.cancellationReason;

  Future<bool> cancelBooking(BookingModel bookingModel) async {
    ShowToastDialog.showLoader("Please wait".tr);
    if (Constant.cancellationCharge != null && Constant.cancellationCharge!.active == true && num.parse(Constant.cancellationCharge!.charge!) > 0) {
      WalletTransactionModel cancellationChargeWallet = WalletTransactionModel(
        id: Constant.getUuid(),
        amount:
            "${Constant.calculateCancellationCharge(amount: ((double.parse(bookingModel.subTotal ?? '0.0')) - (double.parse(bookingModel.discount ?? '0.0'))).toString(), cancellationCharge: Constant.cancellationCharge)}",
        createdDate: Timestamp.now(),
        paymentType: "Wallet",
        transactionId: bookingModel.id,
        isCredit: false,
        type: Constant.typeCustomer,
        userId: bookingModel.customerId,
        note: "Ride Cancellation Charge Debited",
      );

      await FireStoreUtils.setWalletTransaction(cancellationChargeWallet).then((value) async {
        if (value == true) {
          await FireStoreUtils.updateUserWallet(
              amount:
                  "-${Constant.calculateCancellationCharge(amount: ((double.parse(bookingModel.subTotal ?? '0.0')) - (double.parse(bookingModel.discount ?? '0.0'))).toString(), cancellationCharge: Constant.cancellationCharge)}");
        }
      }).catchError((error) {
        log('=======> error  $error');
      });
    }

    if (Constant.cancellationCharge != null && Constant.cancellationCharge!.active == true && num.parse(Constant.cancellationCharge!.charge!) > 0) {
      bookingModel.cancellationCharge = Constant.cancellationCharge;
    }

    Constant.userModel!.activeRideId = "";
    await FireStoreUtils.updateUser(Constant.userModel!);

    bookingModel.bookingStatus = BookingStatus.bookingCancelled;
    bookingModel.cancelledBy = FireStoreUtils.getCurrentUid();
    bookingModel.cancelledReason =
        reasons[selectedIndex.value] != "Other" ? reasons[selectedIndex.value].toString() : "${reasons[selectedIndex.value].toString()} : ${otherReasonController.value.text}";
    final isCancelled = await FireStoreUtils.setBooking(bookingModel);
    if (isCancelled == true && bookingModel.driverId != null) {
      // Update driver status to free
      DriverUserModel? driverModel = await FireStoreUtils.getDriverUserProfile(bookingModel.driverId.toString());
      if (driverModel != null) {
        driverModel.bookingId = "";
        driverModel.status = "free";
        await FireStoreUtils.updateDriverUser(driverModel);
      }

      // Send notification to driver
      await sendCancelRideNotification();
      ShowToastDialog.closeLoader();
    }
    return isCancelled ?? false;
  }

  Future<void> sendCancelRideNotification() async {
    final receiverUserModel = await FireStoreUtils.getDriverUserProfile(bookingModel.value.driverId.toString());
    if (receiverUserModel == null) return;
    final playLoad = {"bookingId": bookingModel.value.id};
    await SendNotification.sendOneNotification(
        type: "order",
        token: receiverUserModel.fcmToken.toString(),
        title: 'Ride Cancelled',
        body: 'Ride #${bookingModel.value.id.toString().substring(0, 5)} is cancelled by Customer',
        bookingId: bookingModel.value.id,
        driverId: bookingModel.value.driverId.toString(),
        senderId: FireStoreUtils.getCurrentUid(),
        payload: playLoad,
        isBooking: false);
  }
}
