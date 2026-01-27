import 'package:driver/app/modules/search_intercity_ride/controllers/search_ride_controller.dart';
import 'package:driver/app/modules/search_intercity_ride/search_intercity_view/widget/search_parcel_ride_widget.dart';
import 'package:driver/constant/constant.dart';
import 'package:driver/theme/app_them_data.dart';
import 'package:driver/utils/dark_theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'widget/search_intercity_ride_widget.dart';

class SearchRideView extends StatelessWidget {
  final String selectedRideType;

  const SearchRideView({super.key, required this.selectedRideType});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);

    return GetBuilder<SearchRideController>(
      init: SearchRideController(),
      builder: (controller) {
        Widget child;

        if (selectedRideType == 'intercity') {
          child = const SearchInterCityRideWidget();
        } else {
          child = const SearchParcelRideWidget();
        }

        return Scaffold(
          backgroundColor: themeChange.isDarkTheme() ? AppThemData.black : AppThemData.grey50,
          appBar: AppBar(
            shape: Border(
              bottom: BorderSide(
                color: themeChange.isDarkTheme() ? AppThemData.grey800 : AppThemData.grey100,
                width: 1,
              ),
            ),
            title: Text(
              'Search Ride'.tr,
              style: GoogleFonts.inter(
                color: themeChange.isDarkTheme() ? AppThemData.white : AppThemData.black,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          body: Obx(() => controller.isLoading.value ? Constant.loader() : child),
        );
      },
    );
  }
}
