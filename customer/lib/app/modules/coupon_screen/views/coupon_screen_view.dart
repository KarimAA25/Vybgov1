import 'package:customer/constant/constant.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:customer/app/models/coupon_model.dart';
import 'package:customer/constant_widgets/app_bar_with_border.dart';
import 'package:customer/constant_widgets/dotted_line_widget.dart';
import 'package:customer/constant_widgets/round_shape_button.dart';
import 'package:customer/extension/date_time_extension.dart';
import 'package:customer/theme/app_them_data.dart';
import 'package:customer/theme/responsive.dart';
import 'package:customer/utils/dark_theme_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../controllers/coupon_screen_controller.dart';

class CouponScreenView extends StatelessWidget {
  const CouponScreenView({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetX(
        init: CouponScreenController(),
        builder: (controller) {
          return Scaffold(
              backgroundColor: themeChange.isDarkTheme() ? AppThemData.black : AppThemData.white,
              appBar: AppBarWithBorder(title: "Coupons".tr, bgColor: themeChange.isDarkTheme() ? AppThemData.black : AppThemData.white),
              body: controller.couponList.isEmpty
                  ? Constant.showEmptyView(message: "No available coupons".tr,)
                  : ListView.builder(
                      itemCount: controller.couponList.length,
                      padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
                      itemBuilder: (context, index) {
                        CouponModel couponModel = controller.couponList[index];
                        return Container(
                          width: Responsive.width(100, context),
                          margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                          decoration: ShapeDecoration(
                            color: const Color(0xFFC4E9E6),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      couponModel.title ?? "No Title".tr,
                                      style: GoogleFonts.inter(
                                        color: AppThemData.grey950,
                                        fontSize: 20,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      "This offer can only be used once and cannot be combined with any other promotions.".tr,
                                      style: GoogleFonts.inter(
                                        color: AppThemData.grey950,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        const Icon(Icons.copy, size: 18),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: SizedBox(
                                            child: Text(
                                              couponModel.code ?? '',
                                              style: GoogleFonts.inter(
                                                color: AppThemData.grey950,
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Stack(
                                alignment: Alignment.center,
                                children: [
                                  const DottedLineWidget(color: AppThemData.grey400),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Container(
                                        width: 16,
                                        height: 16,
                                        transform: Matrix4.translationValues(-5.0, 0.0, 0.0),
                                        decoration: ShapeDecoration(
                                          color: themeChange.isDarkTheme() ? AppThemData.black : AppThemData.white,
                                          shape: const OvalBorder(),
                                        ),
                                      ),
                                      Container(
                                        width: 16,
                                        height: 16,
                                        transform: Matrix4.translationValues(5.0, 0.0, 0.0),
                                        decoration: ShapeDecoration(
                                          color: themeChange.isDarkTheme() ? AppThemData.black : AppThemData.white,
                                          shape: const OvalBorder(),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        "ExpireAt".trParams({"expireAt": couponModel.expireAt!.toDate().dateMonthYear()}),
                                        //'Valid until ${couponModel.expireAt!.toDate().dateMonthYear()}.',
                                        style: GoogleFonts.inter(
                                          color: AppThemData.grey950,
                                          fontSize: 14,
                                          fontStyle: FontStyle.italic,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    RoundShapeButton(
                                        title: "Apply".tr,
                                        buttonColor: AppThemData.primary500,
                                        buttonTextColor: AppThemData.black,
                                        onTap: () {
                                          Get.back(result: couponModel);
                                        },
                                        size: const Size(100, 40))
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ));
        });
  }
}
