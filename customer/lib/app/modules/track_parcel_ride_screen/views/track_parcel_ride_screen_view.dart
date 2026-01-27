// ignore_for_file: deprecated_member_use

import 'package:customer/constant/booking_status.dart';
import 'package:customer/constant/constant.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:customer/theme/app_them_data.dart';
import 'package:customer/theme/responsive.dart';
import 'package:customer/utils/dark_theme_provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../controllers/track_parcel_ride_screen_controller.dart';
import 'package:latlong2/latlong.dart' as latlang;
import 'package:flutter_map/flutter_map.dart' as osm;

class TrackParcelRideScreenView extends GetView<TrackParcelRideScreenController> {
  const TrackParcelRideScreenView({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);

    return GetX(
        init: TrackParcelRideScreenController(),
        builder: (controller) {
          return Scaffold(
            backgroundColor: themeChange.isDarkTheme() ? AppThemData.black : AppThemData.white,
            extendBodyBehindAppBar: true,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              // automaticallyImplyLeading: false,
              leading: InkWell(
                onTap: () {
                  Get.back();
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
                ? Constant.loader()
                : Stack(
                    children: [
                      SizedBox(
                        height: Responsive.height(100, context),
                        child: Constant.selectedMap == "Google Map"
                            ? GoogleMap(
                                initialCameraPosition: CameraPosition(
                                  target: LatLng(
                                    controller.bookingModel.value.pickUpLocation!.latitude ?? 0.0,
                                    controller.bookingModel.value.pickUpLocation!.longitude ?? 0.0,
                                  ),
                                  zoom: 14,
                                ),
                                polylines: Set<Polyline>.of(controller.polyLines.values),
                                markers: Set<Marker>.of(controller.markers.values),
                                onMapCreated: (mapController) {
                                  controller.mapController = mapController;
                                },
                              )
                            : osm.FlutterMap(
                                mapController: controller.osmMapController,
                                options: osm.MapOptions(
                                  initialCenter: latlang.LatLng(
                                    controller.bookingModel.value.pickUpLocation!.latitude ?? 0.0,
                                    controller.bookingModel.value.pickUpLocation!.longitude ?? 0.0,
                                  ),
                                  initialZoom: 14,
                                ),
                                children: [
                                  osm.TileLayer(
                                    urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                                  ),
                                  if (controller.osmMarkers.isNotEmpty) osm.MarkerLayer(markers: controller.osmMarkers),
                                  if (controller.osmRoute.isNotEmpty)
                                    osm.PolylineLayer(
                                      polylines: [
                                        osm.Polyline(
                                          points: controller.osmRoute.toList(),
                                          color: AppThemData.primary500,
                                          strokeWidth: 5,
                                        ),
                                      ],
                                    ),
                                ],
                              ),
                      ),

                      /// ✅ ETA Floating Card
                      Positioned(
                        bottom: 24,
                        left: 20,
                        right: 20,
                        child: Obx(() {
                          String nextStop = "";

                          if (controller.bookingModel.value.bookingStatus == BookingStatus.bookingAccepted) {
                            nextStop = "Driver is on the way to pick up your parcel";
                          } else if (controller.bookingModel.value.bookingStatus == BookingStatus.bookingOngoing ||
                              controller.bookingModel.value.bookingStatus == BookingStatus.bookingOnHold) {
                            nextStop = "Heading to delivery location";
                          } else if (controller.bookingModel.value.bookingStatus == BookingStatus.bookingCompleted) {
                            nextStop = "Parcel delivered";
                          } else {
                            nextStop = "Ride in progress";
                          }
                          double remainingMeters = 0;
                          if (Constant.selectedMap == "Google Map" && controller.polyLines.isNotEmpty) {
                            final points = controller.polyLines.values.first.points;
                            for (int i = 0; i < points.length - 1; i++) {
                              remainingMeters += controller.calculateDistanceMeters(
                                points[i].latitude,
                                points[i].longitude,
                                points[i + 1].latitude,
                                points[i + 1].longitude,
                              );
                            }
                          } else if (Constant.selectedMap != "Google Map" && controller.osmRoute.isNotEmpty) {
                            final points = controller.osmRoute;
                            for (int i = 0; i < points.length - 1; i++) {
                              remainingMeters += controller.calculateDistanceMeters(
                                points[i].latitude,
                                points[i].longitude,
                                points[i + 1].latitude,
                                points[i + 1].longitude,
                              );
                            }
                          }
                          final remainingKm = (remainingMeters / 1000).toStringAsFixed(1);
                          final etaTime = DateTime.now().add(Duration(minutes: controller.etaInMinutes.value));
                          return Container(
                            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
                            decoration: BoxDecoration(
                              color: themeChange.isDarkTheme() ? AppThemData.black : AppThemData.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 10,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  height: 42,
                                  width: 42,
                                  decoration: BoxDecoration(
                                    color: AppThemData.primary500.withOpacity(0.15),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.access_time,
                                    color: AppThemData.primary500,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Estimated Arrival",
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: themeChange.isDarkTheme() ? Colors.white70 : Colors.black54,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      "${controller.etaInMinutes.value} min (${DateFormat.jm().format(etaTime)})",
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: themeChange.isDarkTheme() ? Colors.white : Colors.black,
                                      ),
                                    ),
                                    Text(
                                      nextStop,
                                      style: TextStyle(fontSize: 12, color: Colors.grey),
                                    ),
                                    Text(
                                      "Remaining Distance: $remainingKm km",
                                      style: TextStyle(fontSize: 12, color: Colors.grey),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        }),
                      )
                    ],
                  ),
          );
        });
  }
}
