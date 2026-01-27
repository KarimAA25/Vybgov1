import 'dart:developer';

import 'package:driver/app/models/booking_model.dart';
import 'package:driver/app/models/driver_user_model.dart';
import 'package:driver/app/models/intercity_model.dart';
import 'package:driver/app/models/parcel_model.dart';
import 'package:driver/app/models/rental_booking_model.dart';
import 'package:driver/app/models/review_customer_model.dart';
import 'package:driver/app/models/user_model.dart';
import 'package:driver/utils/fire_store_utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AddCustomerReviewController extends GetxController {
  RxBool isLoading = true.obs;
  RxDouble rating = 0.0.obs;
  Rx<TextEditingController> commentController = TextEditingController().obs;

  Rx<ReviewModel> reviewModel = ReviewModel().obs;
  Rx<DriverUserModel> driverModel = DriverUserModel().obs;
  Rx<UserModel> userModel = UserModel().obs;
  Rx<BookingModel> bookingModel = BookingModel().obs;
  Rx<IntercityModel> intercityModel = IntercityModel().obs;
  Rx<ParcelModel> parcelModel = ParcelModel().obs;
  Rx<RentalBookingModel> rentalModel = RentalBookingModel().obs;
  RxString customerId = ''.obs;
  RxString bookingId = ''.obs;

  @override
  void onInit() {
    getArgument();
    super.onInit();
  }

  Future<void> getArgument() async {
    dynamic argumentData = Get.arguments;
    if (argumentData != null) {
      bool isIntercity = argumentData["isIntercity"] ?? false;
      bool isParcel = argumentData["isParcel"] ?? false;
      bool isRental = argumentData["isRental"] ?? false;
      bool isCab = argumentData["isCab"] ?? false;

      if (isIntercity) {
        intercityModel.value = argumentData["bookingModel"];
        customerId.value = intercityModel.value.customerId!;
        bookingId.value = intercityModel.value.id!;
      } else if (isParcel) {
        parcelModel.value = argumentData["bookingModel"];
        customerId.value = parcelModel.value.customerId!;
        bookingId.value = parcelModel.value.id!;
      } else if (isRental) {
        rentalModel.value = argumentData["bookingModel"];
        customerId.value = rentalModel.value.customerId!;
        bookingId.value = rentalModel.value.id!;
      } else if (isCab) {
        bookingModel.value = argumentData["bookingModel"];
        customerId.value = bookingModel.value.customerId!;
        bookingId.value = bookingModel.value.id!;
      }
    }
    log("----->1");
    await FireStoreUtils.getUserProfile(customerId.value.toString()).then((value) {
      if (value != null) {
        log("----->2");
        userModel.value = value;
      }
    });
    await FireStoreUtils.getDriverUserProfile(FireStoreUtils.getCurrentUid()).then((value) {
      if (value != null) {
        log("----->3");
        driverModel.value = value;
      }
    });
    isLoading.value = false;
    update();
  }
}
