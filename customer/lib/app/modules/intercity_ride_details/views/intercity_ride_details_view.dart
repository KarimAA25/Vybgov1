// ignore_for_file: deprecated_member_use

import 'package:customer/app/models/emergency_number_model.dart';
import 'package:customer/app/modules/emergency_contacts/views/emergency_contacts_view.dart';
import 'package:customer/app/modules/reason_for_intercity_cancel/views/intercity_reason_for_cancel_view.dart';
import 'package:customer/app/modules/review_screen/views/review_screen_view.dart';
import 'package:customer/app/routes/app_pages.dart';
import 'package:customer/constant/booking_status.dart';
import 'package:customer/constant/constant.dart';
import 'package:customer/constant_widgets/app_bar_with_border.dart';
import 'package:customer/constant_widgets/round_shape_button.dart';
import 'package:customer/constant_widgets/show_toast_dialog.dart';
import 'package:customer/theme/app_them_data.dart';
import 'package:customer/theme/responsive.dart';
import 'package:customer/utils/dark_theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../controllers/intercity_ride_details_controller.dart';
import 'widgets/intercity_bid_widget_view.dart';
import 'widgets/intercity_details_widget_view.dart';
import 'widgets/intercity_payment_dialog_view.dart';

class InterCityRideDetailsView extends GetView<InterCityRideDetailsController> {
  const InterCityRideDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetX(
        init: InterCityRideDetailsController(),
        builder: (controller) {
          return Scaffold(
            backgroundColor: themeChange.isDarkTheme() ? AppThemData.black : AppThemData.white,
            appBar: AppBarWithBorder(
              title: "Intercity Ride Details".tr,
              bgColor: themeChange.isDarkTheme() ? AppThemData.black : AppThemData.white,
              actions: [
                (controller.interCityModel.value.bookingStatus == BookingStatus.bookingOngoing && controller.canShowSOS.value)
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
            bottomNavigationBar: controller.interCityModel.value.bookingStatus != BookingStatus.bookingPlaced
                ? Padding(
                    padding: EdgeInsets.fromLTRB(16, 0, 16, MediaQuery.of(context).padding.bottom + 14),
                    child: Obx(
                      () => Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Obx(
                              () => Container(
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
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        (controller.selectedPaymentMethod.value == Constant.paymentModel!.cash!.name)
                                            ? SvgPicture.asset("assets/icon/ic_cash.svg")
                                            : (controller.selectedPaymentMethod.value == Constant.paymentModel!.wallet!.name)
                                                ? SvgPicture.asset(
                                                    "assets/icon/ic_wallet.svg",
                                                    color: themeChange.isDarkTheme() ? AppThemData.white : AppThemData.black,
                                                  )
                                                : (controller.selectedPaymentMethod.value == Constant.paymentModel!.paypal!.name)
                                                    ? Image.asset("assets/images/ig_paypal.png", height: 24, width: 24)
                                                    : (controller.selectedPaymentMethod.value == Constant.paymentModel!.strip!.name)
                                                        ? Image.asset("assets/images/ig_stripe.png", height: 24, width: 24)
                                                        : (controller.selectedPaymentMethod.value == Constant.paymentModel!.razorpay!.name)
                                                            ? Image.asset("assets/images/ig_razorpay.png", height: 24, width: 24)
                                                            : (controller.selectedPaymentMethod.value == Constant.paymentModel!.payStack!.name)
                                                                ? Image.asset("assets/images/ig_paystack.png", height: 24, width: 24)
                                                                : (controller.selectedPaymentMethod.value == Constant.paymentModel!.mercadoPago!.name)
                                                                    ? Image.asset("assets/images/ig_marcadopago.png", height: 24, width: 24)
                                                                    : (controller.selectedPaymentMethod.value == Constant.paymentModel!.payFast!.name)
                                                                        ? Image.asset("assets/images/ig_payfast.png", height: 24, width: 24)
                                                                        : (controller.selectedPaymentMethod.value == Constant.paymentModel!.flutterWave!.name)
                                                                            ? Image.asset("assets/images/ig_flutterwave.png", height: 24, width: 24)
                                                                            : (controller.selectedPaymentMethod.value == Constant.paymentModel!.midtrans!.name)
                                                                                ? Image.asset("assets/images/ig_midtrans.png", height: 24, width: 24)
                                                                                : (controller.selectedPaymentMethod.value == Constant.paymentModel!.xendit!.name)
                                                                                    ? Image.asset("assets/images/ig_xendit.png", height: 24, width: 24)
                                                                                    : const SizedBox(height: 24, width: 24),
                                        const SizedBox(width: 12),
                                        Text(
                                          controller.selectedPaymentMethod.value.toString(),
                                          style: GoogleFonts.inter(
                                            color: themeChange.isDarkTheme() ? AppThemData.grey25 : AppThemData.grey950,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                      ],
                                    ),
                                    controller.interCityModel.value.paymentStatus != true && controller.interCityModel.value.bookingStatus == BookingStatus.bookingOngoing
                                        ? GestureDetector(
                                            onTap: () {
                                              showModalBottomSheet(
                                                context: context,
                                                isScrollControlled: true,
                                                useSafeArea: true,
                                                isDismissible: true,
                                                enableDrag: true,
                                                constraints: BoxConstraints(maxHeight: Responsive.height(90, context), maxWidth: Responsive.width(100, context)),
                                                builder: (BuildContext context) {
                                                  return const InterCityPaymentDialogView();
                                                },
                                              );
                                            },
                                            child: Text(
                                              "Change",
                                              style: GoogleFonts.inter(
                                                  fontSize: 14,
                                                  decoration: TextDecoration.underline,
                                                  fontWeight: FontWeight.w500,
                                                  color: AppThemData.primary500,
                                                  decorationColor: AppThemData.primary500),
                                            ))
                                        : SizedBox()
                                  ],
                                ),
                              ),
                            ),
                          ),
                          if (controller.interCityModel.value.bookingStatus != BookingStatus.bookingCompleted &&
                              controller.interCityModel.value.bookingStatus != BookingStatus.bookingRejected &&
                              controller.interCityModel.value.bookingStatus != BookingStatus.bookingOngoing &&
                              controller.interCityModel.value.bookingStatus != BookingStatus.bookingOnHold &&
                              controller.interCityModel.value.bookingStatus != BookingStatus.bookingCancelled)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: RoundShapeButton(
                                    title: "Cancel Ride".tr,
                                    buttonColor: AppThemData.danger_500p,
                                    buttonTextColor: AppThemData.white,
                                    onTap: () {
                                      Get.to(const InterCityReasonForCancelView(), arguments: {"interCityModel": controller.interCityModel.value});
                                    },
                                    size: Size(0, 52),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: RoundShapeButton(
                                    title: "Track Ride".tr,
                                    buttonColor: AppThemData.primary500,
                                    buttonTextColor: AppThemData.black,
                                    onTap: () {
                                      Get.toNamed(Routes.TRACK_INTERCITY_RIDE_SCREEN, arguments: {
                                        "IntercityModel": controller.interCityModel.value,
                                      });
                                    },
                                    size: Size(0, 52),
                                  ),
                                )
                              ],
                            ),
                          if (controller.interCityModel.value.paymentStatus != true && controller.interCityModel.value.bookingStatus == BookingStatus.bookingOngoing)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Visibility(
                                  visible: controller.selectedPaymentMethod.value != Constant.paymentModel!.cash!.name,
                                  child: Expanded(
                                    child: RoundShapeButton(
                                      title: "Pay Now".tr,
                                      buttonColor: AppThemData.success500,
                                      buttonTextColor: AppThemData.black,
                                      onTap: () async {
                                        if (controller.selectedPaymentMethod.value == Constant.paymentModel!.wallet!.name) {
                                          controller.getProfileData();
                                          if (double.parse(controller.userModel.value.walletAmount!) < Constant.calculateInterCityFinalAmount(controller.interCityModel.value)) {
                                            ShowToastDialog.showToast("Your wallet amount is insufficient to Payment".tr);
                                          } else {
                                            ShowToastDialog.showLoader("Please wait".tr);
                                            await controller.walletPaymentMethod();
                                            ShowToastDialog.showToast("Payment successful".tr);
                                            ShowToastDialog.closeLoader();
                                          }
                                        } else if (controller.selectedPaymentMethod.value == Constant.paymentModel!.paypal!.name) {
                                          await controller.payPalPayment(amount: Constant.calculateInterCityFinalAmount(controller.interCityModel.value).toString());
                                          // await controller
                                          //     .paypalPaymentSheet(Constant.calculateFinalAmount(controller.bookingModel.value).toString());
                                        } else if (controller.selectedPaymentMethod.value == Constant.paymentModel!.strip!.name) {
                                          ShowToastDialog.showLoader("Please wait".tr);
                                          await controller.stripeMakePayment(amount: Constant.calculateInterCityFinalAmount(controller.interCityModel.value).toString());
                                          ShowToastDialog.closeLoader();
                                        } else if (controller.selectedPaymentMethod.value == Constant.paymentModel!.razorpay!.name) {
                                          await controller.razorpayMakePayment(amount: Constant.calculateInterCityFinalAmount(controller.interCityModel.value).toString());
                                        } else if (controller.selectedPaymentMethod.value == Constant.paymentModel!.flutterWave!.name) {
                                          ShowToastDialog.showLoader("Please wait".tr);
                                          await controller.flutterWaveInitiatePayment(
                                              context: context, amount: Constant.calculateInterCityFinalAmount(controller.interCityModel.value).toString());
                                          ShowToastDialog.closeLoader();
                                        } else if (controller.selectedPaymentMethod.value == Constant.paymentModel!.payStack!.name) {
                                          ShowToastDialog.showLoader("Please wait".tr);
                                          await controller.payStackPayment(Constant.calculateInterCityFinalAmount(controller.interCityModel.value).toString());
                                          ShowToastDialog.closeLoader();
                                        } else if (controller.selectedPaymentMethod.value == Constant.paymentModel!.mercadoPago!.name) {
                                          ShowToastDialog.showLoader("Please wait".tr);
                                          controller.mercadoPagoMakePayment(
                                              context: context, amount: Constant.calculateInterCityFinalAmount(controller.interCityModel.value).toString());
                                          ShowToastDialog.closeLoader();
                                        } else if (controller.selectedPaymentMethod.value == Constant.paymentModel!.payFast!.name) {
                                          ShowToastDialog.showLoader("Please wait".tr);
                                          controller.payFastPayment(context: context, amount: Constant.calculateInterCityFinalAmount(controller.interCityModel.value).toString());
                                          ShowToastDialog.closeLoader();
                                        } else if (controller.selectedPaymentMethod.value == Constant.paymentModel!.midtrans!.name) {
                                          ShowToastDialog.showLoader("Please wait".tr);
                                          controller.midtransPayment(context: context, amount: Constant.calculateInterCityFinalAmount(controller.interCityModel.value).toString());
                                          ShowToastDialog.closeLoader();
                                        } else if (controller.selectedPaymentMethod.value == Constant.paymentModel!.xendit!.name) {
                                          ShowToastDialog.showLoader("Please wait".tr);
                                          controller.xenditPayment(context: context, amount: Constant.calculateInterCityFinalAmount(controller.interCityModel.value).toString());
                                          ShowToastDialog.closeLoader();
                                        }
                                      },
                                      size: Size(0, 52),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 12,
                                ),
                                Expanded(
                                  child: RoundShapeButton(
                                    title: "Track Ride".tr,
                                    buttonColor: AppThemData.primary500,
                                    buttonTextColor: AppThemData.black,
                                    onTap: () {
                                      Get.toNamed(Routes.TRACK_INTERCITY_RIDE_SCREEN, arguments: {
                                        "IntercityModel": controller.interCityModel.value,
                                      });
                                    },
                                    size: Size(0, 52),
                                  ),
                                )
                              ],
                            ),
                          if (controller.interCityModel.value.paymentStatus == true && controller.interCityModel.value.bookingStatus == BookingStatus.bookingOngoing)
                            RoundShapeButton(
                              title: "Track Ride".tr,
                              buttonColor: AppThemData.primary500,
                              buttonTextColor: AppThemData.black,
                              onTap: () {
                                Get.toNamed(Routes.TRACK_RIDE_SCREEN, arguments: {
                                  "bookingModel": controller.interCityModel.value,
                                });
                              },
                              size: Size(Responsive.width(45, context), 52),
                            ),
                          if (controller.interCityModel.value.bookingStatus == BookingStatus.bookingOnHold)
                            RoundShapeButton(
                              title: "Track Ride".tr,
                              buttonColor: AppThemData.primary500,
                              buttonTextColor: AppThemData.black,
                              onTap: () {
                                Get.toNamed(Routes.TRACK_RIDE_SCREEN, arguments: {
                                  "bookingModel": controller.interCityModel.value,
                                });
                              },
                              size: Size(Responsive.width(45, context), 52),
                            ),
                          if (controller.interCityModel.value.paymentStatus == true &&
                              controller.interCityModel.value.bookingStatus == BookingStatus.bookingCompleted &&
                              !controller.reviewList.any((review) => review.bookingId == controller.interCityModel.value.id && review.type == Constant.typeDriver))
                            RoundShapeButton(
                              title: "Review".tr,
                              buttonColor: AppThemData.primary500,
                              buttonTextColor: AppThemData.black,
                              onTap: () async {
                                Get.to(
                                  const ReviewScreenView(),
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
                  )
                : SizedBox(),
            body: RefreshIndicator(
              onRefresh: () => controller.getBookingDetails(),
              child: FutureBuilder(
                future: controller.getBookingDetails(),
                builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                  return SingleChildScrollView(
                      child: controller.interCityModel.value.bookingStatus == BookingStatus.bookingPlaced
                          ? controller.interCityModel.value.isPersonalRide == true
                              ? Constant.isInterCityBid == true
                                  ? InterCityBidView()
                                  : InterCityDetailsView()
                              : Constant.isInterCitySharingBid == true
                                  ? InterCityBidView()
                                  : InterCityDetailsView()
                          : InterCityDetailsView());
                },
              ),
            ),
          );
        });
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
                "Use SOS only during an intercity ride emergency. This will immediately share your live location, trip details, and alert emergency services or your trusted contacts."
                    .tr,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: themeChange.isDarkTheme() ? AppThemData.grey300 : AppThemData.grey600,
                ),
              ),
              SizedBox(height: 24),
              RoundShapeButton(
                title: "Call_sos".trParams({"callsos": Constant.sosAlertNumber.toString()}),
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
