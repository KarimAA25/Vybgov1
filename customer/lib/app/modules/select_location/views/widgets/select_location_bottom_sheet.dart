// ignore_for_file: deprecated_member_use

import 'dart:developer';

import 'package:customer/app/models/zone_model.dart';
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
import 'package:customer/app/modules/select_location/controllers/select_location_controller.dart';
import 'package:customer/constant/constant.dart';
import 'package:customer/theme/app_them_data.dart';
import 'package:customer/theme/responsive.dart';
import 'package:customer/utils/dark_theme_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:latlong2/latlong.dart' as latlng;
import 'package:provider/provider.dart';
import 'package:timelines_plus/timelines_plus.dart';

class SelectLocationBottomSheet extends StatelessWidget {
  final ScrollController scrollController;

  const SelectLocationBottomSheet({
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
                        Center(
                          child: Container(
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
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Select Location".tr,
                              style: GoogleFonts.inter(
                                color: themeChange.isDarkTheme() ? AppThemData.white : AppThemData.grey950,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            TextButton(
                                onPressed: () {
                                  controller.addStop();
                                },
                                child: Text(
                                  "+ Add stops".tr,
                                  style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w500, color: AppThemData.primary500),
                                ))
                          ],
                        ),
                        Obx(
                          () => Timeline.tileBuilder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            theme: TimelineThemeData(
                              nodePosition: 0,
                            ),
                            padding: const EdgeInsets.only(top: 10),
                            builder: TimelineTileBuilder.connected(
                              contentsAlign: ContentsAlign.basic,
                              indicatorBuilder: (context, index) {
                                if (index == 0) {
                                  return SvgPicture.asset("assets/icon/ic_pick_up.svg");
                                } else if (index == controller.stopControllers.length + 1) {
                                  return SvgPicture.asset("assets/icon/ic_drop_in.svg");
                                } else {
                                  return SvgPicture.asset(
                                    "assets/icon/ic_stop_icon.svg",
                                    color: AppThemData.primary500,
                                  ); // stop
                                }
                              },
                              connectorBuilder: (context, index, connectorType) {
                                return DashedLineConnector(
                                  color: themeChange.isDarkTheme() ? AppThemData.grey600 : AppThemData.grey300,
                                );
                              },
                              contentsBuilder: (context, index) {
                                if (index == 0) {
                                  return buildLocationField(context, controller, controller.pickupLocationController, "Pick up Location".tr, controller.pickUpFocusNode, index);
                                }

                                if (index == controller.stopControllers.length + 1) {
                                  return buildLocationField(context, controller, controller.dropLocationController, "Destination Location".tr, controller.dropFocusNode, index);
                                }

                                int stopIndex = index - 1;
                                return buildLocationField(
                                  context,
                                  controller,
                                  controller.stopControllers[stopIndex],
                                  "Stop ${stopIndex + 1}".tr,
                                  controller.stopFocusNodes[stopIndex],
                                  index,
                                  isStop: true,
                                  onRemove: () {
                                    controller.removeStop(stopIndex);
                                  },
                                );
                              },
                              itemCount: controller.stopControllers.length + 2,
                            ),
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

                                  /// GOOGLE MAP RECENT SEARCH
                                  if (Constant.selectedMap == "Google Map")
                                    ListView.builder(
                                      physics: const NeverScrollableScrollPhysics(),
                                      itemCount: controller.googleRecentSearches.length,
                                      shrinkWrap: true,
                                      padding: EdgeInsets.zero,
                                      itemBuilder: (context, index) {
                                        final recentSearch = controller.googleRecentSearches[index];

                                        return _googleRecentTile(context, controller, recentSearch, themeChange);
                                      },
                                    ),

                                  /// OSM MAP RECENT SEARCH
                                  if (Constant.selectedMap != "Google Map")
                                    ListView.builder(
                                      physics: const NeverScrollableScrollPhysics(),
                                      itemCount: controller.osmRecentSearches.length,
                                      shrinkWrap: true,
                                      padding: EdgeInsets.zero,
                                      itemBuilder: (context, index) {
                                        final recentSearch = controller.osmRecentSearches[index];
                                        return _osmRecentTile(context, controller, recentSearch, themeChange);
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
                    alignment: Alignment.bottomRight,
                    child: RoundShapeButton(
                      size: const Size(151, 45),
                      title: "Continue".tr,
                      buttonColor: AppThemData.primary500,
                      buttonTextColor: AppThemData.black,
                      onTap: () async {
                        if (Constant.selectedMap == "Google Map" ? controller.sourceLocation == null : controller.osmSourceLocation == null) {
                          ShowToastDialog.showToast("Please select Pickup Location".tr);
                          return;
                        }
                        if (Constant.selectedMap == "Google Map" ? controller.destination == null : controller.osmDestination == null) {
                          ShowToastDialog.showToast("Please select Drop Location".tr);
                          return;
                        }

                        ZoneModel? pickupZone;

                        if (Constant.selectedMap == "Google Map") {
                          pickupZone = await controller.getCurrentZone(LatLng(controller.sourceLocation!.latitude, controller.sourceLocation!.longitude));
                        } else {
                          pickupZone = await controller.getCurrentZone(LatLng(controller.osmSourceLocation!.latitude, controller.osmSourceLocation!.longitude));
                        }

                        if (pickupZone == null) {
                          ShowToastDialog.showToast("Service is not Available in Pickup Location Area.".tr);
                          return;
                        }

                        controller.updateData();
                      },
                    ),
                  ),
                ),
              ],
            ),
          );
        });
  }

  Widget _googleRecentTile(
    BuildContext context,
    SelectLocationController controller,
    SelectedLocationModel recentSearch,
    DarkThemeProvider themeChange,
  ) {
    return InkWell(
      onTap: () {
        if (controller.pickUpFocusNode.hasFocus) {
          controller.pickupLocationController.text = recentSearch.getFullAddress();
          controller.sourceLocation = LatLng(
            recentSearch.latLng!.latitude,
            recentSearch.latLng!.longitude,
          );
        } else if (controller.dropFocusNode.hasFocus) {
          controller.dropLocationController.text = recentSearch.getFullAddress();
          controller.destination = LatLng(
            recentSearch.latLng!.latitude,
            recentSearch.latLng!.longitude,
          );
        } else {
          final int stopIndex = controller.stopFocusNodes.indexWhere((node) => node.hasFocus);

          if (stopIndex != -1) {
            controller.stopControllers[stopIndex].text = recentSearch.getFullAddress();

            controller.stopsLatLng[stopIndex] = LatLng(
              recentSearch.latLng!.latitude,
              recentSearch.latLng!.longitude,
            );
          }
        }
        FocusScope.of(context).unfocus();
      },
      child: _recentTileUI(recentSearch.getFullAddress(), themeChange),
    );
  }

  Widget _osmRecentTile(
    BuildContext context,
    SelectLocationController controller,
    OsmSelectedLocationModel recentSearch,
    DarkThemeProvider themeChange,
  ) {
    return InkWell(
      onTap: () {
        if (controller.pickUpFocusNode.hasFocus) {
          controller.pickupLocationController.text = recentSearch.getFullAddress();
          controller.osmSourceLocation = recentSearch.latLng;
        } else if (controller.dropFocusNode.hasFocus) {
          controller.dropLocationController.text = recentSearch.getFullAddress();
          controller.osmDestination = recentSearch.latLng;
        } else {
          final int stopIndex = controller.stopFocusNodes.indexWhere((node) => node.hasFocus);

          if (stopIndex != -1) {
            controller.stopControllers[stopIndex].text = recentSearch.getFullAddress();

            controller.osmStopsLatLng[stopIndex] = latlng.LatLng(
              recentSearch.latLng!.latitude,
              recentSearch.latLng!.longitude,
            );
          }
        }
        FocusScope.of(context).unfocus();
      },
      child: _recentTileUI(recentSearch.getFullAddress(), themeChange),
    );
  }

  Widget _recentTileUI(String address, DarkThemeProvider themeChange) {
    return Container(
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
        crossAxisAlignment: CrossAxisAlignment.start,
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
    );
  }

  Widget buildLocationField(
    BuildContext context,
    SelectLocationController locationController,
    TextEditingController controller,
    String hint,
    FocusNode focusNode,
    int index, {
    bool isStop = false,
    VoidCallback? onRemove,
  }) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return Padding(
        padding: const EdgeInsets.all(8.0),
        child: TextFormField(
          focusNode: focusNode,
          cursorColor: AppThemData.primary500,
          readOnly: true,
          controller: controller,
          onTap: () {
            focusNode.requestFocus();
            Constant.selectedMap == "Google Map"
                ? Get.to(LocationPickerScreen())!.then((value) {
                    if (value != null) {
                      SelectedLocationModel selectedLocationModel = value;

                      String formattedAddress = "${selectedLocationModel.address?.street ?? ''}, "
                          "${selectedLocationModel.address?.subLocality}, "
                          "${selectedLocationModel.address?.locality ?? ''}, "
                          "${selectedLocationModel.address?.administrativeArea}, "
                          "${selectedLocationModel.address?.postalCode} "
                          "${selectedLocationModel.address?.country ?? ''}";

                      if (index == 0) {
                        locationController.sourceLocation = selectedLocationModel.latLng!;
                        controller.text = formattedAddress;
                      } else if (isStop) {
                        locationController.stopsLatLng[index - 1] = selectedLocationModel.latLng!;
                        controller.text = formattedAddress;
                      } else {
                        locationController.destination = selectedLocationModel.latLng;
                        controller.text = formattedAddress;
                      }
                      RecentSearchLocation.addLocationInHistory(selectedLocationModel);
                    } else {
                      Future.delayed(Duration(milliseconds: 100), () {
                        focusNode.requestFocus();
                      });
                    }
                  })
                : Get.to(OSMLocationPickerScreen())!.then((value) {
                    if (value != null) {
                      OsmSelectedLocationModel osmSelectedLocationModel = value;
                      String formattedAddress = "${osmSelectedLocationModel.address?.street ?? ''}, "
                          "${osmSelectedLocationModel.address?.subLocality}, "
                          "${osmSelectedLocationModel.address?.locality ?? ''}, "
                          "${osmSelectedLocationModel.address?.administrativeArea}, "
                          "${osmSelectedLocationModel.address?.postalCode} "
                          "${osmSelectedLocationModel.address?.country ?? ''}";

                      log("=====================> OSM Source Location : $formattedAddress");
                      if (index == 0) {
                        locationController.osmSourceLocation = osmSelectedLocationModel.latLng!;
                        controller.text = formattedAddress;
                      } else if (isStop) {
                        locationController.osmStopsLatLng[index - 1] = osmSelectedLocationModel.latLng!;
                        controller.text = formattedAddress;
                      } else {
                        locationController.osmDestination = osmSelectedLocationModel.latLng;
                        controller.text = formattedAddress;
                      }
                      RecentSearchLocation.addOSMLocationInHistory(osmSelectedLocationModel);
                    } else {
                      Future.delayed(Duration(milliseconds: 100), () {
                        focusNode.requestFocus();
                      });
                    }
                  });
          },
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: themeChange.isDarkTheme() ? AppThemData.grey950 : AppThemData.grey50,
            focusColor: AppThemData.primary500,
            suffixIcon: isStop
                ? InkWell(
                    onTap: onRemove,
                    child: const Icon(Icons.delete, color: Colors.red),
                  )
                : (controller.text.isNotEmpty
                    ? InkWell(
                        onTap: () {
                          if (index == 0) {
                            controller.clear();
                          } else {
                            locationController.destination = null;
                            controller.clear();
                          }
                          locationController.getRecentSearches();
                          locationController.polyLines.clear();
                        },
                        child: const Icon(Icons.close),
                      )
                    : null),
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(100), borderSide: BorderSide(color: themeChange.isDarkTheme() ? AppThemData.grey950 : AppThemData.grey25)),
            disabledBorder:
                OutlineInputBorder(borderRadius: BorderRadius.circular(100), borderSide: BorderSide(color: themeChange.isDarkTheme() ? AppThemData.grey950 : AppThemData.grey25)),
            enabledBorder:
                OutlineInputBorder(borderRadius: BorderRadius.circular(100), borderSide: BorderSide(color: themeChange.isDarkTheme() ? AppThemData.grey950 : AppThemData.grey25)),
            errorBorder:
                OutlineInputBorder(borderRadius: BorderRadius.circular(100), borderSide: BorderSide(color: themeChange.isDarkTheme() ? AppThemData.grey950 : AppThemData.grey25)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(100), borderSide: BorderSide(color: AppThemData.primary500)),
            focusedErrorBorder:
                OutlineInputBorder(borderRadius: BorderRadius.circular(100), borderSide: BorderSide(color: themeChange.isDarkTheme() ? AppThemData.grey950 : AppThemData.grey25)),
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
        ));
  }
}
