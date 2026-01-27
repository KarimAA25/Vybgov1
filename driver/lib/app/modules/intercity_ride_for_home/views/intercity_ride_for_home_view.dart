// ignore_for_file: depend_on_referenced_packages, use_build_context_synchronously

import 'package:cached_network_image/cached_network_image.dart';
import 'package:driver/app/models/booking_model.dart';
import 'package:driver/app/models/intercity_model.dart';
import 'package:driver/app/models/user_model.dart';
import 'package:driver/app/models/vehicle_type_model.dart';
import 'package:driver/app/models/wallet_transaction_model.dart';
import 'package:driver/app/modules/home/views/home_view.dart';
import 'package:driver/app/modules/intercity_booking_details/views/intercity_booking_details_view.dart';
import 'package:driver/app/modules/reason_for_cancel_intercity_cab/views/reason_for_cancel_intercity_view.dart';
import 'package:driver/app/modules/search_intercity_ride/search_intercity_view/search_ride_view.dart';
import 'package:driver/app/modules/track_intercity_ride_screen/views/track_intercity_ride_screen_view.dart';
import 'package:driver/app/routes/app_pages.dart';
import 'package:driver/constant/booking_status.dart';
import 'package:driver/constant/constant.dart';
import 'package:driver/constant/send_notification.dart';
import 'package:driver/constant_widgets/custom_dialog_box.dart';
import 'package:driver/constant_widgets/custom_loader.dart';
import 'package:driver/constant_widgets/pick_drop_point_view.dart';
import 'package:driver/constant_widgets/round_shape_button.dart';
import 'package:driver/constant_widgets/show_toast_dialog.dart';
import 'package:driver/extension/date_time_extension.dart';
import 'package:driver/theme/app_them_data.dart';
import 'package:driver/theme/responsive.dart';
import 'package:driver/utils/dark_theme_provider.dart';
import 'package:driver/utils/fire_store_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../controllers/intercity_ride_for_home_controller.dart';

class IntercityRideForHomeView extends GetView<IntercityRideForHomeController> {
  const IntercityRideForHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetX(
      init: IntercityRideForHomeController(),
      builder: (controller) {
        return Scaffold(
            backgroundColor: themeChange.isDarkTheme() ? AppThemData.black : AppThemData.grey25,
            body: Column(
              children: [
                if (controller.intercityRideList.isNotEmpty)
                  Padding(
                    padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: GestureDetector(
                      onTap: () {
                        Get.to(() => SearchRideView(selectedRideType: 'intercity'));
                      },
                      child: Container(
                        width: Responsive.width(100, context),
                        height: 56,
                        padding: const EdgeInsets.all(16),
                        decoration: ShapeDecoration(
                          color: themeChange.isDarkTheme() ? AppThemData.black : AppThemData.white,
                          shape: RoundedRectangleBorder(
                            side: BorderSide(width: 1, color: themeChange.isDarkTheme() ? AppThemData.grey900 : AppThemData.grey50),
                            borderRadius: BorderRadius.circular(100),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_rounded,
                              color: themeChange.isDarkTheme() ? AppThemData.grey400 : AppThemData.grey500,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                "Search Ride".tr,
                                style: GoogleFonts.inter(
                                  color: themeChange.isDarkTheme() ? AppThemData.grey400 : AppThemData.grey500,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                Expanded(
                  child: SingleChildScrollView(
                    child: controller.intercityRideList.isEmpty
                        ? Column(
                            children: [
                              SvgPicture.asset("assets/icon/ic_no_rides.svg"),
                              const SizedBox(
                                height: 24,
                              ),
                              Text(
                                "No Rides Found".tr,
                                textAlign: TextAlign.center,
                                style: GoogleFonts.inter(
                                  color: themeChange.isDarkTheme() ? AppThemData.grey25 : AppThemData.grey950,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 20, right: 20, top: 4, bottom: 24),
                                child: Text(
                                  "Your ride history is currently empty. Start your journey with MyTaxi by riding your first ride now!".tr,
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.inter(
                                    color: themeChange.isDarkTheme() ? AppThemData.grey25 : AppThemData.grey950,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ),
                              RoundShapeButton(
                                  title: "Search Ride".tr,
                                  buttonColor: AppThemData.primary500,
                                  buttonTextColor: AppThemData.black,
                                  onTap: () {
                                    Get.to(() => SearchRideView(selectedRideType: 'intercity'));
                                  },
                                  size: Size(200, 52))
                            ],
                          ).paddingOnly(top: 100)
                        : ListView.builder(
                            shrinkWrap: true,
                            itemCount: controller.intercityRideList.length,
                            physics: NeverScrollableScrollPhysics(),
                            itemBuilder: (context, index) {
                              RxBool isOpen = false.obs;
                              IntercityModel intercity = controller.intercityRideList[index];
                              return GestureDetector(
                                onTap: () {
                                  isOpen.value = !isOpen.value;
                                },
                                child: Container(
                                  width: Responsive.width(100, context),
                                  padding: const EdgeInsets.only(left: 16, right: 16, top: 16),
                                  margin: const EdgeInsets.only(top: 12, left: 16, right: 16),
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
                                            intercity.bookingTime == null ? "" : intercity.bookingTime!.toDate().dateMonthYear(),
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
                                              intercity.bookingTime == null ? "" : intercity.bookingTime!.toDate().time(),
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
                                              Get.to(
                                                InterCityBookingDetailsView(),
                                                arguments: {"bookingId": intercity.id ?? ''},
                                              );
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
                                        padding: const EdgeInsets.only(bottom: 12),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            FutureBuilder<UserModel?>(
                                              future: FireStoreUtils.getUserProfile(intercity.customerId ?? ''),
                                              builder: (context, snapshot) {
                                                if (snapshot.connectionState == ConnectionState.waiting) {
                                                  return Center(
                                                    child: CustomLoader(),
                                                  );
                                                }

                                                if (!snapshot.hasData || snapshot.data == null) {
                                                  return Container();
                                                }
                                                UserModel customerModel = snapshot.data ?? UserModel();
                                                return Container(
                                                  width: 60,
                                                  height: 60,
                                                  margin: const EdgeInsets.only(right: 10),
                                                  clipBehavior: Clip.antiAlias,
                                                  decoration: ShapeDecoration(
                                                    color: themeChange.isDarkTheme() ? AppThemData.grey950 : AppThemData.white,
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(200),
                                                    ),
                                                  ),
                                                  child: CachedNetworkImage(
                                                    imageUrl: (customerModel.profilePic != null && customerModel.profilePic!.isNotEmpty)
                                                        ? customerModel.profilePic!
                                                        : Constant.profileConstant,
                                                    fit: BoxFit.cover,
                                                    placeholder: (context, url) => Center(
                                                      child: CustomLoader(),
                                                    ),
                                                    errorWidget: (context, url, error) => Image.asset(Constant.userPlaceHolder),
                                                  ),
                                                );
                                              },
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    "Id".trParams({"id": intercity.id!.substring(0, 5)}),
                                                    //'ID: ${intercity.id!.substring(0, 5)}',
                                                    style: GoogleFonts.inter(
                                                      color: themeChange.isDarkTheme() ? AppThemData.grey25 : AppThemData.grey950,
                                                      fontSize: 16,
                                                      fontWeight: FontWeight.w600,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 2),
                                                  Text(
                                                    "Ride_Date".trParams({"ridedate": Constant.formatDate(Constant.parseDate(intercity.startDate))}),
                                                    // 'Ride Start Date: ${Constant.formatDate(Constant.parseDate(intercity.startDate))}',
                                                    style: GoogleFonts.inter(
                                                      color: themeChange.isDarkTheme() ? AppThemData.grey25 : AppThemData.grey950,
                                                      fontSize: 14,
                                                      fontWeight: FontWeight.w400,
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
                                                  Constant.amountToShow(amount: Constant.calculateInterCityFinalAmount(intercity).toString()),
                                                  // amount: Constant.calculateInterCityFinalAmount(intercity).toStringAsFixed(2)),
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
                                                      '${intercity.persons}',
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
                                      Obx(
                                        () => Visibility(
                                          visible: isOpen.value,
                                          child: Column(
                                            children: [
                                              const SizedBox(height: 12),
                                              PickDropPointView(
                                                pickUpAddress: intercity.pickUpLocationAddress ?? '',
                                                dropAddress: intercity.dropLocationAddress ?? '',
                                                stopAddress: intercity.stops!.isEmpty ? [] : intercity.stops!.map((e) => e.address!).toList(),
                                              ),
                                              const SizedBox(height: 16),
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  // Constant.isInterCityBid == false
                                                  intercity.bookingStatus == BookingStatus.bookingPlaced
                                                      ? intercity.isPersonalRide == true
                                                          ? Constant.isInterCityBid == true
                                                              ? Expanded(
                                                                  child: RoundShapeButton(
                                                                    title: (intercity.driverBidIdList == null || intercity.driverBidIdList!.isEmpty)
                                                                        ? "Add Bid".tr
                                                                        : (intercity.driverBidIdList!.contains(FireStoreUtils.getCurrentUid()) ? "View Bid".tr : "Add Bid".tr),
                                                                    buttonColor: AppThemData.primary500,
                                                                    buttonTextColor: AppThemData.black,
                                                                    onTap: () {
                                                                      Get.to(
                                                                        InterCityBookingDetailsView(),
                                                                        arguments: {"bookingId": intercity.id ?? ''},
                                                                      );
                                                                    },
                                                                    size: const Size(double.infinity, 48),
                                                                  ),
                                                                )
                                                              : Row(
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
                                                                                    List rejectedId = intercity.rejectedDriverId ?? [];
                                                                                    rejectedId.add(FireStoreUtils.getCurrentUid());
                                                                                    intercity.bookingStatus = BookingStatus.bookingRejected;
                                                                                    intercity.rejectedDriverId = rejectedId;
                                                                                    intercity.updateAt = Timestamp.now();
                                                                                    FireStoreUtils.setInterCityBooking(intercity).then((value) async {
                                                                                      if (value == true) {
                                                                                        ShowToastDialog.showToast("Ride cancelled successfully!".tr);
                                                                                        // DriverUserModel? driverModel =
                                                                                        //     await FireStoreUtils.getDriverUserProfile(intercity!.driverId.toString());
                                                                                        UserModel? receiverUserModel =
                                                                                            await FireStoreUtils.getUserProfile(intercity.customerId.toString());
                                                                                        Map<String, dynamic> playLoad = <String, dynamic>{"bookingId": intercity.id};

                                                                                        await SendNotification.sendOneNotification(
                                                                                            type: "order",
                                                                                            token: receiverUserModel!.fcmToken.toString(),
                                                                                            title: "Your Ride is Rejected".tr,
                                                                                            customerId: receiverUserModel.id,
                                                                                            senderId: FireStoreUtils.getCurrentUid(),
                                                                                            bookingId: intercity.id.toString(),
                                                                                            driverId: intercity.driverId.toString(),isBooking: false,
                                                                                            body:
                                                                                                'Your ride #${intercity.id.toString().substring(0, 5)} has been Rejected by Driver.',
                                                                                            // body: 'Your ride has been rejected by ${driverModel!.fullName}.',
                                                                                            payload: playLoad);

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
                                                                    SizedBox(
                                                                      width: 4,
                                                                    ),
                                                                    RoundShapeButton(
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
                                                                                      "Are you sure you want to accept this ride request? Once confirmed, you will be directed to the next step to proceed with the ride.".tr,
                                                                                  img: Image.asset(
                                                                                    "assets/icon/ic_green_right.png",
                                                                                    height: 58,
                                                                                    width: 58,
                                                                                  ),
                                                                                  positiveClick: () async {
                                                                                    if (Constant.isSubscriptionEnable == true) {
                                                                                      if (Constant.userModel!.subscriptionPlanId != null &&
                                                                                          Constant.userModel!.subscriptionPlanId!.isNotEmpty) {
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
                                                                                          // ShowToastDialog.showToast(
                                                                                          //     "You can't accept more Bookings.Upgrade your Plan.");
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
                                                                                        // ShowToastDialog.showToast(
                                                                                        //     "Your subscription has expired. Please renew your plan.");
                                                                                        return;
                                                                                      }
                                                                                    }

                                                                                    VehicleTypeModel? vehicleModel = await FireStoreUtils.getVehicleTypeById(
                                                                                        Constant.userModel!.driverVehicleDetails!.vehicleTypeId.toString());
                                                                                    intercity.driverVehicleDetails = Constant.userModel!.driverVehicleDetails;
                                                                                    intercity.vehicleType = vehicleModel;
                                                                                    intercity.driverId = FireStoreUtils.getCurrentUid();
                                                                                    intercity.bookingStatus = BookingStatus.bookingAccepted;
                                                                                    intercity.updateAt = Timestamp.now();
                                                                                    FireStoreUtils.setInterCityBooking(intercity).then((value) async {
                                                                                      if (value == true) {
                                                                                        ShowToastDialog.showToast("Ride accepted successfully!".tr);

                                                                                        UserModel? receiverUserModel =
                                                                                            await FireStoreUtils.getUserProfile(intercity.customerId.toString());
                                                                                        Map<String, dynamic> playLoad = <String, dynamic>{"bookingId": intercity.id};

                                                                                        await SendNotification.sendOneNotification(
                                                                                            type: "order",
                                                                                            token: receiverUserModel!.fcmToken.toString(),
                                                                                            title: 'Your Ride is Accepted',
                                                                                            customerId: receiverUserModel.id,
                                                                                            senderId: FireStoreUtils.getCurrentUid(),
                                                                                            bookingId: intercity.id.toString(),
                                                                                            driverId: intercity.driverId.toString(),isBooking: false,
                                                                                            body: 'Your ride #${intercity.id.toString().substring(0, 5)} has been confirmed.',
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
                                                                          ShowToastDialog.showToast("minimumAmountToAcceptRide".trParams(
                                                                              {"minimumAmountToAcceptRide": Constant.amountShow(amount: Constant.minimumAmountToAcceptRide)}));

                                                                          // ShowToastDialog.showToast(
                                                                          //     "You do not have sufficient wallet balance to accept the ride, as the minimum amount required is ${Constant.amountShow(amount: Constant.minimumAmountToAcceptRide)}.");
                                                                        }
                                                                      },
                                                                      size: Size(Responsive.width(40, context), 42),
                                                                    )
                                                                  ],
                                                                )
                                                          : Constant.isInterCitySharingBid == true
                                                              ? Expanded(
                                                                  child: RoundShapeButton(
                                                                    title: (intercity.driverBidIdList == null || intercity.driverBidIdList!.isEmpty)
                                                                        ? "Add Bid".tr
                                                                        : (intercity.driverBidIdList!.contains(FireStoreUtils.getCurrentUid()) ? "View Bid".tr : "Add Bid".tr),
                                                                    buttonColor: AppThemData.primary500,
                                                                    buttonTextColor: AppThemData.black,
                                                                    onTap: () {
                                                                      Get.to(
                                                                        InterCityBookingDetailsView(),
                                                                        arguments: {"bookingId": intercity.id ?? ''},
                                                                      );
                                                                    },
                                                                    size: const Size(double.infinity, 48),
                                                                  ),
                                                                )
                                                              : Row(
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
                                                                                    List rejectedId = intercity.rejectedDriverId ?? [];
                                                                                    rejectedId.add(FireStoreUtils.getCurrentUid());
                                                                                    intercity.bookingStatus = BookingStatus.bookingRejected;
                                                                                    intercity.rejectedDriverId = rejectedId;
                                                                                    intercity.updateAt = Timestamp.now();
                                                                                    FireStoreUtils.setInterCityBooking(intercity).then((value) async {
                                                                                      if (value == true) {
                                                                                        ShowToastDialog.showToast("Ride cancelled successfully!".tr);
                                                                                        // DriverUserModel? driverModel =
                                                                                        //     await FireStoreUtils.getDriverUserProfile(intercity!.driverId.toString());
                                                                                        UserModel? receiverUserModel =
                                                                                            await FireStoreUtils.getUserProfile(intercity.customerId.toString());
                                                                                        Map<String, dynamic> playLoad = <String, dynamic>{"bookingId": intercity.id};

                                                                                        await SendNotification.sendOneNotification(
                                                                                            type: "order",
                                                                                            token: receiverUserModel!.fcmToken.toString(),
                                                                                            title: 'Your Ride is Rejected',
                                                                                            customerId: receiverUserModel.id,
                                                                                            senderId: FireStoreUtils.getCurrentUid(),
                                                                                            bookingId: intercity.id.toString(),
                                                                                            driverId: intercity.driverId.toString(),isBooking: false,
                                                                                            body:
                                                                                                'Your ride #${intercity.id.toString().substring(0, 5)} has been Rejected by Driver.',
                                                                                            // body: 'Your ride has been rejected by ${driverModel!.fullName}.',
                                                                                            payload: playLoad);

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
                                                                    SizedBox(
                                                                      width: 4,
                                                                    ),
                                                                    RoundShapeButton(
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
                                                                                  positiveClick: () async {
                                                                                    if (Constant.isSubscriptionEnable == true) {
                                                                                      if (Constant.userModel!.subscriptionPlanId != null &&
                                                                                          Constant.userModel!.subscriptionPlanId!.isNotEmpty) {
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
                                                                                          // ShowToastDialog.showToast("You can't accept more Bookings.Upgrade your Plan.");
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
                                                                                        // ShowToastDialog.showToast("Your subscription has expired. Please renew your plan.");
                                                                                        return;
                                                                                      }
                                                                                    }
                                                                                    VehicleTypeModel? vehicleModel = await FireStoreUtils.getVehicleTypeById(
                                                                                        Constant.userModel!.driverVehicleDetails!.vehicleTypeId.toString());
                                                                                    intercity.driverVehicleDetails = Constant.userModel!.driverVehicleDetails;
                                                                                    intercity.vehicleType = vehicleModel;
                                                                                    intercity.driverId = FireStoreUtils.getCurrentUid();
                                                                                    intercity.bookingStatus = BookingStatus.bookingAccepted;
                                                                                    intercity.updateAt = Timestamp.now();
                                                                                    FireStoreUtils.setInterCityBooking(intercity).then((value) async {
                                                                                      if (value == true) {
                                                                                        ShowToastDialog.showToast("Ride accepted successfully!".tr);

                                                                                        UserModel? receiverUserModel =
                                                                                            await FireStoreUtils.getUserProfile(intercity.customerId.toString());
                                                                                        Map<String, dynamic> playLoad = <String, dynamic>{"bookingId": intercity.id};

                                                                                        await SendNotification.sendOneNotification(
                                                                                            type: "order",
                                                                                            token: receiverUserModel!.fcmToken.toString(),
                                                                                            title: 'Your Ride is Accepted',
                                                                                            customerId: receiverUserModel.id,
                                                                                            senderId: FireStoreUtils.getCurrentUid(),
                                                                                            bookingId: intercity.id.toString(),
                                                                                            driverId: intercity.driverId.toString(),isBooking: false,
                                                                                            body: 'Your ride #${intercity.id.toString().substring(0, 5)} has been confirmed.',
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
                                                                          ShowToastDialog.showToast("minimumAmountToAcceptRide".trParams(
                                                                              {"minimumAmountToAcceptRide": Constant.amountShow(amount: Constant.minimumAmountToAcceptRide)}));

                                                                          // ShowToastDialog.showToast(
                                                                          //     "You do not have sufficient wallet balance to accept the ride, as the minimum amount required is ${Constant.amountShow(amount: Constant.minimumAmountToAcceptRide)}.");
                                                                        }
                                                                      },
                                                                      size: Size(Responsive.width(40, context), 42),
                                                                    )
                                                                  ],
                                                                )
                                                      : intercity.bookingStatus == BookingStatus.bookingAccepted
                                                          ? Row(
                                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                              crossAxisAlignment: CrossAxisAlignment.center,
                                                              children: [
                                                                RoundShapeButton(
                                                                  title: "Cancel Ride".tr,
                                                                  buttonColor: themeChange.isDarkTheme() ? AppThemData.grey900 : AppThemData.grey50,
                                                                  buttonTextColor: themeChange.isDarkTheme() ? AppThemData.white : AppThemData.black,
                                                                  onTap: () {
                                                                    Get.to(() => ReasonForCancelInterCityView(bookingInterCityModel: intercity));
                                                                  },
                                                                  size: Size(Responsive.width(40, context), 42),
                                                                ),
                                                                const SizedBox(width: 4),
                                                                RoundShapeButton(
                                                                  title: "Pickup".tr,
                                                                  buttonColor: AppThemData.primary500,
                                                                  buttonTextColor: AppThemData.black,
                                                                  onTap: () {
                                                                    if (Constant.isOtpFeatureEnable == true) {
                                                                      Get.toNamed(Routes.ASK_FOR_OTP_INTERCITY, arguments: {
                                                                        "intercity": intercity,
                                                                      });
                                                                    } else {
                                                                      showDialog(
                                                                          context: context,
                                                                          builder: (BuildContext context) {
                                                                            return CustomDialogBox(
                                                                                themeChange: themeChange,
                                                                                title: "Confirm Ride Request".tr,
                                                                                descriptions:
                                                                                    "Are you sure you want to accept this ride request? Once confirmed, you will be directed to the next step to proceed with the ride."
                                                                                        .tr,
                                                                                positiveString: "Confirm".tr,
                                                                                negativeString: "Cancel".tr,
                                                                                positiveClick: () async {
                                                                                  Navigator.pop(context);
                                                                                  intercity.bookingStatus = BookingStatus.bookingOngoing;
                                                                                  intercity.updateAt = Timestamp.now();
                                                                                  intercity.pickupTime = Timestamp.now();
                                                                                  await FireStoreUtils.setInterCityBooking(intercity);
                                                                                  ShowToastDialog.showToast("Your ride started....");
                                                                                  UserModel? receiverUserModel =
                                                                                      await FireStoreUtils.getUserProfile(intercity.customerId.toString());
                                                                                  Map<String, dynamic> playLoad = <String, dynamic>{"bookingId": intercity.id};

                                                                                  await SendNotification.sendOneNotification(
                                                                                      type: "order",
                                                                                      token: receiverUserModel!.fcmToken.toString(),
                                                                                      title: 'Your Ride is Started',
                                                                                      customerId: receiverUserModel.id,
                                                                                      senderId: FireStoreUtils.getCurrentUid(),
                                                                                      bookingId: intercity.id.toString(),
                                                                                      driverId: intercity.driverId.toString(),isBooking: false,
                                                                                      body:
                                                                                          'Your Ride is Started From ${intercity.pickUpLocationAddress.toString()} to ${intercity.dropLocationAddress.toString()}.',
                                                                                      payload: playLoad);
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
                                                                  size: Size(Responsive.width(40, context), 42),
                                                                )
                                                              ],
                                                            )
                                                          // : SizedBox()
                                                          : intercity.bookingStatus == BookingStatus.bookingPlaced
                                                              ? Expanded(
                                                                  child: RoundShapeButton(
                                                                    title: (intercity.driverBidIdList == null || intercity.driverBidIdList!.isEmpty)
                                                                        ? "Add Bid".tr
                                                                        : (intercity.driverBidIdList!.contains(FireStoreUtils.getCurrentUid()) ? "View Bid".tr : "Add Bid".tr),
                                                                    buttonColor: AppThemData.primary500,
                                                                    buttonTextColor: AppThemData.black,
                                                                    onTap: () {
                                                                      Get.to(
                                                                        InterCityBookingDetailsView(),
                                                                        arguments: {"bookingId": intercity.id ?? ''},
                                                                      );
                                                                    },
                                                                    size: const Size(double.infinity, 48),
                                                                  ),
                                                                )
                                                              : intercity.bookingStatus == BookingStatus.bookingAccepted
                                                                  ? Row(
                                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                      crossAxisAlignment: CrossAxisAlignment.center,
                                                                      children: [
                                                                        RoundShapeButton(
                                                                          title: "Cancel Ride".tr,
                                                                          buttonColor: themeChange.isDarkTheme() ? AppThemData.grey900 : AppThemData.grey50,
                                                                          buttonTextColor: themeChange.isDarkTheme() ? AppThemData.white : AppThemData.black,
                                                                          onTap: () {
                                                                            Get.to(() => ReasonForCancelInterCityView(bookingInterCityModel: intercity));
                                                                          },
                                                                          size: Size(Responsive.width(40, context), 42),
                                                                        ),
                                                                        const SizedBox(width: 4),
                                                                        RoundShapeButton(
                                                                          title: "Pickup".tr,
                                                                          buttonColor: AppThemData.primary500,
                                                                          buttonTextColor: AppThemData.black,
                                                                          onTap: () {
                                                                            if (Constant.isOtpFeatureEnable == true) {
                                                                              Get.toNamed(Routes.ASK_FOR_OTP_INTERCITY, arguments: {
                                                                                "intercity": intercity,
                                                                              });
                                                                            } else {
                                                                              showDialog(
                                                                                  context: context,
                                                                                  builder: (BuildContext context) {
                                                                                    return CustomDialogBox(
                                                                                        themeChange: themeChange,
                                                                                        title: "Confirm Ride Request".tr,
                                                                                        descriptions:
                                                                                            "Are you sure you want to accept this ride request? Once confirmed, you will be directed to the next step to proceed with the ride."
                                                                                                .tr,
                                                                                        positiveString: "Confirm".tr,
                                                                                        negativeString: "Cancel".tr,
                                                                                        positiveClick: () async {
                                                                                          Navigator.pop(context);
                                                                                          intercity.bookingStatus = BookingStatus.bookingOngoing;
                                                                                          intercity.updateAt = Timestamp.now();
                                                                                          intercity.pickupTime = Timestamp.now();
                                                                                          await FireStoreUtils.setInterCityBooking(intercity);
                                                                                          ShowToastDialog.showToast("Your ride started....");
                                                                                          UserModel? receiverUserModel =
                                                                                              await FireStoreUtils.getUserProfile(intercity.customerId.toString());
                                                                                          Map<String, dynamic> playLoad = <String, dynamic>{"bookingId": intercity.id};

                                                                                          await SendNotification.sendOneNotification(
                                                                                              type: "order",
                                                                                              token: receiverUserModel!.fcmToken.toString(),
                                                                                              title: 'Your Ride is Started',
                                                                                              customerId: receiverUserModel.id,
                                                                                              senderId: FireStoreUtils.getCurrentUid(),
                                                                                              bookingId: intercity.id.toString(),
                                                                                              driverId: intercity.driverId.toString(),isBooking: false,
                                                                                              body:
                                                                                                  'Your Ride is Started From ${intercity.pickUpLocationAddress.toString()} to ${intercity.dropLocationAddress.toString()}.',
                                                                                              payload: playLoad);
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
                                                                          size: Size(Responsive.width(40, context), 42),
                                                                        )
                                                                      ],
                                                                    )
                                                                  // intercity.bookingStatus == BookingStatus.bookingOngoing
                                                                  //                 ? Row(
                                                                  //                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                  //                     crossAxisAlignment: CrossAxisAlignment.center,
                                                                  //                     children: [
                                                                  //                       RoundShapeButton(
                                                                  //                         title: "Cancel Ride",
                                                                  //                         buttonColor: themeChange.isDarkTheme() ? AppThemData.grey900 : AppThemData.grey50,
                                                                  //                         buttonTextColor: themeChange.isDarkTheme() ? AppThemData.white : AppThemData.black,
                                                                  //                         onTap: () {
                                                                  //                           Get.to(() => ReasonForCancelInterCityView(
                                                                  //                                 bookingInterCityModel: intercity ?? IntercityModel(),
                                                                  //                               ));
                                                                  //                         },
                                                                  //                         size: Size(Responsive.width(40, context), 42),
                                                                  //                       ),
                                                                  //                       RoundShapeButton(
                                                                  //                         title: "Pickup",
                                                                  //                         buttonColor: AppThemData.primary500,
                                                                  //                         buttonTextColor: AppThemData.black,
                                                                  //                         onTap: () {
                                                                  //                           Get.toNamed(Routes.ASK_FOR_OTP_INTERCITY, arguments: {
                                                                  //                             "intercity": intercity,
                                                                  //                           });
                                                                  //                         },
                                                                  //                         size: Size(Responsive.width(40, context), 42),
                                                                  //                       )
                                                                  //                     ],
                                                                  //                   )
                                                                  : SizedBox(),
                                                  Row(
                                                    children: [
                                                      intercity.bookingStatus == BookingStatus.bookingOngoing
                                                          ? RoundShapeButton(
                                                              title: "Complete Ride".tr,
                                                              buttonColor: AppThemData.success500,
                                                              buttonTextColor: AppThemData.white,
                                                              onTap: () {
                                                                if (intercity.paymentType != Constant.paymentModel!.cash!.name) {
                                                                  if (intercity.paymentStatus == true) {
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
                                                                              controller.completeInterCityBooking(intercity);
                                                                              Get.back();

                                                                              // Get.to(const HomeView());

                                                                              // Get.offAll(const HomeView());
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
                                                                            if (intercity.paymentType == Constant.paymentModel!.cash!.name) {
                                                                              Navigator.pop(context);
                                                                              intercity.paymentStatus = true;
                                                                              if (Constant.adminCommission != null &&
                                                                                  Constant.adminCommission!.active == true &&
                                                                                  num.parse(Constant.adminCommission!.value!) > 0) {
                                                                                WalletTransactionModel adminCommissionWallet = WalletTransactionModel(
                                                                                    id: Constant.getUuid(),
                                                                                    amount:
                                                                                        "${Constant.calculateAdminCommission(amount: ((double.parse(intercity.subTotal ?? '0.0')) - (double.parse(intercity.discount ?? '0.0'))).toString(), adminCommission: intercity.adminCommission)}",
                                                                                    createdDate: Timestamp.now(),
                                                                                    paymentType: "Wallet",
                                                                                    transactionId: intercity.id,
                                                                                    isCredit: false,
                                                                                    type: Constant.typeDriver,
                                                                                    userId: intercity.driverId,
                                                                                    note: "Admin commission Debited".tr,
                                                                                    adminCommission: intercity.adminCommission);

                                                                                await FireStoreUtils.setWalletTransaction(adminCommissionWallet).then((value) async {
                                                                                  if (value == true) {
                                                                                    await FireStoreUtils.updateDriverUserWallet(
                                                                                        amount:
                                                                                            "-${Constant.calculateAdminCommission(amount: ((double.parse(intercity.subTotal ?? '0.0')) - (double.parse(intercity.discount ?? '0.0'))).toString(), adminCommission: intercity.adminCommission)}");
                                                                                  }
                                                                                });
                                                                              }

                                                                              await FireStoreUtils.setInterCityBooking(intercity).then((value) async {
                                                                                controller.completeInterCityBooking(intercity);
                                                                                await FireStoreUtils.updateTotalEarning(
                                                                                    amount: (double.parse(Constant.calculateInterCityFinalAmount(intercity).toString()) -
                                                                                            double.parse(Constant.calculateAdminCommission(
                                                                                                    amount: ((double.parse(intercity.subTotal ?? '0.0')) -
                                                                                                            (double.parse(intercity.discount ?? '0.0')))
                                                                                                        .toString(),
                                                                                                    adminCommission: intercity.adminCommission)
                                                                                                .toString()))
                                                                                        .toString());
                                                                                Navigator.pop(context);
                                                                                Get.to(const HomeView());

                                                                                // Get.back();
                                                                                // Get.offAll(const HomeView());
                                                                              });
                                                                            } else {
                                                                              if (intercity.paymentStatus == true) {
                                                                                controller.completeInterCityBooking(intercity);
                                                                                Navigator.pop(context);
                                                                                // Get.to(const HomeView());
                                                                                // Get.back();
                                                                                // Get.offAll(const HomeView());
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
                                                              size: Size(140, 52),
                                                            )
                                                          : SizedBox(),
                                                      SizedBox(
                                                        width: 8,
                                                      ),
                                                      intercity.bookingStatus == BookingStatus.bookingOngoing
                                                          ? RoundShapeButton(
                                                              title: "Hold Ride".tr,
                                                              buttonColor: AppThemData.danger500,
                                                              buttonTextColor: AppThemData.white,
                                                              onTap: () async {
                                                                intercity.holdTiming ??= [];

                                                                intercity.holdTiming!.add(HoldTimingModel(startTime: Timestamp.now(), endTime: null));

                                                                intercity.bookingStatus = BookingStatus.bookingOnHold;
                                                                intercity.updateAt = Timestamp.now();

                                                                FireStoreUtils.setInterCityBooking(intercity);
                                                                ShowToastDialog.showToast("Ride On Hold".tr);

                                                                UserModel? receiverUserModel = await FireStoreUtils.getUserProfile(intercity.customerId.toString());
                                                                Map<String, dynamic> playLoad = <String, dynamic>{"bookingId": intercity.id};

                                                                await SendNotification.sendOneNotification(
                                                                    type: "order",
                                                                    token: receiverUserModel!.fcmToken.toString(),
                                                                    title: 'Your Ride is On Hold'.tr,
                                                                    customerId: receiverUserModel.id,
                                                                    senderId: FireStoreUtils.getCurrentUid(),isBooking: false,
                                                                    bookingId: intercity.id.toString(),
                                                                    driverId: intercity.driverId.toString(),
                                                                    body: 'Your ride #${intercity.id.toString().substring(0, 4)} is currently on hold.',
                                                                    payload: playLoad);
                                                              },
                                                              size: Size(100, 52),
                                                            )
                                                          : SizedBox(),
                                                      intercity.bookingStatus == BookingStatus.bookingOnHold
                                                          ? RoundShapeButton(
                                                              title: "Resume Ride".tr,
                                                              buttonColor: AppThemData.danger500,
                                                              buttonTextColor: AppThemData.white,
                                                              onTap: () async {
                                                                controller.calculateHoldCharge(intercity);
                                                                UserModel? receiverUserModel = await FireStoreUtils.getUserProfile(intercity.customerId.toString());
                                                                Map<String, dynamic> playLoad = <String, dynamic>{"bookingId": intercity.id};

                                                                await SendNotification.sendOneNotification(
                                                                    type: "order",
                                                                    token: receiverUserModel!.fcmToken.toString(),
                                                                    title: 'Your Ride has Resumed'.tr,
                                                                    customerId: receiverUserModel.id,
                                                                    senderId: FireStoreUtils.getCurrentUid(),
                                                                    bookingId: intercity.id.toString(),
                                                                    driverId: intercity.driverId.toString(),isBooking: false,
                                                                    body: 'Your ride #${intercity.id.toString().substring(0, 4)} has Resumed',
                                                                    payload: playLoad);
                                                              },
                                                              size: Size(220, 52),
                                                            )
                                                          : SizedBox(),
                                                      SizedBox(
                                                        width: 8,
                                                      ),
                                                      intercity.bookingStatus == BookingStatus.bookingOnHold || intercity.bookingStatus == BookingStatus.bookingOngoing
                                                          ? InkWell(
                                                              onTap: () {
                                                                Get.to(() => TrackIntercityRideScreenView(), arguments: {"interCityModel": intercity});
                                                              },
                                                              child: SvgPicture.asset(
                                                                "assets/icon/ic_live_track.svg",
                                                                width: 40,
                                                              ))
                                                          : SizedBox()
                                                    ],
                                                  )
                                                ],
                                              ),
                                              const SizedBox(height: 10),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ),
              ],
            ));
      },
    );
  }
}
