import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:driver/constant_widgets/round_shape_button.dart';
import 'package:driver/theme/app_them_data.dart';
import 'package:driver/utils/dark_theme_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../controllers/permission_controller.dart';

class PermissionView extends StatelessWidget {
  const PermissionView({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetBuilder(
        init: PermissionController(),
        builder: (controller) {
          return Scaffold(
            body: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Center(
                  child: Image.asset(
                    "assets/icon/gif_location.gif",
                    height: 120.0,
                    width: 120.0,
                  ),
                ),
                Text(
                  "Location Access for Drivers",
                  //'${'Welcome to'.tr} ${Constant.appName}',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    color: themeChange.isDarkTheme()
                        ? AppThemData.grey25
                        : AppThemData.grey950,
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(40, 8, 40, 40),
                  child: Text(
                    "MyTaxi collects location data to enable essential driver features, including:\n\n"
                    "• Receiving nearby ride requests\n"
                    "• Live trip tracking for customers and admin\n"
                    "• Navigation and accurate pickup & drop-off locations\n"
                    "• Driver availability while on duty\n\n"
                    "Location data is collected even when the app is closed or not in use to ensure uninterrupted ride tracking and service availability.\n\n"
                    "You can go offline anytime to stop location tracking.",
                    textAlign: TextAlign.left,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      height: 1.5,
                      color: themeChange.isDarkTheme()
                          ? AppThemData.grey25
                          : AppThemData.grey950,
                    ),
                  ),
                ),
                RoundShapeButton(
                  size: const Size(208, 52),
                  title: "I Agree & Continue".tr,
                  buttonColor: AppThemData.primary500,
                  buttonTextColor: AppThemData.black,
                  onTap: () {
                    controller.forceRequestPermissions();
                  },
                ),
              ],
            ),
          );
        });
  }
}
