// ignore_for_file: deprecated_member_use

import 'package:cached_network_image/cached_network_image.dart';
import 'package:customer/app/models/driver_user_model.dart';
import 'package:customer/app/models/emergency_number_model.dart';
import 'package:customer/app/models/tax_model.dart';
import 'package:customer/app/modules/chat_screen/views/chat_screen_view.dart';
import 'package:customer/app/modules/emergency_contacts/views/emergency_contacts_view.dart';
import 'package:customer/app/modules/payment_method/views/widgets/price_row_view.dart';
import 'package:customer/app/modules/reason_for_rental_cancel/views/rental_reason_for_cancel_view.dart';
import 'package:customer/app/modules/rental_ride_details/controllers/rental_ride_details_controller.dart';
import 'package:customer/app/modules/rental_ride_details/views/widgets/rental_payment_dialog_view.dart';
import 'package:customer/app/modules/review_screen/views/review_screen_view.dart';
import 'package:customer/app/routes/app_pages.dart';
import 'package:customer/constant/booking_status.dart';
import 'package:customer/constant/constant.dart';
import 'package:customer/constant_widgets/app_bar_with_border.dart';
import 'package:customer/constant_widgets/round_shape_button.dart';
import 'package:customer/constant_widgets/show_toast_dialog.dart';
import 'package:customer/constant_widgets/title_view.dart';
import 'package:customer/extension/date_time_extension.dart';
import 'package:customer/extension/string_extensions.dart';
import 'package:customer/theme/app_them_data.dart';
import 'package:customer/theme/responsive.dart';
import 'package:customer/utils/dark_theme_provider.dart';
import 'package:customer/utils/fire_store_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class RentalRideDetailsView extends GetView<RentalRideDetailsController> {
  const RentalRideDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetX(
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
              padding: EdgeInsets.fromLTRB(16, 0, 16, MediaQuery.of(context).padding.bottom + 14),
              child: Column(
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
                            controller.rentalModel.value.paymentStatus != true && controller.rentalModel.value.bookingStatus == BookingStatus.bookingOngoing
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
                                          return const RentalPaymentDialogView();
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
                  if (controller.rentalModel.value.bookingStatus != BookingStatus.bookingPlaced &&
                      controller.rentalModel.value.bookingStatus != BookingStatus.bookingCompleted &&
                      controller.rentalModel.value.bookingStatus != BookingStatus.bookingRejected &&
                      controller.rentalModel.value.bookingStatus != BookingStatus.bookingOngoing &&
                      controller.rentalModel.value.bookingStatus != BookingStatus.bookingCancelled)
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
                              Get.to(RentalReasonForCancelView(), arguments: {"rentalModel": controller.rentalModel.value});
                            },
                            size: Size(0, 52),
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
                              Get.toNamed(Routes.TRACK_RENTAL_RIDE_SCREEN, arguments: {
                                "rentalModel": controller.rentalModel.value,
                              });
                            },
                            size: Size(0, 52),
                          ),
                        )
                      ],
                    ),
                  if (controller.rentalModel.value.paymentStatus != true &&
                      controller.rentalModel.value.bookingStatus == BookingStatus.bookingOngoing &&
                      controller.rentalModel.value.completedKM != null &&
                      controller.rentalModel.value.completedKM!.isNotEmpty)
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
                                  if (double.parse(controller.userModel.value.walletAmount!) < Constant.calculateFinalRentalRideAmount(controller.rentalModel.value)) {
                                    ShowToastDialog.showToast("Your wallet amount is insufficient to Payment".tr);
                                  } else {
                                    ShowToastDialog.showLoader("Please wait".tr);
                                    await controller.walletPaymentMethod();
                                    ShowToastDialog.showToast("Payment successful");
                                    ShowToastDialog.closeLoader();
                                  }
                                } else if (controller.selectedPaymentMethod.value == Constant.paymentModel!.paypal!.name) {
                                  await controller.payPalPayment(amount: Constant.calculateFinalRentalRideAmount(controller.rentalModel.value).toString());
                                } else if (controller.selectedPaymentMethod.value == Constant.paymentModel!.strip!.name) {
                                  ShowToastDialog.showLoader("Please wait".tr);
                                  await controller.stripeMakePayment(amount: Constant.calculateFinalRentalRideAmount(controller.rentalModel.value).toString());
                                  ShowToastDialog.closeLoader();
                                } else if (controller.selectedPaymentMethod.value == Constant.paymentModel!.razorpay!.name) {
                                  await controller.razorpayMakePayment(amount: Constant.calculateFinalRentalRideAmount(controller.rentalModel.value).toString());
                                } else if (controller.selectedPaymentMethod.value == Constant.paymentModel!.flutterWave!.name) {
                                  ShowToastDialog.showLoader("Please wait".tr);
                                  await controller.flutterWaveInitiatePayment(
                                      context: context, amount: Constant.calculateFinalRentalRideAmount(controller.rentalModel.value).toString());
                                  ShowToastDialog.closeLoader();
                                } else if (controller.selectedPaymentMethod.value == Constant.paymentModel!.payStack!.name) {
                                  ShowToastDialog.showLoader("Please wait".tr);
                                  await controller.payStackPayment(Constant.calculateFinalRentalRideAmount(controller.rentalModel.value).toString());
                                  ShowToastDialog.closeLoader();
                                } else if (controller.selectedPaymentMethod.value == Constant.paymentModel!.mercadoPago!.name) {
                                  ShowToastDialog.showLoader("Please wait".tr);
                                  controller.mercadoPagoMakePayment(context: context, amount: Constant.calculateFinalRentalRideAmount(controller.rentalModel.value).toString());
                                  ShowToastDialog.closeLoader();
                                } else if (controller.selectedPaymentMethod.value == Constant.paymentModel!.payFast!.name) {
                                  ShowToastDialog.showLoader("Please wait".tr);
                                  controller.payFastPayment(context: context, amount: Constant.calculateFinalRentalRideAmount(controller.rentalModel.value).toString());
                                  ShowToastDialog.closeLoader();
                                } else if (controller.selectedPaymentMethod.value == Constant.paymentModel!.xendit!.name) {
                                  ShowToastDialog.showLoader("Please wait".tr);
                                  controller.xenditPayment(context: context, amount: Constant.calculateFinalRentalRideAmount(controller.rentalModel.value).toString());
                                  ShowToastDialog.closeLoader();
                                } else if (controller.selectedPaymentMethod.value == Constant.paymentModel!.midtrans!.name) {
                                  ShowToastDialog.showLoader("Please wait".tr);
                                  controller.midtransPayment(context: context, amount: Constant.calculateFinalRentalRideAmount(controller.rentalModel.value).toString());
                                  ShowToastDialog.closeLoader();
                                }
                              },
                              size: Size(0, 52),
                            ),
                          ),
                        ),
                      ],
                    ),
                  if (controller.rentalModel.value.paymentStatus == true &&
                      controller.rentalModel.value.bookingStatus == BookingStatus.bookingCompleted &&
                      !controller.reviewList.any((review) => review.bookingId == controller.rentalModel.value.id && review.type == Constant.typeDriver))
                    RoundShapeButton(
                      title: "Review".tr,
                      buttonColor: AppThemData.primary500,
                      buttonTextColor: AppThemData.black,
                      onTap: () {
                        Get.to(() => ReviewScreenView(), arguments: {
                          "isRental": true,
                          "bookingModel": controller.rentalModel.value,
                        });
                        controller.getReview();
                      },
                      size: Size(Responsive.width(45, context), 52),
                    ),
                ],
              ),
            ),
            body: RefreshIndicator(
              onRefresh: () => controller.getBookingDetails(),
              child: SingleChildScrollView(
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
                      const SizedBox(height: 16),
                      Visibility(
                        visible: controller.rentalModel.value.bookingStatus == BookingStatus.bookingAccepted &&
                            controller.rentalModel.value.otp != null &&
                            controller.rentalModel.value.otp!.isNotEmpty,
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                "Your OTP for Ride".tr,
                                style: GoogleFonts.inter(
                                  color: themeChange.isDarkTheme() ? AppThemData.grey25 : AppThemData.grey950,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            Text(
                              controller.rentalModel.value.otp ?? '',
                              textAlign: TextAlign.right,
                              style: GoogleFonts.inter(
                                color: AppThemData.primary500,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            )
                          ],
                        ),
                      ),
                      TitleView(titleText: "Cab Details".tr, padding: const EdgeInsets.fromLTRB(0, 12, 0, 12)),
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
                                  imageUrl:
                                      controller.rentalModel.value.vehicleType == null ? Constant.profileConstant : controller.rentalModel.value.vehicleType!.image.toString(),
                                  fit: BoxFit.fill,
                                  placeholder: (context, url) => Constant.loader(),
                                  errorWidget: (context, url, error) => Image.asset(
                                        Constant.userPlaceHolder,
                                        fit: BoxFit.cover,
                                      )),
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
                                    const SizedBox(height: 2),
                                    controller.rentalModel.value.bookingStatus == BookingStatus.bookingCancelled ||
                                            controller.rentalModel.value.bookingStatus == BookingStatus.bookingRejected
                                        ? SizedBox()
                                        : Text(
                                            (controller.rentalModel.value.paymentStatus ?? false) ? "Payment is Completed".tr : "Payment is Pending".tr,
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
                                    Constant.amountToShow(amount: Constant.calculateFinalRentalRideAmount(controller.rentalModel.value).toStringAsFixed(2)),
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
                      if ((controller.rentalModel.value.bookingStatus ?? '') != BookingStatus.bookingPlaced && (controller.rentalModel.value.driverId ?? '').isNotEmpty) ...{
                        FutureBuilder<DriverUserModel?>(
                            future: FireStoreUtils.getDriverUserProfile(controller.rentalModel.value.driverId ?? ''),
                            builder: (context, snapshot) {
                              if (!snapshot.hasData) {
                                return Container();
                              }
                              DriverUserModel driverUserModel = snapshot.data ?? DriverUserModel();
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  TitleView(titleText: "Driver Details".tr, padding: const EdgeInsets.fromLTRB(0, 0, 0, 12)),
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
                                              image: NetworkImage(driverUserModel.profilePic != null
                                                  ? driverUserModel.profilePic!.isNotEmpty
                                                      ? driverUserModel.profilePic ?? Constant.profileConstant
                                                      : Constant.profileConstant
                                                  : Constant.profileConstant),
                                              fit: BoxFit.fill,
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                driverUserModel.fullName ?? '',
                                                style: GoogleFonts.inter(
                                                  color: themeChange.isDarkTheme() ? AppThemData.grey25 : AppThemData.grey950,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              Row(
                                                children: [
                                                  const Icon(Icons.star_rate_rounded, color: AppThemData.warning500),
                                                  Text(
                                                    Constant.calculateReview(reviewCount: driverUserModel.reviewsCount, reviewSum: driverUserModel.reviewsSum).toString(),
                                                    // driverUserModel.reviewsSum ?? '0.0',
                                                    style: GoogleFonts.inter(
                                                      color: themeChange.isDarkTheme() ? AppThemData.white : AppThemData.black,
                                                      fontSize: 14,
                                                      fontWeight: FontWeight.w400,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        InkWell(
                                            onTap: () {
                                              Get.to(ChatScreenView(
                                                receiverId: driverUserModel.id ?? '',
                                              ));
                                            },
                                            child: SvgPicture.asset("assets/icon/ic_message.svg")),
                                        const SizedBox(width: 12),
                                        InkWell(
                                            onTap: () {
                                              Constant().launchCall("${driverUserModel.countryCode}${driverUserModel.phoneNumber}");
                                            },
                                            child: SvgPicture.asset("assets/icon/ic_phone.svg"))
                                      ],
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 16,
                                  )
                                ],
                              );
                            }),
                      },
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
                      TitleView(titleText: "Rental Package".tr, padding: const EdgeInsets.fromLTRB(0, 12, 0, 12)),
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
                                      "Included".tr,
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
                                      "Extra Per KM Charge".tr,
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
                                      "Extra Per Hours Charge".tr,
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
                            TitleView(titleText: "Extra KM & Hours".tr, padding: const EdgeInsets.fromLTRB(0, 12, 0, 12)),
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
                                            "Extra KM".tr,
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
                                            "Extra Hours".tr,
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
                                  amount: controller.rentalModel.value.subTotal.toString(),
                                ),
                                title: "Sub Total".tr,
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
                                          : "Discount (${controller.rentalModel.value.coupon!.code})".tr,
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
                      if (controller.driverToCustomerReview.value.bookingId != null) ...[
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
                      if (controller.customerToDriverReview.value.bookingId != null) ...[
                        TitleView(titleText: "Driver Review".tr, padding: const EdgeInsets.fromLTRB(0, 20, 0, 0)),
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
                      ]
                    ],
                  ),
                ),
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
                "Use SOS only during a rental ride emergency. This will instantly share your live location and rental trip details with emergency services or trusted contacts.".tr,
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
                  size: Size(Responsive.width(100, context), 52)),
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
