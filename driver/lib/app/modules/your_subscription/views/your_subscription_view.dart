// ignore_for_file: deprecated_member_use

import 'package:driver/app/models/subscription_plan_history.dart';
import 'package:driver/app/modules/your_subscription/controllers/your_subscription_controller.dart';
import 'package:driver/constant/constant.dart';
import 'package:driver/theme/app_them_data.dart';
import 'package:driver/utils/dark_theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class YourSubscriptionView extends GetView<YourSubscriptionController> {
  const YourSubscriptionView({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetX(
      init: YourSubscriptionController(),
      builder: (controller) {
        return Scaffold(
          // appBar: AppBarWithBorder(title: "Your Subscription".tr, bgColor: themeChange.isDarkTheme() ? AppThemData.black : AppThemData.white),
          body: controller.isLoading.value
              ? Constant.loader()
              : controller.subscriptionHistory.isEmpty
                  ? Constant.showEmptyView(message: "No Subscription History Found".tr)
                  : ListView.builder(
                      shrinkWrap: true,
                      itemCount: controller.subscriptionHistory.length,
                      padding: EdgeInsets.only(bottom: 16),
                      itemBuilder: (context, index) {
                        SubscriptionHistoryModel subscriptionHistory = controller.subscriptionHistory[index];
                        return Container(
                          margin: EdgeInsets.fromLTRB(16, 16, 16, 0),
                          padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                          decoration: BoxDecoration(
                            color: themeChange.isDarkTheme() ? AppThemData.grey900 : AppThemData.grey50,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                subscriptionHistory.subscriptionPlan!.title.toString(),
                                style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w500, color: themeChange.isDarkTheme() ? AppThemData.grey25 : AppThemData.grey950),
                              ),
                              SizedBox(
                                height: 16,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    Constant.amountShow(amount: subscriptionHistory.subscriptionPlan!.price),
                                    style: GoogleFonts.inter(
                                        textStyle:
                                            TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: themeChange.isDarkTheme() ? AppThemData.grey25 : AppThemData.grey950)),
                                  ),
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: (subscriptionHistory.expiryDate == null || subscriptionHistory.expiryDate!.toDate().isAfter(DateTime.now()))
                                          ? AppThemData.success500.withOpacity(.2)
                                          : AppThemData.danger500.withOpacity(.2),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text((subscriptionHistory.expiryDate == null || subscriptionHistory.expiryDate!.toDate().isAfter(DateTime.now())) ? "Active" : "Expired",
                                        style: GoogleFonts.inter(
                                            textStyle: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: (subscriptionHistory.expiryDate == null || subscriptionHistory.expiryDate!.toDate().isAfter(DateTime.now()))
                                              ? AppThemData.success500
                                              : AppThemData.danger500,
                                        ))),
                                  )
                                ],
                              ),
                              SizedBox(
                                height: 8,
                              ),
                              Text(
                                subscriptionHistory.subscriptionPlan!.description.toString(),
                                style: GoogleFonts.inter(
                                    textStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: themeChange.isDarkTheme() ? AppThemData.grey400 : AppThemData.grey500)),
                              ),
                              SizedBox(
                                height: 16,
                              ),
                              if (subscriptionHistory.subscriptionPlan!.features != null)
                                Column(
                                  children: [featuresRow(context, title: "Rides".tr, value: "${subscriptionHistory.subscriptionPlan!.features!.bookings}")],
                                ),
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                child: Divider(
                                  color: themeChange.isDarkTheme() ? AppThemData.grey400 : AppThemData.grey100,
                                ),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("Payment Method".tr,
                                      style: GoogleFonts.inter(
                                          textStyle:
                                              TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: themeChange.isDarkTheme() ? AppThemData.grey400 : AppThemData.grey500))),
                                  Row(
                                    children: [
                                      (subscriptionHistory.paymentType == Constant.paymentModel!.cash!.name)
                                          ? SvgPicture.asset("assets/icon/ic_cash.svg")
                                          : (subscriptionHistory.paymentType == Constant.paymentModel!.wallet!.name)
                                              ? SvgPicture.asset(
                                                  "assets/icon/ic_wallet.svg",
                                                  color: themeChange.isDarkTheme() ? AppThemData.white : AppThemData.black,
                                                )
                                              : (subscriptionHistory.paymentType == Constant.paymentModel!.paypal!.name)
                                                  ? Image.asset("assets/images/ig_paypal.png", height: 24, width: 24)
                                                  : (subscriptionHistory.paymentType == Constant.paymentModel!.strip!.name)
                                                      ? Image.asset("assets/images/ig_stripe.png", height: 24, width: 24)
                                                      : (subscriptionHistory.paymentType == Constant.paymentModel!.razorpay!.name)
                                                          ? Image.asset("assets/images/ig_razorpay.png", height: 24, width: 24)
                                                          : (subscriptionHistory.paymentType == Constant.paymentModel!.payStack!.name)
                                                              ? Image.asset("assets/images/ig_paystack.png", height: 24, width: 24)
                                                              : (subscriptionHistory.paymentType == Constant.paymentModel!.mercadoPago!.name)
                                                                  ? Image.asset("assets/images/ig_marcadopago.png", height: 24, width: 24)
                                                                  : (subscriptionHistory.paymentType == Constant.paymentModel!.payFast!.name)
                                                                      ? Image.asset("assets/images/ig_payfast.png", height: 24, width: 24)
                                                                      : (subscriptionHistory.paymentType == Constant.paymentModel!.flutterWave!.name)
                                                                          ? Image.asset("assets/images/ig_flutterwave.png", height: 24, width: 24)
                                                                          : (subscriptionHistory.paymentType == Constant.paymentModel!.midtrans!.name)
                                                                              ? Image.asset("assets/images/ig_midtrans.png", height: 24, width: 24)
                                                                              : (subscriptionHistory.paymentType == Constant.paymentModel!.xendit!.name)
                                                                                  ? Image.asset("assets/images/ig_xendit.png", height: 24, width: 24)
                                                                                  : const SizedBox(height: 24, width: 24),
                                      SizedBox(
                                        width: 6,
                                      ),
                                      Text(
                                        subscriptionHistory.paymentType ?? "Free",
                                        style: GoogleFonts.inter(
                                          textStyle: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w400,
                                            color: (subscriptionHistory.paymentType == null || subscriptionHistory.paymentType!.isEmpty)
                                                ? AppThemData.success500
                                                : (themeChange.isDarkTheme() ? AppThemData.grey50 : AppThemData.grey950),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              if (subscriptionHistory.expiryDate != null)
                                Row(
                                  children: [
                                    Text("Expire At : ".tr,
                                        style: GoogleFonts.inter(textStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: AppThemData.danger500))),
                                    Text(Constant.timestampToDate(subscriptionHistory.expiryDate!),
                                        style: GoogleFonts.inter(textStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: AppThemData.danger500))),
                                  ],
                                ).paddingOnly(top: 10),
                            ],
                          ),
                        );
                      }),
        );
      },
    );
  }

  Row featuresRow(BuildContext context, {required String title, required String value}) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return Row(
      children: [
        SvgPicture.asset(
          "assets/icon/ic_check_circle.svg",
          height: 20,
          color: AppThemData.primary500,
        ),
        SizedBox(
          width: 8,
        ),
        Text(
          "${value == "-1" ? "Unlimited" : value} $title",
          style: GoogleFonts.inter(textStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: themeChange.isDarkTheme() ? AppThemData.grey25 : AppThemData.grey950)),
        ),
      ],
    );
  }
}
