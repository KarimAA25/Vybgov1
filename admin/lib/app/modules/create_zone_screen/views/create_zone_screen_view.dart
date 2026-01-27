// ignore_for_file: use_build_context_synchronously

import 'package:admin/app/components/dialog_box.dart';
import 'package:admin/app/constant/constants.dart';
import 'package:admin/app/constant/show_toast.dart';
import 'package:admin/app/modules/create_zone_screen/controllers/create_zone_screen_controller.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:latlong2/latlong.dart' as osmLatLng;
import 'package:nb_utils/nb_utils.dart';
import 'package:provider/provider.dart';
import 'package:flutter/cupertino.dart';
import '../../../../widget/common_ui.dart';
import '../../../../widget/container_custom.dart';
import '../../../../widget/global_widgets.dart';
import '../../../../widget/text_widget.dart';
import '../../../components/custom_button.dart';
import '../../../components/custom_text_form_field.dart';
import '../../../components/menu_widget.dart';
import '../../../routes/app_pages.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_them_data.dart';
import '../../../utils/dark_theme_provider.dart';
import '../../../utils/responsive.dart';
import 'package:flutter_map/flutter_map.dart' as osm;

class CreateZoneScreenView extends GetView<CreateZoneScreenController> {
  const CreateZoneScreenView({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetX<CreateZoneScreenController>(
      init: CreateZoneScreenController(),
      builder: (controller) {
        return ResponsiveWidget(
            mobile: Scaffold(
              backgroundColor: themeChange.isDarkTheme() ? AppThemData.greyShade950 : AppThemData.greyShade50,
              appBar: AppBar(
                elevation: 0.0,
                toolbarHeight: 70,
                automaticallyImplyLeading: false,
                backgroundColor: themeChange.isDarkTheme() ? AppThemData.primaryBlack : AppThemData.primaryWhite,
                leadingWidth: 200,
                leading: Builder(
                  builder: (BuildContext context) {
                    return GestureDetector(
                      onTap: () {
                        if (!ResponsiveWidget.isDesktop(context)) {
                          Scaffold.of(context).openDrawer();
                        }
                      },
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: !ResponsiveWidget.isDesktop(context)
                            ? Padding(
                                padding: const EdgeInsets.only(left: 10),
                                child: Icon(
                                  Icons.menu,
                                  size: 30,
                                  color: themeChange.isDarkTheme() ? AppThemData.primary500 : AppThemData.primary500,
                                ),
                              )
                            : SizedBox(
                                height: 45,
                                child: InkWell(
                                  onTap: () {
                                    Get.toNamed(Routes.DASHBOARD_SCREEN);
                                  },
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Image.asset(
                                        "assets/image/logo.png",
                                        height: 45,
                                        color: AppThemData.primary500,
                                      ),
                                      spaceW(),
                                      const TextCustom(
                                        title: 'My Taxi',
                                        color: AppThemData.primary500,
                                        fontSize: 30,
                                        fontFamily: AppThemeData.semiBold,
                                        fontWeight: FontWeight.w700,
                                      )
                                    ],
                                  ),
                                ),
                              ),
                      ),
                    );
                  },
                ),
                actions: [
                  GestureDetector(
                    onTap: () {
                      if (themeChange.darkTheme == 1) {
                        themeChange.darkTheme = 0;
                      } else if (themeChange.darkTheme == 0) {
                        themeChange.darkTheme = 1;
                      } else if (themeChange.darkTheme == 2) {
                        themeChange.darkTheme = 0;
                      } else {
                        themeChange.darkTheme = 2;
                      }
                    },
                    child: themeChange.isDarkTheme()
                        ? SvgPicture.asset(
                            "assets/icons/ic_sun.svg",
                            color: AppThemData.yellow600,
                            height: 20,
                            width: 20,
                          )
                        : SvgPicture.asset(
                            "assets/icons/ic_moon.svg",
                            color: AppThemData.blue400,
                            height: 20,
                            width: 20,
                          ),
                  ),
                  spaceW(),
                  const LanguagePopUp(),
                  spaceW(),
                  ProfilePopUp()
                ],
              ),
              drawer: Drawer(
                width: 270,
                backgroundColor: themeChange.isDarkTheme() ? AppThemData.primaryBlack : AppThemData.primaryWhite,
                child: const MenuWidget(),
              ),
              body: Padding(
                padding: paddingEdgeInsets(),
                child: SingleChildScrollView(
                  child: ContainerCustom(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              TextCustom(title: controller.title.value, fontSize: 20, fontFamily: AppThemeData.bold),
                              spaceH(height: 2),
                              Row(children: [
                                GestureDetector(
                                    onTap: () => Get.offAllNamed(Routes.DASHBOARD_SCREEN),
                                    child: TextCustom(title: 'Dashboard'.tr, fontSize: 14, fontFamily: AppThemeData.medium, color: AppThemData.greyShade500)),
                                const TextCustom(title: ' / ', fontSize: 14, fontFamily: AppThemeData.medium, color: AppThemData.greyShade500),
                                GestureDetector(
                                    onTap: () {
                                      Get.back();
                                      controller.setDefaultData();
                                    },
                                    child: TextCustom(title: 'All Zone'.tr, fontSize: 14, fontFamily: AppThemeData.medium, color: AppThemData.greyShade500)),
                                const TextCustom(title: ' / ', fontSize: 14, fontFamily: AppThemeData.medium, color: AppThemData.greyShade500),
                                TextCustom(title: ' ${controller.title.value} ', fontSize: 14, fontFamily: AppThemeData.medium, color: AppThemData.primary500)
                              ])
                            ]),
                          ],
                        ),
                        spaceH(height: 20),
                        controller.isLoading.value
                            ? Constant.loader()
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const TextCustom(
                                    title: "Instructions",
                                    fontSize: 16,
                                    fontFamily: AppThemeData.bold,
                                  ),
                                  spaceH(height: 16),
                                  TextCustom(
                                    title: "Allow User to define the boundary of the business zone interactively on the map by clicking to add points or dots.",
                                    fontSize: 14,
                                    fontFamily: AppThemeData.regular,
                                    maxLine: 3,
                                    color: themeChange.isDarkTheme() ? AppThemData.greyShade300 : AppThemData.greyShade700,
                                  ),
                                  spaceH(height: 16),
                                  Row(
                                    children: [
                                      Container(
                                        decoration: const BoxDecoration(
                                          color: AppThemData.primary500,
                                        ),
                                        child: const Padding(
                                          padding: EdgeInsets.all(4.0),
                                          child: Icon(
                                            Icons.add_circle,
                                            color: Colors.white,
                                            size: 20,
                                          ),
                                        ),
                                      ),
                                      spaceW(width: 6),
                                      Expanded(
                                        child: TextCustom(
                                          title: "Use the 'Shape Tool' to highlight areas and connect the dots. A minimum of three points/dots required.",
                                          fontSize: 14,
                                          fontFamily: AppThemeData.regular,
                                          maxLine: 2,
                                          color: themeChange.isDarkTheme() ? AppThemData.greyShade300 : AppThemData.greyShade700,
                                        ),
                                      ),
                                    ],
                                  ),
                                  spaceH(height: 16),
                                  Row(
                                    children: [
                                      Container(
                                        decoration: const BoxDecoration(
                                          color: AppThemData.primary500,
                                        ),
                                        child: const Padding(
                                          padding: EdgeInsets.all(4.0),
                                          child: Icon(
                                            Icons.delete,
                                            color: Colors.white,
                                            size: 20,
                                          ),
                                        ),
                                      ),
                                      spaceW(width: 6),
                                      TextCustom(
                                        title: "Use the 'Trash Tool' to remove the selected Area.",
                                        fontSize: 14,
                                        fontFamily: AppThemeData.regular,
                                        maxLine: 2,
                                        color: themeChange.isDarkTheme() ? AppThemData.greyShade300 : AppThemData.greyShade700,
                                      ),
                                    ],
                                  ),
                                  spaceH(height: 20),
                                  CustomTextFormField(
                                    hintText: "Enter Zone Name",
                                    controller: controller.zoneController.value,
                                    title: "Zone Name",
                                    inputFormatters: [
                                      FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9\s]')),
                                    ],
                                  ),
                                  spaceH(height: 10),
                                  const TextCustom(title: "Status"),
                                  spaceH(height: 4),
                                  Transform.scale(
                                    scale: 0.8,
                                    child: CupertinoSwitch(
                                      activeTrackColor: AppThemData.primary500,
                                      value: controller.isActive.value,
                                      onChanged: (value) {
                                        controller.isActive.value = value;
                                      },
                                    ),
                                  ),
                                  spaceH(height: 16),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: SizedBox(
                                          width: double.infinity,
                                          height: 0.7.sw,
                                          child: Stack(
                                            children: [
                                              Constant.selectedMap == "Google Map"
                                                  ? GoogleMap(
                                                      onMapCreated: (GoogleMapController googleMapController) {
                                                        controller.googleMapController = googleMapController;
                                                        if (controller.polygonCoords.isNotEmpty) {
                                                          controller.moveCameraToPolygon();
                                                        }
                                                      },
                                                      initialCameraPosition: CameraPosition(
                                                        target: Constant.currentPosition != null
                                                            ? LatLng(Constant.currentPosition!.latitude, Constant.currentPosition!.longitude)
                                                            : const LatLng(0, 0),
                                                        // target: LatLng(Constant.currentPosition!.latitude, Constant.currentPosition!.longitude), // San Francisco
                                                        zoom: 13,
                                                      ),
                                                      polygons: controller.polygons.toSet(),
                                                      onTap: controller.addPolygon,
                                                      myLocationEnabled: true,
                                                      zoomControlsEnabled: true,
                                                      mapType: MapType.normal,
                                                    )
                                                  : osm.FlutterMap(
                                                      mapController: controller.osmMapController,
                                                      options: osm.MapOptions(
                                                        initialCenter: Constant.currentPosition != null
                                                            ? osmLatLng.LatLng(
                                                                Constant.currentPosition!.latitude,
                                                                Constant.currentPosition!.longitude,
                                                              )
                                                            : const osmLatLng.LatLng(0, 0),
                                                        initialZoom: 13,
                                                        interactionOptions: const osm.InteractionOptions(
                                                          flags: osm.InteractiveFlag.drag |
                                                              osm.InteractiveFlag.pinchZoom |
                                                              osm.InteractiveFlag.doubleTapZoom |
                                                              osm.InteractiveFlag.scrollWheelZoom |
                                                              osm.InteractiveFlag.flingAnimation,
                                                        ),
                                                        onTap: (tapPosition, point) {
                                                          controller.addPolygonOSM(point);
                                                        },
                                                        onMapReady: () {
                                                          controller.isOsmMapReady.value = true;
                                                        },
                                                      ),
                                                      children: [
                                                        osm.TileLayer(
                                                          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                                        ),
                                                        Obx(() {
                                                          if (controller.osmPolygonCoords.isEmpty) {
                                                            return const SizedBox();
                                                          }
                                                          return osm.PolygonLayer(
                                                            polygons: [
                                                              osm.Polygon(
                                                                points: controller.osmPolygonCoords,
                                                                borderColor: Colors.black,
                                                                borderStrokeWidth: 3,
                                                                color: Colors.black.withOpacity(0.2),
                                                              ),
                                                            ],
                                                          );
                                                        }),
                                                        Obx(() {
                                                          return osm.MarkerLayer(
                                                            markers: controller.osmPolygonCoords.map((point) {
                                                              return osm.Marker(
                                                                point: point,
                                                                width: 40,
                                                                height: 40,
                                                                child: const Icon(
                                                                  Icons.location_on,
                                                                  color: Colors.red,
                                                                  size: 30,
                                                                ),
                                                              );
                                                            }).toList(),
                                                          );
                                                        }),
                                                      ],
                                                    ),
                                              Center(child: Icon(Icons.location_pin, size: 40, color: AppThemData.primary500)),
                                              Positioned(
                                                top: 10,
                                                left: 10,
                                                right: 10,
                                                child: Column(
                                                  children: [
                                                    TextFormField(
                                                      controller: controller.searchController,
                                                      style: TextStyle(color: themeChange.isDarkTheme() ? AppThemData.greyShade300 : AppThemData.greyShade700),
                                                      decoration: InputDecoration(
                                                        filled: true,
                                                        fillColor: themeChange.isDarkTheme() ? AppThemData.primaryBlack : AppThemData.primaryWhite,
                                                        hintText: 'Search place'.tr,
                                                        border: InputBorder.none,
                                                        contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                                                        hintStyle: TextStyle(
                                                          fontSize: 14,
                                                          fontFamily: AppThemeData.regular,
                                                          color: themeChange.isDarkTheme() ? AppThemData.greyShade300 : AppThemData.greyShade700,
                                                        ),
                                                        focusedBorder: OutlineInputBorder(
                                                          borderRadius: BorderRadius.circular(50),
                                                          borderSide: BorderSide.none,
                                                        ),
                                                        enabledBorder: OutlineInputBorder(
                                                          borderRadius: BorderRadius.circular(50),
                                                          borderSide: BorderSide.none,
                                                        ),
                                                        disabledBorder: OutlineInputBorder(
                                                          borderRadius: BorderRadius.circular(50),
                                                          borderSide: BorderSide.none,
                                                        ),
                                                      ),
                                                      onChanged: (value) {
                                                        if (kIsWeb) {
                                                          controller.fetchPredictions(value);
                                                        }
                                                      },
                                                    ),
                                                    Obx(() {
                                                      if (controller.predictions.isEmpty) return SizedBox();
                                                      return Container(
                                                        color: themeChange.isDarkTheme() ? AppThemData.greyShade900 : AppThemData.greyShade100,
                                                        child: ListView.builder(
                                                          shrinkWrap: true,
                                                          itemCount: controller.predictions.length,
                                                          itemBuilder: (context, index) {
                                                            final p = controller.predictions[index];
                                                            return ListTile(
                                                              title: TextCustom(
                                                                title: p['description'],
                                                                fontSize: 16,
                                                                fontFamily: AppThemeData.medium,
                                                                color: themeChange.isDarkTheme() ? AppThemData.greyShade100 : AppThemData.greyShade900,
                                                              ),
                                                              onTap: () {
                                                                controller.selectPrediction(p);
                                                              },
                                                            );
                                                          },
                                                        ),
                                                      );
                                                    })
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      spaceW(width: 12),
                                      Column(
                                        children: [
                                          InkWell(
                                            onTap: () => controller.addPolygon,
                                            child: Container(
                                              decoration: const BoxDecoration(
                                                color: AppThemData.primary500,
                                              ),
                                              child: const Padding(
                                                padding: EdgeInsets.all(4.0),
                                                child: Icon(
                                                  Icons.add_circle,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ),
                                          spaceH(height: 16),
                                          InkWell(
                                            onTap: () => controller.clearPolygon(),
                                            child: Container(
                                              decoration: const BoxDecoration(
                                                color: AppThemData.primary500,
                                              ),
                                              child: const Padding(
                                                padding: EdgeInsets.all(4.0),
                                                child: Icon(
                                                  Icons.delete,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  spaceH(height: 16),
                                  Align(
                                    alignment: Alignment.bottomRight,
                                    child: CustomButtonWidget(
                                      buttonTitle: "Save",
                                      buttonColor: AppThemData.primary500,
                                      onPress: () {
                                        if (Constant.isDemo) {
                                          DialogBox.demoDialogBox();
                                        } else {
                                          if (controller.zoneController.value.text.isEmpty) {
                                            ShowToastDialog.errorToast("Please Enter Zone name..".tr);
                                          } else {
                                            controller.addZone();
                                          }
                                        }
                                      },
                                    ),
                                  )
                                ],
                              )
                      ],
                    ),
                  ),
                ),
              ),
            ),
            tablet: Scaffold(
              backgroundColor: themeChange.isDarkTheme() ? AppThemData.greyShade950 : AppThemData.greyShade50,
              appBar: AppBar(
                elevation: 0.0,
                toolbarHeight: 70,
                automaticallyImplyLeading: false,
                backgroundColor: themeChange.isDarkTheme() ? AppThemData.primaryBlack : AppThemData.primaryWhite,
                leadingWidth: 200,
                leading: Builder(
                  builder: (BuildContext context) {
                    return GestureDetector(
                      onTap: () {
                        if (!ResponsiveWidget.isDesktop(context)) {
                          Scaffold.of(context).openDrawer();
                        }
                      },
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: !ResponsiveWidget.isDesktop(context)
                            ? Padding(
                                padding: const EdgeInsets.only(left: 10),
                                child: Icon(
                                  Icons.menu,
                                  size: 30,
                                  color: themeChange.isDarkTheme() ? AppThemData.primary500 : AppThemData.primary500,
                                ),
                              )
                            : SizedBox(
                                height: 45,
                                child: InkWell(
                                  onTap: () {
                                    Get.toNamed(Routes.DASHBOARD_SCREEN);
                                  },
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Image.asset(
                                        "assets/image/logo.png",
                                        height: 45,
                                        color: AppThemData.primary500,
                                      ),
                                      spaceW(),
                                      const TextCustom(
                                        title: 'My Taxi',
                                        color: AppThemData.primary500,
                                        fontSize: 30,
                                        fontFamily: AppThemeData.semiBold,
                                        fontWeight: FontWeight.w700,
                                      )
                                    ],
                                  ),
                                ),
                              ),
                      ),
                    );
                  },
                ),
                actions: [
                  GestureDetector(
                    onTap: () {
                      if (themeChange.darkTheme == 1) {
                        themeChange.darkTheme = 0;
                      } else if (themeChange.darkTheme == 0) {
                        themeChange.darkTheme = 1;
                      } else if (themeChange.darkTheme == 2) {
                        themeChange.darkTheme = 0;
                      } else {
                        themeChange.darkTheme = 2;
                      }
                    },
                    child: themeChange.isDarkTheme()
                        ? SvgPicture.asset(
                            "assets/icons/ic_sun.svg",
                            color: AppThemData.yellow600,
                            height: 20,
                            width: 20,
                          )
                        : SvgPicture.asset(
                            "assets/icons/ic_moon.svg",
                            color: AppThemData.blue400,
                            height: 20,
                            width: 20,
                          ),
                  ),
                  spaceW(),
                  const LanguagePopUp(),
                  spaceW(),
                  ProfilePopUp()
                ],
              ),
              drawer: Drawer(
                // key: scaffoldKey,
                width: 270,
                backgroundColor: themeChange.isDarkTheme() ? AppThemData.primaryBlack : AppThemData.primaryWhite,
                child: const MenuWidget(),
              ),
              body: Padding(
                padding: paddingEdgeInsets(),
                child: SingleChildScrollView(
                  child: ContainerCustom(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              TextCustom(title: controller.title.value, fontSize: 20, fontFamily: AppThemeData.bold),
                              spaceH(height: 2),
                              Row(children: [
                                GestureDetector(
                                    onTap: () => Get.offAllNamed(Routes.DASHBOARD_SCREEN),
                                    child: TextCustom(title: 'Dashboard'.tr, fontSize: 14, fontFamily: AppThemeData.medium, color: AppThemData.greyShade500)),
                                const TextCustom(title: ' / ', fontSize: 14, fontFamily: AppThemeData.medium, color: AppThemData.greyShade500),
                                GestureDetector(
                                    onTap: () {
                                      Get.back();
                                      controller.setDefaultData();
                                    },
                                    child: TextCustom(title: 'All Zone'.tr, fontSize: 14, fontFamily: AppThemeData.medium, color: AppThemData.greyShade500)),
                                const TextCustom(title: ' / ', fontSize: 14, fontFamily: AppThemeData.medium, color: AppThemData.greyShade500),
                                TextCustom(title: ' ${controller.title.value} ', fontSize: 14, fontFamily: AppThemeData.medium, color: AppThemData.primary500)
                              ])
                            ]),
                          ],
                        ),
                        spaceH(height: 20),
                        const TextCustom(
                          title: "Instructions",
                          fontSize: 16,
                          fontFamily: AppThemeData.bold,
                        ),
                        spaceH(height: 16),
                        TextCustom(
                          title: "Allow User to define the boundary of the business zone interactively on the map by clicking to add points or dots.",
                          fontSize: 14,
                          fontFamily: AppThemeData.regular,
                          maxLine: 3,
                          color: themeChange.isDarkTheme() ? AppThemData.greyShade300 : AppThemData.greyShade700,
                        ),
                        spaceH(height: 16),
                        Row(
                          children: [
                            Container(
                              decoration: const BoxDecoration(
                                color: AppThemData.primary500,
                              ),
                              child: const Padding(
                                padding: EdgeInsets.all(4.0),
                                child: Icon(
                                  Icons.add_circle,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                            spaceW(width: 6),
                            Expanded(
                              child: TextCustom(
                                title: "Use the 'Shape Tool' to highlight areas and connect the dots. A minimum of three points/dots required.",
                                fontSize: 14,
                                fontFamily: AppThemeData.regular,
                                maxLine: 2,
                                color: themeChange.isDarkTheme() ? AppThemData.greyShade300 : AppThemData.greyShade700,
                              ),
                            ),
                          ],
                        ),
                        spaceH(height: 16),
                        Row(
                          children: [
                            Container(
                              decoration: const BoxDecoration(
                                color: AppThemData.primary500,
                              ),
                              child: const Padding(
                                padding: EdgeInsets.all(4.0),
                                child: Icon(
                                  Icons.delete,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                            spaceW(width: 6),
                            Expanded(
                              child: TextCustom(
                                title: "Use the 'Trash Tool' to remove the selected Area.",
                                fontSize: 14,
                                fontFamily: AppThemeData.regular,
                                maxLine: 2,
                                color: themeChange.isDarkTheme() ? AppThemData.greyShade300 : AppThemData.greyShade700,
                              ),
                            ),
                          ],
                        ),
                        spaceH(height: 20),
                        CustomTextFormField(
                          hintText: "Enter Zone Name",
                          controller: controller.zoneController.value,
                          title: "Zone Name",
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9\s]')), // disallow dash
                          ],
                        ),
                        spaceH(height: 10),
                        const TextCustom(title: "Status"),
                        spaceH(height: 4),
                        Transform.scale(
                          scale: 0.8,
                          child: CupertinoSwitch(
                            activeTrackColor: AppThemData.primary500,
                            value: controller.isActive.value,
                            onChanged: (value) {
                              controller.isActive.value = value;
                            },
                          ),
                        ),
                        spaceH(height: 16),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: SizedBox(
                                width: double.infinity,
                                height: 0.7.sw,
                                child: Stack(
                                  children: [
                                    Constant.selectedMap == "Google Map"
                                        ? GoogleMap(
                                            onMapCreated: (GoogleMapController googleMapController) {
                                              controller.googleMapController = googleMapController;
                                              if (controller.polygonCoords.isNotEmpty) {
                                                controller.moveCameraToPolygon();
                                              }
                                            },
                                            initialCameraPosition: CameraPosition(
                                              target: Constant.currentPosition != null
                                                  ? LatLng(Constant.currentPosition!.latitude, Constant.currentPosition!.longitude)
                                                  : const LatLng(0, 0),
                                              // target: LatLng(Constant.currentPosition!.latitude, Constant.currentPosition!.longitude), // San Francisco
                                              zoom: 13,
                                            ),
                                            polygons: controller.polygons.toSet(),
                                            onTap: controller.addPolygon,
                                            myLocationEnabled: true,
                                            zoomControlsEnabled: true,
                                            mapType: MapType.normal,
                                          )
                                        : osm.FlutterMap(
                                            mapController: controller.osmMapController,
                                            options: osm.MapOptions(
                                              initialCenter: Constant.currentPosition != null
                                                  ? osmLatLng.LatLng(
                                                      Constant.currentPosition!.latitude,
                                                      Constant.currentPosition!.longitude,
                                                    )
                                                  : const osmLatLng.LatLng(0, 0),
                                              initialZoom: 13,
                                              interactionOptions: const osm.InteractionOptions(
                                                flags: osm.InteractiveFlag.drag |
                                                    osm.InteractiveFlag.pinchZoom |
                                                    osm.InteractiveFlag.doubleTapZoom |
                                                    osm.InteractiveFlag.scrollWheelZoom |
                                                    osm.InteractiveFlag.flingAnimation,
                                              ),
                                              onTap: (tapPosition, point) {
                                                controller.addPolygonOSM(point);
                                              },
                                              onMapReady: () {
                                                controller.isOsmMapReady.value = true;
                                              },
                                            ),
                                            children: [
                                              osm.TileLayer(
                                                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                              ),
                                              Obx(() {
                                                if (controller.osmPolygonCoords.isEmpty) {
                                                  return const SizedBox();
                                                }
                                                return osm.PolygonLayer(
                                                  polygons: [
                                                    osm.Polygon(
                                                      points: controller.osmPolygonCoords,
                                                      borderColor: Colors.black,
                                                      borderStrokeWidth: 3,
                                                      color: Colors.black.withOpacity(0.2),
                                                    ),
                                                  ],
                                                );
                                              }),
                                              Obx(() {
                                                return osm.MarkerLayer(
                                                  markers: controller.osmPolygonCoords.map((point) {
                                                    return osm.Marker(
                                                      point: point,
                                                      width: 40,
                                                      height: 40,
                                                      child: const Icon(
                                                        Icons.location_on,
                                                        color: Colors.red,
                                                        size: 30,
                                                      ),
                                                    );
                                                  }).toList(),
                                                );
                                              }),
                                            ],
                                          ),
                                    Center(child: Icon(Icons.location_pin, size: 40, color: AppThemData.primary500)),
                                    Positioned(
                                      top: 10,
                                      left: 10,
                                      right: 10,
                                      child: Column(
                                        children: [
                                          TextFormField(
                                            controller: controller.searchController,
                                            style: TextStyle(color: themeChange.isDarkTheme() ? AppThemData.greyShade300 : AppThemData.greyShade700),
                                            decoration: InputDecoration(
                                              filled: true,
                                              fillColor: themeChange.isDarkTheme() ? AppThemData.primaryBlack : AppThemData.primaryWhite,
                                              hintText: 'Search place',
                                              border: InputBorder.none,
                                              contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                                              hintStyle: TextStyle(
                                                fontSize: 14,
                                                fontFamily: AppThemeData.regular,
                                                color: themeChange.isDarkTheme() ? AppThemData.greyShade300 : AppThemData.greyShade700,
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(50),
                                                borderSide: BorderSide.none,
                                              ),
                                              enabledBorder: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(50),
                                                borderSide: BorderSide.none,
                                              ),
                                              disabledBorder: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(50),
                                                borderSide: BorderSide.none,
                                              ),
                                            ),
                                            onChanged: (value) {
                                              if (kIsWeb) {
                                                controller.fetchPredictions(value);
                                              }
                                            },
                                          ),
                                          Obx(() {
                                            if (controller.predictions.isEmpty) return SizedBox();
                                            return Container(
                                              color: themeChange.isDarkTheme() ? AppThemData.greyShade900 : AppThemData.greyShade100,
                                              child: ListView.builder(
                                                shrinkWrap: true,
                                                itemCount: controller.predictions.length,
                                                itemBuilder: (context, index) {
                                                  final p = controller.predictions[index];
                                                  return ListTile(
                                                    title: TextCustom(
                                                      title: p['description'],
                                                      fontSize: 16,
                                                      fontFamily: AppThemeData.medium,
                                                      color: themeChange.isDarkTheme() ? AppThemData.greyShade100 : AppThemData.greyShade900,
                                                    ),
                                                    onTap: () {
                                                      controller.selectPrediction(p);
                                                    },
                                                  );
                                                },
                                              ),
                                            );
                                          })
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            spaceW(width: 12),
                            Column(
                              children: [
                                InkWell(
                                  onTap: () => controller.addPolygon,
                                  child: Container(
                                    decoration: const BoxDecoration(
                                      color: AppThemData.primary500,
                                    ),
                                    child: const Padding(
                                      padding: EdgeInsets.all(4.0),
                                      child: Icon(
                                        Icons.add_circle,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                                spaceH(height: 16),
                                InkWell(
                                  onTap: () => controller.clearPolygon(),
                                  child: Container(
                                    decoration: const BoxDecoration(
                                      color: AppThemData.primary500,
                                    ),
                                    child: const Padding(
                                      padding: EdgeInsets.all(4.0),
                                      child: Icon(
                                        Icons.delete,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        spaceH(height: 16),
                        Align(
                          alignment: Alignment.bottomRight,
                          child: CustomButtonWidget(
                            buttonTitle: "Save",
                            buttonColor: AppThemData.primary500,
                            onPress: () {
                              if (Constant.isDemo) {
                                DialogBox.demoDialogBox();
                              } else {
                                if (controller.zoneController.value.text.isEmpty) {
                                  ShowToastDialog.errorToast("Please Enter Zone name..".tr);
                                } else {
                                  controller.addZone();
                                }
                              }
                            },
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
            desktop: Scaffold(
              backgroundColor: themeChange.isDarkTheme() ? AppThemData.greyShade950 : AppThemData.greyShade50,
              appBar: AppBar(
                elevation: 0.0,
                toolbarHeight: 70,
                automaticallyImplyLeading: false,
                backgroundColor: themeChange.isDarkTheme() ? AppThemData.primaryBlack : AppThemData.primaryWhite,
                leadingWidth: 200,
                leading: Builder(
                  builder: (BuildContext context) {
                    return GestureDetector(
                      onTap: () {
                        if (!ResponsiveWidget.isDesktop(context)) {
                          Scaffold.of(context).openDrawer();
                        }
                      },
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: !ResponsiveWidget.isDesktop(context)
                            ? Padding(
                                padding: const EdgeInsets.only(left: 10),
                                child: Icon(
                                  Icons.menu,
                                  size: 30,
                                  color: themeChange.isDarkTheme() ? AppThemData.primary500 : AppThemData.primary500,
                                ),
                              )
                            : SizedBox(
                                height: 45,
                                child: InkWell(
                                  onTap: () {
                                    Get.toNamed(Routes.DASHBOARD_SCREEN);
                                  },
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Image.asset(
                                        "assets/image/logo.png",
                                        height: 45,
                                        color: AppThemData.primary500,
                                      ),
                                      spaceW(),
                                      const TextCustom(
                                        title: 'My Taxi',
                                        color: AppThemData.primary500,
                                        fontSize: 30,
                                        fontFamily: AppThemeData.semiBold,
                                        fontWeight: FontWeight.w700,
                                      )
                                    ],
                                  ),
                                ),
                              ),
                      ),
                    );
                  },
                ),
                actions: [
                  GestureDetector(
                    onTap: () {
                      if (themeChange.darkTheme == 1) {
                        themeChange.darkTheme = 0;
                      } else if (themeChange.darkTheme == 0) {
                        themeChange.darkTheme = 1;
                      } else if (themeChange.darkTheme == 2) {
                        themeChange.darkTheme = 0;
                      } else {
                        themeChange.darkTheme = 2;
                      }
                    },
                    child: themeChange.isDarkTheme()
                        ? SvgPicture.asset(
                            "assets/icons/ic_sun.svg",
                            color: AppThemData.yellow600,
                            height: 20,
                            width: 20,
                          )
                        : SvgPicture.asset(
                            "assets/icons/ic_moon.svg",
                            color: AppThemData.blue400,
                            height: 20,
                            width: 20,
                          ),
                  ),
                  spaceW(),
                  const LanguagePopUp(),
                  spaceW(),
                  ProfilePopUp()
                ],
              ),
              drawer: Drawer(
                // key: scaffoldKey,
                width: 270,
                backgroundColor: themeChange.isDarkTheme() ? AppThemData.primaryBlack : AppThemData.primaryWhite,
                child: const MenuWidget(),
              ),
              body: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (ResponsiveWidget.isDesktop(context)) ...{const MenuWidget()},
                  Expanded(
                    child: Padding(
                      padding: paddingEdgeInsets(),
                      child: SingleChildScrollView(
                        child: ContainerCustom(
                          child: Column(
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  InkWell(
                                    onTap: () => Get.back(),
                                    child: SvgPicture.asset(
                                      "assets/icons/ic_arrow_back.svg",
                                      height: 28,
                                      colorFilter: ColorFilter.mode(themeChange.isDarkTheme() ? AppThemData.primaryWhite : AppThemData.primaryBlack, BlendMode.srcIn),
                                    ),
                                  ),
                                  10.width,
                                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                    TextCustom(title: controller.title.value, fontSize: 20, fontFamily: AppThemeData.bold),
                                    spaceH(height: 2),
                                    Row(children: [
                                      GestureDetector(
                                          onTap: () => Get.offAllNamed(Routes.DASHBOARD_SCREEN),
                                          child: TextCustom(title: 'Dashboard'.tr, fontSize: 14, fontFamily: AppThemeData.medium, color: AppThemData.greyShade500)),
                                      const TextCustom(title: ' / ', fontSize: 14, fontFamily: AppThemeData.medium, color: AppThemData.greyShade500),
                                      GestureDetector(
                                          onTap: () {
                                            Get.back();
                                            controller.setDefaultData();
                                          },
                                          child: TextCustom(title: 'All Zone'.tr, fontSize: 14, fontFamily: AppThemeData.medium, color: AppThemData.greyShade500)),
                                      const TextCustom(title: ' / ', fontSize: 14, fontFamily: AppThemeData.medium, color: AppThemData.greyShade500),
                                      TextCustom(title: ' ${controller.title.value} ', fontSize: 14, fontFamily: AppThemeData.medium, color: AppThemData.primary500)
                                    ])
                                  ]),
                                ],
                              ),
                              spaceH(height: 20),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Flexible(
                                    flex: 2,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        TextCustom(
                                          title: "Instructions".tr,
                                          fontSize: 16,
                                          fontFamily: AppThemeData.bold,
                                        ),
                                        spaceH(height: 16),
                                        TextCustom(
                                          title: "Allow User to define the boundary of the business zone interactively on the map by clicking to add points or dots.".tr,
                                          fontSize: 14,
                                          fontFamily: AppThemeData.regular,
                                          maxLine: 3,
                                          color: themeChange.isDarkTheme() ? AppThemData.greyShade300 : AppThemData.greyShade700,
                                        ),
                                        spaceH(height: 16),
                                        Row(
                                          children: [
                                            Container(
                                              decoration: const BoxDecoration(
                                                color: AppThemData.primary500,
                                              ),
                                              child: const Padding(
                                                padding: EdgeInsets.all(4.0),
                                                child: Icon(
                                                  Icons.add_circle,
                                                  color: Colors.white,
                                                  size: 20,
                                                ),
                                              ),
                                            ),
                                            spaceW(width: 6),
                                            Expanded(
                                              child: TextCustom(
                                                title: "Use the 'Shape Tool' to highlight areas and connect the dots. A minimum of three points/dots required.".tr,
                                                fontSize: 14,
                                                fontFamily: AppThemeData.regular,
                                                maxLine: 2,
                                                color: themeChange.isDarkTheme() ? AppThemData.greyShade300 : AppThemData.greyShade700,
                                              ),
                                            ),
                                          ],
                                        ),
                                        spaceH(height: 16),
                                        Row(
                                          children: [
                                            Container(
                                              decoration: const BoxDecoration(
                                                color: AppThemData.primary500,
                                              ),
                                              child: const Padding(
                                                padding: EdgeInsets.all(4.0),
                                                child: Icon(
                                                  Icons.delete,
                                                  color: Colors.white,
                                                  size: 20,
                                                ),
                                              ),
                                            ),
                                            spaceW(width: 6),
                                            TextCustom(
                                              title: "Use the 'Trash Tool' to remove the selected Area.".tr,
                                              fontSize: 14,
                                              fontFamily: AppThemeData.regular,
                                              color: themeChange.isDarkTheme() ? AppThemData.greyShade300 : AppThemData.greyShade700,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  spaceW(width: 32),
                                  Flexible(
                                    flex: 3,
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            SizedBox(
                                              width: 0.25.sw,
                                              child: CustomTextFormField(
                                                hintText: "Enter Zone Name".tr,
                                                controller: controller.zoneController.value,
                                                title: "Zone Name".tr,
                                                inputFormatters: [
                                                  FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9\s]')),
                                                ],
                                              ),
                                            ),
                                            spaceW(width: 10),
                                            Column(
                                              children: [
                                                TextCustom(title: "Status".tr),
                                                spaceH(height: 4),
                                                Transform.scale(
                                                  scale: 0.8,
                                                  child: CupertinoSwitch(
                                                    activeTrackColor: AppThemData.primary500,
                                                    value: controller.isActive.value,
                                                    onChanged: (value) {
                                                      controller.isActive.value = value;
                                                    },
                                                  ),
                                                ),
                                              ],
                                            )
                                          ],
                                        ),
                                        spaceH(height: 12),
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            SizedBox(
                                              width: 0.4.sw,
                                              height: 0.3.sw,
                                              child: Stack(
                                                children: [
                                                  Constant.selectedMap == "Google Map"
                                                      ? GoogleMap(
                                                          onMapCreated: (GoogleMapController googleMapController) {
                                                            controller.googleMapController = googleMapController;
                                                            if (controller.polygonCoords.isNotEmpty) {
                                                              controller.moveCameraToPolygon();
                                                            }
                                                          },
                                                          initialCameraPosition: CameraPosition(
                                                            target: Constant.currentPosition != null
                                                                ? LatLng(Constant.currentPosition!.latitude, Constant.currentPosition!.longitude)
                                                                : const LatLng(0, 0),
                                                            zoom: 13,
                                                          ),
                                                          polygons: controller.polygons.toSet(),
                                                          markers: controller.markers,
                                                          onTap: controller.addPolygon,
                                                          myLocationEnabled: true,
                                                          zoomControlsEnabled: true,
                                                          mapType: MapType.normal,
                                                        )
                                                      : osm.FlutterMap(
                                                          mapController: controller.osmMapController,
                                                          options: osm.MapOptions(
                                                            initialCenter: Constant.currentPosition != null
                                                                ? osmLatLng.LatLng(
                                                                    Constant.currentPosition!.latitude,
                                                                    Constant.currentPosition!.longitude,
                                                                  )
                                                                : const osmLatLng.LatLng(0, 0),
                                                            initialZoom: 13,
                                                            interactionOptions: const osm.InteractionOptions(
                                                              flags: osm.InteractiveFlag.drag |
                                                                  osm.InteractiveFlag.pinchZoom |
                                                                  osm.InteractiveFlag.doubleTapZoom |
                                                                  osm.InteractiveFlag.scrollWheelZoom |
                                                                  osm.InteractiveFlag.flingAnimation,
                                                            ),
                                                            onTap: (tapPosition, point) {
                                                              controller.addPolygonOSM(point);
                                                            },
                                                            onMapReady: () {
                                                              controller.isOsmMapReady.value = true;
                                                            },
                                                          ),
                                                          children: [
                                                            osm.TileLayer(
                                                              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                                            ),
                                                            Obx(() {
                                                              if (controller.osmPolygonCoords.isEmpty) {
                                                                return const SizedBox();
                                                              }
                                                              return osm.PolygonLayer(
                                                                polygons: [
                                                                  osm.Polygon(
                                                                    points: controller.osmPolygonCoords,
                                                                    borderColor: Colors.black,
                                                                    borderStrokeWidth: 3,
                                                                    color: Colors.black.withOpacity(0.2),
                                                                  ),
                                                                ],
                                                              );
                                                            }),
                                                            Obx(() {
                                                              return osm.MarkerLayer(
                                                                markers: controller.osmPolygonCoords.map((point) {
                                                                  return osm.Marker(
                                                                    point: point,
                                                                    width: 40,
                                                                    height: 40,
                                                                    child: const Icon(
                                                                      Icons.location_on,
                                                                      color: Colors.red,
                                                                      size: 30,
                                                                    ),
                                                                  );
                                                                }).toList(),
                                                              );
                                                            }),
                                                          ],
                                                        ),
                                                  Center(child: Icon(Icons.location_pin, size: 40, color: AppThemData.primary500)),
                                                  Positioned(
                                                    top: 10,
                                                    left: 10,
                                                    right: 10,
                                                    child: Column(
                                                      children: [
                                                        TextFormField(
                                                          controller: controller.searchController,
                                                          style: TextStyle(color: themeChange.isDarkTheme() ? AppThemData.greyShade300 : AppThemData.greyShade700),
                                                          decoration: InputDecoration(
                                                            filled: true,
                                                            fillColor: themeChange.isDarkTheme() ? AppThemData.primaryBlack : AppThemData.primaryWhite,
                                                            hintText: 'Search place',
                                                            border: InputBorder.none,
                                                            contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                                                            hintStyle: TextStyle(
                                                              fontSize: 14,
                                                              fontFamily: AppThemeData.regular,
                                                              color: themeChange.isDarkTheme() ? AppThemData.greyShade300 : AppThemData.greyShade700,
                                                            ),
                                                            focusedBorder: OutlineInputBorder(
                                                              borderRadius: BorderRadius.circular(50),
                                                              borderSide: BorderSide.none,
                                                            ),
                                                            enabledBorder: OutlineInputBorder(
                                                              borderRadius: BorderRadius.circular(50),
                                                              borderSide: BorderSide.none,
                                                            ),
                                                            disabledBorder: OutlineInputBorder(
                                                              borderRadius: BorderRadius.circular(50),
                                                              borderSide: BorderSide.none,
                                                            ),
                                                          ),
                                                          onChanged: (value) {
                                                            if (kIsWeb) {
                                                              controller.fetchPredictions(value);
                                                            }
                                                          },
                                                        ),
                                                        Obx(() {
                                                          if (controller.predictions.isEmpty) return SizedBox();
                                                          return Container(
                                                            color: themeChange.isDarkTheme() ? AppThemData.greyShade900 : AppThemData.greyShade100,
                                                            child: ListView.builder(
                                                              shrinkWrap: true,
                                                              itemCount: controller.predictions.length,
                                                              itemBuilder: (context, index) {
                                                                final p = controller.predictions[index];
                                                                return ListTile(
                                                                  title: TextCustom(
                                                                    title: p['description'],
                                                                    fontSize: 16,
                                                                    fontFamily: AppThemeData.medium,
                                                                    color: themeChange.isDarkTheme() ? AppThemData.greyShade100 : AppThemData.greyShade900,
                                                                  ),
                                                                  onTap: () {
                                                                    controller.selectPrediction(p);
                                                                  },
                                                                );
                                                              },
                                                            ),
                                                          );
                                                        })
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            spaceW(width: 12),
                                            Column(
                                              children: [
                                                InkWell(
                                                  onTap: () => controller.addPolygon,
                                                  child: Container(
                                                    decoration: const BoxDecoration(
                                                      color: AppThemData.primary500,
                                                    ),
                                                    child: const Padding(
                                                      padding: EdgeInsets.all(4.0),
                                                      child: Icon(
                                                        Icons.add_circle,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                spaceH(height: 16),
                                                InkWell(
                                                  onTap: () => controller.clearPolygon(),
                                                  child: Container(
                                                    decoration: const BoxDecoration(
                                                      color: AppThemData.primary500,
                                                    ),
                                                    child: const Padding(
                                                      padding: EdgeInsets.all(4.0),
                                                      child: Icon(
                                                        Icons.delete,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        spaceH(height: 16),
                                        Align(
                                          alignment: Alignment.bottomRight,
                                          child: CustomButtonWidget(
                                            buttonTitle: "Save".tr,
                                            buttonColor: AppThemData.primary500,
                                            onPress: () {
                                              if (Constant.isDemo) {
                                                DialogBox.demoDialogBox();
                                              } else {
                                                if (controller.zoneController.value.text.isEmpty) {
                                                  ShowToastDialog.errorToast("Please Enter Zone name..".tr);
                                                } else {
                                                  controller.addZone();
                                                }
                                              }
                                            },
                                          ),
                                        )
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
                  ),
                ],
              ),
            ));
      },
    );
  }
}
