import 'package:customer/app/modules/rental_location/views/widgets/rental_select_location_bottom_sheet.dart';
import 'package:customer/app/modules/rental_location/views/widgets/rental_select_vehicle_type_bottom_sheet.dart';
import 'package:customer/constant/constant.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:customer/theme/app_them_data.dart';
import 'package:customer/theme/responsive.dart';
import 'package:customer/utils/dark_theme_provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:latlong2/latlong.dart' as latlang;
import 'package:flutter_map/flutter_map.dart' as osm;
import '../controllers/rental_select_location_controller.dart';
import 'widgets/rental_package.dart';

class RentalLocationView extends StatelessWidget {
  const RentalLocationView({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetX<RentalSelectLocationController>(
        init: RentalSelectLocationController(),
        builder: (controller) {
          if (controller.isLoading.value ||
              (Constant.selectedMap == "Google Map" && controller.googleSourceLocation == null) ||
              (Constant.selectedMap == "OSM Map" && controller.osmSourceLocation == null)) {
            return Scaffold(
              backgroundColor: themeChange.isDarkTheme() ? AppThemData.black : AppThemData.white,
              body: const Center(child: CircularProgressIndicator()),
            );
          }
          return Scaffold(
            backgroundColor: themeChange.isDarkTheme() ? AppThemData.black : AppThemData.white,
            extendBodyBehindAppBar: true,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              // automaticallyImplyLeading: false,
              leading: InkWell(
                onTap: () {
                  if (controller.bookingId.value.isEmpty) {
                    if (controller.popupIndex.value == 0) {
                      Get.back();
                    } else if (controller.popupIndex.value == 2) {
                      controller.popupIndex.value = 1;
                    } else {
                      controller.popupIndex.value = 0;
                      controller.pickUpFocusNode.requestFocus();
                    }
                  } else {
                    Get.back();
                  }
                },
                child: Container(
                  height: 42,
                  width: 42,
                  decoration: BoxDecoration(color: themeChange.isDarkTheme() ? AppThemData.black : AppThemData.white, shape: BoxShape.circle),
                  margin: EdgeInsets.only(left: 16),
                  padding: const EdgeInsets.all(8),
                  child: Icon(
                    Icons.arrow_back,
                    color: themeChange.isDarkTheme() ? AppThemData.white : AppThemData.black,
                  ),
                ),
              ),
            ),
            body: controller.isLoading.value
                ? const Center(child: CircularProgressIndicator())
                : Stack(
                    children: [
                      SizedBox(
                          height: Responsive.height(80, context),
                          child: Obx(
                            () {
                              if (Constant.selectedMap == "Google Map") {
                                return GoogleMap(
                                  initialCameraPosition: CameraPosition(
                                    target: LatLng(controller.googleSourceLocation!.latitude, controller.googleSourceLocation!.longitude),
                                    zoom: 5,
                                  ),
                                  padding: const EdgeInsets.only(
                                    top: 22.0,
                                  ),
                                  polylines: Set<Polyline>.of(controller.polyLines.values),
                                  markers: Set<Marker>.of(controller.googleMarkers.values),
                                  onMapCreated: (GoogleMapController mapController) {
                                    controller.googleMapController = mapController;
                                    controller.addMarker(
                                      latitude: controller.googleSourceLocation!.latitude,
                                      longitude: controller.googleSourceLocation!.longitude,
                                      id: "pickUp",
                                      descriptor: controller.pickUpIcon!,
                                      rotation: 0
                                    );
                                    controller.googleMapController!.animateCamera(
                                      CameraUpdate.newLatLngZoom(controller.googleSourceLocation!, 15),
                                    );
                                  },
                                );
                              } else {
                                return osm.FlutterMap(
                                  mapController: controller.osmMapController,
                                  options: osm.MapOptions(
                                    initialCenter: latlang.LatLng(controller.osmSourceLocation?.latitude ?? 20.59, controller.osmSourceLocation?.longitude ?? 78.96),
                                    initialZoom: 14,
                                  ),
                                  children: [
                                    osm.TileLayer(urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png'),
                                    if (controller.osmPolylinePoints.isNotEmpty)
                                      osm.PolylineLayer(
                                        polylines: [
                                          osm.Polyline(
                                            points: controller.osmPolylinePoints.toList(),
                                            strokeWidth: 4,
                                            color: AppThemData.primary500,
                                          )
                                        ],
                                      ),
                                    osm.MarkerLayer(markers: controller.osmMarkers.toList()),
                                  ],
                                );
                              }
                            },
                          )),
                      if (controller.popupIndex.value == 0) ...{
                        DraggableScrollableSheet(
                          initialChildSize: 0.60,
                          snapSizes: const [0.31, 0.35, 0.40, 0.45, 0.50, 0.55, 0.60, 0.70],
                          minChildSize: 0.31,
                          maxChildSize: 0.70,
                          snap: true,
                          expand: true,
                          builder: (BuildContext context, ScrollController scrollController) {
                            return RentalSelectLocationBottomSheet(
                              scrollController: scrollController,
                            );
                          },
                        ),
                      },
                      if (controller.popupIndex.value == 1) ...{
                        DraggableScrollableSheet(
                          initialChildSize: 0.50,
                          snapSizes: const [0.31, 0.35, 0.40, 0.45, 0.50, 0.55, 0.60],
                          minChildSize: 0.31,
                          maxChildSize: 0.60,
                          snap: true,
                          expand: true,
                          builder: (BuildContext context, ScrollController scrollController) {
                            return RentalSelectVehicleTypeBottomSheet(
                              scrollController: scrollController,
                            );
                          },
                        ),
                      },
                      if (controller.popupIndex.value == 2) ...{
                        DraggableScrollableSheet(
                          initialChildSize: 0.70,
                          snapSizes: const [0.70],
                          minChildSize: 0.70,
                          maxChildSize: 0.70,
                          snap: true,
                          expand: true,
                          builder: (BuildContext context, ScrollController scrollController) {
                            return RentalPackageBottomSheet(scrollController: scrollController);
                          },
                        ),
                      },
                    ],
                  ),
          );
        });
  }
}
