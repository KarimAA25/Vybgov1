// ignore_for_file: depend_on_referenced_packages, use_build_context_synchronously, deprecated_member_use
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:driver/app/models/booking_model.dart';
import 'package:driver/app/models/emergency_number_model.dart';
import 'package:driver/app/models/user_model.dart';
import 'package:driver/app/models/vehicle_type_model.dart';
import 'package:driver/app/models/wallet_transaction_model.dart';
import 'package:driver/app/modules/add_customer_review/views/add_customer_review_view.dart';
import 'package:driver/app/modules/emergency_contacts/views/emergency_contacts_view.dart';
import 'package:driver/app/modules/home/views/home_view.dart';
import 'package:driver/app/modules/reason_for_cancel_intercity_cab/views/reason_for_cancel_intercity_view.dart';
import 'package:driver/app/modules/search_intercity_ride/controllers/search_ride_controller.dart';
import 'package:driver/app/modules/track_intercity_ride_screen/views/track_intercity_ride_screen_view.dart';
import 'package:driver/app/routes/app_pages.dart';
import 'package:driver/constant/booking_status.dart';
import 'package:driver/constant/constant.dart';
import 'package:driver/constant/send_notification.dart';
import 'package:driver/constant_widgets/app_bar_with_border.dart';
import 'package:driver/constant_widgets/custom_dialog_box.dart';
import 'package:driver/constant_widgets/round_shape_button.dart';
import 'package:driver/constant_widgets/show_toast_dialog.dart';
import 'package:driver/theme/app_them_data.dart';
import 'package:driver/theme/responsive.dart';
import 'package:driver/utils/dark_theme_provider.dart';
import 'package:driver/utils/fire_store_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../controllers/intercity_booking_details_controller.dart';
import 'widget/intercity_bid_view.dart';
import 'widget/intercity_detail_view.dart';

class InterCityBookingDetailsView extends StatelessWidget {
  const InterCityBookingDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetX(
        init: InterCityBookingDetailsController(),
        builder: (controller) {
          bool shouldShowButton = controller.interCityModel.value.bidList?.any((bid) => bid.driverID == FireStoreUtils.getCurrentUid()) == false;
          return Scaffold(
            backgroundColor: themeChange.isDarkTheme() ? AppThemData.black : AppThemData.white,
            appBar: AppBarWithBorder(
              title: "Intercity Ride Detail".tr,
              bgColor: themeChange.isDarkTheme() ? AppThemData.black : AppThemData.white,
              actions: [
                (controller.interCityModel.value.bookingStatus == BookingStatus.bookingOngoing && controller.canShowSOS.value)
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
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (controller.interCityModel.value.bookingStatus == BookingStatus.bookingPlaced) ...{
                    controller.interCityModel.value.isPersonalRide == true
                        ? Constant.isInterCityBid == true
                            ? shouldShowButton != true
                                ? SizedBox()
                                : RoundShapeButton(
                                    title: "Add Bid".tr,
                                    buttonColor: AppThemData.primary500,
                                    buttonTextColor: AppThemData.black,
                                    onTap: () {
                                      showDialog(
                                        context: context,
                                        builder: (context) {
                                          return BidDialogBox(
                                            onPressConfirm: () async {
                                              if (Constant.isSubscriptionEnable == true) {
                                                if (Constant.userModel!.subscriptionPlanId != null && Constant.userModel!.subscriptionPlanId!.isNotEmpty) {
                                                  if (Constant.userModel!.subscriptionTotalBookings == '0') {
                                                    Navigator.pop(context);
                                                    showDialog(
                                                        context: context,
                                                        builder: (context) {
                                                          return SubscriptionAlertDialog(
                                                            title: "You can't Add the Bid. Upgrade your Plan.".tr,
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
                                              controller.saveBidDetail();
                                              Navigator.pop(context);
                                            },
                                            themeChange: themeChange,
                                            onPressCancel: () {
                                              Get.back();
                                            },
                                          );
                                        },
                                      );
                                    },
                                    size: Size(Responsive.width(90, context), 52),
                                  )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(top: 10),
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
                                                    List rejectedId = controller.interCityModel.value.rejectedDriverId ?? [];
                                                    rejectedId.add(FireStoreUtils.getCurrentUid());
                                                    controller.interCityModel.value.bookingStatus = BookingStatus.bookingRejected;
                                                    controller.interCityModel.value.rejectedDriverId = rejectedId;
                                                    controller.interCityModel.value.updateAt = Timestamp.now();
                                                    FireStoreUtils.setInterCityBooking(controller.interCityModel.value).then((value) async {
                                                      if (value == true) {
                                                        ShowToastDialog.showToast("Intercity ride cancelled successfully!".tr);
                                                        // DriverUserModel? driverModel =
                                                        //     await FireStoreUtils.getDriverUserProfile(bookingModel!.driverId.toString());
                                                        UserModel? receiverUserModel = await FireStoreUtils.getUserProfile(controller.interCityModel.value.customerId.toString());
                                                        Map<String, dynamic> playLoad = <String, dynamic>{"bookingId": controller.interCityModel.value.id};

                                                        await SendNotification.sendOneNotification(
                                                            type: "order",
                                                            token: receiverUserModel!.fcmToken.toString(),
                                                            title: 'Your Intercity Ride is Rejected',
                                                            customerId: receiverUserModel.id,
                                                            senderId: FireStoreUtils.getCurrentUid(),
                                                            bookingId: controller.interCityModel.value.id.toString(),
                                                            driverId: controller.interCityModel.value.driverId.toString(),
                                                            body: 'Your ride #${controller.interCityModel.value.id.toString().substring(0, 5)} has been Rejected by Driver.',
                                                            // body: 'Your ride has been rejected by ${driverModel!.fullName}.',
                                                            payload: playLoad,isBooking: false);

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
                                      size: Size(Responsive.width(40, context), 52),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 12,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 10),
                                    child: RoundShapeButton(
                                      title: "Accept".tr,
                                      buttonColor: AppThemData.primary500,
                                      buttonTextColor: AppThemData.black,
                                      onTap: () {
                                        if (double.parse(Constant.userModel!.walletAmount.toString()) >= double.parse(Constant.minimumAmountToAcceptRide.toString())) {
                                          showDialog(
                                            context: context,
                                            builder: (context) {
                                              return CustomDialogBox(
                                                  title: "Confirm Intercity Ride Request".tr,
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
                                                    VehicleTypeModel? vehicleModel =
                                                        await FireStoreUtils.getVehicleTypeById(Constant.userModel!.driverVehicleDetails!.vehicleTypeId.toString());
                                                    controller.interCityModel.value.driverVehicleDetails = Constant.userModel!.driverVehicleDetails;
                                                    controller.interCityModel.value.vehicleType = vehicleModel;
                                                    controller.interCityModel.value.driverId = FireStoreUtils.getCurrentUid();
                                                    controller.interCityModel.value.bookingStatus = BookingStatus.bookingAccepted;
                                                    controller.interCityModel.value.updateAt = Timestamp.now();
                                                    FireStoreUtils.setInterCityBooking(controller.interCityModel.value).then((value) async {
                                                      if (value == true) {
                                                        ShowToastDialog.showToast("Intercity Ride accepted successfully!".tr);
                                                        UserModel? receiverUserModel = await FireStoreUtils.getUserProfile(controller.interCityModel.value.customerId.toString());
                                                        Map<String, dynamic> playLoad = <String, dynamic>{"bookingId": controller.interCityModel.value.id};

                                                        if (controller.isSearch.value == true) {
                                                          SearchRideController searchController = Get.put(SearchRideController());
                                                          searchController.searchIntercityList.removeWhere((parcel) => parcel.id == controller.interCityModel.value.id);
                                                          searchController.intercityBookingList.removeWhere((parcel) => parcel.id == controller.interCityModel.value.id);
                                                          ShowToastDialog.closeLoader();
                                                        }

                                                        await SendNotification.sendOneNotification(
                                                            type: "order",
                                                            token: receiverUserModel!.fcmToken.toString(),
                                                            title: 'Your Intercity Ride is Accepted',
                                                            customerId: receiverUserModel.id,
                                                            senderId: FireStoreUtils.getCurrentUid(),
                                                            bookingId: controller.interCityModel.value.id.toString(),
                                                            driverId: controller.interCityModel.value.driverId.toString(),isBooking: false,
                                                            body: 'Your ride #${controller.interCityModel.value.id.toString().substring(0, 5)} has been confirmed.',
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
                                          ShowToastDialog.showToast(
                                              "minimumAmountToAcceptRide".trParams({"minimumAmountToAcceptRide": Constant.amountShow(amount: Constant.minimumAmountToAcceptRide)}));

                                          // ShowToastDialog.showToast(
                                          //     "You do not have sufficient wallet balance to accept the ride, as the minimum amount required is ${Constant.amountShow(amount: Constant.minimumAmountToAcceptRide)}.");
                                        }
                                      },
                                      size: Size(Responsive.width(40, context), 52),
                                    ),
                                  )
                                ],
                              )
                        : Constant.isInterCitySharingBid == true
                            ? shouldShowButton != true
                                ? SizedBox()
                                : RoundShapeButton(
                                    title: "Add Bid".tr,
                                    buttonColor: AppThemData.primary500,
                                    buttonTextColor: AppThemData.black,
                                    onTap: () {
                                      showDialog(
                                        context: context,
                                        builder: (context) {
                                          return BidDialogBox(
                                            onPressConfirm: () async {
                                              if (Constant.isSubscriptionEnable == true) {
                                                if (Constant.userModel!.subscriptionPlanId != null && Constant.userModel!.subscriptionPlanId!.isNotEmpty) {
                                                  if (Constant.userModel!.subscriptionTotalBookings == '0') {
                                                    Navigator.pop(context);
                                                    showDialog(
                                                        context: context,
                                                        builder: (context) {
                                                          return SubscriptionAlertDialog(
                                                            title: "You can't Add the Bid. Upgrade your Plan.".tr,
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

                                              controller.saveBidDetail();
                                              Navigator.pop(context);
                                            },
                                            themeChange: themeChange,
                                            onPressCancel: () {
                                              Get.back();
                                            },
                                          );
                                        },
                                      );
                                    },
                                    size: Size(Responsive.width(90, context), 52),
                                  )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(top: 10),
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
                                                    List rejectedId = controller.interCityModel.value.rejectedDriverId ?? [];
                                                    rejectedId.add(FireStoreUtils.getCurrentUid());
                                                    controller.interCityModel.value.bookingStatus = BookingStatus.bookingRejected;
                                                    controller.interCityModel.value.rejectedDriverId = rejectedId;
                                                    controller.interCityModel.value.updateAt = Timestamp.now();
                                                    FireStoreUtils.setInterCityBooking(controller.interCityModel.value).then((value) async {
                                                      if (value == true) {
                                                        ShowToastDialog.showToast("Intercity ride cancelled successfully!".tr);
                                                        // DriverUserModel? driverModel =
                                                        //     await FireStoreUtils.getDriverUserProfile(bookingModel!.driverId.toString());
                                                        UserModel? receiverUserModel = await FireStoreUtils.getUserProfile(controller.interCityModel.value.customerId.toString());
                                                        Map<String, dynamic> playLoad = <String, dynamic>{"bookingId": controller.interCityModel.value.id};

                                                        await SendNotification.sendOneNotification(
                                                            type: "order",
                                                            token: receiverUserModel!.fcmToken.toString(),
                                                            title: 'Your Intercity Ride is Rejected',
                                                            customerId: receiverUserModel.id,
                                                            senderId: FireStoreUtils.getCurrentUid(),
                                                            bookingId: controller.interCityModel.value.id.toString(),
                                                            driverId: controller.interCityModel.value.driverId.toString(),isBooking: false,
                                                            body: 'Your ride #${controller.interCityModel.value.id.toString().substring(0, 5)} has been Rejected by Driver.',
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
                                      size: Size(Responsive.width(40, context), 52), // 40% width
                                    ),
                                  ),
                                  SizedBox(
                                    width: 12,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 10),
                                    child: RoundShapeButton(
                                      title: "Accept".tr,
                                      buttonColor: AppThemData.primary500,
                                      buttonTextColor: AppThemData.black,
                                      onTap: () {
                                        if (double.parse(Constant.userModel!.walletAmount.toString()) >= double.parse(Constant.minimumAmountToAcceptRide.toString())) {
                                          showDialog(
                                            context: context,
                                            builder: (context) {
                                              return CustomDialogBox(
                                                  title: "Confirm Intercity Ride Request".tr,
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
                                                    VehicleTypeModel? vehicleModel =
                                                        await FireStoreUtils.getVehicleTypeById(Constant.userModel!.driverVehicleDetails!.vehicleTypeId.toString());
                                                    controller.interCityModel.value.driverVehicleDetails = Constant.userModel!.driverVehicleDetails;
                                                    controller.interCityModel.value.vehicleType = vehicleModel;
                                                    controller.interCityModel.value.driverId = FireStoreUtils.getCurrentUid();
                                                    controller.interCityModel.value.bookingStatus = BookingStatus.bookingAccepted;
                                                    controller.interCityModel.value.updateAt = Timestamp.now();
                                                    FireStoreUtils.setInterCityBooking(controller.interCityModel.value).then((value) async {
                                                      if (value == true) {
                                                        ShowToastDialog.showToast("Intercity Ride accepted successfully!".tr);
                                                        UserModel? receiverUserModel = await FireStoreUtils.getUserProfile(controller.interCityModel.value.customerId.toString());
                                                        Map<String, dynamic> playLoad = <String, dynamic>{"bookingId": controller.interCityModel.value.id};

                                                        await SendNotification.sendOneNotification(
                                                            type: "order",
                                                            token: receiverUserModel!.fcmToken.toString(),
                                                            title: 'Your Intercity Ride is Accepted',
                                                            customerId: receiverUserModel.id,
                                                            senderId: FireStoreUtils.getCurrentUid(),
                                                            bookingId: controller.interCityModel.value.id.toString(),
                                                            driverId: controller.interCityModel.value.driverId.toString(),isBooking: false,
                                                            body: 'Your ride #${controller.interCityModel.value.id.toString().substring(0, 5)} has been confirmed.',
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
                                          ShowToastDialog.showToast(
                                              "minimumAmountToAcceptRide".trParams({"minimumAmountToAcceptRide": Constant.amountShow(amount: Constant.minimumAmountToAcceptRide)}));

                                          // ShowToastDialog.showToast(
                                          //     "You do not have sufficient wallet balance to accept the ride, as the minimum amount required is ${Constant.amountShow(amount: Constant.minimumAmountToAcceptRide)}.");
                                        }
                                      },
                                      size: Size(Responsive.width(40, context), 52),
                                    ),
                                  )
                                ],
                              )
                  },
                  if (controller.interCityModel.value.bookingStatus == BookingStatus.bookingAccepted &&
                      controller.interCityModel.value.driverId == FireStoreUtils.getCurrentUid()) ...{
                    Expanded(
                      child: RoundShapeButton(
                        title: "Cancel".tr,
                        buttonColor: AppThemData.grey50,
                        buttonTextColor: AppThemData.black,
                        onTap: () {
                          Get.to(() => ReasonForCancelInterCityView(
                                bookingInterCityModel: controller.interCityModel.value,
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
                      buttonColor: AppThemData.primary500,
                      buttonTextColor: AppThemData.black,
                      onTap: () {
                        if (Constant.isOtpFeatureEnable == true) {
                          Get.toNamed(Routes.ASK_FOR_OTP_INTERCITY, arguments: {
                            "intercity": controller.interCityModel.value,
                          });
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
                                      controller.interCityModel.value.bookingStatus = BookingStatus.bookingOngoing;
                                      controller.interCityModel.value.updateAt = Timestamp.now();
                                      controller.interCityModel.value.pickupTime = Timestamp.now();
                                      await FireStoreUtils.setInterCityBooking(controller.interCityModel.value);
                                      ShowToastDialog.showToast("Your ride started....".tr);
                                      UserModel? receiverUserModel = await FireStoreUtils.getUserProfile(controller.interCityModel.value.customerId.toString());
                                      Map<String, dynamic> playLoad = <String, dynamic>{"bookingId": controller.interCityModel.value.id};

                                      await SendNotification.sendOneNotification(
                                          type: "order",
                                          token: receiverUserModel!.fcmToken.toString(),
                                          title: 'Your Ride is Started',
                                          customerId: receiverUserModel.id,
                                          senderId: FireStoreUtils.getCurrentUid(),
                                          bookingId: controller.interCityModel.value.id.toString(),
                                          driverId: controller.interCityModel.value.driverId.toString(),isBooking: false,
                                          body:
                                              'Your Ride is Started From ${controller.interCityModel.value.pickUpLocationAddress.toString()} to ${controller.interCityModel.value.dropLocationAddress.toString()}.',
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
                      size: Size(0, 52),
                    )),
                  },
                  if (controller.interCityModel.value.bookingStatus == BookingStatus.bookingOngoing)
                    Expanded(
                      child: RoundShapeButton(
                        title: "Complete Ride".tr,
                        buttonColor: AppThemData.success500,
                        buttonTextColor: AppThemData.white,
                        onTap: () {
                          controller.getBookingDetails();
                          if (controller.interCityModel.value.paymentType != Constant.paymentModel!.cash!.name) {
                            if (controller.interCityModel.value.paymentStatus == true) {
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
                                        controller.completeInterCityBooking(controller.interCityModel.value);
                                        controller.getBookingDetails();
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
                                      if (controller.interCityModel.value.paymentType == Constant.paymentModel!.cash!.name) {
                                        Navigator.pop(context);
                                        controller.interCityModel.value.paymentStatus = true;
                                        if (Constant.adminCommission != null && Constant.adminCommission!.active == true && num.parse(Constant.adminCommission!.value!) > 0) {
                                          WalletTransactionModel adminCommissionWallet = WalletTransactionModel(
                                              id: Constant.getUuid(),
                                              amount:
                                                  "${Constant.calculateAdminCommission(amount: ((double.parse(controller.interCityModel.value.subTotal ?? '0.0')) - (double.parse(controller.interCityModel.value.discount ?? '0.0'))).toString(), adminCommission: controller.interCityModel.value.adminCommission)}",
                                              createdDate: Timestamp.now(),
                                              paymentType: "Wallet",
                                              transactionId: controller.interCityModel.value.id,
                                              isCredit: false,
                                              type: Constant.typeDriver,
                                              userId: controller.interCityModel.value.driverId,
                                              note: "Admin commission Debited".tr,
                                              adminCommission: controller.interCityModel.value.adminCommission);

                                          await FireStoreUtils.setWalletTransaction(adminCommissionWallet).then((value) async {
                                            if (value == true) {
                                              await FireStoreUtils.updateDriverUserWallet(
                                                  amount:
                                                      "-${Constant.calculateAdminCommission(amount: ((double.parse(controller.interCityModel.value.subTotal ?? '0.0')) - (double.parse(controller.interCityModel.value.discount ?? '0.0'))).toString(), adminCommission: controller.interCityModel.value.adminCommission)}");
                                            }
                                          });
                                        }

                                        await FireStoreUtils.setInterCityBooking(controller.interCityModel.value).then((value) async {
                                          controller.completeInterCityBooking(controller.interCityModel.value);
                                          await FireStoreUtils.updateTotalEarning(
                                              amount: (double.parse(Constant.calculateInterCityFinalAmount(controller.interCityModel.value).toString()) -
                                                      double.parse(Constant.calculateAdminCommission(
                                                              amount: ((double.parse(controller.interCityModel.value.subTotal ?? '0.0')) -
                                                                      (double.parse(controller.interCityModel.value.discount ?? '0.0')))
                                                                  .toString(),
                                                              adminCommission: controller.interCityModel.value.adminCommission)
                                                          .toString()))
                                                  .toString());
                                          controller.getBookingDetails();

                                          // Navigator.pop(context);
                                          Get.to(const HomeView());

                                          // Get.back();
                                          // Get.offAll(const HomeView());
                                        });
                                      } else {
                                        if (controller.interCityModel.value.paymentStatus == true) {
                                          controller.completeInterCityBooking(controller.interCityModel.value);
                                          controller.getBookingDetails();
                                          Navigator.pop(context);
                                          Get.to(const HomeView());
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
                        size: Size(0, 52),
                      ).paddingOnly(right: 8),
                    ),
                  if (controller.interCityModel.value.bookingStatus == BookingStatus.bookingOngoing)
                    RoundShapeButton(
                      title: "Hold Ride".tr,
                      buttonColor: AppThemData.danger500,
                      buttonTextColor: AppThemData.white,
                      onTap: () async {
                        if (controller.interCityModel.value.holdTiming == null) {
                          controller.interCityModel.value.holdTiming = [];
                        }

                        controller.interCityModel.value.holdTiming!.add(HoldTimingModel(startTime: Timestamp.now(), endTime: null));

                        controller.interCityModel.value.bookingStatus = BookingStatus.bookingOnHold;
                        controller.interCityModel.value.updateAt = Timestamp.now();

                        FireStoreUtils.setInterCityBooking(controller.interCityModel.value);
                        ShowToastDialog.showToast("Ride On Hold".tr);

                        UserModel? receiverUserModel = await FireStoreUtils.getUserProfile(controller.interCityModel.value.customerId.toString());
                        Map<String, dynamic> playLoad = <String, dynamic>{"bookingId": controller.interCityModel.value.id};

                        await SendNotification.sendOneNotification(
                            type: "order",
                            token: receiverUserModel!.fcmToken.toString(),
                            title: 'Your Ride is On Hold'.tr,
                            customerId: receiverUserModel.id,
                            senderId: FireStoreUtils.getCurrentUid(),
                            bookingId: controller.interCityModel.value.id.toString(),
                            driverId: controller.interCityModel.value.driverId.toString(),isBooking: false,
                            body: 'Your ride #${controller.interCityModel.value.id.toString().substring(0, 4)} is currently on hold.',
                            payload: playLoad);
                      },
                      size: Size(100, 52),
                    ).paddingOnly(right: 8),
                  if (controller.interCityModel.value.bookingStatus == BookingStatus.bookingOnHold)
                    Expanded(
                        child: RoundShapeButton(
                      title: "Resume Ride".tr,
                      buttonColor: AppThemData.danger500,
                      buttonTextColor: AppThemData.white,
                      onTap: () async {
                        controller.calculateHoldCharge();
                        UserModel? receiverUserModel = await FireStoreUtils.getUserProfile(controller.interCityModel.value.customerId.toString());
                        Map<String, dynamic> playLoad = <String, dynamic>{"bookingId": controller.interCityModel.value.id};

                        await SendNotification.sendOneNotification(
                            type: "order",
                            token: receiverUserModel!.fcmToken.toString(),
                            title: 'Your Ride has Resumed'.tr,
                            customerId: receiverUserModel.id,
                            senderId: FireStoreUtils.getCurrentUid(),
                            bookingId: controller.interCityModel.value.id.toString(),
                            driverId: controller.interCityModel.value.driverId.toString(),isBooking: false,
                            body: 'Your ride #${controller.interCityModel.value.id.toString().substring(0, 4)} has Resumed',
                            payload: playLoad);
                      },
                      size: Size(200, 52),
                    )),
                  if (controller.interCityModel.value.bookingStatus == BookingStatus.bookingOnHold || controller.interCityModel.value.bookingStatus == BookingStatus.bookingOngoing)
                    InkWell(
                        onTap: () {
                          Get.to(() => TrackIntercityRideScreenView(), arguments: {"interCityModel": controller.interCityModel.value});
                        },
                        child: SvgPicture.asset(
                          "assets/icon/ic_live_track.svg",
                          width: 40,
                        )).paddingOnly(left: 8),
                  if (controller.interCityModel.value.paymentStatus == true &&
                      controller.interCityModel.value.bookingStatus == BookingStatus.bookingCompleted &&
                      !controller.reviewList.any((review) => review.bookingId == controller.interCityModel.value.id && review.type == Constant.typeCustomer))
                    RoundShapeButton(
                      title: "Review".tr,
                      buttonColor: AppThemData.primary500,
                      buttonTextColor: AppThemData.black,
                      onTap: () async {
                        Get.to(
                          const AddCustomerReviewView(),
                          arguments: {
                            "isIntercity": true,
                            "bookingModel": controller.interCityModel.value,
                          },
                        );
                        await controller.getReview();
                      },
                      size: Size(Responsive.width(45, context), 52),
                    ),
                ],
              ),
            ),
            body: RefreshIndicator(
              onRefresh: () => controller.getBookingDetails(),
              child: Obx(
                () {
                  if (controller.isLoading.value) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (controller.interCityModel.value.bookingStatus == null) {
                    return Constant.showEmptyView(message: "No booking details available.".tr);
                  }

                  return SingleChildScrollView(
                      child: controller.isLoading.value == true
                          ? Constant.loader()
                          : controller.interCityModel.value.bookingStatus == BookingStatus.bookingPlaced
                              ? controller.interCityModel.value.isPersonalRide == true
                                  ? Constant.isInterCityBid == true
                                      ? InterCityBidView()
                                      : IntercityDetailView()
                                  // : InterCityBidView()
                                  : Constant.isInterCitySharingBid == true
                                      ? InterCityBidView()
                                      : IntercityDetailView()
                              : IntercityDetailView());
                },
              ),
            ),
          );
        });
  }

  Container sosAlertBottomSheet(BuildContext context, themeChange, InterCityBookingDetailsController controller) {
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
                "Use SOS only in case of a real emergency during your trip. This will instantly share your live location and alert emergency services or your trusted contacts.".tr,
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

  Container emergencyContactsBottomSheet(BuildContext context, themeChange, InterCityBookingDetailsController controller) {
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

class BidDialogBox extends StatelessWidget {
  BidDialogBox({
    super.key,
    required this.onPressConfirm,
    required this.onPressCancel,
    required this.themeChange,
  });

  final Function() onPressConfirm;
  final Function() onPressCancel;
  final DarkThemeProvider themeChange;

  final InterCityBookingDetailsController controller = Get.put(InterCityBookingDetailsController());

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30.0),
        child: Material(
          color: Colors.transparent,
          child: Wrap(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: themeChange.isDarkTheme() ? AppThemData.black : AppThemData.white,
                  borderRadius: const BorderRadius.all(Radius.circular(24)),
                ),
                child: Form(
                  key: controller.formKey.value, // ✅ Ensure FormKey is used
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SvgPicture.asset(
                        'assets/icon/ic_Handshake.svg',
                        height: 52,
                        width: 52,
                        color: themeChange.isDarkTheme() ? AppThemData.grey200 : AppThemData.grey800,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "Enter Bid Amount".tr,
                        style: GoogleFonts.inter(
                          color: themeChange.isDarkTheme() ? AppThemData.grey25 : AppThemData.grey950,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: themeChange.isDarkTheme() ? AppThemData.secondary900 : AppThemData.secondary100),
                        child: Text(
                          "Recommended_Price".trParams({"price": Constant.amountToShow(amount: controller.interCityModel.value.recommendedPrice)}),
                          //'Recommended Price For this Ride ${Constant.amountToShow(amount: controller.interCityModel.value.recommendedPrice)}',
                          style: GoogleFonts.inter(
                            textStyle: TextStyle(
                              color: AppThemData.secondary500,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        cursorColor: AppThemData.primary500,
                        controller: controller.enterBidAmountController,
                        keyboardType: TextInputType.numberWithOptions(decimal: true, signed: true),
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.allow(RegExp("[0-9]")),
                        ],
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Enter Bid Amount'.tr;
                          }
                          return null; // ✅ No error if valid
                        },
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: themeChange.isDarkTheme() ? AppThemData.white : AppThemData.grey950,
                          fontWeight: FontWeight.w400,
                        ),
                        decoration: InputDecoration(
                          labelText: "Enter Bid Amount".tr,
                          labelStyle: GoogleFonts.inter(
                            fontSize: 14,
                            color: AppThemData.grey500,
                            fontWeight: FontWeight.w400,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: AppThemData.grey500),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: AppThemData.primary500, width: 2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: RoundShapeButton(
                              title: "Cancel".tr,
                              buttonColor: AppThemData.bookingCancelled,
                              buttonTextColor: AppThemData.white,
                              onTap: () {
                                Navigator.pop(context);
                              },
                              size: const Size(100, 48),
                            ),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: RoundShapeButton(
                              title: "Bid".tr,
                              buttonColor: AppThemData.primary500,
                              buttonTextColor: AppThemData.black,
                              onTap: () {
                                // ✅ Validate the form before proceeding
                                if (controller.formKey.value.currentState!.validate()) {
                                  onPressConfirm(); // Call the confirm function if valid
                                }
                              },
                              size: const Size(100, 48),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
