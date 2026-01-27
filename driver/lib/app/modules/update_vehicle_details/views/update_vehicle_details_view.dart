import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:driver/app/models/vehicle_type_model.dart';
import 'package:driver/constant/custom_search_dialog.dart';
import 'package:driver/constant_widgets/app_bar_with_border.dart';
import 'package:driver/constant_widgets/round_shape_button.dart';
import 'package:driver/constant_widgets/show_toast_dialog.dart';
import 'package:driver/constant_widgets/text_field_with_title.dart';
import 'package:driver/theme/app_them_data.dart';
import 'package:driver/theme/responsive.dart';
import 'package:driver/utils/dark_theme_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../controllers/update_vehicle_details_controller.dart';

class UpdateVehicleDetailsView extends StatelessWidget {
  final bool isUploaded;

  const UpdateVehicleDetailsView({super.key, required this.isUploaded});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetBuilder(
        init: UpdateVehicleDetailsController(),
        builder: (controller) {
          return Scaffold(
            backgroundColor: themeChange.isDarkTheme() ? AppThemData.black : AppThemData.white,
            appBar: isUploaded ? null : AppBarWithBorder(title: "Vehicle Details".tr, bgColor: themeChange.isDarkTheme() ? AppThemData.black : AppThemData.white),
            body: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Select Vehicle Type".tr,
                      style: GoogleFonts.inter(
                        color: themeChange.isDarkTheme() ? AppThemData.grey25 : AppThemData.grey950,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Container(
                      height: 60.0,
                      width: Responsive.width(100, context),
                      margin: const EdgeInsets.only(top: 16, bottom: 16),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: themeChange.isDarkTheme() ? AppThemData.grey800 : AppThemData.grey100,
                        ),
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: Obx(
                        () => DropdownButtonHideUnderline(
                          child: DropdownButton<VehicleTypeModel>(
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              color: themeChange.isDarkTheme() ? AppThemData.white : AppThemData.grey950,
                            ),
                            hint: Text(
                              "  Select Vehicle Type".tr,
                              style: GoogleFonts.inter(
                                color: themeChange.isDarkTheme() ? AppThemData.grey300 : AppThemData.grey950,
                                fontSize: 16,
                              ),
                            ),
                            itemHeight: 70,
                            dropdownColor: themeChange.isDarkTheme() ? AppThemData.black : AppThemData.white,
                            padding: const EdgeInsets.only(right: 12),
                            selectedItemBuilder: (context) {
                              return controller.vehicleTypeList.map((VehicleTypeModel value) {
                                return Padding(
                                  padding: const EdgeInsets.only(left: 12, right: 12),
                                  child: Row(
                                    children: [
                                      Image.network(
                                        value.image.toString(),
                                        height: 42,
                                        width: 42,
                                      ),
                                      const SizedBox(width: 15),
                                      Text(value.title.toString()),
                                    ],
                                  ),
                                );
                              }).toList();
                            },
                            items: controller.vehicleTypeList.map<DropdownMenuItem<VehicleTypeModel>>((VehicleTypeModel value) {
                              return DropdownMenuItem(
                                value: value,
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        Image.network(
                                          value.image.toString(),
                                          height: 42,
                                          width: 42,
                                        ),
                                        const SizedBox(width: 15),
                                        Text(value.title.toString()),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    Visibility(
                                      visible: controller.vehicleTypeList.indexOf(value) != (controller.vehicleTypeList.length - 1),
                                      child: const Divider(),
                                    )
                                  ],
                                ),
                              );
                            }).toList(),
                            borderRadius: BorderRadius.circular(12),
                            isExpanded: false,
                            isDense: false,
                            onChanged: (VehicleTypeModel? newSelectedType) {
                              if (newSelectedType != null) {
                                controller.selectedVehicleTypeModel.value = newSelectedType;
                              }
                            },
                            value: controller.selectedVehicleTypeModel.value.id == null ? null : controller.selectedVehicleTypeModel.value,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "Select Zones".tr,
                      style: GoogleFonts.inter(
                        color: themeChange.isDarkTheme() ? AppThemData.grey25 : AppThemData.grey950,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Container(
                      height: 52.0,
                      width: Responsive.width(100, context),
                      margin: const EdgeInsets.only(top: 16, bottom: 16),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: themeChange.isDarkTheme() ? AppThemData.grey800 : AppThemData.grey100,
                        ),
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12.0),
                        onTap: () async {
                          List<String> tempSelectedZoneIds = List.from(controller.selectedZoneIds);

                          await showDialog(
                            context: context,
                            builder: (_) {
                              return StatefulBuilder(
                                builder: (context, setState) {
                                  return AlertDialog(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    title: Text("Select Zones".tr),
                                    content: SizedBox(
                                      width: double.maxFinite,
                                      child: ListView.builder(
                                        shrinkWrap: true,
                                        itemCount: controller.zoneList.length,
                                        itemBuilder: (context, index) {
                                          final zone = controller.zoneList[index];
                                          return CheckboxListTile(
                                            value: tempSelectedZoneIds.contains(zone.id),
                                            onChanged: (val) {
                                              setState(() {
                                                if (val == true) {
                                                  tempSelectedZoneIds.add(zone.id ?? '');
                                                } else {
                                                  tempSelectedZoneIds.remove(zone.id ?? '');
                                                }
                                              });
                                            },
                                            title: Text(zone.name ?? ''),
                                          );
                                        },
                                      ),
                                    ),
                                    actions: [
                                      RoundShapeButton(
                                        title: "Save".tr,
                                        buttonColor: AppThemData.primary500,
                                        buttonTextColor: AppThemData.black,
                                        onTap: () {
                                          controller.selectedZoneIds.value = tempSelectedZoneIds;
                                          Navigator.pop(context);
                                        },
                                        size: const Size(100, 35),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                          );
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Obx(() {
                                if (controller.selectedZoneIds.isEmpty) {
                                  return Text(
                                    "Select Zones".tr,
                                    style: GoogleFonts.inter(
                                      color: themeChange.isDarkTheme() ? AppThemData.grey300 : AppThemData.grey950,
                                      fontSize: 16,
                                    ),
                                  );
                                } else {
                                  final selectedZones = controller.zoneList.where((z) => controller.selectedZoneIds.contains(z.id)).map((z) => z.name ?? '').join(", ");
                                  return Text(
                                    selectedZones,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.inter(
                                      color: themeChange.isDarkTheme() ? AppThemData.white : AppThemData.grey950,
                                      fontSize: 16,
                                    ),
                                  );
                                }
                              }),
                            ),
                            Icon(
                              Icons.arrow_drop_down,
                              color: themeChange.isDarkTheme() ? AppThemData.white : AppThemData.grey950,
                            ),
                          ],
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        CustomSearchDialog.vehicleBrandSearchDialog(
                            bgColor: themeChange.isDarkTheme() ? AppThemData.black : AppThemData.white,
                            context: context,
                            title: "Search Vehicle Brand".tr,
                            list: controller.vehicleBrandList,
                            themeChange: themeChange);
                      },
                      child: TextFieldWithTitle(
                        title: "Vehicle Brand".tr,
                        hintText: "Select Vehicle Brand".tr,
                        keyboardType: TextInputType.text,
                        controller: controller.vehicleBrandController,
                        isEnable: false,
                      ),
                    ),
                    const SizedBox(height: 16),
                    InkWell(
                      onTap: () {
                        CustomSearchDialog.vehicleModelSearchDialog(
                            bgColor: themeChange.isDarkTheme() ? AppThemData.black : AppThemData.white,
                            context: context,
                            title: "Search Vehicle Model".tr,
                            list: controller.vehicleModelList,
                            themeChange: themeChange);
                      },
                      child: TextFieldWithTitle(
                        title: "Vehicle Model".tr,
                        hintText: "Select Vehicle Model".tr,
                        keyboardType: TextInputType.text,
                        controller: controller.vehicleModelController,
                        isEnable: false,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFieldWithTitle(
                      title: "Vehicle Number".tr,
                      hintText: "Enter Vehicle Number".tr,
                      keyboardType: TextInputType.text,
                      controller: controller.vehicleNumberController,
                      isEnable: true,
                    ),
                    const SizedBox(height: 32),
                    Center(
                      child: RoundShapeButton(
                        title: "Submit".tr,
                        buttonColor: AppThemData.primary500,
                        buttonTextColor: AppThemData.black,
                        onTap: () {
                          if (controller.vehicleBrandController.text.isEmpty) {
                            ShowToastDialog.showToast("Please enter vehicle brand".tr);
                          } else if (controller.vehicleModelController.text.isEmpty) {
                            ShowToastDialog.showToast("Please enter vehicle model".tr);
                          } else if (controller.vehicleNumberController.text.isEmpty) {
                            ShowToastDialog.showToast("Please enter vehicle number".tr);
                          } else if (controller.selectedZoneIds.isEmpty) {
                            ShowToastDialog.showToast("Please select one zone".tr);
                          } else if (controller.selectedVehicleTypeModel.value.id == null) {
                            ShowToastDialog.showToast("Please select vehicle type".tr);
                          } else {
                            controller.saveVehicleDetails();
                          }
                        },
                        size: const Size(208, 52),
                      ),
                    )
                  ],
                ),
              ),
            ),
          );
        });
  }
}
