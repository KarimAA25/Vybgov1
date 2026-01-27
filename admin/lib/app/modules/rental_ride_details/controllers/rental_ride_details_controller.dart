import 'dart:developer' as developer;

import 'package:admin/app/models/driver_user_model.dart';
import 'package:admin/app/models/payment_method_model.dart';
import 'package:admin/app/models/rental_booking_model.dart';
import 'package:admin/app/models/user_model.dart';
import 'package:admin/app/utils/fire_store_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RentalRideDetailsController extends GetxController {
  RxString title = "Rental Ride Details".tr.obs;
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  RxBool isLoading = true.obs;
  Rx<RentalBookingModel> rentalModel = RentalBookingModel().obs;
  Rx<DriverUserModel> driverModel = DriverUserModel().obs;
  Rx<UserModel> userModel = UserModel().obs;

  RxDouble extraKm = 0.0.obs;
  RxInt extraHours = 0.obs;

  Rx<PaymentModel> paymentModel = PaymentModel().obs;
  @override
  void onInit() {
    super.onInit();
    getArgument();
  }

  Future<void> getArgument() async {
    isLoading.value = true;
    try {
      String? bookingId = Get.parameters['rentalBookingId']!;
      await FireStoreUtils.getRentalRideByBookingId(bookingId).then((value) async {
        if (value != null) {
          rentalModel.value = value;
          calculateExtraKmAndHours();
        }
        await FireStoreUtils.getDriverByDriverID(rentalModel.value.driverId.toString()).then((driver) {
          if (driver != null) {
            driverModel.value = driver;
          }
        });
        await FireStoreUtils.getUserByUserID(rentalModel.value.customerId.toString()).then((user) {
          if (user != null) {
            userModel.value = user;
          }
        });
        await FireStoreUtils.getPayment().then((value) {
          if (value != null) {
            paymentModel.value = value;
          }
        });

        isLoading.value = false;
      });
    } catch (e) {
      isLoading.value = false;
      developer.log("Error in getArgument: $e");
    }
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
}
