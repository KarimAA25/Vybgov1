// ignore_for_file: deprecated_member_use

import 'package:driver/constant/booking_status.dart';
import 'package:driver/constant/constant.dart';
import 'package:driver/constant_widgets/round_shape_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:driver/theme/app_them_data.dart';
import 'package:driver/theme/responsive.dart';
import 'package:driver/utils/dark_theme_provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:latlong2/latlong.dart' as latlang;
import 'package:flutter_map/flutter_map.dart' as osm;
import '../controllers/track_intercity_ride_screen_controller.dart';

class TrackIntercityRideScreenView extends GetView<TrackInterCityRideScreenController> {
  const TrackIntercityRideScreenView({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);

    return GetX(
        init: TrackInterCityRideScreenController(),
        builder: (controller) {
          return Scaffold(
            backgroundColor: themeChange.isDarkTheme() ? AppThemData.black : AppThemData.white,
            extendBodyBehindAppBar: true,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
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
                                    controller.intercityModel.value.pickUpLocation!.latitude ?? 0.0,
                                    controller.intercityModel.value.pickUpLocation!.longitude ?? 0.0,
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
                                    controller.intercityModel.value.pickUpLocation!.latitude ?? 0.0,
                                    controller.intercityModel.value.pickUpLocation!.longitude ?? 0.0,
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
                        bottom: 16,
                        left: 20,
                        right: 20,
                        child: Obx(() {
                          // Determine the next stop or status text
                          String nextStop = "";
                          final status = controller.intercityModel.value.bookingStatus;
                          final stops = controller.intercityModel.value.stops;

                          if (status == BookingStatus.bookingAccepted) {
                            nextStop = "Driver is on the way to pick you up";
                          } else if (stops != null && stops.isNotEmpty) {
                            nextStop = "Next Stop: ${stops.first.address ?? "Way Point"}";
                          } else if (status == BookingStatus.bookingOngoing || status == BookingStatus.bookingOnHold) {
                            nextStop = "Heading to your destination city";
                          } else if (status == BookingStatus.bookingCompleted) {
                            nextStop = "Ride completed";
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
                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
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
                              ),
                              SizedBox(height: 10),
                              RoundShapeButton(
                                  title: "Redirect to Google Map",
                                  buttonColor: AppThemData.primary500,
                                  buttonTextColor: AppThemData.black,
                                  onTap: () {
                                    controller.openGoogleMap();
                                  },
                                  size: Size(MediaQuery.of(context).size.width, 48))
                            ],
                          );
                        }),
                      )
                    ],
                  ),
          );
        });
  }
}
