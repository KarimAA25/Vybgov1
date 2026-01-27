// ignore_for_file: depend_on_referenced_packages

import 'package:driver/app/models/rental_booking_model.dart';
import 'package:driver/constant/booking_status.dart';
import 'package:driver/constant/constant.dart';
import 'package:driver/utils/fire_store_utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ReasonForCancelRentalRideController extends GetxController {
  Rx<RentalBookingModel> rentalBookingModel = RentalBookingModel().obs;
  Rx<TextEditingController> otherReasonController = TextEditingController().obs;

  RxInt selectedIndex = 0.obs;

  List<dynamic> reasons = Constant.cancellationReason;

  Future<bool> cancelBooking(RentalBookingModel bookingModels) async {
    RentalBookingModel bookingModel = bookingModels;
    bookingModel.bookingStatus = BookingStatus.bookingRejected;
    bookingModel.cancelledBy = FireStoreUtils.getCurrentUid();
    bookingModel.driverId = FireStoreUtils.getCurrentUid();
    bookingModel.cancelledReason = reasons[selectedIndex.value] != "Other" ? reasons[selectedIndex.value] : otherReasonController.value.text.trim();
    bookingModel.updateAt = Timestamp.now();
    bool result = await FireStoreUtils.setRentalRide(bookingModel);
    return result;
  }
}
