// ignore_for_file: depend_on_referenced_packages, use_build_context_synchronously

import 'package:cached_network_image/cached_network_image.dart';
import 'package:driver/app/models/driver_user_model.dart';
import 'package:driver/app/models/rental_booking_model.dart';
import 'package:driver/app/models/user_model.dart';
import 'package:driver/app/modules/home/controllers/home_controller.dart';
import 'package:driver/app/modules/reason_for_cancel_rental_ride/views/reason_for_cancel_rental_ride_view.dart';
import 'package:driver/app/modules/rental_ride_details/views/rental_ride_details_view.dart';
import 'package:driver/app/routes/app_pages.dart';
import 'package:driver/constant/booking_status.dart';
import 'package:driver/constant/constant.dart';
import 'package:driver/constant/send_notification.dart';
import 'package:driver/constant_widgets/custom_dialog_box.dart';
import 'package:driver/constant_widgets/no_rides_view.dart';
import 'package:driver/constant_widgets/round_shape_button.dart';
import 'package:driver/constant_widgets/show_toast_dialog.dart';
import 'package:driver/extension/date_time_extension.dart';
import 'package:driver/theme/app_them_data.dart';
import 'package:driver/utils/dark_theme_provider.dart';
import 'package:driver/utils/fire_store_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RentalRidesWidget extends StatelessWidget {
  const RentalRidesWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetX(
        init: HomeController(),
        builder: (controller) {
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Visibility(
                  visible: controller.isOnline.value == true,
                  child: controller.rentalRideList.isEmpty
                      ? NoRidesView(themeChange: themeChange)
                      : ListView.builder(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          itemCount: controller.rentalRideList.length,
                          shrinkWrap: true,
                          itemBuilder: (context, index) {
                            RentalBookingModel rentalBookingModel = controller.rentalRideList[index];
                            return InkWell(
                              onTap: () {
                                Get.to(() => const RentalRideDetailsView(), arguments: {"rentalBookingModel": rentalBookingModel});
                              },
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                margin: const EdgeInsets.only(bottom: 16),
                                decoration: ShapeDecoration(
                                  shape: RoundedRectangleBorder(
                                    side: BorderSide(width: 1, color: themeChange.isDarkTheme() ? AppThemData.grey800 : AppThemData.grey100),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Text(
                                          rentalBookingModel.bookingTime!.toDate().dateMonthYear(),
                                          style: GoogleFonts.inter(
                                            color: themeChange.isDarkTheme() ? AppThemData.grey400 : AppThemData.grey500,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Container(
                                          height: 15,
                                          decoration: ShapeDecoration(
                                            shape: RoundedRectangleBorder(
                                              side: BorderSide(
                                                width: 1,
                                                strokeAlign: BorderSide.strokeAlignCenter,
                                                color: themeChange.isDarkTheme() ? AppThemData.grey800 : AppThemData.grey100,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            rentalBookingModel.bookingTime!.toDate().time(),
                                            style: GoogleFonts.inter(
                                              color: themeChange.isDarkTheme() ? AppThemData.grey400 : AppThemData.grey500,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Icon(
                                          Icons.keyboard_arrow_right_sharp,
                                          color: themeChange.isDarkTheme() ? AppThemData.grey400 : AppThemData.grey500,
                                        )
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Container(
                                      padding: const EdgeInsets.only(bottom: 12),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          CachedNetworkImage(
                                            height: 60,
                                            width: 60,
                                            imageUrl: rentalBookingModel.vehicleType!.image.toString(),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  rentalBookingModel.vehicleType!.title.toString(),
                                                  style: GoogleFonts.inter(
                                                    color: themeChange.isDarkTheme() ? AppThemData.grey25 : AppThemData.grey950,
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                                rentalBookingModel.bookingStatus == BookingStatus.bookingCancelled ||
                                                        rentalBookingModel.bookingStatus == BookingStatus.bookingRejected
                                                    ? SizedBox()
                                                    : Text(
                                                        (rentalBookingModel.paymentStatus ?? false) ? "Payment is Completed".tr : "Payment is Pending".tr,
                                                        style: GoogleFonts.inter(
                                                          color: themeChange.isDarkTheme() ? AppThemData.grey25 : AppThemData.grey950,
                                                          fontSize: 14,
                                                          fontWeight: FontWeight.w400,
                                                        ),
                                                      ).paddingOnly(top: 2),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          Column(
                                            mainAxisSize: MainAxisSize.min,
                                            mainAxisAlignment: MainAxisAlignment.end,
                                            crossAxisAlignment: CrossAxisAlignment.end,
                                            children: [
                                              Text(
                                                Constant.amountShow(amount: Constant.calculateFinalRentalRideAmount(rentalBookingModel).toStringAsFixed(2)),
                                                textAlign: TextAlign.right,
                                                style: GoogleFonts.inter(
                                                  color: themeChange.isDarkTheme() ? AppThemData.grey25 : AppThemData.grey950,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              const SizedBox(height: 2),
                                              Row(
                                                mainAxisSize: MainAxisSize.min,
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                children: [
                                                  SvgPicture.asset("assets/icon/ic_multi_person.svg"),
                                                  const SizedBox(width: 6),
                                                  Text(
                                                    rentalBookingModel.vehicleType!.persons.toString(),
                                                    style: GoogleFonts.inter(
                                                      color: AppThemData.primary500,
                                                      fontSize: 16,
                                                      fontWeight: FontWeight.w400,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: ShapeDecoration(
                                        color: themeChange.isDarkTheme() ? AppThemData.primary950 : AppThemData.primary50,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          SvgPicture.asset("assets/icon/ic_pick_up.svg"),
                                          SizedBox(
                                            width: 12,
                                          ),
                                          Expanded(
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  "Pickup Point".tr,
                                                  style: GoogleFonts.inter(
                                                    color: themeChange.isDarkTheme() ? AppThemData.grey25 : AppThemData.grey950,
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w400,
                                                  ),
                                                ),
                                                Text(
                                                  rentalBookingModel.pickUpLocationAddress.toString(),
                                                  maxLines: 3,
                                                  overflow: TextOverflow.ellipsis,
                                                  style: GoogleFonts.inter(
                                                    color: themeChange.isDarkTheme() ? AppThemData.grey25 : AppThemData.grey950,
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                )
                                              ],
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                    if ((((rentalBookingModel.bookingStatus ?? '') == BookingStatus.bookingPlaced) ||
                                            ((rentalBookingModel.bookingStatus ?? '') == BookingStatus.driverAssigned)) &&
                                        !rentalBookingModel.rejectedDriverId!.contains(FireStoreUtils.getCurrentUid())) ...{
                                      const SizedBox(height: 16),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Expanded(
                                            child: RoundShapeButton(
                                              title: "Cancel Ride".tr,
                                              buttonColor: AppThemData.danger500,
                                              buttonTextColor: AppThemData.white,
                                              onTap: () {
                                                showDialog(
                                                    context: context,
                                                    builder: (BuildContext context) {
                                                      return CustomDialogBox(
                                                          themeChange: themeChange,
                                                          title: "Cancel Ride".tr,
                                                          negativeButtonColor: themeChange.isDarkTheme() ? AppThemData.grey950 : AppThemData.grey50,
                                                          negativeButtonTextColor: themeChange.isDarkTheme() ? AppThemData.grey50 : AppThemData.grey950,
                                                          positiveButtonColor: AppThemData.danger500,
                                                          positiveButtonTextColor: AppThemData.grey25,
                                                          descriptions: "Are you sure you want cancel this ride?".tr,
                                                          positiveString: "Cancel Ride".tr,
                                                          negativeString: "Cancel".tr,
                                                          positiveClick: () async {
                                                            Navigator.pop(context);
                                                            List rejectedId = rentalBookingModel.rejectedDriverId ?? [];
                                                            rejectedId.add(FireStoreUtils.getCurrentUid());
                                                            rentalBookingModel.bookingStatus = BookingStatus.bookingRejected;
                                                            rentalBookingModel.rejectedDriverId = rejectedId;
                                                            rentalBookingModel.updateAt = Timestamp.now();
                                                            FireStoreUtils.setRentalRide(rentalBookingModel).then((value) async {
                                                              if (value == true) {
                                                                ShowToastDialog.showToast("Ride cancelled successfully!".tr);
                                                                if (rentalBookingModel.driverId!.isNotEmpty) {
                                                                  DriverUserModel? driverModel = await FireStoreUtils.getDriverUserProfile(rentalBookingModel.driverId.toString());
                                                                  driverModel!.bookingId = "";
                                                                  driverModel.status = "free";
                                                                  FireStoreUtils.updateDriverUser(driverModel);
                                                                }

                                                                Navigator.pop(context);
                                                              } else {
                                                                ShowToastDialog.showToast("Something went wrong!".tr);
                                                                Navigator.pop(context);
                                                              }
                                                            });
                                                          },
                                                          negativeClick: () {
                                                            Navigator.pop(context);
                                                          },
                                                          img: Image.asset(
                                                            "assets/icon/ic_close.png",
                                                            height: 58,
                                                            width: 58,
                                                          ));
                                                    });
                                              },
                                              size: Size(0, 42),
                                            ),
                                          ),
                                          SizedBox(
                                            width: 10,
                                          ),
                                          Expanded(
                                            child: RoundShapeButton(
                                              title: "Accept".tr,
                                              buttonColor: AppThemData.primary500,
                                              buttonTextColor: AppThemData.black,
                                              onTap: () {
                                                double walletAmount = double.tryParse(Constant.userModel?.walletAmount.toString() ?? '0') ?? 0;
                                                double minRequired = double.tryParse(Constant.minimumAmountToAcceptRide.toString()) ?? 0;

                                                if (walletAmount < 0) {
                                                  ShowToastDialog.showToast("Your wallet balance is negative. You cannot accept a ride.".tr);
                                                } else if (minRequired == 0 || walletAmount >= minRequired) {
                                                  showDialog(
                                                    context: context,
                                                    builder: (context) {
                                                      return CustomDialogBox(
                                                          title: "Confirm Ride Request".tr,
                                                          descriptions:
                                                              "Are you sure you want to accept this ride request? Once confirmed, you will be directed to the next step to proceed with the ride."
                                                                  .tr,
                                                          img: Image.asset(
                                                            "assets/icon/ic_green_right.png",
                                                            height: 58,
                                                            width: 58,
                                                          ),
                                                          positiveClick: () {
                                                            if (Constant.isSubscriptionEnable == true) {
                                                              if (Constant.userModel!.subscriptionPlanId != null && Constant.userModel!.subscriptionPlanId!.isNotEmpty) {
                                                                if (Constant.userModel!.subscriptionTotalBookings == '0') {
                                                                  Navigator.pop(context);
                                                                  showDialog(
                                                                      context: context,
                                                                      builder: (context) {
                                                                        return SubscriptionAlertDialog(
                                                                          title: "You can't accept more Rides.Upgrade your Plan.".tr,
                                                                          themeChange: themeChange,
                                                                        );
                                                                      });
                                                                  return;
                                                                }
                                                              }

                                                              if (Constant.userModel!.subscriptionExpiryDate != null &&
                                                                  Constant.userModel!.subscriptionExpiryDate!.toDate().isBefore(DateTime.now())) {
                                                                Navigator.pop(context);
                                                                showDialog(
                                                                    context: context,
                                                                    builder: (context) {
                                                                      return SubscriptionAlertDialog(
                                                                        title: "Your subscription has expired. Please renew your plan.".tr,
                                                                        themeChange: themeChange,
                                                                      );
                                                                    });
                                                                return;
                                                              }
                                                            }

                                                            rentalBookingModel.driverId = FireStoreUtils.getCurrentUid();
                                                            rentalBookingModel.bookingStatus = BookingStatus.bookingAccepted;
                                                            rentalBookingModel.updateAt = Timestamp.now();
                                                            FireStoreUtils.setRentalRide(rentalBookingModel).then((value) async {
                                                              if (value == true) {
                                                                ShowToastDialog.showToast("Ride accepted successfully!".tr);

                                                                UserModel? receiverUserModel = await FireStoreUtils.getUserProfile(rentalBookingModel.customerId.toString());
                                                                Map<String, dynamic> playLoad = <String, dynamic>{"bookingId": rentalBookingModel.id};

                                                                await SendNotification.sendOneNotification(
                                                                    type: "order",
                                                                    token: receiverUserModel!.fcmToken.toString(),
                                                                    title: "Your Ride is Accepted".tr,
                                                                    customerId: receiverUserModel.id,
                                                                    senderId: FireStoreUtils.getCurrentUid(),
                                                                    bookingId: rentalBookingModel.id.toString(),
                                                                    driverId: rentalBookingModel.driverId.toString(),isBooking: false,
                                                                    body: 'Your ride #${rentalBookingModel.id.toString().substring(0, 4)} has been confirmed.',
                                                                    payload: playLoad);

                                                                if (Constant.isSubscriptionEnable == true &&
                                                                    Constant.userModel!.subscriptionPlanId != null &&
                                                                    Constant.userModel!.subscriptionPlanId!.isNotEmpty &&
                                                                    Constant.userModel!.subscriptionTotalBookings != '0' &&
                                                                    Constant.userModel!.subscriptionTotalBookings != '-1' &&
                                                                    Constant.userModel!.subscriptionTotalBookings != null) {
                                                                  int remainingBookings = int.parse(Constant.userModel!.subscriptionTotalBookings!) - 1;
                                                                  Constant.userModel!.subscriptionTotalBookings = remainingBookings.toString();
                                                                  await FireStoreUtils.updateDriverUser(Constant.userModel!);
                                                                }
                                                              } else {
                                                                ShowToastDialog.showToast("Something went wrong!".tr);
                                                                Navigator.pop(context);
                                                              }
                                                            });
                                                            Navigator.pop(context);
                                                          },
                                                          negativeClick: () {
                                                            Navigator.pop(context);
                                                          },
                                                          positiveString: "Confirm".tr,
                                                          negativeString: "Cancel".tr,
                                                          themeChange: themeChange);
                                                    },
                                                  );
                                                } else {
                                                  ShowToastDialog.showToast("minimumAmountToAcceptRide"
                                                      .trParams({"minimumAmountToAcceptRide": Constant.amountShow(amount: Constant.minimumAmountToAcceptRide)}));
                                                }
                                              },
                                              size: Size(0, 42),
                                            ),
                                          )
                                        ],
                                      )
                                    },
                                    if ((rentalBookingModel.bookingStatus ?? '') == BookingStatus.bookingAccepted &&
                                        !rentalBookingModel.rejectedDriverId!.contains(FireStoreUtils.getCurrentUid()) &&
                                        rentalBookingModel.driverId!.contains(FireStoreUtils.getCurrentUid())) ...{
                                      const SizedBox(height: 16),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Expanded(
                                            child: RoundShapeButton(
                                              title: "Cancel Ride".tr,
                                              buttonColor: themeChange.isDarkTheme() ? AppThemData.grey900 : AppThemData.grey50,
                                              buttonTextColor: themeChange.isDarkTheme() ? AppThemData.white : AppThemData.black,
                                              onTap: () {
                                                Get.to(() => ReasonForCancelRentalRideView(
                                                      rentalBookingModel: rentalBookingModel,
                                                    ));
                                              },
                                              size: Size(0, 42),
                                            ),
                                          ),
                                          SizedBox(width: 10),
                                          Expanded(
                                            child: RoundShapeButton(
                                              title: "Pickup".tr,
                                              buttonColor: AppThemData.primary500,
                                              buttonTextColor: AppThemData.black,
                                              onTap: () {
                                                showDialog(
                                                    context: context, builder: (context) => enterCurrentKilometerDialog(context, themeChange, controller, rentalBookingModel));
                                              },
                                              size: Size(0, 42),
                                            ),
                                          )
                                        ],
                                      )
                                    }
                                  ],
                                ),
                              ),
                            );
                          }),
                ),
              ],
            ),
          );
        });
  }

  Dialog enterCurrentKilometerDialog(BuildContext context, themeChange, HomeController controller, RentalBookingModel rentalModel) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(20),
      child: Container(
        padding: const EdgeInsets.only(left: 20, top: 20, right: 20, bottom: 20),
        decoration: BoxDecoration(shape: BoxShape.rectangle, color: themeChange.isDarkTheme() ? AppThemData.grey950 : Colors.white, borderRadius: BorderRadius.circular(20)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Align(alignment: Alignment.centerRight, child: Icon(Icons.close, color: themeChange.isDarkTheme() ? AppThemData.white : AppThemData.grey950, size: 24))),
            SizedBox(
              height: 10,
            ),
            Text(
              "Current kilometers".tr,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: themeChange.isDarkTheme() ? AppThemData.white : AppThemData.grey950),
            ),
            SizedBox(
              height: 4,
            ),
            TextFormField(
              cursorColor: AppThemData.primary500,
              controller: controller.currentReadingController.value,
              keyboardType: TextInputType.numberWithOptions(decimal: true, signed: true),
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.allow(RegExp("[0-9]")),
              ],
              enabled: true,
              style: GoogleFonts.inter(fontSize: 14, color: themeChange.isDarkTheme() ? AppThemData.white : AppThemData.grey950, fontWeight: FontWeight.w400),
              decoration: InputDecoration(
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                border: OutlineInputBorder(borderSide: BorderSide(color: themeChange.isDarkTheme() ? AppThemData.grey800 : AppThemData.grey200, width: 1)),
                focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: AppThemData.primary500, width: 1)),
                enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: themeChange.isDarkTheme() ? AppThemData.grey800 : AppThemData.grey200, width: 1)),
                errorBorder: OutlineInputBorder(borderSide: BorderSide(color: themeChange.isDarkTheme() ? AppThemData.grey800 : AppThemData.grey200, width: 1)),
                disabledBorder: OutlineInputBorder(borderSide: BorderSide(color: themeChange.isDarkTheme() ? AppThemData.grey800 : AppThemData.grey200, width: 1)),
                hintText: "Enter Current kilometers".tr,
                hintStyle: GoogleFonts.inter(fontSize: 14, color: themeChange.isDarkTheme() ? AppThemData.grey300 : AppThemData.grey500, fontWeight: FontWeight.w400),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Align(
              alignment: Alignment.centerRight,
              child: RoundShapeButton(
                  title: "Continue".tr,
                  buttonColor: AppThemData.primary500,
                  buttonTextColor: AppThemData.black,
                  onTap: () async {
                    if (controller.currentReadingController.value.text.isNotEmpty) {
                      rentalModel.currentKM = controller.currentReadingController.value.text.trim();
                      await FireStoreUtils.setRentalRide(rentalModel).then((value) {
                        Navigator.pop(context);
                        if (Constant.isOtpFeatureEnable == true) {
                          Get.toNamed(Routes.ASK_FOR_OTP_RENTAL, arguments: {
                            "rentalBookingModel": rentalModel,
                          });
                        } else {
                          showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return CustomDialogBox(
                                    themeChange: themeChange,
                                    title: "Confirm Rental Ride Request".tr,
                                    descriptions:
                                        "Are you sure you want to accept this ride request? Once confirmed, you will be directed to the next step to proceed with the ride.".tr,
                                    positiveString: "Confirm".tr,
                                    negativeString: "Cancel".tr,
                                    positiveClick: () async {
                                      Navigator.pop(context);
                                      rentalModel.bookingStatus = BookingStatus.bookingOngoing;
                                      rentalModel.updateAt = Timestamp.now();
                                      rentalModel.pickupTime = Timestamp.now();
                                      await FireStoreUtils.setRentalRide(rentalModel);
                                      DriverUserModel? driverModel = await FireStoreUtils.getDriverUserProfile(rentalModel.driverId.toString());

                                      driverModel!.bookingId = rentalModel.id;
                                      driverModel.status = "busy";
                                      await FireStoreUtils.updateDriverUser(driverModel);

                                      ShowToastDialog.showToast("Your ride started....".tr);
                                      UserModel? receiverUserModel = await FireStoreUtils.getUserProfile(rentalModel.customerId.toString());
                                      if (receiverUserModel != null && receiverUserModel.fcmToken != null && receiverUserModel.fcmToken!.isNotEmpty) {
                                        Map<String, dynamic> playLoad = <String, dynamic>{"bookingId": rentalModel.id};
                                        await SendNotification.sendOneNotification(
                                          type: "order",
                                          token: receiverUserModel.fcmToken!,
                                          title: "Your Ride is Started".tr,
                                          customerId: receiverUserModel.id,
                                          senderId: FireStoreUtils.getCurrentUid(),
                                          bookingId: rentalModel.id.toString(),
                                          driverId: rentalModel.driverId.toString(),
                                          body: 'Your Ride is Started From ${rentalModel.pickUpLocationAddress.toString()}.',
                                          payload: playLoad,isBooking: false
                                        );
                                      }

                                      Get.back();
                                    },
                                    negativeClick: () {
                                      Navigator.pop(context);
                                    },
                                    img: Image.asset(
                                      "assets/icon/ic_green_right.png",
                                      height: 58,
                                      width: 58,
                                    ));
                              });
                        }
                      });
                    } else {
                      ShowToastDialog.showToast("Please Entered Current Kilometers".tr);
                    }
                  },
                  size: Size(150, 48)),
            )
          ],
        ),
      ),
    );
  }
}
