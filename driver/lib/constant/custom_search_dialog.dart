// ignore_for_file: use_build_context_synchronously

import 'package:driver/app/models/vehicle_brand_model.dart';
import 'package:driver/app/models/vehicle_model_model.dart';
import 'package:driver/app/modules/update_vehicle_details/controllers/update_vehicle_details_controller.dart';
import 'package:driver/theme/app_them_data.dart';
import 'package:driver/theme/responsive.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomSearchDialog {
  static Future vehicleBrandSearchDialog({required Color bgColor, required BuildContext context, required String title, required List<VehicleBrandModel> list, themeChange}) {
    RxList<VehicleBrandModel> localList = list.obs;
    UpdateVehicleDetailsController controller = Get.put(UpdateVehicleDetailsController());
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: bgColor,
            contentPadding: const EdgeInsets.all(12),
            insetPadding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: const Icon(Icons.close))
              ],
            ),
            content: SingleChildScrollView(
              child: SizedBox(
                width: Responsive.width(100, context),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CupertinoSearchTextField(
                      cursorColor: AppThemData.primary500,
                      style: GoogleFonts.inter(
                        color: themeChange.isDarkTheme() ? AppThemData.white : AppThemData.black,
                      ),
                      placeholderStyle: GoogleFonts.inter(color: AppThemData.grey500),
                      prefixIcon: Icon(CupertinoIcons.search, color: AppThemData.grey500),
                      onChanged: (value) {
                        List<VehicleBrandModel> tempList = [];
                        tempList = list.where((element) => element.title!.toLowerCase().contains(value.toLowerCase())).toList();
                        localList.clear();
                        localList.addAll(tempList);
                      },
                    ),
                    Obx(
                      () => Column(
                          children: localList
                              .map((e) => InkWell(
                                    onTap: () async {
                                      controller.selectedBrandModel.value = e;
                                      controller.vehicleBrandController.text = e.title.toString();
                                      await controller.getVehicleModel(e.id.toString());
                                      Navigator.pop(context);
                                    },
                                    child: ListTile(
                                      title: Text(e.title.toString()),
                                    ),
                                  ))
                              .toList()),
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }

  static Future vehicleModelSearchDialog({required Color bgColor, required BuildContext context, required String title, required List<VehicleModelModel> list, themeChange}) {
    RxList<VehicleModelModel> localList = list.obs;
    UpdateVehicleDetailsController controller = Get.put(UpdateVehicleDetailsController());
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: bgColor,
            contentPadding: const EdgeInsets.all(12),
            insetPadding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: const Icon(Icons.close))
              ],
            ),
            content: SingleChildScrollView(
              child: SizedBox(
                width: Responsive.width(100, context),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CupertinoSearchTextField(
                      cursorColor: AppThemData.primary500,
                      style: GoogleFonts.inter(
                        color: themeChange.isDarkTheme() ? AppThemData.white : AppThemData.black,
                      ),
                      placeholderStyle: GoogleFonts.inter(color: AppThemData.grey500),
                      prefixIcon: Icon(CupertinoIcons.search, color: AppThemData.grey500),
                      onChanged: (value) {
                        List<VehicleModelModel> tempList = [];
                        tempList = list.where((element) => element.title!.toLowerCase().contains(value.toLowerCase())).toList();
                        localList.clear();
                        localList.addAll(tempList);
                      },
                    ),
                    Obx(
                      () => Column(
                          children: localList
                              .map((e) => InkWell(
                                    onTap: () async {
                                      controller.selectedVehicleModelModel.value = e;
                                      controller.vehicleModelController.text = e.title.toString();
                                      Navigator.pop(context);
                                    },
                                    child: ListTile(
                                      title: Text(e.title.toString()),
                                    ),
                                  ))
                              .toList()),
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }
}
