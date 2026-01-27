// ignore_for_file: use_build_context_synchronously, depend_on_referenced_packages

import 'package:cached_network_image/cached_network_image.dart';
import 'package:driver/app/models/driver_user_model.dart';
import 'package:driver/app/models/rental_booking_model.dart';
import 'package:driver/app/models/user_model.dart';
import 'package:driver/app/modules/reason_for_cancel_rental_ride/views/reason_for_cancel_rental_ride_view.dart';
import 'package:driver/app/modules/rental_ride_details/views/rental_ride_details_view.dart';
import 'package:driver/app/modules/rental_rides/controllers/rental_rides_controller.dart';
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
import 'package:driver/theme/responsive.dart';
import 'package:driver/utils/dark_theme_provider.dart';
import 'package:driver/utils/fire_store_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RentalRidesView extends GetView {
  const RentalRidesView({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetBuilder(
        init: RentalRidesController(),
        builder: (controller) {
          return Scaffold(
            backgroundColor: themeChange.isDarkTheme() ? AppThemData.black : AppThemData.white,
            body: Column(
              children: [
                SizedBox(
                  height: Responsive.height(8, context),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                    child: Obx(
                      () => SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            RoundShapeButton(
                              title: "Active".tr,
                              buttonColor: controller.selectedType.value == 0
                                  ? AppThemData.primary500
                                  : themeChange.isDarkTheme()
                                      ? AppThemData.black
                                      : AppThemData.white,
                              buttonTextColor: controller.selectedType.value == 0
                                  ? AppThemData.black
                                  : themeChange.isDarkTheme()
                                      ? AppThemData.white
                                      : AppThemData.black,
                              onTap: () {
                                controller.selectedType.value = 0;
                              },
                              size: Size((Responsive.width(90, context) / 3), 38),
                              textSize: 12,
                            ),
                            const SizedBox(width: 10),
                            RoundShapeButton(
                              title: "OnGoing".tr,
                              buttonColor: controller.selectedType.value == 1
                                  ? AppThemData.primary500
                                  : themeChange.isDarkTheme()
                                      ? AppThemData.black
                                      : AppThemData.white,
                              buttonTextColor: controller.selectedType.value == 1
                                  ? AppThemData.black
                                  : (themeChange.isDarkTheme() ? AppThemData.white : AppThemData.black),
                              onTap: () {
                                controller.selectedType.value = 1;
                              },
                              size: Size((Responsive.width(90, context) / 3), 38),
                              textSize: 12,
                            ),
                            const SizedBox(width: 10),
                            RoundShapeButton(
                              title: "Completed".tr,
                              buttonColor: controller.selectedType.value == 2
                                  ? AppThemData.primary500
                                  : themeChange.isDarkTheme()
                                      ? AppThemData.black
                                      : AppThemData.white,
                              buttonTextColor: controller.selectedType.value == 2
                                  ? AppThemData.black
                                  : themeChange.isDarkTheme()
                                      ? AppThemData.white
                                      : AppThemData.black,
                              onTap: () {
                                controller.selectedType.value = 2;
                              },
                              size: Size((Responsive.width(100, context) / 3), 38),
                              textSize: 12,
                            ),
                            const SizedBox(width: 10),
                            RoundShapeButton(
                              title: "Cancelled".tr,
                              buttonColor: controller.selectedType.value == 3
                                  ? AppThemData.primary500
                                  : themeChange.isDarkTheme()
                                      ? AppThemData.black
                                      : AppThemData.white,
                              buttonTextColor: controller.selectedType.value == 3
                                  ? AppThemData.black
                                  : themeChange.isDarkTheme()
                                      ? AppThemData.white
                                      : AppThemData.black,
                              onTap: () {
                                controller.selectedType.value = 3;
                              },
                              size: Size((Responsive.width(90, context) / 3), 38),
                              textSize: 12,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const Divider(),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () async {
                      if (controller.selectedType.value == 0) {
                        await controller.getData(
                            isActiveDataFetch: true, isOngoingDataFetch: false, isCompletedDataFetch: false, isRejectedDataFetch: false);
                      } else if (controller.selectedType.value == 1) {
                        await controller.getData(
                            isActiveDataFetch: false, isOngoingDataFetch: true, isCompletedDataFetch: false, isRejectedDataFetch: false);
                      } else if (controller.selectedType.value == 2) {
                        await controller.getData(
                            isActiveDataFetch: false, isOngoingDataFetch: false, isCompletedDataFetch: true, isRejectedDataFetch: false);
                      } else {
                        await controller.getData(
                            isActiveDataFetch: false, isOngoingDataFetch: false, isCompletedDataFetch: false, isRejectedDataFetch: true);
                      }
                    },
                    child: Obx(
                      () => (controller.selectedType.value == 0
                              ? controller.activeRides.isNotEmpty
                              : controller.selectedType.value == 1
                                  ? controller.ongoingRides.isNotEmpty
                                  : controller.selectedType.value == 2
                                      ? controller.completedRides.isNotEmpty
                                      : controller.rejectedRides.isNotEmpty)
                          ? ListView.builder(
                              padding: EdgeInsets.only(bottom: 8),
                              itemCount: controller.selectedType.value == 0
                                  ? controller.activeRides.length
                                  : controller.selectedType.value == 1
                                      ? controller.ongoingRides.length
                                      : controller.selectedType.value == 2
                                          ? controller.completedRides.length
                                          : controller.rejectedRides.length,
                              shrinkWrap: true,
                              itemBuilder: (context, index) {
                                RxBool isOpen = false.obs;
                                RentalBookingModel rentalBookingModel = controller.selectedType.value == 0
                                    ? controller.activeRides[index]
                                    : controller.selectedType.value == 1
                                        ? controller.ongoingRides[index]
                                        : controller.selectedType.value == 2
                                            ? controller.completedRides[index]
                                            : controller.rejectedRides[index];
                                return GestureDetector(
                                  onTap: () {
                                    isOpen.value = !isOpen.value;
                                  },
                                  child: Container(
                                    width: Responsive.width(100, context),
                                    padding: const EdgeInsets.all(16),
                                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                    decoration: ShapeDecoration(
                                      shape: RoundedRectangleBorder(
                                        side: BorderSide(
                                            width: 1, color: themeChange.isDarkTheme() ? AppThemData.grey800 : AppThemData.grey100),
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
                                              rentalBookingModel.bookingTime == null
                                                  ? ""
                                                  : rentalBookingModel.bookingTime!.toDate().dateMonthYear(),
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
                                                rentalBookingModel.bookingTime == null
                                                    ? ""
                                                    : rentalBookingModel.bookingTime!.toDate().time(),
                                                style: GoogleFonts.inter(
                                                  color: themeChange.isDarkTheme() ? AppThemData.grey400 : AppThemData.grey500,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w400,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            GestureDetector(
                                              onTap: () {
                                                Get.to(RentalRideDetailsView(), arguments: {"rentalBookingModel": rentalBookingModel});
                                              },
                                              child: Icon(
                                                Icons.keyboard_arrow_right_sharp,
                                                color: themeChange.isDarkTheme() ? AppThemData.grey400 : AppThemData.grey500,
                                              ),
                                            )
                                          ],
                                        ),
                                        const SizedBox(height: 12),
                                        Container(
                                          padding: const EdgeInsets.only(bottom: 0),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              ClipRRect(
                                                borderRadius: BorderRadius.circular(2000),
                                                child: CachedNetworkImage(
                                                  height: 60,
                                                  width: 60,
                                                  imageUrl:
                                                      (Constant.userModel?.profilePic != null && Constant.userModel!.profilePic!.isNotEmpty)
                                                          ? Constant.userModel!.profilePic!
                                                          : Constant.profileConstant,
                                                  fit: BoxFit.cover,
                                                  placeholder: (context, url) => Constant.loader(),
                                                  errorWidget: (context, url, error) => Image.asset(Constant.userPlaceHolder),
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: Column(
                                                  mainAxisSize: MainAxisSize.min,
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      'ID: #${rentalBookingModel.id!.substring(0, 5)}',
                                                      style: GoogleFonts.inter(
                                                        color: themeChange.isDarkTheme() ? AppThemData.grey25 : AppThemData.grey950,
                                                        fontSize: 16,
                                                        fontWeight: FontWeight.w600,
                                                      ),
                                                    ),
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
                                                    Constant.amountToShow(
                                                        amount: Constant.calculateFinalRentalRideAmount(rentalBookingModel).toString()),
                                                    textAlign: TextAlign.right,
                                                    style: GoogleFonts.inter(
                                                      color: themeChange.isDarkTheme() ? AppThemData.grey25 : AppThemData.grey950,
                                                      fontSize: 16,
                                                      fontWeight: FontWeight.w500,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        Obx(
                                          () => Visibility(
                                            visible: isOpen.value,
                                            child: Column(
                                              children: [
                                                const SizedBox(height: 12),
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
                                                if (((rentalBookingModel.bookingStatus == BookingStatus.bookingPlaced) ||
                                                        (rentalBookingModel.bookingStatus == BookingStatus.driverAssigned)) &&
                                                    !rentalBookingModel.rejectedDriverId!.contains(FireStoreUtils.getCurrentUid())) ...{
                                                  const SizedBox(height: 16),
                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                    children: [
                                                      Expanded(
                                                        child: RoundShapeButton(
                                                          title: "Cancel Ride".tr,
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
                                                                        List rejectedId = rentalBookingModel.rejectedDriverId ?? [];
                                                                        rejectedId.add(FireStoreUtils.getCurrentUid());
                                                                        rentalBookingModel.bookingStatus = BookingStatus.bookingRejected;
                                                                        rentalBookingModel.rejectedDriverId = rejectedId;
                                                                        rentalBookingModel.updateAt = Timestamp.now();
                                                                        FireStoreUtils.setRentalRide(rentalBookingModel)
                                                                            .then((value) async {
                                                                          if (value == true) {
                                                                            ShowToastDialog.showToast("Ride cancelled successfully!".tr);

                                                                            if (rentalBookingModel.driverId != null &&
                                                                                rentalBookingModel.driverId!.isNotEmpty) {
                                                                              DriverUserModel? driverModel =
                                                                                  await FireStoreUtils.getDriverUserProfile(
                                                                                      rentalBookingModel.driverId.toString());
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
                                                          buttonColor: AppThemData.primary500,
                                                          buttonTextColor: AppThemData.black,
                                                          onTap: () {
                                                            if (double.parse(Constant.userModel!.walletAmount.toString()) >=
                                                                double.parse(Constant.minimumAmountToAcceptRide.toString())) {
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
                                                                          if (Constant.userModel!.subscriptionPlanId != null &&
                                                                              Constant.userModel!.subscriptionPlanId!.isNotEmpty) {
                                                                            if (Constant.userModel!.subscriptionTotalBookings == '0') {
                                                                              Navigator.pop(context);
                                                                              showDialog(
                                                                                  context: context,
                                                                                  builder: (context) {
                                                                                    return SubscriptionAlertDialog(
                                                                                      title:
                                                                                          "You can't accept more Rides.Upgrade your Plan.",
                                                                                      themeChange: themeChange,
                                                                                    );
                                                                                  });
                                                                              return;
                                                                            }
                                                                          }

                                                                          if (Constant.userModel!.subscriptionExpiryDate != null &&
                                                                              Constant.userModel!.subscriptionExpiryDate!
                                                                                  .toDate()
                                                                                  .isBefore(DateTime.now())) {
                                                                            Navigator.pop(context);
                                                                            showDialog(
                                                                                context: context,
                                                                                builder: (context) {
                                                                                  return SubscriptionAlertDialog(
                                                                                    title:
                                                                                        "Your subscription has expired. Please renew your plan.",
                                                                                    themeChange: themeChange,
                                                                                  );
                                                                                });
                                                                            return;
                                                                          }
                                                                        }

                                                                        rentalBookingModel.driverId = FireStoreUtils.getCurrentUid();
                                                                        rentalBookingModel.bookingStatus = BookingStatus.bookingAccepted;
                                                                        rentalBookingModel.updateAt = Timestamp.now();
                                                                        FireStoreUtils.setRentalRide(rentalBookingModel)
                                                                            .then((value) async {
                                                                          if (value == true) {
                                                                            ShowToastDialog.showToast("Ride accepted successfully!".tr);

                                                                            UserModel? receiverUserModel =
                                                                                await FireStoreUtils.getUserProfile(
                                                                                    rentalBookingModel.customerId.toString());
                                                                            Map<String, dynamic> playLoad = <String, dynamic>{
                                                                              "bookingId": rentalBookingModel.id
                                                                            };

                                                                            await SendNotification.sendOneNotification(
                                                                                type: "order",
                                                                                token: receiverUserModel!.fcmToken.toString(),
                                                                                title: 'Your Ride is Accepted'.tr,
                                                                                customerId: receiverUserModel.id,
                                                                                senderId: FireStoreUtils.getCurrentUid(),
                                                                                bookingId: rentalBookingModel.id.toString(),
                                                                                driverId: rentalBookingModel.driverId.toString(),isBooking: false,
                                                                                body:
                                                                                    'Your ride #${rentalBookingModel.id.toString().substring(0, 4)} has been confirmed.',
                                                                                payload: playLoad);
                                                                            if (Constant.isSubscriptionEnable == true &&
                                                                                Constant.userModel!.subscriptionPlanId != null &&
                                                                                Constant.userModel!.subscriptionPlanId!.isNotEmpty &&
                                                                                Constant.userModel!.subscriptionTotalBookings != '0' &&
                                                                                Constant.userModel!.subscriptionTotalBookings != '-1' &&
                                                                                Constant.userModel!.subscriptionTotalBookings != null) {
                                                                              int remainingBookings = int.parse(
                                                                                      Constant.userModel!.subscriptionTotalBookings!) -
                                                                                  1;
                                                                              Constant.userModel!.subscriptionTotalBookings =
                                                                                  remainingBookings.toString();
                                                                              await FireStoreUtils.updateDriverUser(Constant.userModel!);
                                                                            }
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
                                                                      positiveString: "Confirm".tr,
                                                                      negativeString: "Cancel".tr,
                                                                      themeChange: themeChange);
                                                                },
                                                              );
                                                            } else {
                                                              ShowToastDialog.showToast("minimumAmountToAcceptRide".trParams({
                                                                "minimumAmountToAcceptRide":
                                                                    Constant.amountShow(amount: Constant.minimumAmountToAcceptRide)
                                                              }));

                                                              // ShowToastDialog.showToast(
                                                              //     "You do not have sufficient wallet balance to accept the ride, as the minimum amount required is ${Constant.amountShow(amount: Constant.minimumAmountToAcceptRide)}.");
                                                            }
                                                          },
                                                          size: Size(0, 52),
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
                                                      RoundShapeButton(
                                                        title: "Cancel Ride".tr,
                                                        buttonColor: themeChange.isDarkTheme() ? AppThemData.grey900 : AppThemData.grey50,
                                                        buttonTextColor: themeChange.isDarkTheme() ? AppThemData.white : AppThemData.black,
                                                        onTap: () {
                                                          Get.to(() => ReasonForCancelRentalRideView(
                                                                rentalBookingModel: rentalBookingModel,
                                                              ));
                                                        },
                                                        size: Size(Responsive.width(40, context), 42),
                                                      ),
                                                      RoundShapeButton(
                                                        title: "Pickup".tr,
                                                        buttonColor: AppThemData.primary500,
                                                        buttonTextColor: AppThemData.black,
                                                        onTap: () {
                                                          if (Constant.isOtpFeatureEnable == true) {
                                                            Get.toNamed(Routes.ASK_FOR_OTP_RENTAL, arguments: {
                                                              "rentalBookingModel": rentalBookingModel,
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
                                                                        rentalBookingModel.bookingStatus = BookingStatus.bookingOngoing;
                                                                        rentalBookingModel.updateAt = Timestamp.now();
                                                                        rentalBookingModel.pickupTime = Timestamp.now();
                                                                        await FireStoreUtils.setRentalRide(rentalBookingModel);
                                                                        DriverUserModel? driverModel =
                                                                            await FireStoreUtils.getDriverUserProfile(
                                                                                rentalBookingModel.driverId.toString());

                                                                        driverModel!.bookingId = rentalBookingModel.id;
                                                                        driverModel.status = "busy";
                                                                        await FireStoreUtils.updateDriverUser(driverModel);

                                                                        ShowToastDialog.showToast("Your ride started....".tr);
                                                                        UserModel? receiverUserModel = await FireStoreUtils.getUserProfile(
                                                                            rentalBookingModel.customerId.toString());
                                                                        if (receiverUserModel != null &&
                                                                            receiverUserModel.fcmToken != null &&
                                                                            receiverUserModel.fcmToken!.isNotEmpty) {
                                                                          Map<String, dynamic> playLoad = <String, dynamic>{
                                                                            "bookingId": rentalBookingModel.id
                                                                          };
                                                                          await SendNotification.sendOneNotification(
                                                                            type: "order",
                                                                            token: receiverUserModel.fcmToken!,
                                                                            title: 'Your Ride is Started',
                                                                            customerId: receiverUserModel.id,
                                                                            senderId: FireStoreUtils.getCurrentUid(),
                                                                            bookingId: rentalBookingModel.id.toString(),
                                                                            driverId: rentalBookingModel.driverId.toString(),isBooking: false,
                                                                            body:
                                                                                'Your Ride is Started From ${rentalBookingModel.pickUpLocationAddress.toString()}.',
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
                                                        },
                                                        size: Size(Responsive.width(40, context), 42),
                                                      )
                                                    ],
                                                  )
                                                }
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            )
                          : NoRidesView(
                              themeChange: themeChange,
                            ),
                    ),
                  ),
                )
              ],
            ),
          );
        });
  }
}
