// ignore_for_file: use_build_context_synchronously

import 'dart:developer';

import 'package:customer/app/modules/rental_location/controllers/rental_select_location_controller.dart';
import 'package:customer/constant_widgets/osm_place_picker/osm_location_picker_screen.dart';
import 'package:customer/constant_widgets/osm_place_picker/osm_selected_location_model.dart';
import 'package:customer/constant_widgets/place_picker/location_picker_screen.dart';
import 'package:customer/constant_widgets/place_picker/selected_location_model.dart';
import 'package:customer/constant_widgets/round_shape_button.dart';
import 'package:customer/constant_widgets/show_toast_dialog.dart';
import 'package:customer/services/recent_location_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:customer/constant/constant.dart';
import 'package:customer/theme/app_them_data.dart';
import 'package:customer/theme/responsive.dart';
import 'package:customer/utils/dark_theme_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:timelines_plus/timelines_plus.dart';

class RentalSelectLocationBottomSheet extends StatelessWidget {
  final ScrollController scrollController;

  const RentalSelectLocationBottomSheet({
    super.key,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetBuilder(
        init: RentalSelectLocationController(),
        builder: (controller) {
          log("===> ${Constant.mapAPIKey}");
          return Container(
            height: Responsive.height(100, context),
            decoration: BoxDecoration(
              color: themeChange.isDarkTheme() ? AppThemData.black : AppThemData.white,
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
            ),
            padding: const EdgeInsets.only(top: 10, left: 20, right: 20, bottom: 0),
            child: Column(
              children: [
                Expanded(
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
                          "Select Location".tr,
                          style: GoogleFonts.inter(
                            color: themeChange.isDarkTheme() ? AppThemData.white : AppThemData.grey950,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Timeline.tileBuilder(
                          shrinkWrap: true,
                          // physics: const NeverScrollableScrollPhysics(),
                          theme: TimelineThemeData(
                            nodePosition: 0,
                          ),
                          padding: const EdgeInsets.only(top: 10),
                          builder: TimelineTileBuilder.connected(
                            contentsAlign: ContentsAlign.basic,
                            indicatorBuilder: (context, index) {
                              return SvgPicture.asset("assets/icon/ic_pick_up.svg");
                            },
                            connectorBuilder: (context, index, connectorType) {
                              return DashedLineConnector(
                                color: themeChange.isDarkTheme() ? AppThemData.grey600 : AppThemData.grey300,
                              );
                            },
                            contentsBuilder: (context, index) => Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: TextFormField(
                                focusNode: controller.pickUpFocusNode,
                                cursorColor: AppThemData.primary500,
                                readOnly: true,
                                controller: controller.pickupLocationController,
                                onTap: () {
                                  FocusNode tappedFocusNode = controller.pickUpFocusNode;
                                  tappedFocusNode.requestFocus();
                                  Constant.selectedMap == "Google Map"
                                      ? Get.to(LocationPickerScreen())!.then(
                                          (value) async {
                                            if (value != null) {
                                              SelectedLocationModel selectedLocationModel = value;

                                              String formattedAddress =
                                                  "${selectedLocationModel.address?.street ?? ''}, ${selectedLocationModel.address?.subLocality}, ${selectedLocationModel.address?.locality ?? ''}, ${selectedLocationModel.address?.administrativeArea}, ${selectedLocationModel.address?.postalCode} ${selectedLocationModel.address?.country ?? ''}";

                                              controller.googleSourceLocation = selectedLocationModel.latLng!;
                                              controller.pickupLocationController.text = formattedAddress;

                                              // controller.updateData();
                                              FocusScope.of(context).unfocus();
                                              log("++++++++++++++++> ::: $formattedAddress");
                                              RecentSearchLocation.addLocationInHistory(selectedLocationModel);
                                              controller.popupIndex.value = 1;
                                              // Get.to(RentalSelectVehicleTypeBottomSheet(scrollController: ScrollController()));
                                            } else {
                                              Future.delayed(Duration(milliseconds: 100), () {
                                                tappedFocusNode.requestFocus();
                                              });
                                            }
                                          },
                                        )
                                      : Get.to(OSMLocationPickerScreen())!.then(
                                          (value) async {
                                            if (value != null) {
                                              OsmSelectedLocationModel osmSelectedLocationModel = value;

                                              String formattedAddress =
                                                  "${osmSelectedLocationModel.address?.street ?? ''}, ${osmSelectedLocationModel.address?.subLocality}, ${osmSelectedLocationModel.address?.locality ?? ''}, ${osmSelectedLocationModel.address?.administrativeArea}, ${osmSelectedLocationModel.address?.postalCode} ${osmSelectedLocationModel.address?.country ?? ''}";

                                              controller.osmSourceLocation = osmSelectedLocationModel.latLng!;
                                              controller.pickupLocationController.text = formattedAddress;

                                              // controller.updateData();
                                              FocusScope.of(context).unfocus();

                                              RecentSearchLocation.addOSMLocationInHistory(osmSelectedLocationModel);
                                              controller.popupIndex.value = 1;
                                              // Get.to(RentalSelectVehicleTypeBottomSheet(scrollController: ScrollController()));
                                            } else {
                                              Future.delayed(Duration(milliseconds: 100), () {
                                                tappedFocusNode.requestFocus();
                                              });
                                            }
                                          },
                                        );
                                },
                                decoration: InputDecoration(
                                  hintText: "Pick up Location".tr,
                                  filled: true,
                                  fillColor: themeChange.isDarkTheme() ? AppThemData.grey950 : AppThemData.grey50,
                                  focusColor: AppThemData.primary500,
                                  suffixIcon: (controller.pickupLocationController.text.isNotEmpty)
                                      ? InkWell(
                                          onTap: () {
                                            controller.pickupLocationController.clear();
                                            controller.polyLines.clear();
                                            controller.getRecentSearches();
                                          },
                                          child: Icon(Icons.close))
                                      : null,
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(100),
                                      borderSide: BorderSide(color: themeChange.isDarkTheme() ? AppThemData.grey950 : AppThemData.grey25)),
                                  disabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(100),
                                      borderSide: BorderSide(color: themeChange.isDarkTheme() ? AppThemData.grey950 : AppThemData.grey25)),
                                  enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(100),
                                      borderSide: BorderSide(color: themeChange.isDarkTheme() ? AppThemData.grey950 : AppThemData.grey25)),
                                  errorBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(100),
                                      borderSide: BorderSide(color: themeChange.isDarkTheme() ? AppThemData.grey950 : AppThemData.grey25)),
                                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(100), borderSide: BorderSide(color: AppThemData.primary500)),
                                  focusedErrorBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(100),
                                      borderSide: BorderSide(color: themeChange.isDarkTheme() ? AppThemData.grey950 : AppThemData.grey25)),
                                  hintStyle: GoogleFonts.inter(
                                    color: themeChange.isDarkTheme() ? AppThemData.grey25 : AppThemData.grey950,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                style: GoogleFonts.inter(
                                  color: themeChange.isDarkTheme() ? AppThemData.grey25 : AppThemData.grey950,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            itemCount: 1,
                          ),
                        ),
                        if (Constant.selectedMap == "Google Map" ? controller.googleRecentSearches.isNotEmpty : controller.osmRecentSearches.isNotEmpty)
                          Flexible(
                            child: SingleChildScrollView(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 12),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "Recent Search".tr,
                                        style: GoogleFonts.inter(
                                          color: themeChange.isDarkTheme() ? AppThemData.grey25 : AppThemData.grey950,
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      InkWell(
                                        onTap: () {
                                          if (Constant.selectedMap == "Google Map") {
                                            RecentSearchLocation.clearLocationHistoryList().then((_) {
                                              controller.googleRecentSearches.clear();
                                              controller.update();
                                            });
                                          } else {
                                            RecentSearchLocation.clearOSMLocationHistoryList().then((_) {
                                              controller.osmRecentSearches.clear();
                                              controller.update();
                                            });
                                          }
                                        },
                                        child: Text(
                                          "Clear".tr,
                                          style: GoogleFonts.inter(
                                            color: AppThemData.danger500,
                                            fontSize: 15,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  if (Constant.selectedMap == "Google Map")
                                    ListView.builder(
                                      shrinkWrap: true,
                                      padding: EdgeInsets.zero,
                                      physics: const NeverScrollableScrollPhysics(),
                                      itemCount: controller.googleRecentSearches.length,
                                      itemBuilder: (context, index) {
                                        final recentSearch = controller.googleRecentSearches[index];

                                        return _recentTile(
                                          context,
                                          themeChange,
                                          recentSearch.getFullAddress(),
                                          onTap: () {
                                            controller.pickupLocationController.text = recentSearch.getFullAddress();
                                            controller.googleSourceLocation = recentSearch.latLng;
                                            // controller.updateData();
                                            FocusScope.of(context).unfocus();
                                            // controller.popupIndex.value = 1;
                                          },
                                        );
                                      },
                                    ),
                                  if (Constant.selectedMap != "Google Map")
                                    ListView.builder(
                                      shrinkWrap: true,
                                      padding: EdgeInsets.zero,
                                      physics: const NeverScrollableScrollPhysics(),
                                      itemCount: controller.osmRecentSearches.length,
                                      itemBuilder: (context, index) {
                                        final recentSearch = controller.osmRecentSearches[index];
                                        return _recentTile(
                                          context,
                                          themeChange,
                                          recentSearch.getFullAddress(),
                                          onTap: () {
                                            controller.pickupLocationController.text = recentSearch.getFullAddress();
                                            controller.osmSourceLocation = recentSearch.latLng;
                                            // controller.updateData();
                                            FocusScope.of(context).unfocus();
                                            // controller.popupIndex.value = 1;
                                          },
                                        );
                                      },
                                    ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Padding(
                  padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom + 14),
                  child: Align(
                    alignment: AlignmentGeometry.centerRight,
                    child: RoundShapeButton(
                      title: "Continue".tr,
                      buttonColor: AppThemData.primary500,
                      buttonTextColor: AppThemData.black,
                      onTap: () {
                        final bool hasLatLng = Constant.selectedMap == "Google Map" ? controller.googleSourceLocation != null : controller.osmSourceLocation != null;

                        final bool hasAddress = controller.pickupLocationController.text.trim().isNotEmpty;

                        if (!hasLatLng || !hasAddress) {
                          ShowToastDialog.showToast("Please select pickup location".tr);
                          return;
                        }
                        log("++++++++++++++++> ${controller.pickupLocationController.value.text}");
                        controller.updateData();
                      },
                      size: const Size(151, 45),
                    ),
                  ),
                )
              ],
            ),
          );
        });
  }

  Widget _recentTile(
    BuildContext context,
    DarkThemeProvider themeChange,
    String address, {
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: ShapeDecoration(
          shape: RoundedRectangleBorder(
            side: BorderSide(
              width: 1,
              color: themeChange.isDarkTheme() ? AppThemData.grey800 : AppThemData.grey100,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.location_on,
              size: 18,
              color: themeChange.isDarkTheme() ? AppThemData.grey200 : AppThemData.grey800,
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                address,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  color: themeChange.isDarkTheme() ? AppThemData.grey200 : AppThemData.grey800,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
