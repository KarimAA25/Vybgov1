// ignore_for_file: deprecated_member_use

import 'package:driver/constant_widgets/round_shape_button.dart';
import 'package:driver/theme/app_them_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'osm_location_picker_controller.dart';

class OSMLocationPickerScreen extends StatelessWidget {
  const OSMLocationPickerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetX<OsmLocationPickerController>(
      init: OsmLocationPickerController(),
      builder: (controller) {
        if (controller.isLoading.value) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        return SafeArea(
          child: Scaffold(
            body: Stack(
              children: [
                FlutterMap(
                  mapController: controller.mapController,
                  options: MapOptions(
                    initialCenter: controller.currentLocation.value ?? const LatLng(20.59, 78.96),
                    initialZoom: 15,
                    minZoom: 2,
                    maxZoom: 100,
                    onPositionChanged: (mapPosition, hasGesture) {
                      if (!hasGesture) return; // only after gesture ends
                      final center = mapPosition.center;
                      if (center != controller.selectedLocation.value) {
                        controller.onMapMoved(center);
                      }
                    },
                  ),
                  children: [
                    TileLayer(urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png"),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: controller.selectedLocation.value ?? controller.currentLocation.value ?? const LatLng(20.59, 78.96),
                          width: 50,
                          height: 50,
                          child: const Icon(Icons.location_pin, color: Colors.red, size: 40),
                        ),
                      ],
                    ),
                    Positioned(
                      top: 10,
                      left: 10,
                      right: 10,
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: controller.locationController,
                                  style: const TextStyle(color: Colors.white),
                                  decoration: InputDecoration(
                                    fillColor: Colors.black,
                                    filled: true,
                                    hintText: 'Search location',
                                    hintStyle: const TextStyle(color: Colors.white70),
                                    isDense: true,
                                    contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                                    prefixIcon: IconButton(
                                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                                      onPressed: () {
                                        Get.back();
                                      },
                                    ),
                                    suffixIcon: IconButton(
                                      icon: const Icon(Icons.close, color: Colors.white),
                                      onPressed: controller.resetMap,
                                    ),
                                  ),
                                  onChanged: (value) => controller.onSearchChanged(value),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Positioned(
                  bottom: 40,
                  left: 20,
                  right: 20,
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 5)],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Obx(
                          () => Text(
                            controller.address.value,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.w500),
                          ),
                        ),
                        const SizedBox(height: 10),
                        // GestureDetector(
                        //   onTap: () {
                        //     controller.confirmLocation();
                        //     print("Location confirmed: ${controller.address.value}");
                        //   },
                        //   child: Container(
                        //     padding: const EdgeInsets.symmetric(vertical: 12),
                        //     width: double.infinity,
                        //     decoration: BoxDecoration(
                        //       borderRadius: BorderRadius.circular(12),
                        //       color: Colors.blue, // button color
                        //     ),
                        //     child: const Center(
                        //       child: Text(
                        //         "Confirm Location",
                        //         style: TextStyle(
                        //           color: Colors.white,
                        //           fontSize: 16,
                        //           fontWeight: FontWeight.bold,
                        //         ),
                        //       ),
                        //     ),
                        //   ),
                        // ),
                        RoundShapeButton(
                          title: "Confirm Location".tr,
                          buttonColor: AppThemData.primary500,
                          buttonTextColor: AppThemData.black,
                          onTap: () {
                            controller.confirmLocation();
                          },
                            size: Size(190, 45)
                        )
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: 65,
                  left: 10,
                  right: 10,
                  child: Obx(() {
                    if (controller.suggestions.isEmpty || controller.locationController.text.isEmpty) {
                      return const SizedBox();
                    }
                    return Container(
                      decoration: BoxDecoration(color: Colors.black.withOpacity(0.9), borderRadius: BorderRadius.circular(10)),
                      constraints: BoxConstraints(maxHeight: Get.height * 0.5),
                      child: ListView.builder(
                        shrinkWrap: true,
                        padding: EdgeInsets.zero,
                        itemCount: controller.suggestions.length,
                        itemBuilder: (context, index) {
                          final suggestion = controller.suggestions[index];
                          return ListTile(
                            dense: true,
                            title: Text(suggestion.displayName, style: const TextStyle(color: Colors.white, fontSize: 14)),
                            onTap: () {
                              controller.selectSuggestion(suggestion);
                            },
                          );
                        },
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
