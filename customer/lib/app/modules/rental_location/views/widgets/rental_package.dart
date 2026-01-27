// ignore_for_file: depend_on_referenced_packages, use_build_context_synchronously, deprecated_member_use

import 'package:customer/app/modules/home/controllers/home_controller.dart';
import 'package:customer/app/modules/rental_location/controllers/rental_select_location_controller.dart';
import 'package:customer/app/modules/rental_location/views/rental_payment_method_view.dart';
import 'package:customer/constant/constant.dart';
import 'package:customer/constant_widgets/round_shape_button.dart';
import 'package:customer/constant_widgets/show_toast_dialog.dart';
import 'package:customer/theme/app_them_data.dart';
import 'package:customer/theme/responsive.dart';
import 'package:customer/utils/dark_theme_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class RentalPackageBottomSheet extends StatelessWidget {
  final ScrollController scrollController;

  const RentalPackageBottomSheet({super.key, required this.scrollController});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    Get.put(HomeController());
    return GetX<RentalSelectLocationController>(
      init: RentalSelectLocationController(),
      builder: (controller) {
        return Container(
          decoration: BoxDecoration(
            color: themeChange.isDarkTheme() ? AppThemData.black : AppThemData.white,
            borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                          width: 44,
                          height: 5,
                          margin: const EdgeInsets.only(bottom: 10),
                          decoration: ShapeDecoration(
                            color: themeChange.isDarkTheme() ? AppThemData.grey700 : AppThemData.grey200,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(100),
                            ),
                          ),
                        ),
                        Text(
                          "Rental Packages".tr,
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: themeChange.isDarkTheme() ? AppThemData.white : AppThemData.grey950),
                        ),
                        const SizedBox(height: 12),
                        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                          Text(
                            "Allow booking only for women".tr,
                            style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: themeChange.isDarkTheme() ? AppThemData.white : AppThemData.black),
                          ),
                          Transform.scale(
                            scale: .9,
                            child: CupertinoSwitch(
                              value: controller.isForFemale.value,
                              activeTrackColor: AppThemData.primary500,
                              inactiveTrackColor: themeChange.isDarkTheme() ? AppThemData.grey700 : AppThemData.grey100,
                              onChanged: (value) {
                                controller.isForFemale.value = value;
                              },
                            ),
                          )
                        ]),
                        SizedBox(
                          height: 4,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Pickup Date".tr,
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: themeChange.isDarkTheme() ? AppThemData.white : AppThemData.grey950),
                            ),
                            SizedBox(
                              width: 12,
                            ),
                            Expanded(
                              child: TextFormField(
                                cursorColor: AppThemData.primary500,
                                controller: controller.pickupDateController.value,
                                enabled: true,
                                readOnly: true,
                                onTap: () {
                                  controller.selectPickupDateTime(context, themeChange);
                                },
                                style: GoogleFonts.inter(fontSize: 14, color: themeChange.isDarkTheme() ? AppThemData.white : AppThemData.grey950, fontWeight: FontWeight.w400),
                                decoration: InputDecoration(
                                  isDense: true,
                                  border: OutlineInputBorder(borderSide: BorderSide(color: themeChange.isDarkTheme() ? AppThemData.grey800 : AppThemData.grey200, width: 1)),
                                  focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: AppThemData.primary500, width: 1)),
                                  enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: themeChange.isDarkTheme() ? AppThemData.grey800 : AppThemData.grey200, width: 1)),
                                  errorBorder: OutlineInputBorder(borderSide: BorderSide(color: themeChange.isDarkTheme() ? AppThemData.grey800 : AppThemData.grey200, width: 1)),
                                  disabledBorder:
                                      OutlineInputBorder(borderSide: BorderSide(color: themeChange.isDarkTheme() ? AppThemData.grey800 : AppThemData.grey200, width: 1)),
                                  hintText: "Select Pickup Date & Time".tr,
                                  hintStyle:
                                      GoogleFonts.inter(fontSize: 14, color: themeChange.isDarkTheme() ? AppThemData.grey300 : AppThemData.grey500, fontWeight: FontWeight.w400),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Flexible(
                          child: controller.isLoading.value
                              ? const Center(child: CircularProgressIndicator())
                              : Align(
                                  alignment: Alignment.topCenter,
                                  child: SingleChildScrollView(
                                    child: ListView.builder(
                                      padding: EdgeInsets.zero,
                                      controller: scrollController,
                                      shrinkWrap: true,
                                      physics: const BouncingScrollPhysics(),
                                      itemCount: controller.rentalPackages.length,
                                      itemBuilder: (context, index) {
                                        final rentalPackageModel = controller.rentalPackages[index];
                                        return Obx(
                                          () {
                                            final isSelected = controller.selectedRentalPackage.value.id == rentalPackageModel.id;
                                            return GestureDetector(
                                                onTap: () {
                                                  if (!isSelected) {
                                                    controller.selectedRentalPackage.value = rentalPackageModel;
                                                    controller.calculateTotalAmount();
                                                  }
                                                },
                                                child: Container(
                                                  margin: const EdgeInsets.only(bottom: 12),
                                                  padding: const EdgeInsets.all(14),
                                                  decoration: BoxDecoration(
                                                    border: Border.all(
                                                      color: isSelected
                                                          ? AppThemData.primary500
                                                          : themeChange.isDarkTheme()
                                                              ? AppThemData.grey800
                                                              : AppThemData.grey100,
                                                      width: 1,
                                                    ),
                                                    borderRadius: BorderRadius.circular(12),
                                                    color: themeChange.isDarkTheme() ? Colors.grey[850] : Colors.white,
                                                  ),
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      // Title
                                                      Text(
                                                        rentalPackageModel.title.toString(),
                                                        style: TextStyle(
                                                          fontSize: 16,
                                                          fontWeight: FontWeight.bold,
                                                          color: themeChange.isDarkTheme() ? Colors.white : Colors.black,
                                                        ),
                                                      ),
                                                      const SizedBox(height: 12),

                                                      // Base Fare
                                                      Row(
                                                        children: [
                                                          Icon(Icons.receipt_long, size: 18, color: Colors.green),
                                                          const SizedBox(width: 6),
                                                          Text(
                                                            "BaseFare".trParams({"baseFare": Constant.amountToShow(amount: rentalPackageModel.baseFare)}),
                                                            //"Base Fare: ${Constant.amountToShow(amount: rentalPackageModel.baseFare)}",
                                                            style: GoogleFonts.inter(
                                                              fontSize: 14,
                                                              fontWeight: FontWeight.w500,
                                                              color: themeChange.isDarkTheme() ? AppThemData.grey25 : AppThemData.grey950,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      const SizedBox(height: 8),
                                                      Row(
                                                        children: [
                                                          Icon(Icons.directions_car, size: 18, color: Colors.blueAccent),
                                                          const SizedBox(width: 6),
                                                          Text(
                                                            "IncludedHours".trParams({
                                                              "includedHours": rentalPackageModel.includedHours.toString(),
                                                              "includedDistance": rentalPackageModel.includedDistance.toString()
                                                            }),
                                                            // "Included: ${rentalPackageModel.includedHours} Hours / ${rentalPackageModel.includedDistance} km",
                                                            style: GoogleFonts.inter(
                                                              fontSize: 14,
                                                              fontWeight: FontWeight.w400,
                                                              color: themeChange.isDarkTheme() ? AppThemData.grey25 : AppThemData.grey950,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      const SizedBox(height: 8),
                                                      Row(
                                                        children: [
                                                          Icon(Icons.add_circle_outline, size: 18, color: Colors.redAccent),
                                                          const SizedBox(width: 6),
                                                          Text(
                                                            "ExtraKmFare".trParams({
                                                              "extraKmFare": Constant.amountToShow(amount: rentalPackageModel.extraKmFare),
                                                              "extraHourFare": Constant.amountToShow(amount: rentalPackageModel.extraHourFare)
                                                            }),
                                                            // "Extra Fare: ${Constant.amountToShow(amount: rentalPackageModel.extraKmFare)}/km, "
                                                            // "${Constant.amountToShow(amount: rentalPackageModel.extraHourFare)}/Hour",
                                                            style: GoogleFonts.inter(
                                                              fontSize: 14,
                                                              fontWeight: FontWeight.w400,
                                                              color: themeChange.isDarkTheme() ? AppThemData.grey25 : AppThemData.grey950,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ));
                                          },
                                        );
                                      },
                                    ),
                                  ),
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Obx(
                () => Padding(
                  padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom + 14, top: 8),
                  child: Container(
                    width: Responsive.width(100, context),
                    decoration: BoxDecoration(
                        color: themeChange.isDarkTheme() ? AppThemData.black : AppThemData.white,
                        border: Border(
                          top: BorderSide(width: 1.0, color: themeChange.isDarkTheme() ? AppThemData.grey800 : AppThemData.grey100),
                        )),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
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
                                    'Total'.tr,
                                    style: GoogleFonts.inter(
                                      color: themeChange.isDarkTheme() ? AppThemData.grey25 : AppThemData.grey950,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    Constant.amountToShow(amount: controller.totalAmount.toString()),
                                    style: GoogleFonts.inter(
                                      color: themeChange.isDarkTheme() ? AppThemData.grey25 : AppThemData.grey950,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                              InkWell(
                                onTap: () {
                                  Get.to(RentalPaymentMethodView());
                                },
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Container(
                                      width: 32,
                                      height: 32,
                                      padding: const EdgeInsets.all(5),
                                      decoration: ShapeDecoration(
                                        color: themeChange.isDarkTheme() ? AppThemData.grey900 : AppThemData.grey50,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(100),
                                        ),
                                      ),
                                      child: (controller.selectedPaymentMethod.value == Constant.paymentModel!.cash!.name)
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
                                    ),
                                    const SizedBox(width: 8),
                                    SizedBox(
                                      width: 80,
                                      child: Text(
                                        controller.selectedPaymentMethod.value.toString(),
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.inter(
                                          color: themeChange.isDarkTheme() ? AppThemData.grey25 : AppThemData.grey950,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 2),
                                    const Icon(Icons.keyboard_arrow_right_rounded)
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 3),
                        RoundShapeButton(
                            size: const Size(151, 45),
                            title: "Book Now".tr,
                            buttonColor: AppThemData.primary500,
                            buttonTextColor: AppThemData.black,
                            onTap: () async {
                              if (controller.pickupDateController.value.text.isNotEmpty) {
                                controller.confirmRentalBooking();
                              } else {
                                ShowToastDialog.showToast("Please Select the Pickup Date & Time.".tr);
                              }
                            }),
                      ],
                    ),
                  ),
                ),
              )
            ],
          ),
        );
      },
    );
  }
}
