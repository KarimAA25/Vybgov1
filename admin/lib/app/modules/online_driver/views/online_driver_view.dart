import 'package:admin/app/components/menu_widget.dart';
import 'package:admin/app/constant/constants.dart';
import 'package:admin/app/utils/responsive.dart';
import 'package:admin/widget/common_ui.dart';
import 'package:admin/widget/container_custom.dart';
import 'package:admin/widget/global_widgets.dart';
import 'package:admin/widget/text_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart' as osm;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:latlong2/latlong.dart' as osmLatLng;
import 'package:provider/provider.dart';
import 'package:admin/app/utils/app_colors.dart';
import 'package:admin/app/utils/app_them_data.dart';
import 'package:admin/app/utils/dark_theme_provider.dart';
import 'package:get/get.dart';

import '../../../routes/app_pages.dart';
import '../controllers/online_driver_controller.dart';

class OnlineDriverView extends GetView<OnlineDriverController> {
  const OnlineDriverView({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetX(
      init: OnlineDriverController(),
      builder: (controller) {
        return Scaffold(
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
            body: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (ResponsiveWidget.isDesktop(context)) ...{const MenuWidget()},
                Expanded(
                    child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: paddingEdgeInsets(),
                      child: ContainerCustom(
                        child: Column(
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
                                    TextCustom(title: ' ${controller.title.value} ', fontSize: 14, fontFamily: AppThemeData.medium, color: AppThemData.primary500)
                                  ])
                                ]),
                              ],
                            ),
                            spaceH(height: 20),
                            controller.isLoading.value
                                ? Padding(
                                    padding: paddingEdgeInsets(),
                                    child: Constant.loader(),
                                  )
                                : SizedBox(
                                    height: MediaQuery.of(context).size.height - 200,
                                    width: double.infinity,
                                    child: Constant.selectedMap == "Google Map"
                                        ? GoogleMap(
                                            onMapCreated: (GoogleMapController googleMapController) {
                                              controller.googleMapController = googleMapController;
                                            },
                                            initialCameraPosition: CameraPosition(
                                              target: Constant.currentPosition != null
                                                  ? LatLng(Constant.currentPosition!.latitude, Constant.currentPosition!.longitude)
                                                  : const LatLng(0, 0),
                                              zoom: 12,
                                            ),
                                            markers: controller.markers,
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
                                            ),
                                            children: [
                                              osm.TileLayer(
                                                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                              ),
                                              osm.MarkerLayer(
                                                markers: controller.osmMarkers,
                                              )
                                            ],
                                          ),
                                  ),
                          ],
                        ),
                      ),
                    )
                  ],
                ))
              ],
            ));
      },
    );
  }
}
