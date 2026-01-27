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

import '../controllers/track_rental_ride_screen_controller.dart';

class TrackRentalRideScreenView extends GetView<TrackRentalRideScreenController> {
  const TrackRentalRideScreenView({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);

    return GetX(
        init: TrackRentalRideScreenController(),
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
            body: SizedBox(
              height: Responsive.height(100, context),
              child: Constant.selectedMap == "Google Map"
                  ? GoogleMap(
                      initialCameraPosition: CameraPosition(
                        target: LatLng(controller.rentalModel.value.pickUpLocation?.latitude ?? 0.0, controller.rentalModel.value.pickUpLocation?.longitude ?? 0.0),
                        zoom: 14,
                      ),
                      padding: const EdgeInsets.only(
                        top: 22.0,
                      ),
                      polylines: Set<Polyline>.of(controller.polyLines.values),
                      markers: Set<Marker>.of(controller.markers.values),
                      onMapCreated: (GoogleMapController mapController) {
                        controller.mapController = mapController;
                      },
                    )
                  : osm.FlutterMap(
                      mapController: controller.osmMapController,
                      options: osm.MapOptions(
                        initialCenter: latlang.LatLng(controller.rentalModel.value.pickUpLocation?.latitude ?? 0.0, controller.rentalModel.value.pickUpLocation?.longitude ?? 0.0),
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
                              osm.Polyline(points: controller.osmRoute.toList(), color: AppThemData.primary500, strokeWidth: 5),
                            ],
                          ),
                      ],
                    ),
            ),
          );
        });
  }
}
