// ignore_for_file: depend_on_referenced_packages
import 'package:customer/app/modules/select_location/controllers/select_location_controller.dart';
import 'package:customer/constant/constant.dart';
import 'package:customer/constant_widgets/round_shape_button.dart';
import 'package:customer/dependency_packages/google_maps_place_picker_mb/src/place_picker.dart';
import 'package:customer/theme/app_them_data.dart';
import 'package:customer/theme/responsive.dart';
import 'package:customer/utils/dark_theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

class ConfirmPickupBottomSheet extends StatelessWidget {
  final ScrollController scrollController;

  const ConfirmPickupBottomSheet({
    super.key,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetBuilder(
        init: SelectLocationController(),
        builder: (controller) {
          return Container(
            height: Responsive.height(100, context),
            decoration: BoxDecoration(
              color: themeChange.isDarkTheme() ? AppThemData.black : AppThemData.white,
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
            ),
            padding: const EdgeInsets.only(top: 10, left: 10, right: 10, bottom: 0),
            child: SingleChildScrollView(
              controller: scrollController,
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
                    "Confirm the pick-up location".tr,
                    style: GoogleFonts.inter(
                      color: themeChange.isDarkTheme() ? AppThemData.white : AppThemData.grey950,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.center, mainAxisAlignment: MainAxisAlignment.start, children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            width: Responsive.width(53, context),
                            child: Text(
                              controller.pickupLocationController.value.text,
                              style: GoogleFonts.inter(
                                color: themeChange.isDarkTheme() ? AppThemData.white : AppThemData.grey950,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          RoundShapeButton(
                              size: const Size(120, 45),
                              title: "Search".tr,
                              buttonColor: AppThemData.grey100,
                              buttonTextColor: AppThemData.black,
                              onTap: () async {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => PlacePicker(
                                      apiKey: Constant.mapAPIKey,
                                      onPlacePicked: (result) async {
                                        Get.back();
                                        await placemarkFromCoordinates(result.geometry!.location.lat, result.geometry!.location.lng).then((valuePlaceMaker) async {
                                          Placemark placeMark = valuePlaceMaker[0];
                                          controller.pickupLocationController.text =
                                              "${placeMark.street},${placeMark.name}, ${placeMark.subLocality} ,${placeMark.locality}, ${placeMark.administrativeArea}, ${placeMark.postalCode}, ${placeMark.country}";
                                          controller.sourceLocation = LatLng(result.geometry!.location.lat, result.geometry!.location.lng);
                                          controller.updateData();
                                        });
                                      },
                                      initialPosition: const LatLng(-33.8567844, 151.213108),
                                      useCurrentLocation: true,
                                      selectInitialPosition: true,
                                      usePinPointingSearch: true,
                                      usePlaceDetailSearch: true,
                                      initialMapType: MapType.terrain,
                                      zoomGesturesEnabled: true,
                                      zoomControlsEnabled: true,
                                      resizeToAvoidBottomInset: false, // only works in page mode, less flickery, remove if wrong offsets
                                    ),
                                  ),
                                );
                              }),
                        ],
                      ),
                      const SizedBox(height: 20),
                      RoundShapeButton(
                          size: Size(Responsive.width(100, context), 45),
                          title: "Confirm pick-up".tr,
                          buttonColor: AppThemData.primary500,
                          buttonTextColor: AppThemData.black,
                          onTap: () async {
                            controller.confirmBooking();
                          }),
                    ]),
                  )
                ],
              ),
            ),
          );
        });
  }
}
