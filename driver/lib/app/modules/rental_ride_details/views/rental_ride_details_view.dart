// ignore_for_file: use_build_context_synchronously, depend_on_referenced_packages, deprecated_member_use

import 'package:cached_network_image/cached_network_image.dart';
import 'package:driver/app/models/driver_user_model.dart';
import 'package:driver/app/models/emergency_number_model.dart';
import 'package:driver/app/models/tax_model.dart';
import 'package:driver/app/models/user_model.dart';
import 'package:driver/app/models/wallet_transaction_model.dart';
import 'package:driver/app/modules/add_customer_review/views/add_customer_review_view.dart';
import 'package:driver/app/modules/booking_details/widget/price_row_view.dart';
import 'package:driver/app/modules/chat_screen/views/chat_screen_view.dart';
import 'package:driver/app/modules/emergency_contacts/views/emergency_contacts_view.dart';
import 'package:driver/app/modules/home/views/home_view.dart';
import 'package:driver/app/modules/reason_for_cancel_rental_ride/views/reason_for_cancel_rental_ride_view.dart';
import 'package:driver/app/modules/rental_ride_details/controllers/rental_ride_details_controller.dart';
import 'package:driver/app/routes/app_pages.dart';
import 'package:driver/constant/booking_status.dart';
import 'package:driver/constant/constant.dart';
import 'package:driver/constant/send_notification.dart';
import 'package:driver/constant_widgets/app_bar_with_border.dart';
import 'package:driver/constant_widgets/custom_dialog_box.dart';
import 'package:driver/constant_widgets/round_shape_button.dart';
import 'package:driver/constant_widgets/show_toast_dialog.dart';
import 'package:driver/constant_widgets/title_view.dart';
import 'package:driver/extension/date_time_extension.dart';
import 'package:driver/extension/string_extensions.dart';
import 'package:driver/theme/app_them_data.dart';
import 'package:driver/theme/responsive.dart';
import 'package:driver/utils/dark_theme_provider.dart';
import 'package:driver/utils/fire_store_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RentalRideDetailsView extends GetView<RentalRideDetailsController> {
  const RentalRideDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetX<RentalRideDetailsController>(
        init: RentalRideDetailsController(),
        builder: (controller) {
          return Scaffold(
              backgroundColor: themeChange.isDarkTheme() ? AppThemData.black : AppThemData.white,
              appBar: AppBarWithBorder(
                title: "Rental Ride Details".tr,
                bgColor: themeChange.isDarkTheme() ? AppThemData.black : AppThemData.white,
                actions: [
                  (controller.rentalModel.value.bookingStatus == BookingStatus.bookingOngoing && controller.canShowSOS.value)
                      ? GestureDetector(
                          onTap: () {
                            showModalBottomSheet(
                              context: context,
                              builder: (context) {
                                return sosAlertBottomSheet(context, themeChange);
                              },
                            );
                          },
                          child: Icon(
                            Icons.sos_outlined,
                            color: AppThemData.danger500,
                            size: 30,
                          ),
                        ).paddingOnly(right: 16)
                      : Container()
                ],
              ),
              bottomNavigationBar: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if ((controller.rentalModel.value.bookingStatus == BookingStatus.bookingPlaced || controller.rentalModel.value.bookingStatus == BookingStatus.driverAssigned) &&
                        !controller.rentalModel.value.rejectedDriverId!.contains(FireStoreUtils.getCurrentUid())) ...{
                      Expanded(
                        child: RoundShapeButton(
                          title: "Cancel Ride".tr,
                          textSize: 16,
                          buttonColor: AppThemData.grey50,
                          buttonTextColor: AppThemData.black,
                          onTap: () {
                            showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return CustomDialogBox(
                                      themeChange: themeChange,
                                      title: "Cancel Ride".tr,
                                      descriptions: "Are you sure you want cancel this ride?".tr,
                                      positiveString: "Cancel Ride".tr,
                                      negativeString: "Cancel".tr,
                                      positiveClick: () async {
                                        List rejectedId = controller.rentalModel.value.rejectedDriverId ?? [];
                                        rejectedId.add(FireStoreUtils.getCurrentUid());
                                        controller.rentalModel.value.bookingStatus = BookingStatus.bookingRejected;
                                        controller.rentalModel.value.rejectedDriverId = rejectedId;
                                        controller.rentalModel.value.updateAt = Timestamp.now();
                                        FireStoreUtils.setRentalRide(controller.rentalModel.value).then((value) async {
                                          if (value == true) {
                                            ShowToastDialog.showToast("Ride cancelled successfully!".tr);

                                            DriverUserModel? driverModel = await FireStoreUtils.getDriverUserProfile(controller.rentalModel.value.driverId.toString());
                                            driverModel!.bookingId = "";
                                            driverModel.status = "free";
                                            FireStoreUtils.updateDriverUser(driverModel);
                                            Navigator.pop(context);
                                          } else {
                                            ShowToastDialog.showToast("Something went wrong!".tr);
                                            Navigator.pop(context);
                                          }
                                        });
                                        // controller.getBookingDetails();
                                        Navigator.pop(context);
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
                          size: Size(0, 52),
                        ),
                      ),
                      SizedBox(
                        width: 12,
                      ),
                      Expanded(
                        child: RoundShapeButton(
                          title: "Accept".tr,
                          textSize: 16,
                          buttonColor: AppThemData.primary500,
                          buttonTextColor: AppThemData.black,
                          onTap: () {
                            if (double.parse(Constant.userModel!.walletAmount.toString()) >= double.parse(Constant.minimumAmountToAcceptRide.toString())) {
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return CustomDialogBox(
                                      title: "Confirm Ride Request".tr,
                                      descriptions:
                                          "Are you sure you want to accept this ride request? Once confirmed, you will be directed to the next step to proceed with the ride.".tr,
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
                                                      title: "You can't accept more Rides.Upgrade your Plan.",
                                                      themeChange: themeChange,
                                                    );
                                                  });
                                              return;
                                            }
                                          }

                                          if (Constant.userModel!.subscriptionExpiryDate != null && Constant.userModel!.subscriptionExpiryDate!.toDate().isBefore(DateTime.now())) {
                                            Navigator.pop(context);
                                            showDialog(
                                                context: context,
                                                builder: (context) {
                                                  return SubscriptionAlertDialog(
                                                    title: "Your subscription has expired. Please renew your plan.",
                                                    themeChange: themeChange,
                                                  );
                                                });
                                            return;
                                          }
                                        }

                                        controller.rentalModel.value.driverId = FireStoreUtils.getCurrentUid();
                                        controller.rentalModel.value.bookingStatus = BookingStatus.bookingAccepted;
                                        controller.rentalModel.value.updateAt = Timestamp.now();
                                        FireStoreUtils.setRentalRide(controller.rentalModel.value).then((value) async {
                                          if (value == true) {
                                            // controller.getBookingDetails();

                                            ShowToastDialog.showToast("Ride accepted successfully!".tr);

                                            UserModel? receiverUserModel = await FireStoreUtils.getUserProfile(controller.rentalModel.value.customerId.toString());
                                            Map<String, dynamic> playLoad = <String, dynamic>{"bookingId": controller.rentalModel.value.id};

                                            await SendNotification.sendOneNotification(
                                                type: "order",
                                                token: receiverUserModel!.fcmToken.toString(),
                                                title: 'Your Ride is Accepted'.tr,
                                                customerId: receiverUserModel.id,
                                                senderId: FireStoreUtils.getCurrentUid(),
                                                bookingId: controller.rentalModel.value.id.toString(),
                                                driverId: controller.rentalModel.value.driverId.toString(),isBooking: false,
                                                body: 'Your ride #${controller.rentalModel.value.id.toString().substring(0, 4)} has been confirmed.',
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
                                            // Navigator.pop(context);
                                          } else {
                                            ShowToastDialog.showToast("Something went wrong!".tr);
                                            Navigator.pop(context);
                                          }
                                        });
                                        // controller.getBookingDetails();
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
                              ShowToastDialog.showToast(
                                  "minimumAmountToAcceptRide".trParams({"minimumAmountToAcceptRide": Constant.amountShow(amount: Constant.minimumAmountToAcceptRide)}));

                              // ShowToastDialog.showToast(
                              //     "You do not have sufficient wallet balance to accept the ride, as the minimum amount required is ${Constant.amountShow(amount: Constant.minimumAmountToAcceptRide)}.");
                            }
                          },
                          size: Size(0, 52),
                        ),
                      )
                    },
                    if (controller.rentalModel.value.bookingStatus != BookingStatus.bookingCancelled &&
                        controller.rentalModel.value.bookingStatus != BookingStatus.bookingRejected &&
                        controller.rentalModel.value.bookingStatus != BookingStatus.bookingPlaced &&
                        controller.rentalModel.value.bookingStatus != BookingStatus.bookingCompleted &&
                        controller.rentalModel.value.bookingStatus != BookingStatus.bookingOngoing) ...{
                      Expanded(
                        child: RoundShapeButton(
                          title: "Cancel".tr,
                          textSize: 16,
                          buttonColor: AppThemData.grey50,
                          buttonTextColor: AppThemData.black,
                          onTap: () {
                            Get.to(() => ReasonForCancelRentalRideView(
                                  rentalBookingModel: controller.rentalModel.value,
                                ));
                          },
                          size: Size(0, 52),
                        ),
                      ),
                      SizedBox(
                        width: 12,
                      ),
                      Expanded(
                          child: RoundShapeButton(
                        title: "Pickup".tr,
                        textSize: 16,
                        buttonColor: AppThemData.primary500,
                        buttonTextColor: AppThemData.black,
                        onTap: () {
                          showDialog(
                              context: context,
                              builder: (context) {
                                return Dialog(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  elevation: 0,
                                  backgroundColor: Colors.transparent,
                                  insetPadding: const EdgeInsets.all(20),
                                  child: Container(
                                    padding: const EdgeInsets.only(left: 20, top: 20, right: 20, bottom: 20),
                                    decoration: BoxDecoration(
                                        shape: BoxShape.rectangle, color: themeChange.isDarkTheme() ? AppThemData.grey950 : Colors.white, borderRadius: BorderRadius.circular(20)),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        InkWell(
                                            onTap: () {
                                              Navigator.pop(context);
                                            },
                                            child: Align(
                                                alignment: Alignment.centerRight,
                                                child: Icon(Icons.close, color: themeChange.isDarkTheme() ? AppThemData.white : AppThemData.grey950, size: 24))),
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
                                          style: GoogleFonts.inter(
                                              fontSize: 14, color: themeChange.isDarkTheme() ? AppThemData.white : AppThemData.grey950, fontWeight: FontWeight.w400),
                                          decoration: InputDecoration(
                                            isDense: true,
                                            contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                                            border:
                                                OutlineInputBorder(borderSide: BorderSide(color: themeChange.isDarkTheme() ? AppThemData.grey800 : AppThemData.grey200, width: 1)),
                                            focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: AppThemData.primary500, width: 1)),
                                            enabledBorder:
                                                OutlineInputBorder(borderSide: BorderSide(color: themeChange.isDarkTheme() ? AppThemData.grey800 : AppThemData.grey200, width: 1)),
                                            errorBorder:
                                                OutlineInputBorder(borderSide: BorderSide(color: themeChange.isDarkTheme() ? AppThemData.grey800 : AppThemData.grey200, width: 1)),
                                            disabledBorder:
                                                OutlineInputBorder(borderSide: BorderSide(color: themeChange.isDarkTheme() ? AppThemData.grey800 : AppThemData.grey200, width: 1)),
                                            hintText: "Enter Current kilometers".tr,
                                            hintStyle: GoogleFonts.inter(
                                                fontSize: 14, color: themeChange.isDarkTheme() ? AppThemData.grey300 : AppThemData.grey500, fontWeight: FontWeight.w400),
                                          ),
                                        ),
                                        SizedBox(
                                          height: 20,
                                        ),
                                        Align(
                                          alignment: Alignment.centerRight,
                                          child: RoundShapeButton(
                                              title: "Continue".tr,
                                              textSize: 16,
                                              buttonColor: AppThemData.primary500,
                                              buttonTextColor: AppThemData.black,
                                              onTap: () async {
                                                if (controller.currentReadingController.value.text.isNotEmpty) {
                                                  controller.rentalModel.value.currentKM = controller.currentReadingController.value.text.trim();
                                                  await FireStoreUtils.setRentalRide(controller.rentalModel.value).then((value) {
                                                    Navigator.pop(context);
                                                    if (Constant.isOtpFeatureEnable == true) {
                                                      Get.toNamed(Routes.ASK_FOR_OTP_RENTAL, arguments: {
                                                        "rentalBookingModel": controller.rentalModel.value,
                                                      });
                                                    } else {
                                                      showDialog(
                                                          context: context,
                                                          builder: (BuildContext context) {
                                                            return CustomDialogBox(
                                                                themeChange: themeChange,
                                                                title: "Confirm Rental Ride Request".tr,
                                                                descriptions:
                                                                    "Are you sure you want to accept this ride request? Once confirmed, you will be directed to the next step to proceed with the ride."
                                                                        .tr,
                                                                positiveString: "Confirm".tr,
                                                                negativeString: "Cancel".tr,
                                                                positiveClick: () async {
                                                                  Navigator.pop(context);
                                                                  controller.rentalModel.value.bookingStatus = BookingStatus.bookingOngoing;
                                                                  controller.rentalModel.value.updateAt = Timestamp.now();
                                                                  controller.rentalModel.value.pickupTime = Timestamp.now();
                                                                  await FireStoreUtils.setRentalRide(controller.rentalModel.value);
                                                                  DriverUserModel? driverModel =
                                                                      await FireStoreUtils.getDriverUserProfile(controller.rentalModel.value.driverId.toString());

                                                                  driverModel!.bookingId = controller.rentalModel.value.id;
                                                                  driverModel.status = "busy";
                                                                  await FireStoreUtils.updateDriverUser(driverModel);

                                                                  ShowToastDialog.showToast("Your ride started....".tr);
                                                                  UserModel? receiverUserModel =
                                                                      await FireStoreUtils.getUserProfile(controller.rentalModel.value.customerId.toString());
                                                                  if (receiverUserModel != null && receiverUserModel.fcmToken != null && receiverUserModel.fcmToken!.isNotEmpty) {
                                                                    Map<String, dynamic> playLoad = <String, dynamic>{"bookingId": controller.rentalModel.value.id};
                                                                    await SendNotification.sendOneNotification(
                                                                      type: "order",
                                                                      token: receiverUserModel.fcmToken!,
                                                                      title: 'Your Ride is Started',
                                                                      customerId: receiverUserModel.id,
                                                                      senderId: FireStoreUtils.getCurrentUid(),
                                                                      bookingId: controller.rentalModel.value.id.toString(),
                                                                      driverId: controller.rentalModel.value.driverId.toString(),isBooking: false,
                                                                      body: 'Your Ride is Started From ${controller.rentalModel.value.pickUpLocationAddress.toString()}.',
                                                                      payload: playLoad,
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
                              });
                        },
                        size: Size(0, 52),
                      ))
                    },
                    if (controller.rentalModel.value.bookingStatus == BookingStatus.bookingOngoing) ...{
                      Expanded(
                        child: RoundShapeButton(
                          textSize: 16,
                          title: controller.rentalModel.value.completedKM != null && controller.rentalModel.value.completedKM!.isNotEmpty
                              ? "Complete Ride".tr
                              : "Add Final Kilometers".tr,
                          buttonColor: AppThemData.success500,
                          buttonTextColor: AppThemData.white,
                          onTap: () {
                            if (controller.rentalModel.value.completedKM != null && controller.rentalModel.value.completedKM!.isNotEmpty) {
                              if (controller.rentalModel.value.paymentType != Constant.paymentModel!.cash!.name) {
                                if (controller.rentalModel.value.paymentStatus == true) {
                                  showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return CustomDialogBox(
                                          themeChange: themeChange,
                                          title: "Confirm Ride Completion".tr,
                                          descriptions: "Are you sure you want complete this ride?".tr,
                                          positiveString: "Complete".tr,
                                          negativeString: "Cancel".tr,
                                          positiveClick: () async {
                                            Navigator.pop(context);
                                            controller.completeBooking(controller.rentalModel.value);
                                            DriverUserModel? driverModel = await FireStoreUtils.getDriverUserProfile(controller.rentalModel.value.driverId.toString());
                                            driverModel!.bookingId = "";
                                            driverModel.status = "free";
                                            FireStoreUtils.updateDriverUser(driverModel);
                                            Get.back();
                                          },
                                          negativeClick: () {
                                            Navigator.pop(context);
                                          },
                                          img: Icon(
                                            Icons.monetization_on,
                                            color: AppThemData.primary500,
                                            size: 40,
                                          ),
                                        );
                                      });
                                } else {
                                  showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return Dialog(
                                          child: Padding(
                                            padding: const EdgeInsets.all(20.0),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(
                                                  Icons.monetization_on,
                                                  color: AppThemData.primary500,
                                                  size: 40,
                                                ),
                                                SizedBox(
                                                  height: 20,
                                                ),
                                                Text(
                                                  "Waiting for the Payment",
                                                  style: GoogleFonts.inter(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.w600,
                                                    color: themeChange.isDarkTheme() ? AppThemData.grey25 : AppThemData.grey950,
                                                  ),
                                                ),
                                                const SizedBox(
                                                  height: 5,
                                                ),
                                                Text(
                                                  "Please wait until the customer completes the payment.".tr,
                                                  style: GoogleFonts.inter(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w400,
                                                    color: themeChange.isDarkTheme() ? AppThemData.grey25 : AppThemData.grey950,
                                                  ),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      });
                                }
                              } else {
                                showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return CustomDialogBox(
                                        themeChange: themeChange,
                                        title: "Confirm Cash Payment".tr,
                                        descriptions: "Are you sure you want complete the ride with a cash payment?".tr,
                                        positiveString: "Complete".tr,
                                        negativeString: "Cancel".tr,
                                        positiveClick: () async {
                                          if (controller.rentalModel.value.paymentType == Constant.paymentModel!.cash!.name) {
                                            Navigator.pop(context);
                                            controller.rentalModel.value.paymentStatus = true;
                                            if (Constant.adminCommission != null && Constant.adminCommission!.active == true && num.parse(Constant.adminCommission!.value!) > 0) {
                                              WalletTransactionModel adminCommissionWallet = WalletTransactionModel(
                                                  id: Constant.getUuid(),
                                                  amount:
                                                      "${Constant.calculateAdminCommission(amount: ((double.parse(controller.rentalModel.value.subTotal ?? '0.0')) - (double.parse(controller.rentalModel.value.discount ?? '0.0'))).toString(), adminCommission: controller.rentalModel.value.adminCommission)}",
                                                  createdDate: Timestamp.now(),
                                                  paymentType: "Wallet",
                                                  transactionId: controller.rentalModel.value.id,
                                                  isCredit: false,
                                                  type: Constant.typeDriver,
                                                  userId: controller.rentalModel.value.driverId,
                                                  note: "Admin commission Debited",
                                                  adminCommission: controller.rentalModel.value.adminCommission);

                                              await FireStoreUtils.setWalletTransaction(adminCommissionWallet).then((value) async {
                                                if (value == true) {
                                                  await FireStoreUtils.updateDriverUserWallet(
                                                      amount:
                                                          "-${Constant.calculateAdminCommission(amount: ((double.parse(controller.rentalModel.value.subTotal ?? '0.0')) - (double.parse(controller.rentalModel.value.discount ?? '0.0'))).toString(), adminCommission: controller.rentalModel.value.adminCommission)}");
                                                }
                                              });
                                            }

                                            await FireStoreUtils.setRentalRide(controller.rentalModel.value).then((value) async {
                                              controller.completeBooking(controller.rentalModel.value);
                                              await FireStoreUtils.updateTotalEarning(
                                                  amount: (double.parse(Constant.calculateFinalRentalRideAmount(controller.rentalModel.value).toString()) -
                                                          double.parse(Constant.calculateAdminCommission(
                                                                  amount: ((double.parse(controller.rentalModel.value.subTotal ?? '0.0')) -
                                                                          (double.parse(controller.rentalModel.value.discount ?? '0.0')))
                                                                      .toString(),
                                                                  adminCommission: controller.rentalModel.value.adminCommission)
                                                              .toString()))
                                                      .toString());
                                              DriverUserModel? driverModel = await FireStoreUtils.getDriverUserProfile(controller.rentalModel.value.driverId.toString());
                                              driverModel!.bookingId = "";
                                              driverModel.status = "free";
                                              FireStoreUtils.updateDriverUser(driverModel);
                                              Navigator.pop(context);
                                              Get.to(const HomeView());
                                            });
                                          } else {
                                            if (controller.rentalModel.value.paymentStatus == true) {
                                              controller.completeBooking(controller.rentalModel.value);
                                              Navigator.pop(context);
                                            } else {
                                              showDialog(
                                                  context: context,
                                                  builder: (BuildContext context) {
                                                    return Dialog(
                                                      child: Padding(
                                                        padding: const EdgeInsets.all(20.0),
                                                        child: Column(
                                                          mainAxisSize: MainAxisSize.min,
                                                          children: [
                                                            Icon(
                                                              Icons.monetization_on,
                                                              color: AppThemData.primary500,
                                                              size: 40,
                                                            ),
                                                            SizedBox(
                                                              height: 20,
                                                            ),
                                                            Text(
                                                              "Waiting for the Payment",
                                                              style: GoogleFonts.inter(
                                                                fontSize: 18,
                                                                fontWeight: FontWeight.w600,
                                                                color: themeChange.isDarkTheme() ? AppThemData.grey25 : AppThemData.grey950,
                                                              ),
                                                            ),
                                                            const SizedBox(
                                                              height: 5,
                                                            ),
                                                            Text(
                                                              "Please wait until the customer completes the payment.".tr,
                                                              style: GoogleFonts.inter(
                                                                fontSize: 14,
                                                                fontWeight: FontWeight.w400,
                                                                color: themeChange.isDarkTheme() ? AppThemData.grey25 : AppThemData.grey950,
                                                              ),
                                                              textAlign: TextAlign.center,
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    );
                                                  });
                                              Navigator.pop(context);
                                            }
                                          }
                                        },
                                        negativeClick: () {
                                          Navigator.pop(context);
                                        },
                                        img: Icon(
                                          Icons.monetization_on,
                                          color: AppThemData.primary500,
                                          size: 40,
                                        ),
                                      );
                                    });
                              }
                            } else {
                              showDialog(context: context, builder: (context) => enterKilometerDialog(context, themeChange));
                            }
                          },
                          size: Size(0, 52),
                        ),
                      ),
                      // SizedBox(
                      //   width: 12,
                      // ),
                      // Expanded(
                      //     child: RoundShapeButton(
                      //   title: "Track Ride".tr,
                      //   buttonColor: AppThemData.primary500,
                      //   buttonTextColor: AppThemData.black,
                      //   onTap: () {
                      //     Get.toNamed(Routes.TRACK_RENTAL_RIDE_SCREEN, arguments: {"rentalModel": controller.rentalModel.value});
                      //   },
                      //   size: Size(0, 52),
                      // ))
                    },
                    if (controller.rentalModel.value.paymentStatus == true &&
                        controller.rentalModel.value.bookingStatus == BookingStatus.bookingCompleted &&
                        !controller.reviewList.any((review) => review.bookingId == controller.rentalModel.value.id && review.type == Constant.typeCustomer))
                      RoundShapeButton(
                        title: "Review".tr,
                        textSize: 16,
                        buttonColor: AppThemData.primary500,
                        buttonTextColor: AppThemData.black,
                        onTap: () async {
                          Get.to(
                            const AddCustomerReviewView(),
                            arguments: {
                              "isRental": true,
                              "bookingModel": controller.rentalModel.value,
                            },
                          );
                          await controller.getReview();
                        },
                        size: Size(Responsive.width(45, context), 52),
                      ),
                  ],
                ),
              ),
              body: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Ride Status'.tr,
                              style: GoogleFonts.inter(
                                color: themeChange.isDarkTheme() ? AppThemData.grey25 : AppThemData.grey950,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Text(
                            BookingStatus.getBookingStatusTitle(controller.rentalModel.value.bookingStatus ?? ''),
                            textAlign: TextAlign.right,
                            style: GoogleFonts.inter(
                              color: BookingStatus.getBookingStatusTitleColor(controller.rentalModel.value.bookingStatus ?? ''),
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          )
                        ],
                      ),
                      TitleView(titleText: 'Cab Details'.tr, padding: const EdgeInsets.fromLTRB(0, 20, 0, 12)),
                      Container(
                        width: Responsive.width(100, context),
                        padding: const EdgeInsets.all(16),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: ShapeDecoration(
                          shape: RoundedRectangleBorder(
                            side: BorderSide(width: 1, color: themeChange.isDarkTheme() ? AppThemData.grey800 : AppThemData.grey100),
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Container(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              CachedNetworkImage(
                                height: 60,
                                width: 60,
                                imageUrl: controller.rentalModel.value.vehicleType == null ? Constant.profileConstant : controller.rentalModel.value.vehicleType!.image.toString(),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      controller.rentalModel.value.vehicleType == null ? "" : controller.rentalModel.value.vehicleType!.title.toString(),
                                      style: GoogleFonts.inter(
                                        color: themeChange.isDarkTheme() ? AppThemData.grey25 : AppThemData.grey950,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    controller.rentalModel.value.bookingStatus == BookingStatus.bookingCancelled ||
                                            controller.rentalModel.value.bookingStatus == BookingStatus.bookingRejected
                                        ? SizedBox()
                                        : Text(
                                            (controller.rentalModel.value.paymentStatus ?? false) ? 'Payment is Completed'.tr : 'Payment is Pending'.tr,
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
                                    Constant.amountShow(amount: Constant.calculateFinalRentalRideAmount(controller.rentalModel.value).toStringAsFixed(2)),
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
                                        controller.rentalModel.value.vehicleType == null ? "" : controller.rentalModel.value.vehicleType!.persons.toString(),
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
                      ),
                      FutureBuilder<UserModel?>(
                          future: FireStoreUtils.getUserProfile(controller.rentalModel.value.customerId ?? ''),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return Container();
                            }
                            UserModel customerModel = snapshot.data ?? UserModel();
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                TitleView(titleText: 'Customer Details'.tr, padding: const EdgeInsets.fromLTRB(0, 0, 0, 12)),
                                Container(
                                  width: Responsive.width(100, context),
                                  padding: const EdgeInsets.all(16),
                                  decoration: ShapeDecoration(
                                    shape: RoundedRectangleBorder(
                                      side: BorderSide(width: 1, color: themeChange.isDarkTheme() ? AppThemData.grey800 : AppThemData.grey100),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Container(
                                        width: 44,
                                        height: 44,
                                        margin: const EdgeInsets.only(right: 10),
                                        clipBehavior: Clip.antiAlias,
                                        decoration: ShapeDecoration(
                                          color: themeChange.isDarkTheme() ? AppThemData.grey950 : AppThemData.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(200),
                                          ),
                                          image: DecorationImage(
                                            image: NetworkImage(customerModel.profilePic != null
                                                ? customerModel.profilePic!.isNotEmpty
                                                    ? customerModel.profilePic ?? Constant.profileConstant
                                                    : Constant.profileConstant
                                                : Constant.profileConstant),
                                            fit: BoxFit.fill,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Text(
                                          customerModel.fullName ?? '',
                                          style: GoogleFonts.inter(
                                            color: themeChange.isDarkTheme() ? AppThemData.grey25 : AppThemData.grey950,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                      InkWell(
                                          onTap: () {
                                            Get.to(() => ChatScreenView(
                                                  receiverId: controller.rentalModel.value.customerId ?? '',
                                                ));
                                          },
                                          child: SvgPicture.asset("assets/icon/ic_message.svg")),
                                      const SizedBox(width: 12),
                                      InkWell(
                                          onTap: () {
                                            Constant().launchCall("${customerModel.countryCode}${customerModel.phoneNumber}");
                                          },
                                          child: SvgPicture.asset("assets/icon/ic_phone.svg"))
                                    ],
                                  ),
                                ),
                                const SizedBox(
                                  height: 16,
                                ),
                              ],
                            );
                          }),
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
                                    'Pickup Point'.tr,
                                    style: GoogleFonts.inter(
                                      color: themeChange.isDarkTheme() ? AppThemData.grey25 : AppThemData.grey950,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  Text(
                                    controller.rentalModel.value.pickUpLocationAddress.toString(),
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
                      TitleView(titleText: 'Rental Package'.tr, padding: const EdgeInsets.fromLTRB(0, 12, 0, 12)),
                      Container(
                          width: Responsive.width(100, context),
                          padding: const EdgeInsets.all(16),
                          decoration: ShapeDecoration(
                            shape: RoundedRectangleBorder(
                              side: BorderSide(width: 1, color: themeChange.isDarkTheme() ? AppThemData.grey800 : AppThemData.grey100),
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.directions_car, size: 18, color: Colors.blueAccent),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      'Included'.tr,
                                      style: GoogleFonts.inter(
                                        color: themeChange.isDarkTheme() ? AppThemData.grey25 : AppThemData.grey950,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    "${controller.rentalModel.value.rentalPackage!.includedHours} Hours / ${controller.rentalModel.value.rentalPackage!.includedDistance} km",
                                    textAlign: TextAlign.right,
                                    style: GoogleFonts.inter(
                                      color: themeChange.isDarkTheme() ? AppThemData.grey25 : AppThemData.grey950,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      height: 0.11,
                                    ),
                                  ),
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                child: const Divider(),
                              ),
                              Row(
                                children: [
                                  Icon(Icons.add_circle_outline, size: 18, color: Colors.redAccent),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      'Extra Per KM Charge'.tr,
                                      style: GoogleFonts.inter(
                                        color: themeChange.isDarkTheme() ? AppThemData.grey25 : AppThemData.grey950,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    Constant.amountToShow(amount: controller.rentalModel.value.rentalPackage!.extraKmFare),
                                    textAlign: TextAlign.right,
                                    style: GoogleFonts.inter(
                                      color: themeChange.isDarkTheme() ? AppThemData.grey25 : AppThemData.grey950,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      height: 0.11,
                                    ),
                                  ),
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                child: const Divider(),
                              ),
                              Row(
                                children: [
                                  Icon(Icons.add_circle_outline, size: 18, color: Colors.redAccent),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      'Extra Per Hours Charge'.tr,
                                      style: GoogleFonts.inter(
                                        color: themeChange.isDarkTheme() ? AppThemData.grey25 : AppThemData.grey950,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    Constant.amountToShow(amount: controller.rentalModel.value.rentalPackage!.extraHourFare),
                                    textAlign: TextAlign.right,
                                    style: GoogleFonts.inter(
                                      color: themeChange.isDarkTheme() ? AppThemData.grey25 : AppThemData.grey950,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      height: 0.11,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          )),
                      if (controller.rentalModel.value.bookingStatus == BookingStatus.bookingCompleted ||
                          controller.rentalModel.value.bookingStatus == BookingStatus.bookingOngoing)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TitleView(titleText: 'Extra KM & Hours'.tr, padding: const EdgeInsets.fromLTRB(0, 12, 0, 12)),
                            Container(
                                width: Responsive.width(100, context),
                                padding: const EdgeInsets.all(16),
                                decoration: ShapeDecoration(
                                  shape: RoundedRectangleBorder(
                                    side: BorderSide(width: 1, color: themeChange.isDarkTheme() ? AppThemData.grey800 : AppThemData.grey100),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(Icons.directions_car, size: 18, color: Colors.blueAccent),
                                        const SizedBox(width: 6),
                                        Expanded(
                                          child: Text(
                                            'Extra KM'.tr,
                                            style: GoogleFonts.inter(
                                              color: themeChange.isDarkTheme() ? AppThemData.grey25 : AppThemData.grey950,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                        ),
                                        Text(
                                          "${controller.extraKm.value} km",
                                          textAlign: TextAlign.right,
                                          style: GoogleFonts.inter(
                                            color: themeChange.isDarkTheme() ? AppThemData.grey25 : AppThemData.grey950,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            height: 0.11,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 8),
                                      child: const Divider(),
                                    ),
                                    Row(
                                      children: [
                                        Icon(Icons.add_circle_outline, size: 18, color: Colors.redAccent),
                                        const SizedBox(width: 6),
                                        Expanded(
                                          child: Text(
                                            'Extra Hours'.tr,
                                            style: GoogleFonts.inter(
                                              color: themeChange.isDarkTheme() ? AppThemData.grey25 : AppThemData.grey950,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                        ),
                                        Text(
                                          "${controller.extraHours.value} Hours",
                                          textAlign: TextAlign.right,
                                          style: GoogleFonts.inter(
                                            color: themeChange.isDarkTheme() ? AppThemData.grey25 : AppThemData.grey950,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            height: 0.11,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                )),
                          ],
                        ),
                      TitleView(titleText: 'Ride Details'.tr, padding: const EdgeInsets.fromLTRB(0, 12, 0, 12)),
                      Container(
                        width: Responsive.width(100, context),
                        padding: const EdgeInsets.all(16),
                        decoration: ShapeDecoration(
                          shape: RoundedRectangleBorder(
                            side: BorderSide(width: 1, color: themeChange.isDarkTheme() ? AppThemData.grey800 : AppThemData.grey100),
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              children: [
                                SvgPicture.asset(
                                  "assets/icon/ic_calendar.svg",
                                  width: 20,
                                  height: 20,
                                  colorFilter: ColorFilter.mode(themeChange.isDarkTheme() ? AppThemData.grey25 : AppThemData.grey950, BlendMode.srcIn),
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    'Date'.tr,
                                    style: GoogleFonts.inter(
                                      color: themeChange.isDarkTheme() ? AppThemData.grey25 : AppThemData.grey950,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ),
                                Text(
                                  controller.rentalModel.value.pickupTime == null ? "" : controller.rentalModel.value.pickupTime!.toDate().dateMonthYear(),
                                  textAlign: TextAlign.right,
                                  style: GoogleFonts.inter(
                                    color: themeChange.isDarkTheme() ? AppThemData.grey25 : AppThemData.grey950,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    height: 0.11,
                                  ),
                                ),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: const Divider(),
                            ),
                            Row(
                              children: [
                                SvgPicture.asset(
                                  "assets/icon/ic_time.svg",
                                  width: 20,
                                  height: 20,
                                  colorFilter: ColorFilter.mode(themeChange.isDarkTheme() ? AppThemData.grey25 : AppThemData.grey950, BlendMode.srcIn),
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    'Time'.tr,
                                    style: GoogleFonts.inter(
                                      color: themeChange.isDarkTheme() ? AppThemData.grey25 : AppThemData.grey950,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ),
                                Text(
                                  controller.rentalModel.value.pickupTime == null ? "" : controller.rentalModel.value.pickupTime!.toDate().time(),
                                  textAlign: TextAlign.right,
                                  style: GoogleFonts.inter(
                                    color: themeChange.isDarkTheme() ? AppThemData.grey25 : AppThemData.grey950,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    height: 0.11,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      TitleView(titleText: 'Price Details'.tr, padding: const EdgeInsets.fromLTRB(0, 20, 0, 0)),
                      Container(
                        width: Responsive.width(100, context),
                        padding: const EdgeInsets.all(20),
                        margin: const EdgeInsets.only(top: 12),
                        decoration: ShapeDecoration(
                          color: themeChange.isDarkTheme() ? AppThemData.grey900 : AppThemData.grey50,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Obx(
                          () => Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              PriceRowView(
                                price: Constant.amountToShow(
                                  amount: controller.rentalModel.value.subTotal.toString(),
                                ),
                                title: "Amount".tr,
                                priceColor: themeChange.isDarkTheme() ? AppThemData.grey25 : AppThemData.grey950,
                                titleColor: themeChange.isDarkTheme() ? AppThemData.grey25 : AppThemData.grey950,
                              ),
                              if (controller.rentalModel.value.extraKmCharge != null &&
                                  controller.rentalModel.value.extraKmCharge!.isNotEmpty &&
                                  controller.rentalModel.value.extraKmCharge != '0.0')
                                PriceRowView(
                                        price: Constant.amountToShow(amount: controller.rentalModel.value.extraKmCharge ?? '0.0'),
                                        title: "Extra Km Charge".tr,
                                        priceColor: themeChange.isDarkTheme() ? AppThemData.grey25 : AppThemData.grey950,
                                        titleColor: themeChange.isDarkTheme() ? AppThemData.grey25 : AppThemData.grey950)
                                    .paddingOnly(top: 16),
                              if (controller.rentalModel.value.extraHourCharge != null &&
                                  controller.rentalModel.value.extraHourCharge!.isNotEmpty &&
                                  controller.rentalModel.value.extraHourCharge != '0.0')
                                PriceRowView(
                                        price: Constant.amountToShow(amount: controller.rentalModel.value.extraHourCharge ?? '0.0'),
                                        title: "Extra Hour Charge".tr,
                                        priceColor: themeChange.isDarkTheme() ? AppThemData.grey25 : AppThemData.grey950,
                                        titleColor: themeChange.isDarkTheme() ? AppThemData.grey25 : AppThemData.grey950)
                                    .paddingOnly(top: 16),
                              PriceRowView(
                                      price: controller.rentalModel.value.discount == null || controller.rentalModel.value.discount!.isEmpty
                                          ? Constant.amountToShow(amount: "0.0")
                                          : "- ${Constant.amountToShow(amount: controller.rentalModel.value.discount.toString())}",
                                      title: (controller.rentalModel.value.coupon == null || controller.rentalModel.value.coupon!.id == null)
                                          ? "Discount"
                                          : "discountCode".trParams({"code": controller.rentalModel.value.coupon!.code ?? ""}),
                                      //"discountCode (${controller.rentalModel.value.coupon!.code})".tr,
                                      priceColor: AppThemData.danger500,
                                      titleColor: themeChange.isDarkTheme() ? AppThemData.grey25 : AppThemData.grey950)
                                  .paddingOnly(top: 16),
                              const SizedBox(height: 16),
                              ListView.builder(
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: controller.rentalModel.value.taxList!.length,
                                shrinkWrap: true,
                                itemBuilder: (context, index) {
                                  TaxModel taxModel = controller.rentalModel.value.taxList![index];
                                  return Column(
                                    children: [
                                      PriceRowView(
                                          price: Constant.amountToShow(
                                              amount: Constant.calculateTax(
                                                      amount: (((double.parse(controller.rentalModel.value.subTotal ?? '0.0')) +
                                                                  double.parse(controller.rentalModel.value.extraHourCharge ?? '0.0') +
                                                                  double.parse(controller.rentalModel.value.extraKmCharge ?? '0.0')) -
                                                              (double.parse(controller.rentalModel.value.discount ?? '0.0')))
                                                          .toString(),
                                                      taxModel: taxModel)
                                                  .toString()),
                                          title: "${taxModel.name!} (${taxModel.isFix == true ? Constant.amountToShow(amount: taxModel.value) : "${taxModel.value}%"})",
                                          priceColor: themeChange.isDarkTheme() ? AppThemData.grey25 : AppThemData.grey950,
                                          titleColor: themeChange.isDarkTheme() ? AppThemData.grey25 : AppThemData.grey950),
                                      const SizedBox(height: 16),
                                    ],
                                  );
                                },
                              ),
                              const SizedBox(height: 8),
                              Divider(color: themeChange.isDarkTheme() ? AppThemData.grey800 : AppThemData.grey100),
                              const SizedBox(height: 12),
                              PriceRowView(
                                price: Constant.amountToShow(amount: Constant.calculateFinalRentalRideAmount(controller.rentalModel.value).toString()),
                                title: "Total Amount".tr,
                                priceColor: AppThemData.primary500,
                                titleColor: themeChange.isDarkTheme() ? AppThemData.grey25 : AppThemData.grey950,
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (controller.customerToDriverReview.value.bookingId != null) ...[
                        TitleView(titleText: "your Review".tr, padding: const EdgeInsets.fromLTRB(0, 20, 0, 0)),
                        Container(
                          width: Responsive.width(100, context),
                          padding: const EdgeInsets.all(16),
                          margin: const EdgeInsets.only(top: 8),
                          decoration: ShapeDecoration(
                            color: themeChange.isDarkTheme() ? AppThemData.grey900 : AppThemData.grey50,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              RatingBar.builder(
                                glow: true,
                                initialRating: controller.customerToDriverReview.value.rating.toDouble(),
                                minRating: 0,
                                ignoreGestures: true,
                                direction: Axis.horizontal,
                                allowHalfRating: true,
                                itemCount: 5,
                                itemSize: 20,
                                itemPadding: const EdgeInsets.symmetric(horizontal: 2.0),
                                itemBuilder: (context, _) => Icon(
                                  Icons.star_rate_rounded,
                                  color: AppThemData.warning500,
                                ),
                                onRatingUpdate: (double value) {},
                              ),
                              controller.customerToDriverReview.value.comment != null && controller.customerToDriverReview.value.comment!.isNotEmpty
                                  ? Text(
                                      controller.customerToDriverReview.value.comment ?? '',
                                      style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w400, color: AppThemData.info500),
                                    ).paddingOnly(top: 8)
                                  : SizedBox(),
                            ],
                          ),
                        ),
                      ],
                      if (controller.driverToCustomerReview.value.bookingId != null) ...[
                        TitleView(titleText: "Customer Review".tr, padding: const EdgeInsets.fromLTRB(0, 20, 0, 0)),
                        Container(
                          width: Responsive.width(100, context),
                          padding: const EdgeInsets.all(16),
                          margin: const EdgeInsets.only(top: 8),
                          decoration: ShapeDecoration(
                            color: themeChange.isDarkTheme() ? AppThemData.grey900 : AppThemData.grey50,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              RatingBar.builder(
                                glow: true,
                                initialRating: controller.driverToCustomerReview.value.rating.toDouble(),
                                minRating: 0,
                                ignoreGestures: true,
                                direction: Axis.horizontal,
                                allowHalfRating: true,
                                itemCount: 5,
                                itemSize: 20,
                                itemPadding: const EdgeInsets.symmetric(horizontal: 2.0),
                                itemBuilder: (context, _) => Icon(
                                  Icons.star_rate_rounded,
                                  color: AppThemData.warning500,
                                ),
                                onRatingUpdate: (double value) {},
                              ),
                              controller.driverToCustomerReview.value.comment != null && controller.driverToCustomerReview.value.comment!.isNotEmpty
                                  ? Text(
                                      controller.driverToCustomerReview.value.comment ?? '',
                                      style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w400, color: AppThemData.info500),
                                    ).paddingOnly(top: 8)
                                  : SizedBox(),
                            ],
                          ),
                        ),
                      ],
                      TitleView(titleText: 'Payment Method'.tr, padding: const EdgeInsets.fromLTRB(0, 20, 0, 12)),
                      Container(
                        width: Responsive.width(100, context),
                        height: 56,
                        padding: const EdgeInsets.all(16),
                        decoration: ShapeDecoration(
                          shape: RoundedRectangleBorder(
                            side: BorderSide(width: 1, color: themeChange.isDarkTheme() ? AppThemData.grey800 : AppThemData.grey100),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            (controller.rentalModel.value.paymentType == Constant.paymentModel!.cash!.name)
                                ? SvgPicture.asset("assets/icon/ic_cash.svg")
                                : (controller.rentalModel.value.paymentType == Constant.paymentModel!.wallet!.name)
                                    ? SvgPicture.asset(
                                        "assets/icon/ic_wallet.svg",
                                        color: themeChange.isDarkTheme() ? AppThemData.white : AppThemData.black,
                                      )
                                    : (controller.rentalModel.value.paymentType == Constant.paymentModel!.paypal!.name)
                                        ? Image.asset("assets/images/ig_paypal.png", height: 24, width: 24)
                                        : (controller.rentalModel.value.paymentType == Constant.paymentModel!.strip!.name)
                                            ? Image.asset("assets/images/ig_stripe.png", height: 24, width: 24)
                                            : (controller.rentalModel.value.paymentType == Constant.paymentModel!.razorpay!.name)
                                                ? Image.asset("assets/images/ig_razorpay.png", height: 24, width: 24)
                                                : (controller.rentalModel.value.paymentType == Constant.paymentModel!.payStack!.name)
                                                    ? Image.asset("assets/images/ig_paystack.png", height: 24, width: 24)
                                                    : (controller.rentalModel.value.paymentType == Constant.paymentModel!.mercadoPago!.name)
                                                        ? Image.asset("assets/images/ig_marcadopago.png", height: 24, width: 24)
                                                        : (controller.rentalModel.value.paymentType == Constant.paymentModel!.payFast!.name)
                                                            ? Image.asset("assets/images/ig_payfast.png", height: 24, width: 24)
                                                            : (controller.rentalModel.value.paymentType == Constant.paymentModel!.flutterWave!.name)
                                                                ? Image.asset("assets/images/ig_flutterwave.png", height: 24, width: 24)
                                                                : (controller.rentalModel.value.paymentType == Constant.paymentModel!.midtrans!.name)
                                                                    ? Image.asset("assets/images/ig_midtrans.png", height: 24, width: 24)
                                                                    : (controller.rentalModel.value.paymentType == Constant.paymentModel!.xendit!.name)
                                                                        ? Image.asset("assets/images/ig_xendit.png", height: 24, width: 24)
                                                                        : const SizedBox(height: 24, width: 24),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                controller.rentalModel.value.paymentType ?? '',
                                style: GoogleFonts.inter(
                                  color: themeChange.isDarkTheme() ? AppThemData.grey25 : AppThemData.grey950,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ));
        });
  }

  Dialog enterKilometerDialog(BuildContext context, themeChange) {
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
              "Completed kilometers".tr,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: themeChange.isDarkTheme() ? AppThemData.white : AppThemData.grey950),
            ),
            SizedBox(
              height: 4,
            ),
            TextFormField(
              cursorColor: AppThemData.primary500,
              controller: controller.completedReadingController.value,
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
                hintText: "Enter Completed kilometers".tr,
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
                  textSize: 16,
                  buttonColor: AppThemData.primary500,
                  buttonTextColor: AppThemData.black,
                  onTap: () async {
                    if (controller.completedReadingController.value.text.isNotEmpty) {
                      String enteredKM = controller.completedReadingController.value.text.trim();
                      double completedKM = double.tryParse(enteredKM) ?? 0.0;
                      double currentKM = double.tryParse(controller.rentalModel.value.currentKM ?? '0.0') ?? 0.0;
                      controller.rentalModel.value.completedKM = enteredKM;

                      double extraKm = completedKM - currentKM;
                      // Extra KM Calculation
                      double extraKmCharge = 0.0;
                      if (extraKm > double.tryParse(controller.rentalModel.value.rentalPackage!.includedDistance ?? '0.0')!) {
                        double overKm = extraKm - double.tryParse(controller.rentalModel.value.rentalPackage!.includedDistance ?? '0.0')!;
                        controller.extraKm.value = overKm;
                        extraKmCharge = overKm * (double.tryParse(controller.rentalModel.value.rentalPackage!.extraKmFare ?? '0.0') ?? 0.0);
                      }

                      controller.rentalModel.value.extraKmCharge = extraKmCharge.toStringAsFixed(2);
                      // Extra Hours Calculation
                      try {
                        DateTime pickupTime = controller.rentalModel.value.pickupTime!.toDate();
                        DateTime now = DateTime.now();

                        Duration totalDuration = now.difference(pickupTime);
                        double includedHours = double.tryParse(controller.rentalModel.value.rentalPackage!.includedHours ?? '0') ?? 0.0;

                        double usedHours = totalDuration.inMinutes / 60.0;

                        double extraHourCharge = 0.0;
                        if (usedHours > includedHours) {
                          int extraHours = (usedHours - includedHours).ceil();
                          controller.extraHours.value = extraHours;
                          extraHourCharge = extraHours * (double.tryParse(controller.rentalModel.value.rentalPackage!.extraHourFare ?? '0.0') ?? 0.0);
                        }
                        controller.rentalModel.value.extraHourCharge = extraHourCharge.toStringAsFixed(2);
                      } catch (e) {
                        if (kDebugMode) {
                          print("Error calculating extra hours: $e");
                        }
                      }
                      await FireStoreUtils.setRentalRide(controller.rentalModel.value);
                      controller.calculateExtraKmAndHours();
                      Navigator.pop(context);
                    } else {
                      ShowToastDialog.showToast("Please Entered Completed Kilometers".tr);
                    }
                  },
                  size: Size(150, 48)),
            )
          ],
        ),
      ),
    );
  }

  Container sosAlertBottomSheet(BuildContext context, themeChange) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
          color: themeChange.isDarkTheme() ? AppThemData.grey950 : AppThemData.grey50,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          )),
      child: Column(
        children: [
          Container(
            width: 44,
            height: 5,
            margin: const EdgeInsets.only(top: 10, bottom: 25),
            decoration: ShapeDecoration(
              color: themeChange.isDarkTheme() ? AppThemData.grey700 : AppThemData.grey200,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(100),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Emergency SOS".tr,
                style: GoogleFonts.inter(
                  color: themeChange.isDarkTheme() ? AppThemData.grey25 : AppThemData.grey950,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 8),
              Text(
                "Use SOS only in case of an emergency during a rental ride. Activating SOS will instantly share your live location and rental trip details with emergency services or your trusted contacts.".tr,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: themeChange.isDarkTheme() ? AppThemData.grey300 : AppThemData.grey600,
                ),
              ),
              SizedBox(height: 24),
              RoundShapeButton(
                title: "Call_sos".trParams({"callsos":Constant.sosAlertNumber.toString()}),
                buttonColor: AppThemData.danger500,
                buttonTextColor: AppThemData.white,
                onTap: () {
                  controller.callOnHelpline();
                },
                size: Size(Responsive.width(100, context), 52),
              ),
              SizedBox(height: 16),
              RoundShapeButton(
                title: "Notify Emergency Contacts".tr,
                buttonColor: AppThemData.primary500,
                buttonTextColor: AppThemData.white,
                onTap: () {
                  Get.back();
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    builder: (context) {
                      return SizedBox(height: MediaQuery.of(context).size.height * 0.8, child: emergencyContactsBottomSheet(context, themeChange));
                    },
                  );
                },
                size: Size(Responsive.width(100, context), 52),
              ),
            ],
          )
        ],
      ),
    );
  }

  Container emergencyContactsBottomSheet(BuildContext context, themeChange) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
          color: themeChange.isDarkTheme() ? AppThemData.black : AppThemData.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          )),
      child: Column(
        children: [
          Container(
            width: 44,
            height: 5,
            margin: const EdgeInsets.only(top: 10, bottom: 25),
            decoration: ShapeDecoration(
              color: themeChange.isDarkTheme() ? AppThemData.grey700 : AppThemData.grey200,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(100),
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Emergency Contacts".tr,
                    style: GoogleFonts.inter(
                      color: themeChange.isDarkTheme() ? AppThemData.grey25 : AppThemData.grey950,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 24),
                  Obx(
                    () => controller.totalEmergencyContacts.isEmpty
                        ? SizedBox(
                            height: MediaQuery.of(context).size.height * 0.6,
                            child: Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Constant.showEmptyView(
                                    message: "No Emergency Contacts Added".tr,
                                  ),
                                  SizedBox(height: 16),
                                  RoundShapeButton(
                                    title: "Add Emergency Contact".tr,
                                    buttonColor: AppThemData.primary500,
                                    buttonTextColor: AppThemData.white,
                                    onTap: () {
                                      Get.back();
                                      Get.to(EmergencyContactsView());
                                    },
                                    size: Size(
                                      Responsive.width(100, context),
                                      52,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : ListView.builder(
                            itemCount: controller.totalEmergencyContacts.length,
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemBuilder: (context, index) {
                              EmergencyContactModel contactModel = controller.totalEmergencyContacts[index];
                              return Container(
                                margin: EdgeInsets.only(bottom: index == controller.totalEmergencyContacts.length - 1 ? 0 : 12),
                                padding: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: themeChange.isDarkTheme() ? AppThemData.grey900 : AppThemData.grey50,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                contactModel.name.toString(),
                                                style: GoogleFonts.inter(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w500,
                                                  color: themeChange.isDarkTheme() ? AppThemData.grey25 : AppThemData.grey950,
                                                ),
                                              ),
                                              SizedBox(height: 2),
                                              Text(
                                                "${contactModel.countryCode} ${contactModel.phoneNumber}",
                                                style: GoogleFonts.inter(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w400,
                                                  color: themeChange.isDarkTheme() ? AppThemData.grey400 : AppThemData.grey600,
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                        Obx(() => Checkbox(
                                              value: controller.selectedEmergencyContactIds.contains(contactModel.id),
                                              activeColor: AppThemData.primary500,
                                              onChanged: (value) {
                                                final id = contactModel.id;
                                                if (id == null) return;

                                                value == true ? controller.selectedEmergencyContactIds.add(id) : controller.selectedEmergencyContactIds.remove(id);
                                              },
                                            )),
                                      ],
                                    )
                                  ],
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
          controller.totalEmergencyContacts.isNotEmpty
              ? Padding(
                  padding: EdgeInsetsGeometry.symmetric(horizontal: 24, vertical: 10),
                  child: RoundShapeButton(
                    title: "Notify".tr,
                    size: const Size(200, 45),
                    buttonColor: AppThemData.primary500,
                    buttonTextColor: AppThemData.white,
                    onTap: () {
                      controller.notifySelectedContacts();
                    },
                  ),
                )
              : SizedBox()
        ],
      ),
    );
  }
}
