// ignore_for_file: use_build_context_synchronously


import 'package:cached_network_image/cached_network_image.dart';

// ignore_for_file: depend_on_referenced_packages
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:driver/app/models/booking_model.dart';
import 'package:driver/app/models/driver_user_model.dart';
import 'package:driver/app/models/user_model.dart';
import 'package:driver/app/models/vehicle_type_model.dart';
import 'package:driver/app/models/wallet_transaction_model.dart';
import 'package:driver/app/modules/booking_details/controllers/booking_details_controller.dart';
import 'package:driver/app/modules/booking_details/views/booking_details_view.dart';
import 'package:driver/app/modules/home/views/home_view.dart';
import 'package:driver/app/modules/reason_for_cancel_cab/views/reason_for_cancel_cab_view.dart';
import 'package:driver/app/modules/track_ride_screen/views/track_ride_screen_view.dart';
import 'package:driver/app/routes/app_pages.dart';
import 'package:driver/constant/booking_status.dart';
import 'package:driver/constant/constant.dart';
import 'package:driver/constant/send_notification.dart';
import 'package:driver/constant_widgets/custom_dialog_box.dart';
import 'package:driver/constant_widgets/pick_drop_point_view.dart';
import 'package:driver/constant_widgets/round_shape_button.dart';
import 'package:driver/constant_widgets/show_toast_dialog.dart';
import 'package:driver/extension/date_time_extension.dart';
import 'package:driver/theme/app_them_data.dart';
import 'package:driver/theme/responsive.dart';
import 'package:driver/utils/dark_theme_provider.dart';
import 'package:driver/utils/fire_store_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class NewRideView extends StatelessWidget {
  final BookingModel? bookingModel;

  const NewRideView({super.key, this.bookingModel});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return InkWell(
      onTap: () {
        if (bookingModel != null) {
          Get.to(
            () => const BookingDetailsView(),
            arguments: {"bookingModel": bookingModel},
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 16),
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
                  bookingModel == null ? "" : bookingModel!.bookingTime!.toDate().dateMonthYear(),
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
                    bookingModel == null ? "" : bookingModel!.bookingTime!.toDate().time(),
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
                    imageUrl: bookingModel == null ? Constant.profileConstant : bookingModel!.vehicleType!.image.toString(),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          bookingModel == null ? "" : bookingModel!.vehicleType!.title.toString(),
                          style: GoogleFonts.inter(
                            color: themeChange.isDarkTheme() ? AppThemData.grey25 : AppThemData.grey950,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        bookingModel!.bookingStatus == BookingStatus.bookingCancelled || bookingModel!.bookingStatus == BookingStatus.bookingRejected
                            ? SizedBox()
                            : Text(
                                (bookingModel!.paymentStatus ?? false) ? "Payment is Completed".tr : "Payment is Pending".tr,
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
                        bookingModel == null ? "" : Constant.amountShow(amount: Constant.calculateFinalAmount(bookingModel!).toStringAsFixed(2)),
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
                            bookingModel == null ? "" : bookingModel!.vehicleType!.persons.toString(),
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
            PickDropPointView(
              pickUpAddress: bookingModel == null ? "" : bookingModel!.pickUpLocationAddress ?? '',
              dropAddress: bookingModel == null ? "" : bookingModel!.dropLocationAddress ?? '',
              stopAddress: bookingModel!.stops!.isEmpty ? [] : bookingModel!.stops!.map((e) => e.address!).toList(),
              bookingModel: bookingModel,
              isDirectionIconShown: true,
              onDirectionTap: () {
                Get.to(() => TrackRideScreenView(), arguments: {"bookingModel": bookingModel});
              },
            ),
            if ((((bookingModel!.bookingStatus ?? '') == BookingStatus.bookingPlaced) || ((bookingModel!.bookingStatus ?? '') == BookingStatus.driverAssigned)) &&
                !bookingModel!.rejectedDriverId!.contains(FireStoreUtils.getCurrentUid())) ...{
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  RoundShapeButton(
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
                                  List rejectedId = bookingModel!.rejectedDriverId ?? [];
                                  rejectedId.add(FireStoreUtils.getCurrentUid());
                                  bookingModel!.bookingStatus = BookingStatus.bookingRejected;
                                  bookingModel!.rejectedDriverId = rejectedId;
                                  bookingModel!.updateAt = Timestamp.now();
                                  bookingModel!.driverId = "";
                                  FireStoreUtils.setBooking(bookingModel!).then((value) async {
                                    if (value == true) {
                                      ShowToastDialog.showToast("Ride cancelled successfully!".tr);
                                      DriverUserModel? driverModel = await FireStoreUtils.getDriverUserProfile(bookingModel!.driverId.toString());
                                      driverModel!.bookingId = "";
                                      driverModel.status = "free";
                                      FireStoreUtils.updateDriverUser(driverModel);

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
                    size: Size(Responsive.width(40, context), 42),
                  ),
                  RoundShapeButton(
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

                                  bookingModel!.driverId = FireStoreUtils.getCurrentUid();
                                  bookingModel!.bookingStatus = BookingStatus.bookingAccepted;
                                  bookingModel!.updateAt = Timestamp.now();
                                  FireStoreUtils.setBooking(bookingModel!).then((value) async {
                                    if (value == true) {
                                      ShowToastDialog.showToast("Ride accepted successfully!".tr);

                                      UserModel? receiverUserModel = await FireStoreUtils.getUserProfile(bookingModel!.customerId.toString());
                                      Map<String, dynamic> playLoad = <String, dynamic>{"bookingId": bookingModel!.id};

                                      await SendNotification.sendOneNotification(
                                          type: "order",
                                          token: receiverUserModel!.fcmToken.toString(),
                                          title: "Your Ride is Accepted".tr,
                                          customerId: receiverUserModel.id,
                                          senderId: FireStoreUtils.getCurrentUid(),
                                          bookingId: bookingModel!.id.toString(),
                                          driverId: bookingModel!.driverId.toString(),isBooking: false,
                                          body: 'Your ride #${bookingModel!.id.toString().substring(0, 4)} has been confirmed.',
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
                    size: Size(Responsive.width(40, context), 42),
                  )
                ],
              )
            },
            if ((bookingModel!.bookingStatus ?? '') == BookingStatus.bookingAccepted &&
                !bookingModel!.rejectedDriverId!.contains(FireStoreUtils.getCurrentUid()) &&
                bookingModel!.driverId!.contains(FireStoreUtils.getCurrentUid())) ...{
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
                        Get.to(() => ReasonForCancelCabView(bookingModel: bookingModel ?? BookingModel()));
                      },
                      size: Size(0, 42),
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: RoundShapeButton(
                      title: "Pickup".tr,
                      buttonColor: AppThemData.primary500,
                      buttonTextColor: AppThemData.black,
                      onTap: () {
                        if (Constant.isOtpFeatureEnable == true) {
                          Get.toNamed(Routes.ASK_FOR_OTP, arguments: {"bookingModel": bookingModel!});
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
                                      bookingModel!.bookingStatus = BookingStatus.bookingOngoing;
                                      bookingModel!.updateAt = Timestamp.now();
                                      bookingModel!.pickupTime = Timestamp.now();
                                      await FireStoreUtils.setBooking(bookingModel!);
                                      ShowToastDialog.showToast("Your ride started....".tr);
                                      UserModel? receiverUserModel = await FireStoreUtils.getUserProfile(bookingModel!.customerId.toString());
                                      Map<String, dynamic> playLoad = <String, dynamic>{"bookingId": bookingModel!.id};

                                      await SendNotification.sendOneNotification(
                                        type: "order",
                                        token: receiverUserModel!.fcmToken.toString(),
                                        title: "Your Ride is Started".tr,
                                        customerId: receiverUserModel.id,isBooking: false,
                                        senderId: FireStoreUtils.getCurrentUid(),
                                        bookingId: bookingModel!.id.toString(),
                                        driverId: bookingModel!.driverId.toString(),
                                        body: 'Your Ride is Started From ${bookingModel!.pickUpLocationAddress.toString()} to ${bookingModel!.dropLocationAddress.toString()}.',
                                        payload: playLoad,
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
                      size: Size(0, 42),
                    ),
                  ),
                  SizedBox(width: 8),
                  InkWell(
                      onTap: () {
                        Get.toNamed(Routes.TRACK_RIDE_SCREEN, arguments: {"bookingModel": bookingModel});
                      },
                      child: SvgPicture.asset(
                        "assets/icon/ic_live_track.svg",
                        width: 40,
                      ))
                ],
              ),
            },
            if (bookingModel!.bookingStatus == BookingStatus.bookingOngoing || bookingModel!.bookingStatus == BookingStatus.bookingOnHold)
              SizedBox(
                height: 12,
              ),
            Row(
              children: [
                bookingModel!.bookingStatus == BookingStatus.bookingOngoing
                    ? Expanded(
                        child: RoundShapeButton(
                          title: "Complete Ride".tr,
                          buttonColor: AppThemData.success500,
                          buttonTextColor: AppThemData.white,
                          onTap: () {
                            BookingDetailsController controller = Get.put(BookingDetailsController());
                            if (bookingModel!.paymentType != Constant.paymentModel!.cash!.name) {
                              if (bookingModel!.paymentStatus == true) {
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
                                          controller.completeBooking(bookingModel!);

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
                                        if (bookingModel!.paymentType == Constant.paymentModel!.cash!.name) {
                                          Navigator.pop(context);
                                          bookingModel!.paymentStatus = true;
                                          if (Constant.adminCommission != null && Constant.adminCommission!.active == true && num.parse(Constant.adminCommission!.value!) > 0) {
                                            WalletTransactionModel adminCommissionWallet = WalletTransactionModel(
                                                id: Constant.getUuid(),
                                                amount:
                                                    "${Constant.calculateAdminCommission(amount: ((double.parse(bookingModel!.subTotal ?? '0.0')) - (double.parse(bookingModel!.discount ?? '0.0'))).toString(), adminCommission: bookingModel!.adminCommission)}",
                                                createdDate: Timestamp.now(),
                                                paymentType: "Wallet",
                                                transactionId: bookingModel!.id,
                                                isCredit: false,
                                                type: Constant.typeDriver,
                                                userId: bookingModel!.driverId,
                                                note: "Admin commission Debited",
                                                adminCommission: bookingModel!.adminCommission);

                                            await FireStoreUtils.setWalletTransaction(adminCommissionWallet).then((value) async {
                                              if (value == true) {
                                                await FireStoreUtils.updateDriverUserWallet(
                                                    amount:
                                                        "-${Constant.calculateAdminCommission(amount: ((double.parse(bookingModel!.subTotal ?? '0.0')) - (double.parse(bookingModel!.discount ?? '0.0'))).toString(), adminCommission: bookingModel!.adminCommission)}");
                                              }
                                            });
                                          }

                                          await FireStoreUtils.setBooking(bookingModel!).then((value) async {
                                            controller.completeBooking(bookingModel!);
                                            await FireStoreUtils.updateTotalEarning(
                                                amount: (double.parse(Constant.calculateFinalAmount(bookingModel!).toString()) -
                                                        double.parse(Constant.calculateAdminCommission(
                                                                amount:
                                                                    ((double.parse(bookingModel!.subTotal ?? '0.0')) - (double.parse(bookingModel!.discount ?? '0.0'))).toString(),
                                                                adminCommission: bookingModel!.adminCommission)
                                                            .toString()))
                                                    .toString());
                                            DriverUserModel? driverModel = await FireStoreUtils.getDriverUserProfile(bookingModel!.driverId.toString());
                                            driverModel!.bookingId = "";
                                            driverModel.status = "free";
                                            FireStoreUtils.updateDriverUser(driverModel);

                                            // Navigator.pop(context);
                                            Get.to(const HomeView());
                                          });
                                        } else {
                                          if (bookingModel!.paymentStatus == true) {
                                            controller.completeBooking(bookingModel!);
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
                        ),
                      )
                    : SizedBox(),
                SizedBox(
                  width: 8,
                ),
                bookingModel!.bookingStatus == BookingStatus.bookingOngoing
                    ? RoundShapeButton(
                        title: "Hold Ride".tr,
                        buttonColor: AppThemData.danger500,
                        buttonTextColor: AppThemData.white,
                        onTap: () async {
                          if (bookingModel!.holdTiming == null) {
                            bookingModel!.holdTiming = [];
                          }

                          bookingModel!.holdTiming!.add(HoldTimingModel(startTime: Timestamp.now(), endTime: null));

                          bookingModel!.bookingStatus = BookingStatus.bookingOnHold;
                          bookingModel!.updateAt = Timestamp.now();

                          FireStoreUtils.setBooking(bookingModel!);
                          ShowToastDialog.showToast("Ride On Hold".tr);

                          UserModel? receiverUserModel = await FireStoreUtils.getUserProfile(bookingModel!.customerId.toString());
                          Map<String, dynamic> playLoad = <String, dynamic>{"bookingId": bookingModel!.id};

                          await SendNotification.sendOneNotification(
                              type: "order",
                              token: receiverUserModel!.fcmToken.toString(),
                              title: "Your Ride is On Hold".tr,
                              customerId: receiverUserModel.id,isBooking: false,
                              senderId: FireStoreUtils.getCurrentUid(),
                              bookingId: bookingModel!.id.toString(),
                              driverId: bookingModel!.driverId.toString(),
                              body: 'Your ride #${bookingModel!.id.toString().substring(0, 4)} is currently on hold.',
                              payload: playLoad);
                        },
                        size: Size(100, 52),
                      )
                    : SizedBox(),
                bookingModel!.bookingStatus == BookingStatus.bookingOnHold
                    ? Expanded(
                        child: RoundShapeButton(
                          title: "Resume Ride".tr,
                          buttonColor: AppThemData.danger500,
                          buttonTextColor: AppThemData.white,
                          onTap: () async {
                            if (bookingModel!.holdTiming != null && bookingModel!.holdTiming!.isNotEmpty) {
                              bookingModel!.holdTiming!.last.endTime = Timestamp.now();
                            }
                            bookingModel!.bookingStatus = BookingStatus.bookingOngoing;
                            if (bookingModel!.holdTiming == null || bookingModel!.holdTiming!.isEmpty) return;

                            ZoneChargesModel? currentZoneCharge = bookingModel!.vehicleType!.zoneCharges?.firstWhere(
                              (zc) => zc.zoneId == bookingModel!.zoneModel!.id,
                              orElse: () => bookingModel!.vehicleType!.zoneCharges!.first,
                            );

                            if (currentZoneCharge == null) return;

                            double holdChargePerMinute = double.tryParse(currentZoneCharge.charges!.holdCharge ?? '0') ?? 0;

                            double totalHoldCharge = 0.0;

                            for (var hold in bookingModel!.holdTiming!) {
                              if (hold.endTime != null) {
                                final seconds = hold.endTime!.seconds - hold.startTime!.seconds;
                                final minutes = seconds / 60.0;
                                totalHoldCharge += holdChargePerMinute * minutes;
                              }
                            }
                            bookingModel!.holdCharges = totalHoldCharge.toStringAsFixed(2);
                            bookingModel!.updateAt = Timestamp.now();
                            await FireStoreUtils.setBooking(bookingModel!);
                            ShowToastDialog.showToast("Ride resumed".tr);

                            UserModel? receiverUserModel = await FireStoreUtils.getUserProfile(bookingModel!.customerId.toString());
                            Map<String, dynamic> playLoad = <String, dynamic>{"bookingId": bookingModel!.id};

                            await SendNotification.sendOneNotification(
                                type: "order",
                                token: receiverUserModel!.fcmToken.toString(),
                                title: "Your Ride has Resumed".tr,
                                customerId: receiverUserModel.id,
                                senderId: FireStoreUtils.getCurrentUid(),
                                bookingId: bookingModel!.id.toString(),
                                driverId: bookingModel!.driverId.toString(),isBooking: false,
                                body: 'Your ride #${bookingModel!.id.toString().substring(0, 4)} has Resumed',
                                payload: playLoad);
                          },
                          size: Size(100, 52),
                        ),
                      )
                    : SizedBox(),
                SizedBox(
                  width: 8,
                ),
                bookingModel!.bookingStatus == BookingStatus.bookingOngoing || bookingModel!.bookingStatus == BookingStatus.bookingOnHold
                    ? InkWell(
                        onTap: () {
                          Get.toNamed(Routes.TRACK_RIDE_SCREEN, arguments: {"bookingModel": bookingModel});
                        },
                        child: SvgPicture.asset(
                          "assets/icon/ic_live_track.svg",
                          width: 40,
                        ))
                    : SizedBox(),
                // Expanded(
                //   child: RoundShapeButton(
                //     title: "Track Ride".tr,
                //     buttonColor: AppThemData.primary500,
                //     buttonTextColor: AppThemData.black,
                //     onTap: () {
                //     },
                //     size: Size(0, 52),
                //   ),
                // )
              ],
            )
          ],
        ),
      ),
    );
  }
}
