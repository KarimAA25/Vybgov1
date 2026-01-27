// ignore_for_file: use_build_context_synchronously, deprecated_member_use

import 'package:cached_network_image/cached_network_image.dart';

// ignore_for_file: depend_on_referenced_packages
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:driver/app/models/booking_model.dart';
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
import 'package:driver/app/modules/reason_for_cancel_cab/views/reason_for_cancel_cab_view.dart';
import 'package:driver/app/modules/track_ride_screen/views/track_ride_screen_view.dart';
import 'package:driver/app/routes/app_pages.dart';
import 'package:driver/constant/booking_status.dart';
import 'package:driver/constant/constant.dart';
import 'package:driver/constant/send_notification.dart';
import 'package:driver/constant_widgets/app_bar_with_border.dart';
import 'package:driver/constant_widgets/custom_dialog_box.dart';
import 'package:driver/constant_widgets/pick_drop_point_view.dart';
import 'package:driver/constant_widgets/round_shape_button.dart';
import 'package:driver/constant_widgets/show_toast_dialog.dart';
import 'package:driver/constant_widgets/title_view.dart';
import 'package:driver/extension/date_time_extension.dart';
import 'package:driver/extension/string_extensions.dart';
import 'package:driver/theme/app_them_data.dart';
import 'package:driver/theme/responsive.dart';
import 'package:driver/utils/dark_theme_provider.dart';
import 'package:driver/utils/fire_store_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../controllers/booking_details_controller.dart';

class BookingDetailsView extends StatelessWidget {
  const BookingDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetX(
        init: BookingDetailsController(),
        builder: (controller) {
          return Scaffold(
              backgroundColor: themeChange.isDarkTheme() ? AppThemData.black : AppThemData.white,
              appBar: AppBarWithBorder(
                title: "Ride Detail".tr,
                bgColor: themeChange.isDarkTheme() ? AppThemData.black : AppThemData.white,
                actions: [
                  (controller.bookingModel.value.bookingStatus == BookingStatus.bookingOngoing && controller.canShowSOS.value)
                      ? GestureDetector(
                          onTap: () {
                            showModalBottomSheet(
                              context: context,
                              builder: (context) {
                                return sosAlertBottomSheet(context, themeChange, controller);
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
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if ((controller.bookingModel.value.bookingStatus == BookingStatus.bookingPlaced ||
                            controller.bookingModel.value.bookingStatus == BookingStatus.driverAssigned) &&
                        !controller.bookingModel.value.rejectedDriverId!.contains(FireStoreUtils.getCurrentUid())) ...{
                      Expanded(
                        child: RoundShapeButton(
                          textSize: 16,
                          title: "Cancel Ride".tr,
                          buttonColor: AppThemData.danger500,
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
                                        List rejectedId = controller.bookingModel.value.rejectedDriverId ?? [];
                                        rejectedId.add(FireStoreUtils.getCurrentUid());
                                        controller.bookingModel.value.bookingStatus = BookingStatus.bookingRejected;
                                        controller.bookingModel.value.rejectedDriverId = rejectedId;
                                        controller.bookingModel.value.updateAt = Timestamp.now();
                                        FireStoreUtils.setBooking(controller.bookingModel.value).then((value) async {
                                          if (value == true) {
                                            ShowToastDialog.showToast("Ride cancelled successfully!".tr);

                                            DriverUserModel? driverModel = await FireStoreUtils.getDriverUserProfile(controller.bookingModel.value.driverId.toString());
                                            driverModel!.bookingId = "";
                                            driverModel.status = "free";
                                            FireStoreUtils.updateDriverUser(driverModel);
                                            Navigator.pop(context);
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
                          textSize: 16,
                          title: "Accept".tr,
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
                                                      title: "You can't accept more Rides.Upgrade your Plan.".tr,
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
                                                    title: "Your subscription has expired. Please renew your plan.".tr,
                                                    themeChange: themeChange,
                                                  );
                                                });
                                            return;
                                          }
                                        }

                                        controller.bookingModel.value.driverId = FireStoreUtils.getCurrentUid();
                                        controller.bookingModel.value.bookingStatus = BookingStatus.bookingAccepted;
                                        controller.bookingModel.value.updateAt = Timestamp.now();
                                        FireStoreUtils.setBooking(controller.bookingModel.value).then((value) async {
                                          if (value == true) {
                                            ShowToastDialog.showToast("Ride accepted successfully!".tr);

                                            UserModel? receiverUserModel = await FireStoreUtils.getUserProfile(controller.bookingModel.value.customerId.toString());
                                            Map<String, dynamic> playLoad = <String, dynamic>{"bookingId": controller.bookingModel.value.id};

                                            await SendNotification.sendOneNotification(
                                                type: "order",
                                                token: receiverUserModel!.fcmToken.toString(),
                                                title: "Your Ride is Accepted".tr,
                                                customerId: receiverUserModel.id,
                                                senderId: FireStoreUtils.getCurrentUid(),
                                                bookingId: controller.bookingModel.value.id.toString(),
                                                driverId: controller.bookingModel.value.driverId.toString(),
                                                body: 'Your ride #${controller.bookingModel.value.id.toString().substring(0, 4)} has been confirmed.',
                                                payload: playLoad,isBooking: false);
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
                    if (controller.bookingModel.value.bookingStatus != BookingStatus.bookingCancelled &&
                        controller.bookingModel.value.bookingStatus != BookingStatus.bookingRejected &&
                        controller.bookingModel.value.bookingStatus != BookingStatus.bookingPlaced &&
                        controller.bookingModel.value.bookingStatus != BookingStatus.bookingCompleted &&
                        controller.bookingModel.value.bookingStatus != BookingStatus.driverAssigned &&
                        controller.bookingModel.value.bookingStatus != BookingStatus.bookingOnHold &&
                        controller.bookingModel.value.bookingStatus != BookingStatus.bookingOngoing) ...{
                      Expanded(
                        child: RoundShapeButton(
                          title: "Cancel".tr,
                          textSize: 16,
                          buttonColor: themeChange.isDarkTheme() ? AppThemData.grey900 : AppThemData.grey50,
                          buttonTextColor: themeChange.isDarkTheme() ? AppThemData.white : AppThemData.black,
                          onTap: () {
                            Get.to(() => ReasonForCancelCabView(
                                  bookingModel: controller.bookingModel.value,
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
                          if (Constant.isOtpFeatureEnable == true) {
                            Get.toNamed(Routes.ASK_FOR_OTP, arguments: {"bookingModel": controller.bookingModel.value});
                          } else {
                            showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return CustomDialogBox(
                                      themeChange: themeChange,
                                      title: "Confirm Ride Request".tr,
                                      descriptions:
                                          "Are you sure you want to accept this ride request? Once confirmed, you will be directed to the next step to proceed with the ride.".tr,
                                      positiveString: "Confirm".tr,
                                      negativeString: "Cancel".tr,
                                      positiveClick: () async {
                                        Navigator.pop(context);
                                        controller.bookingModel.value.bookingStatus = BookingStatus.bookingOngoing;
                                        controller.bookingModel.value.updateAt = Timestamp.now();
                                        controller.bookingModel.value.pickupTime = Timestamp.now();
                                        await FireStoreUtils.setBooking(controller.bookingModel.value);
                                        ShowToastDialog.showToast("Your ride started....".tr);
                                        UserModel? receiverUserModel = await FireStoreUtils.getUserProfile(controller.bookingModel.value.customerId.toString());
                                        Map<String, dynamic> playLoad = <String, dynamic>{"bookingId": controller.bookingModel.value.id};

                                        await SendNotification.sendOneNotification(
                                          type: "order",
                                          token: receiverUserModel!.fcmToken.toString(),
                                          title: "Your Ride is Started".tr,
                                          customerId: receiverUserModel.id,
                                          senderId: FireStoreUtils.getCurrentUid(),
                                          bookingId: controller.bookingModel.value.id.toString(),
                                          driverId: controller.bookingModel.value.driverId.toString(),
                                          body:
                                              'Your Ride is Started From ${controller.bookingModel.value.pickUpLocationAddress.toString()} to ${controller.bookingModel.value.dropLocationAddress.toString()}.',
                                          payload: playLoad,isBooking: false
                                        );
                                        Get.back();
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
                        },
                        size: Size(0, 52),
                      ))
                    },
                    if (controller.bookingModel.value.bookingStatus == BookingStatus.bookingOngoing)
                      Expanded(
                        child: RoundShapeButton(
                          title: "Complete Ride".tr,
                          textSize: 16,
                          buttonColor: AppThemData.success500,
                          buttonTextColor: AppThemData.white,
                          onTap: () {
                            if (controller.bookingModel.value.paymentType != Constant.paymentModel!.cash!.name) {
                              if (controller.bookingModel.value.paymentStatus == true) {
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
                                          controller.completeBooking(controller.bookingModel.value);

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
                                                "Waiting for the Payment".tr,
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
                                        if (controller.bookingModel.value.paymentType == Constant.paymentModel!.cash!.name) {
                                          Navigator.pop(context);
                                          controller.bookingModel.value.paymentStatus = true;
                                          if (Constant.adminCommission != null && Constant.adminCommission!.active == true && num.parse(Constant.adminCommission!.value!) > 0) {
                                            WalletTransactionModel adminCommissionWallet = WalletTransactionModel(
                                                id: Constant.getUuid(),
                                                amount:
                                                    "${Constant.calculateAdminCommission(amount: ((double.parse(controller.bookingModel.value.subTotal ?? '0.0')) - (double.parse(controller.bookingModel.value.discount ?? '0.0'))).toString(), adminCommission: controller.bookingModel.value.adminCommission)}",
                                                createdDate: Timestamp.now(),
                                                paymentType: "Wallet",
                                                transactionId: controller.bookingModel.value.id,
                                                isCredit: false,
                                                type: Constant.typeDriver,
                                                userId: controller.bookingModel.value.driverId,
                                                note: "Admin commission Debited",
                                                adminCommission: controller.bookingModel.value.adminCommission);

                                            await FireStoreUtils.setWalletTransaction(adminCommissionWallet).then((value) async {
                                              if (value == true) {
                                                await FireStoreUtils.updateDriverUserWallet(
                                                    amount:
                                                        "-${Constant.calculateAdminCommission(amount: ((double.parse(controller.bookingModel.value.subTotal ?? '0.0')) - (double.parse(controller.bookingModel.value.discount ?? '0.0'))).toString(), adminCommission: controller.bookingModel.value.adminCommission)}");
                                              }
                                            });
                                          }

                                          await FireStoreUtils.setBooking(controller.bookingModel.value).then((value) async {
                                            controller.completeBooking(controller.bookingModel.value);
                                            await FireStoreUtils.updateTotalEarning(
                                                amount: (double.parse(Constant.calculateFinalAmount(controller.bookingModel.value).toString()) -
                                                        double.parse(Constant.calculateAdminCommission(
                                                                amount: ((double.parse(controller.bookingModel.value.subTotal ?? '0.0')) -
                                                                        (double.parse(controller.bookingModel.value.discount ?? '0.0')))
                                                                    .toString(),
                                                                adminCommission: controller.bookingModel.value.adminCommission)
                                                            .toString()))
                                                    .toString());
                                            DriverUserModel? driverModel = await FireStoreUtils.getDriverUserProfile(controller.bookingModel.value.driverId.toString());
                                            driverModel!.bookingId = "";
                                            driverModel.status = "free";
                                            FireStoreUtils.updateDriverUser(driverModel);

                                            Get.to(const HomeView());
                                          });
                                        } else {
                                          if (controller.bookingModel.value.paymentStatus == true) {
                                            controller.completeBooking(controller.bookingModel.value);
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
                                                            "Waiting for the Payment".tr,
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
                          },
                          size: Size(0, 52),
                        ).paddingOnly(right: 8),
                      ),
                    if (controller.bookingModel.value.bookingStatus == BookingStatus.bookingOngoing)
                      RoundShapeButton(
                        textSize: 16,
                        title: "Hold Ride".tr,
                        buttonColor: AppThemData.danger500,
                        buttonTextColor: AppThemData.white,
                        onTap: () async {
                          if (controller.bookingModel.value.holdTiming == null) {
                            controller.bookingModel.value.holdTiming = [];
                          }

                          controller.bookingModel.value.holdTiming!.add(HoldTimingModel(startTime: Timestamp.now(), endTime: null));

                          controller.bookingModel.value.bookingStatus = BookingStatus.bookingOnHold;
                          controller.bookingModel.value.updateAt = Timestamp.now();

                          FireStoreUtils.setBooking(controller.bookingModel.value);
                          ShowToastDialog.showToast("Ride On Hold".tr);

                          UserModel? receiverUserModel = await FireStoreUtils.getUserProfile(controller.bookingModel.value.customerId.toString());
                          Map<String, dynamic> playLoad = <String, dynamic>{"bookingId": controller.bookingModel.value.id};

                          await SendNotification.sendOneNotification(
                              type: "order",
                              token: receiverUserModel!.fcmToken.toString(),
                              title: "Your Ride is On Hold".tr,
                              customerId: receiverUserModel.id,
                              senderId: FireStoreUtils.getCurrentUid(),
                              bookingId: controller.bookingModel.value.id.toString(),
                              driverId: controller.bookingModel.value.driverId.toString(),
                              body: 'Your ride #${controller.bookingModel.value.id.toString().substring(0, 4)} is currently on hold.',
                              payload: playLoad,isBooking: false);
                        },
                        size: Size(100, 52),
                      ).paddingOnly(right: 8),
                    if (controller.bookingModel.value.bookingStatus == BookingStatus.bookingOnHold)
                      Expanded(
                          child: RoundShapeButton(
                        title: "Resume Ride".tr,
                        textSize: 16,
                        buttonColor: AppThemData.danger500,
                        buttonTextColor: AppThemData.white,
                        onTap: () async {
                          await controller.calculateHoldCharges();
                        },
                        size: Size(0, 52),
                      )),
                    if (controller.bookingModel.value.bookingStatus == BookingStatus.bookingOnHold || controller.bookingModel.value.bookingStatus == BookingStatus.bookingOngoing)
                      InkWell(
                          onTap: () {
                            Get.toNamed(Routes.TRACK_RIDE_SCREEN, arguments: {"bookingModel": controller.bookingModel.value});
                          },
                          child: SvgPicture.asset(
                            "assets/icon/ic_live_track.svg",
                            width: 40,
                          )).paddingOnly(left: 8),
                    if (controller.bookingModel.value.paymentStatus == true &&
                        controller.bookingModel.value.bookingStatus == BookingStatus.bookingCompleted &&
                        !controller.reviewList.any((review) => review.bookingId == controller.bookingModel.value.id && review.type == Constant.typeCustomer))
                      Expanded(
                        child: RoundShapeButton(
                          title: "Review".tr,
                          textSize: 16,
                          buttonColor: AppThemData.primary500,
                          buttonTextColor: AppThemData.black,
                          onTap: () async {
                            Get.to(
                              const AddCustomerReviewView(),
                              arguments: {
                                "isCab": true,
                                "bookingModel": controller.bookingModel.value,
                              },
                            );
                            await controller.getReview();
                          },
                          size: Size(Responsive.width(45, context), 52),
                        ),
                      ),
                  ],
                ),
              ),
              body: controller.isLoading.value
                  ? Constant.loader()
                  : SingleChildScrollView(
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
                                    "Ride Status".tr,
                                    style: GoogleFonts.inter(
                                      color: themeChange.isDarkTheme() ? AppThemData.grey25 : AppThemData.grey950,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                Text(
                                  BookingStatus.getBookingStatusTitle(controller.bookingModel.value.bookingStatus ?? ''),
                                  textAlign: TextAlign.right,
                                  style: GoogleFonts.inter(
                                    color: BookingStatus.getBookingStatusTitleColor(controller.bookingModel.value.bookingStatus ?? ''),
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                )
                              ],
                            ),
                            TitleView(titleText: "Cab Details".tr, padding: const EdgeInsets.fromLTRB(0, 20, 0, 12)),
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
                                      imageUrl: controller.bookingModel.value.vehicleType == null
                                          ? Constant.profileConstant
                                          : controller.bookingModel.value.vehicleType!.image.toString(),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            controller.bookingModel.value.vehicleType == null ? "" : controller.bookingModel.value.vehicleType!.title.toString(),
                                            style: GoogleFonts.inter(
                                              color: themeChange.isDarkTheme() ? AppThemData.grey25 : AppThemData.grey950,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          controller.bookingModel.value.bookingStatus == BookingStatus.bookingCancelled ||
                                                  controller.bookingModel.value.bookingStatus == BookingStatus.bookingRejected
                                              ? SizedBox()
                                              : Text(
                                                  (controller.bookingModel.value.paymentStatus ?? false) ? "Payment is Completed".tr : "Payment is Pending".tr,
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
                                          Constant.amountShow(amount: Constant.calculateFinalAmount(controller.bookingModel.value).toStringAsFixed(2)),
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
                                              controller.bookingModel.value.vehicleType == null ? "" : controller.bookingModel.value.vehicleType!.persons.toString(),
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
                                future: FireStoreUtils.getUserProfile(controller.bookingModel.value.customerId ?? ''),
                                builder: (context, snapshot) {
                                  if (!snapshot.hasData) {
                                    return Container();
                                  }
                                  UserModel customerModel = snapshot.data ?? UserModel();
                                  return Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      TitleView(titleText: "Customer Details".tr, padding: const EdgeInsets.fromLTRB(0, 0, 0, 12)),
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
                                                        receiverId: controller.bookingModel.value.customerId ?? '',
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
                            PickDropPointView(
                              pickUpAddress: controller.bookingModel.value.pickUpLocationAddress ?? '',
                              dropAddress: controller.bookingModel.value.dropLocationAddress ?? '',
                              bookingModel: controller.bookingModel.value,
                              stopAddress: controller.bookingModel.value.stops?.map((e) => e.address ?? '').toList() ?? [],
                              isDirectionIconShown: true,
                              onDirectionTap: () {
                                Get.to(() => TrackRideScreenView(), arguments: {"bookingModel": controller.bookingModel.value});
                              },
                            ),
                            TitleView(titleText: "Ride Details".tr, padding: const EdgeInsets.fromLTRB(0, 20, 0, 12)),
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
                                          "Date".tr,
                                          style: GoogleFonts.inter(
                                            color: themeChange.isDarkTheme() ? AppThemData.grey25 : AppThemData.grey950,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        controller.bookingModel.value.bookingTime == null ? "" : controller.bookingModel.value.bookingTime!.toDate().dateMonthYear(),
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
                                  const SizedBox(height: 12),
                                  const Divider(),
                                  const SizedBox(height: 12),
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
                                          "Time".tr,
                                          style: GoogleFonts.inter(
                                            color: themeChange.isDarkTheme() ? AppThemData.grey25 : AppThemData.grey950,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        controller.bookingModel.value.bookingTime == null ? "" : controller.bookingModel.value.bookingTime!.toDate().time(),
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
                                  const SizedBox(height: 12),
                                  const Divider(),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      SvgPicture.asset(
                                        "assets/icon/ic_distance.svg",
                                        width: 20,
                                        height: 20,
                                        colorFilter: ColorFilter.mode(themeChange.isDarkTheme() ? AppThemData.grey25 : AppThemData.grey950, BlendMode.srcIn),
                                      ),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          "Distance".tr,
                                          style: GoogleFonts.inter(
                                            color: themeChange.isDarkTheme() ? AppThemData.grey25 : AppThemData.grey950,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                      ),
                                      FutureBuilder<String>(
                                        future: controller.getDistanceInKm(),
                                        initialData: '',
                                        builder: (context, snapshot) {
                                          if (!snapshot.hasData) {
                                            return Container();
                                          }
                                          return Text(
                                            snapshot.data ?? '',
                                            textAlign: TextAlign.right,
                                            style: GoogleFonts.inter(
                                              color: themeChange.isDarkTheme() ? AppThemData.grey25 : AppThemData.grey950,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              height: 0.11,
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            TitleView(titleText: "Price Details".tr, padding: const EdgeInsets.fromLTRB(0, 20, 0, 0)),
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
                                        amount: controller.bookingModel.value.subTotal.toString(),
                                      ),
                                      title: "Amount".tr,
                                      priceColor: themeChange.isDarkTheme() ? AppThemData.grey25 : AppThemData.grey950,
                                      titleColor: themeChange.isDarkTheme() ? AppThemData.grey25 : AppThemData.grey950,
                                    ),
                                    const SizedBox(height: 16),
                                    if (controller.bookingModel.value.nightCharge != null && controller.bookingModel.value.nightCharge != "0.0")
                                      PriceRowView(
                                        price: Constant.amountToShow(
                                          amount: controller.bookingModel.value.nightCharge.toString(),
                                        ),
                                        title: "Night Charge".tr,
                                        priceColor: themeChange.isDarkTheme() ? AppThemData.grey25 : AppThemData.grey950,
                                        titleColor: themeChange.isDarkTheme() ? AppThemData.grey25 : AppThemData.grey950,
                                      ).paddingOnly(bottom: 16),
                                    if (controller.bookingModel.value.holdCharges != null && controller.bookingModel.value.holdCharges != "0.0")
                                      PriceRowView(
                                        price: Constant.amountToShow(
                                          amount: controller.bookingModel.value.holdCharges.toString(),
                                        ),
                                        title: "Hold Charge".tr,
                                        priceColor: themeChange.isDarkTheme() ? AppThemData.grey25 : AppThemData.grey950,
                                        titleColor: themeChange.isDarkTheme() ? AppThemData.grey25 : AppThemData.grey950,
                                      ).paddingOnly(bottom: 16),
                                    PriceRowView(
                                        price: controller.bookingModel.value.discount == null || controller.bookingModel.value.discount!.isEmpty
                                            ? Constant.amountToShow(amount: "0.0")
                                            : "- ${Constant.amountToShow(amount: controller.bookingModel.value.discount.toString())}",
                                        title: (controller.bookingModel.value.coupon == null || controller.bookingModel.value.coupon!.id == null)
                                            ? "Discount".tr
                                            : "discountCode".trParams({"code": controller.bookingModel.value.coupon!.code ?? ""}),

                                        // "Discount (${controller.bookingModel.value.coupon!.code})".tr,
                                        priceColor: AppThemData.danger500,
                                        titleColor: themeChange.isDarkTheme() ? AppThemData.grey25 : AppThemData.grey950),
                                    const SizedBox(height: 16),
                                    ListView.builder(
                                      physics: const NeverScrollableScrollPhysics(),
                                      itemCount: controller.bookingModel.value.taxList!.length,
                                      shrinkWrap: true,
                                      itemBuilder: (context, index) {
                                        TaxModel taxModel = controller.bookingModel.value.taxList![index];
                                        return Column(
                                          children: [
                                            PriceRowView(
                                                price: Constant.amountToShow(
                                                    amount: Constant.calculateTax(amount: Constant.amountBeforeTax(controller.bookingModel.value).toString(), taxModel: taxModel)
                                                        .toString()),
                                                title: "${taxModel.name!} (${taxModel.isFix == true ? Constant.amountToShow(amount: taxModel.value) : "${taxModel.value}%"})",
                                                priceColor: themeChange.isDarkTheme() ? AppThemData.grey25 : AppThemData.grey950,
                                                titleColor: themeChange.isDarkTheme() ? AppThemData.grey25 : AppThemData.grey950),
                                          ],
                                        );
                                      },
                                    ),
                                    const SizedBox(height: 8),
                                    Divider(color: themeChange.isDarkTheme() ? AppThemData.grey800 : AppThemData.grey100),
                                    const SizedBox(height: 12),
                                    PriceRowView(
                                      price: Constant.amountToShow(amount: Constant.calculateFinalAmount(controller.bookingModel.value).toString()),
                                      title: "Total Amount".tr,
                                      priceColor: AppThemData.primary500,
                                      titleColor: themeChange.isDarkTheme() ? AppThemData.grey25 : AppThemData.grey950,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            if (controller.customerToDriverReview.value.bookingId != null) ...[
                              TitleView(titleText: "Your Review".tr, padding: const EdgeInsets.fromLTRB(0, 20, 0, 0)),
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
                            TitleView(titleText: "Payment Method".tr, padding: const EdgeInsets.fromLTRB(0, 20, 0, 12)),
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
                                  (controller.bookingModel.value.paymentType == Constant.paymentModel!.cash!.name)
                                      ? SvgPicture.asset("assets/icon/ic_cash.svg")
                                      : (controller.bookingModel.value.paymentType == Constant.paymentModel!.wallet!.name)
                                          ? SvgPicture.asset(
                                              "assets/icon/ic_wallet.svg",
                                              color: themeChange.isDarkTheme() ? AppThemData.white : AppThemData.black,
                                            )
                                          : (controller.bookingModel.value.paymentType == Constant.paymentModel!.paypal!.name)
                                              ? Image.asset("assets/images/ig_paypal.png", height: 24, width: 24)
                                              : (controller.bookingModel.value.paymentType == Constant.paymentModel!.strip!.name)
                                                  ? Image.asset("assets/images/ig_stripe.png", height: 24, width: 24)
                                                  : (controller.bookingModel.value.paymentType == Constant.paymentModel!.razorpay!.name)
                                                      ? Image.asset("assets/images/ig_razorpay.png", height: 24, width: 24)
                                                      : (controller.bookingModel.value.paymentType == Constant.paymentModel!.payStack!.name)
                                                          ? Image.asset("assets/images/ig_paystack.png", height: 24, width: 24)
                                                          : (controller.bookingModel.value.paymentType == Constant.paymentModel!.mercadoPago!.name)
                                                              ? Image.asset("assets/images/ig_marcadopago.png", height: 24, width: 24)
                                                              : (controller.bookingModel.value.paymentType == Constant.paymentModel!.payFast!.name)
                                                                  ? Image.asset("assets/images/ig_payfast.png", height: 24, width: 24)
                                                                  : (controller.bookingModel.value.paymentType == Constant.paymentModel!.flutterWave!.name)
                                                                      ? Image.asset("assets/images/ig_flutterwave.png", height: 24, width: 24)
                                                                      : (controller.bookingModel.value.paymentType == Constant.paymentModel!.midtrans!.name)
                                                                          ? Image.asset("assets/images/ig_midtrans.png", height: 24, width: 24)
                                                                          : (controller.bookingModel.value.paymentType == Constant.paymentModel!.xendit!.name)
                                                                              ? Image.asset("assets/images/ig_xendit.png", height: 24, width: 24)
                                                                              : const SizedBox(height: 24, width: 24),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      controller.bookingModel.value.paymentType ?? '',
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

  Container sosAlertBottomSheet(BuildContext context, themeChange, BookingDetailsController controller) {
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
                "Tap SOS in case of danger during a trip. Your real-time location will be shared with emergency services and support teams.",
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: themeChange.isDarkTheme() ? AppThemData.grey300 : AppThemData.grey600,
                ),
              ),
              SizedBox(height: 24),
              RoundShapeButton(
                title: "Call_sos".trParams({"callsos":Constant.sosAlertNumber.toString()}),
                // "Call ${Constant.sosAlertNumber}",
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
                      return SizedBox(height: MediaQuery.of(context).size.height * 0.8, child: emergencyContactsBottomSheet(context, themeChange, controller));
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

  Container emergencyContactsBottomSheet(BuildContext context, themeChange, BookingDetailsController controller) {
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
                    buttonColor: AppThemData.primary500,
                    buttonTextColor: AppThemData.white,
                    onTap: () {
                      controller.notifySelectedContacts();
                    },
                    size: Size(Responsive.width(100, context), 52),
                  ),
                )
              : SizedBox()
        ],
      ),
    );
  }
}
