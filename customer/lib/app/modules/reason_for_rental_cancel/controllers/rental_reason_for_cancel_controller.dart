// ignore_for_file: unnecessary_overrides, depend_on_referenced_packages

import 'dart:developer';

import 'package:customer/app/models/rental_booking_model.dart';
import 'package:customer/app/models/wallet_transaction_model.dart';
import 'package:customer/constant/booking_status.dart';
import 'package:customer/constant/constant.dart';
import 'package:customer/constant/send_notification.dart';
import 'package:customer/constant_widgets/show_toast_dialog.dart';
import 'package:customer/utils/fire_store_utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RentalReasonForCancelController extends GetxController {
  Rx<RentalBookingModel> rentalBookingModel = RentalBookingModel().obs;
  Rx<TextEditingController> otherReasonController = TextEditingController().obs;

  @override
  void onInit() {
    getArgument();
    super.onInit();
  }

  void getArgument() {
    dynamic argumentData = Get.arguments;
    if (argumentData != null) {
      rentalBookingModel.value = argumentData['rentalModel'];
    }
  }

  RxInt selectedIndex = 0.obs;

  List<dynamic> reasons = Constant.cancellationReason;

  Future<bool> cancelBooking(RentalBookingModel bookingModel) async {
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
        log('=======> success of transcation 3333 $value');
      }).catchError((error) {
        log('=======> error of transcation 3333 $error');
      });
    }

    if (Constant.cancellationCharge != null && Constant.cancellationCharge!.active == true && num.parse(Constant.cancellationCharge!.charge!) > 0) {
      bookingModel.cancellationCharge = Constant.cancellationCharge;
    }
    bookingModel.bookingStatus = BookingStatus.bookingCancelled;
    bookingModel.cancelledBy = FireStoreUtils.getCurrentUid();
    bookingModel.cancelledReason =
        reasons[selectedIndex.value] != "Other" ? reasons[selectedIndex.value].toString() : "${reasons[selectedIndex.value]} : ${otherReasonController.value.text}";
    final isCancelled = await FireStoreUtils.setRentalRide(bookingModel);
    ShowToastDialog.closeLoader();
    return isCancelled ?? false;
  }

  Future<void> sendCancelRideNotification() async {
    final receiverUserModel = await FireStoreUtils.getDriverUserProfile(rentalBookingModel.value.driverId.toString());
    if (receiverUserModel == null) return;
    final playLoad = {"bookingId": rentalBookingModel.value.id};
    await SendNotification.sendOneNotification(
        type: "order",
        token: receiverUserModel.fcmToken.toString(),
        title: 'Ride Cancelled',
        body: 'Ride #${rentalBookingModel.value.id.toString().substring(0, 5)} is cancelled by Customer',
        bookingId: rentalBookingModel.value.id,
        driverId: rentalBookingModel.value.driverId.toString(),
        senderId: FireStoreUtils.getCurrentUid(),
        payload: playLoad,
        isBooking: false);
  }
}
