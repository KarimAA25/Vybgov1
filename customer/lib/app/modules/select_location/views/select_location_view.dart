import 'package:customer/constant/constant.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:customer/app/modules/select_location/views/widgets/finding_driver.dart';
import 'package:customer/app/modules/select_location/views/widgets/select_location_bottom_sheet.dart';
import 'package:customer/app/modules/select_location/views/widgets/select_vehicle_type_bottom_sheet.dart';
import 'package:customer/theme/app_them_data.dart';
import 'package:customer/utils/dark_theme_provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:latlong2/latlong.dart' as latlang;
import 'package:provider/provider.dart';
import 'package:flutter_map/flutter_map.dart' as osm;

import '../controllers/select_location_controller.dart';

class SelectLocationView extends StatelessWidget {
  const SelectLocationView({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetX(
        init: SelectLocationController(),
        builder: (controller) {
          return Scaffold(
            backgroundColor: themeChange.isDarkTheme() ? AppThemData.black : AppThemData.white,
            extendBodyBehindAppBar: true,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              leading: InkWell(
                onTap: () {
                  final bookingId = controller.bookingModel.value.id;
                  if (bookingId == null || bookingId.isEmpty) {
                    if (controller.popupIndex.value == 0) {
                      Get.back();
                    } else if (controller.popupIndex.value == 2) {
                      controller.popupIndex.value = 1;
                    } else {
                      controller.popupIndex.value = 0;
                      controller.dropFocusNode.requestFocus();
                    }
                  }
                  // ✅ Booking already exists
                  else {
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
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : Stack(
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height,
                        child: Obx(() {
                          if (Constant.selectedMap == "Google Map") {
                            return GoogleMap(
                              initialCameraPosition: CameraPosition(
                                target: controller.sourceLocation ?? LatLng(20.59, 78.96),
                                zoom: 10,
                              ),
                              markers: Set<Marker>.of(controller.markers.values),
                              polylines: Set<Polyline>.of(controller.polyLines.values),
                              onMapCreated: (mapController) {
                                controller.mapController = mapController;

                                if (controller.sourceLocation != null) {
                                  mapController.moveCamera(
                                    CameraUpdate.newLatLngZoom(controller.sourceLocation!, 14),
                                  );
                                }
                              },
                            );
                          } else {
                            return osm.FlutterMap(
                              mapController: controller.osmMapController,
                              options: osm.MapOptions(
                                initialCenter: controller.osmSourceLocation ?? latlang.LatLng(20.59, 78.96),
                                initialZoom: 14,
                              ),
                              children: [
                                osm.TileLayer(urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png'),
                                if (controller.osmPolyline.isNotEmpty)
                                  osm.PolylineLayer(
                                    polylines: [
                                      osm.Polyline(
                                        points: controller.osmPolyline.toList(),
                                        strokeWidth: 4,
                                        color: AppThemData.primary500,
                                      )
                                    ],
                                  ),
                                osm.MarkerLayer(markers: controller.osmMarkers.toList()),
                              ],
                            );
                          }
                        }),
                      ),
                      if (controller.popupIndex.value == 0) ...{
                        DraggableScrollableSheet(
                          initialChildSize: 0.60,
                          snapSizes: const [0.31, 0.35, 0.40, 0.45, 0.50, 0.55, 0.60, 0.70],
                          minChildSize: 0.31,
                          maxChildSize: 0.70,
                          snap: true,
                          expand: true,
                          builder: (BuildContext context, ScrollController scrollController) {
                            return SelectLocationBottomSheet(
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
                            return SelectVehicleTypeBottomSheet(
                              scrollController: scrollController,
                            );
                          },
                        ),
                      },
                      // if (controller.popupIndex.value == 2) ...{
                      //   DraggableScrollableSheet(
                      //     initialChildSize: 0.25,
                      //     snapSizes: const [0.21, 0.25, 0.30],
                      //     minChildSize: 0.21,
                      //     maxChildSize: 0.30,
                      //     snap: true,
                      //     expand: true,
                      //     builder: (BuildContext context, ScrollController scrollController) {
                      //       return ConfirmPickupBottomSheet(
                      //         scrollController: scrollController,
                      //       );
                      //     },
                      //   ),
                      // },
                      if (controller.popupIndex.value == 2) ...{
                        DraggableScrollableSheet(
                          initialChildSize: 0.70,
                          snapSizes: const [0.40, 0.45, 0.50, 0.55, 0.70],
                          minChildSize: 0.40,
                          maxChildSize: 0.70,
                          snap: true,
                          expand: true,
                          builder: (BuildContext context, ScrollController scrollController) {
                            return FindingDriverBottomSheet(
                              scrollController: scrollController,
                            );
                          },
                        ),
                      },
                    ],
                  ),
          );
        });
  }
}
