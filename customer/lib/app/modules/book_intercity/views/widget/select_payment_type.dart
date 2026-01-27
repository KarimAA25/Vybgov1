// ignore_for_file: deprecated_member_use

import 'package:customer/app/models/coupon_model.dart';
import 'package:customer/app/models/tax_model.dart';
import 'package:customer/app/modules/book_intercity/controllers/book_intercity_controller.dart';
import 'package:customer/app/modules/coupon_screen/views/coupon_screen_view.dart';
import 'package:customer/app/modules/payment_method/views/widgets/price_row_view.dart';
import 'package:customer/constant/constant.dart';
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

class SelectPaymentType extends StatelessWidget {
  const SelectPaymentType({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetBuilder(
        init: BookIntercityController(),
        builder: (controller) {
          return Scaffold(
            appBar: AppBar(
              title: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Select Payment Methods".tr,
                  style: GoogleFonts.inter(
                    color: themeChange.isDarkTheme() ? AppThemData.grey25 : AppThemData.grey950,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    height: 0.09,
                  ),
                ),
              ),
              centerTitle: true,
              backgroundColor: themeChange.isDarkTheme() ? AppThemData.black : AppThemData.white,
            ),
            backgroundColor: themeChange.isDarkTheme() ? Color(0xff1D1D21) : AppThemData.grey50,
            bottomNavigationBar: Padding(
              padding: EdgeInsets.fromLTRB((Responsive.width(100, context) - 200) / 2, 0, (Responsive.width(100, context) - 200) / 2, MediaQuery.of(context).padding.bottom + 14),
              child: RoundShapeButton(
                  size: const Size(200, 45),
                  title: "Ride Placed".tr,
                  buttonColor: AppThemData.primary500,
                  buttonTextColor: AppThemData.black,
                  onTap: () {
                    controller.bookInterCity();
                  }),
            ),
            body: Padding(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
              child: SingleChildScrollView(
                child: Obx(
                  () => Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                                price: Constant.amountToShow(amount: controller.subTotal.value.toString()),
                                title: "Sub Total".tr,
                                priceColor: themeChange.isDarkTheme() ? AppThemData.grey25 : AppThemData.grey950,
                                titleColor: themeChange.isDarkTheme() ? AppThemData.grey25 : AppThemData.grey950,
                              ),
                              const SizedBox(height: 16),
                              // if (controller.nightCharges.value.toString() != "0.0")
                              //   PriceRowView(
                              //     price: Constant.amountToShow(amount: controller.nightCharges.value.toStringAsFixed(2)),
                              //     title: "Night Charges".tr,
                              //     priceColor: themeChange.isDarkTheme() ? AppThemData.grey25 : AppThemData.grey950,
                              //     titleColor: themeChange.isDarkTheme() ? AppThemData.grey25 : AppThemData.grey950,
                              //   ).paddingOnly(bottom: 16),
                              PriceRowView(
                                  price: "- ${Constant.amountToShow(amount: controller.discountAmount.toString())}",
                                  title: controller.selectedCouponModel.value.id == null ? "Discount".tr : "Discount (${controller.selectedCouponModel.value.code})".tr,
                                  priceColor: AppThemData.danger500,
                                  titleColor: themeChange.isDarkTheme() ? AppThemData.grey25 : AppThemData.grey950),
                              const SizedBox(height: 16),
                              ListView.builder(
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: controller.taxList.length,
                                shrinkWrap: true,
                                itemBuilder: (context, index) {
                                  TaxModel taxModel = controller.taxList[index];
                                  return Column(
                                    children: [
                                      PriceRowView(
                                          price: Constant.amountToShow(
                                              amount: Constant.calculateTax(amount: (controller.subTotal.value - controller.discountAmount.value).toString(), taxModel: taxModel)
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
                              const SizedBox(height: 8),
                              PriceRowView(
                                price: Constant.amountToShow(amount: controller.totalAmount.value.toString()),
                                title: "Total Amount".tr,
                                priceColor: AppThemData.primary500,
                                titleColor: themeChange.isDarkTheme() ? AppThemData.grey25 : AppThemData.grey950,
                              ),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 20, 0, 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              'Coupons'.tr,
                              style: GoogleFonts.inter(
                                color: themeChange.isDarkTheme() ? AppThemData.grey25 : AppThemData.grey950,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            InkWell(
                              onTap: () async {
                                await Get.to(const CouponScreenView())!.then((value) {
                                  if (value != null) {
                                    controller.selectedCouponModel.value = value;
                                    controller.couponCode.value = controller.selectedCouponModel.value.code ?? '';
                                    controller.couponCodeController.value.text = controller.selectedCouponModel.value.code ?? '';
                                    // controller.updateCalculation();
                                    controller.applyCouponCalculation();
                                  }
                                });
                              },
                              child: Text(
                                'View All',
                                textAlign: TextAlign.right,
                                style: GoogleFonts.inter(
                                  color: AppThemData.primary500,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                      TextFormField(
                        cursorColor: AppThemData.primary500,
                        controller: controller.couponCodeController.value,
                        enabled: true,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: themeChange.isDarkTheme() ? AppThemData.white : AppThemData.grey950,
                          fontWeight: FontWeight.w400,
                        ),
                        decoration: InputDecoration(
                          isDense: true,
                          suffixIcon: Obx(() {
                            final appliedCode = controller.selectedCouponModel.value.id ?? '';
                            final bool isApplied = appliedCode.trim().isNotEmpty;

                            return InkWell(
                              onTap: () async {
                                if (isApplied) {
                                  controller.selectedCouponModel.value = CouponModel();
                                  controller.discountAmount.value = 0.0;
                                  controller.couponCode.value = '';
                                  controller.couponCodeController.value.text = '';
                                  controller.applyCouponCalculation();
                                  ShowToastDialog.showToast("Coupon removed".tr);
                                } else {
                                  if (controller.couponCodeController.value.text.isNotEmpty) {
                                    await controller.getCoupon();
                                    controller.applyCouponCalculation();
                                  } else {
                                    ShowToastDialog.showToast("Please add or select a coupon code".tr);
                                  }
                                }
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                                child: Text(
                                  isApplied ? "Remove".tr : "Apply".tr,
                                  textAlign: TextAlign.right,
                                  style: GoogleFonts.inter(
                                    color: AppThemData.primary500,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            );
                          }),
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 16,
                            horizontal: 12,
                          ),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: themeChange.isDarkTheme() ? AppThemData.grey800 : AppThemData.grey200,
                              width: 1,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: AppThemData.primary500,
                              width: 1,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: themeChange.isDarkTheme() ? AppThemData.grey800 : AppThemData.grey200,
                              width: 1,
                            ),
                          ),
                          hintText: "Enter Coupon Code".tr,
                          hintStyle: GoogleFonts.inter(
                            fontSize: 14,
                            color: themeChange.isDarkTheme() ? AppThemData.grey300 : AppThemData.grey500,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                      SizedBox(height: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Visibility(
                            visible: Constant.paymentModel!.cash != null && Constant.paymentModel!.cash!.isActive == true,
                            child: Column(
                              children: [
                                Container(
                                  transform: Matrix4.translationValues(0.0, -10.0, 0.0),
                                  child: RadioListTile(
                                    value: Constant.paymentModel!.cash!.name.toString(),
                                    groupValue: controller.selectedPaymentMethod.value,
                                    controlAffinity: ListTileControlAffinity.trailing,
                                    contentPadding: EdgeInsets.zero,
                                    activeColor: AppThemData.primary500,
                                    title: Row(
                                      children: [
                                        SvgPicture.asset(
                                          "assets/icon/ic_cash.svg",
                                          width: 24,
                                        ),
                                        const SizedBox(width: 12),
                                        Text(
                                          Constant.paymentModel!.cash!.name ?? "",
                                          style: GoogleFonts.inter(
                                            color: themeChange.isDarkTheme() ? AppThemData.white : AppThemData.black,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                    onChanged: (value) {
                                      controller.selectedPaymentMethod.value = Constant.paymentModel!.cash!.name.toString();
                                    },
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.only(left: 40, right: 10),
                                  transform: Matrix4.translationValues(0.0, -20.0, 0.0),
                                  child: Divider(
                                    color: themeChange.isDarkTheme() ? AppThemData.grey800 : AppThemData.grey100,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Visibility(
                            visible: Constant.paymentModel!.wallet != null && Constant.paymentModel!.wallet!.isActive == true,
                            child: Column(
                              children: [
                                Container(
                                  transform: Matrix4.translationValues(0.0, -10.0, 0.0),
                                  child: RadioListTile(
                                    value: Constant.paymentModel!.wallet!.name.toString(),
                                    groupValue: controller.selectedPaymentMethod.value,
                                    controlAffinity: ListTileControlAffinity.trailing,
                                    contentPadding: EdgeInsets.zero,
                                    activeColor: AppThemData.primary500,
                                    title: Row(
                                      children: [
                                        SvgPicture.asset(
                                          "assets/icon/ic_wallet.svg",
                                          height: 24,
                                          width: 24,
                                          color: themeChange.isDarkTheme() ? AppThemData.white : AppThemData.black,
                                        ),
                                        const SizedBox(width: 12),
                                        Text(
                                          Constant.paymentModel!.wallet!.name ?? "",
                                          style: GoogleFonts.inter(
                                            color: themeChange.isDarkTheme() ? AppThemData.white : AppThemData.black,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                    onChanged: (value) {
                                      controller.selectedPaymentMethod.value = Constant.paymentModel!.wallet!.name.toString();
                                      controller.interCityModel.value.paymentType = Constant.paymentModel!.wallet!.name;
                                    },
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.only(left: 40, right: 10),
                                  transform: Matrix4.translationValues(0.0, -20.0, 0.0),
                                  child: Divider(
                                    color: themeChange.isDarkTheme() ? AppThemData.grey800 : AppThemData.grey100,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Visibility(
                            visible: Constant.paymentModel!.paypal != null && Constant.paymentModel!.paypal!.isActive == true,
                            child: Column(
                              children: [
                                Container(
                                  transform: Matrix4.translationValues(0.0, -10.0, 0.0),
                                  child: RadioListTile(
                                    value: Constant.paymentModel!.paypal!.name.toString(),
                                    groupValue: controller.selectedPaymentMethod.value,
                                    controlAffinity: ListTileControlAffinity.trailing,
                                    contentPadding: EdgeInsets.zero,
                                    activeColor: AppThemData.primary500,
                                    title: Row(
                                      children: [
                                        Image.asset(
                                          "assets/images/ig_paypal.png",
                                          height: 24,
                                          width: 24,
                                        ),
                                        const SizedBox(width: 12),
                                        Text(
                                          Constant.paymentModel!.paypal!.name ?? "",
                                          style: GoogleFonts.inter(
                                            color: themeChange.isDarkTheme() ? AppThemData.white : AppThemData.black,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                    onChanged: (value) {
                                      controller.selectedPaymentMethod.value = Constant.paymentModel!.paypal!.name.toString();
                                      controller.interCityModel.value.paymentType = Constant.paymentModel!.paypal!.name;
                                    },
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.only(left: 40, right: 10),
                                  transform: Matrix4.translationValues(0.0, -20.0, 0.0),
                                  child: Divider(
                                    color: themeChange.isDarkTheme() ? AppThemData.grey800 : AppThemData.grey100,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Visibility(
                            visible: Constant.paymentModel!.strip != null && Constant.paymentModel!.strip!.isActive == true,
                            child: Column(
                              children: [
                                Container(
                                  transform: Matrix4.translationValues(0.0, -10.0, 0.0),
                                  child: RadioListTile(
                                    value: Constant.paymentModel!.strip!.name.toString(),
                                    groupValue: controller.selectedPaymentMethod.value,
                                    controlAffinity: ListTileControlAffinity.trailing,
                                    contentPadding: EdgeInsets.zero,
                                    activeColor: AppThemData.primary500,
                                    title: Row(
                                      children: [
                                        Image.asset(
                                          "assets/images/ig_stripe.png",
                                          height: 24,
                                          width: 24,
                                        ),
                                        const SizedBox(width: 12),
                                        Text(
                                          Constant.paymentModel!.strip!.name ?? "",
                                          style: GoogleFonts.inter(
                                            color: themeChange.isDarkTheme() ? AppThemData.white : AppThemData.black,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                    onChanged: (value) {
                                      controller.selectedPaymentMethod.value = Constant.paymentModel!.strip!.name.toString();
                                      controller.interCityModel.value.paymentType = Constant.paymentModel!.strip!.name;
                                    },
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.only(left: 40, right: 10),
                                  transform: Matrix4.translationValues(0.0, -20.0, 0.0),
                                  child: Divider(
                                    color: themeChange.isDarkTheme() ? AppThemData.grey800 : AppThemData.grey100,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Visibility(
                            visible: Constant.paymentModel!.razorpay != null && Constant.paymentModel!.razorpay!.isActive == true,
                            child: Column(
                              children: [
                                Container(
                                  transform: Matrix4.translationValues(0.0, -10.0, 0.0),
                                  child: RadioListTile(
                                    value: Constant.paymentModel!.razorpay!.name.toString(),
                                    groupValue: controller.selectedPaymentMethod.value,
                                    controlAffinity: ListTileControlAffinity.trailing,
                                    contentPadding: EdgeInsets.zero,
                                    activeColor: AppThemData.primary500,
                                    title: Row(
                                      children: [
                                        Image.asset(
                                          "assets/images/ig_razorpay.png",
                                          height: 24,
                                          width: 24,
                                        ),
                                        const SizedBox(width: 12),
                                        Text(
                                          Constant.paymentModel!.razorpay!.name ?? "",
                                          style: GoogleFonts.inter(
                                            color: themeChange.isDarkTheme() ? AppThemData.white : AppThemData.black,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                    onChanged: (value) {
                                      controller.selectedPaymentMethod.value = Constant.paymentModel!.razorpay!.name.toString();
                                      controller.interCityModel.value.paymentType = Constant.paymentModel!.razorpay!.name;
                                    },
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.only(left: 40, right: 10),
                                  transform: Matrix4.translationValues(0.0, -20.0, 0.0),
                                  child: Divider(
                                    color: themeChange.isDarkTheme() ? AppThemData.grey800 : AppThemData.grey100,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Visibility(
                            visible: Constant.paymentModel!.payStack != null && Constant.paymentModel!.payStack!.isActive == true,
                            child: Column(
                              children: [
                                Container(
                                  transform: Matrix4.translationValues(0.0, -10.0, 0.0),
                                  child: RadioListTile(
                                    value: Constant.paymentModel!.payStack!.name.toString(),
                                    groupValue: controller.selectedPaymentMethod.value,
                                    controlAffinity: ListTileControlAffinity.trailing,
                                    contentPadding: EdgeInsets.zero,
                                    activeColor: AppThemData.primary500,
                                    title: Row(
                                      children: [
                                        Image.asset(
                                          "assets/images/ig_paystack.png",
                                          height: 24,
                                          width: 24,
                                        ),
                                        const SizedBox(width: 12),
                                        Text(
                                          Constant.paymentModel!.payStack!.name ?? "",
                                          style: GoogleFonts.inter(
                                            color: themeChange.isDarkTheme() ? AppThemData.white : AppThemData.black,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                    onChanged: (value) {
                                      controller.selectedPaymentMethod.value = Constant.paymentModel!.payStack!.name.toString();
                                      controller.interCityModel.value.paymentType = Constant.paymentModel!.payStack!.name;
                                    },
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.only(left: 40, right: 10),
                                  transform: Matrix4.translationValues(0.0, -20.0, 0.0),
                                  child: Divider(
                                    color: themeChange.isDarkTheme() ? AppThemData.grey800 : AppThemData.grey100,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Visibility(
                            visible: Constant.paymentModel!.mercadoPago != null && Constant.paymentModel!.mercadoPago!.isActive == true,
                            child: Column(
                              children: [
                                Container(
                                  transform: Matrix4.translationValues(0.0, -10.0, 0.0),
                                  child: RadioListTile(
                                    value: Constant.paymentModel!.mercadoPago!.name.toString(),
                                    groupValue: controller.selectedPaymentMethod.value,
                                    controlAffinity: ListTileControlAffinity.trailing,
                                    contentPadding: EdgeInsets.zero,
                                    activeColor: AppThemData.primary500,
                                    title: Row(
                                      children: [
                                        Image.asset(
                                          "assets/images/ig_marcadopago.png",
                                          height: 24,
                                          width: 24,
                                        ),
                                        const SizedBox(width: 12),
                                        Text(
                                          Constant.paymentModel!.mercadoPago!.name ?? "",
                                          style: GoogleFonts.inter(
                                            color: themeChange.isDarkTheme() ? AppThemData.white : AppThemData.black,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                    onChanged: (value) {
                                      controller.selectedPaymentMethod.value = Constant.paymentModel!.mercadoPago!.name.toString();
                                      controller.interCityModel.value.paymentType = Constant.paymentModel!.mercadoPago!.name;
                                    },
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.only(left: 40, right: 10),
                                  transform: Matrix4.translationValues(0.0, -20.0, 0.0),
                                  child: Divider(
                                    color: themeChange.isDarkTheme() ? AppThemData.grey800 : AppThemData.grey100,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Visibility(
                            visible: Constant.paymentModel!.payFast != null && Constant.paymentModel!.payFast!.isActive == true,
                            child: Column(
                              children: [
                                Container(
                                  transform: Matrix4.translationValues(0.0, -10.0, 0.0),
                                  child: RadioListTile(
                                    value: Constant.paymentModel!.payFast!.name.toString(),
                                    groupValue: controller.selectedPaymentMethod.value,
                                    controlAffinity: ListTileControlAffinity.trailing,
                                    contentPadding: EdgeInsets.zero,
                                    activeColor: AppThemData.primary500,
                                    title: Row(
                                      children: [
                                        Image.asset(
                                          "assets/images/ig_payfast.png",
                                          height: 24,
                                          width: 24,
                                        ),
                                        const SizedBox(width: 12),
                                        Text(
                                          Constant.paymentModel!.payFast!.name ?? "",
                                          style: GoogleFonts.inter(
                                            color: themeChange.isDarkTheme() ? AppThemData.white : AppThemData.black,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                    onChanged: (value) {
                                      controller.selectedPaymentMethod.value = Constant.paymentModel!.payFast!.name.toString();
                                      controller.interCityModel.value.paymentType = Constant.paymentModel!.payFast!.name;
                                    },
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.only(left: 40, right: 10),
                                  transform: Matrix4.translationValues(0.0, -20.0, 0.0),
                                  child: Divider(
                                    color: themeChange.isDarkTheme() ? AppThemData.grey800 : AppThemData.grey100,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Visibility(
                            visible: Constant.paymentModel!.flutterWave != null && Constant.paymentModel!.flutterWave!.isActive == true,
                            child: Column(
                              children: [
                                Container(
                                  transform: Matrix4.translationValues(0.0, -10.0, 0.0),
                                  child: RadioListTile(
                                    value: Constant.paymentModel!.flutterWave!.name.toString(),
                                    groupValue: controller.selectedPaymentMethod.value,
                                    controlAffinity: ListTileControlAffinity.trailing,
                                    contentPadding: EdgeInsets.zero,
                                    activeColor: AppThemData.primary500,
                                    title: Row(
                                      children: [
                                        Image.asset(
                                          "assets/images/ig_flutterwave.png",
                                          height: 24,
                                          width: 24,
                                        ),
                                        const SizedBox(width: 12),
                                        Text(
                                          Constant.paymentModel!.flutterWave!.name ?? "",
                                          style: GoogleFonts.inter(
                                            color: themeChange.isDarkTheme() ? AppThemData.white : AppThemData.black,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                    onChanged: (value) {
                                      controller.selectedPaymentMethod.value = Constant.paymentModel!.flutterWave!.name.toString();
                                      controller.interCityModel.value.paymentType = Constant.paymentModel!.flutterWave!.name;
                                    },
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.only(left: 40, right: 10),
                                  transform: Matrix4.translationValues(0.0, -20.0, 0.0),
                                  child: Divider(
                                    color: themeChange.isDarkTheme() ? AppThemData.grey800 : AppThemData.grey100,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Visibility(
                            visible: Constant.paymentModel!.midtrans != null && Constant.paymentModel!.midtrans!.isActive == true,
                            child: Column(
                              children: [
                                Container(
                                  transform: Matrix4.translationValues(0.0, -10.0, 0.0),
                                  child: RadioListTile(
                                    value: Constant.paymentModel!.midtrans!.name.toString(),
                                    groupValue: controller.selectedPaymentMethod.value,
                                    controlAffinity: ListTileControlAffinity.trailing,
                                    contentPadding: EdgeInsets.zero,
                                    activeColor: AppThemData.primary500,
                                    onChanged: (value) {
                                      controller.selectedPaymentMethod.value = Constant.paymentModel!.midtrans!.name.toString();
                                      controller.interCityModel.value.paymentType = Constant.paymentModel!.midtrans!.name;
                                    },
                                    title: Row(
                                      children: [
                                        Image.asset(
                                          "assets/images/ig_midtrans.png",
                                          height: 26,
                                          width: 26,
                                        ),
                                        const SizedBox(width: 12),
                                        Text(
                                          Constant.paymentModel!.midtrans!.name ?? "",
                                          style: GoogleFonts.inter(
                                            color: themeChange.isDarkTheme() ? AppThemData.white : AppThemData.black,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.only(left: 40, right: 10),
                                  transform: Matrix4.translationValues(0.0, -20.0, 0.0),
                                  child: const Divider(),
                                ),
                              ],
                            ),
                          ),
                          Visibility(
                            visible: Constant.paymentModel!.xendit != null && Constant.paymentModel!.xendit!.isActive == true,
                            child: Column(
                              children: [
                                Container(
                                  transform: Matrix4.translationValues(0.0, -10.0, 0.0),
                                  child: RadioListTile(
                                    value: Constant.paymentModel!.xendit!.name.toString(),
                                    groupValue: controller.selectedPaymentMethod.value,
                                    controlAffinity: ListTileControlAffinity.trailing,
                                    contentPadding: EdgeInsets.zero,
                                    activeColor: AppThemData.primary500,
                                    onChanged: (value) {
                                      controller.selectedPaymentMethod.value = Constant.paymentModel!.xendit!.name.toString();
                                      controller.interCityModel.value.paymentType = Constant.paymentModel!.xendit!.name;
                                    },
                                    title: Row(
                                      children: [
                                        Image.asset(
                                          "assets/images/ig_xendit.png",
                                          height: 24,
                                          width: 24,
                                        ),
                                        const SizedBox(width: 12),
                                        Text(
                                          Constant.paymentModel!.xendit!.name ?? "",
                                          style: GoogleFonts.inter(
                                            color: themeChange.isDarkTheme() ? AppThemData.white : AppThemData.black,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.only(left: 40, right: 10),
                                  transform: Matrix4.translationValues(0.0, -20.0, 0.0),
                                  child: const Divider(),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        });
  }
}
