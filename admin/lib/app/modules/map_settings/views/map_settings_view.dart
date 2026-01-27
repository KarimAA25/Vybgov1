import 'package:admin/app/components/custom_button.dart';
import 'package:admin/app/components/dialog_box.dart';
import 'package:admin/app/constant/constants.dart';
import 'package:admin/app/components/custom_text_form_field.dart';
import 'package:admin/app/utils/app_colors.dart';
import 'package:admin/app/utils/app_them_data.dart';
import 'package:admin/app/utils/dark_theme_provider.dart';
import 'package:admin/app/utils/responsive.dart';
import 'package:admin/widget/container_custom.dart';
import 'package:admin/widget/global_widgets.dart';
import 'package:admin/widget/text_widget.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../../routes/app_pages.dart';
import '../controllers/map_settings_controller.dart';

class MapSettingsView extends GetView<MapSettingsController> {
  const MapSettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);

    return GetBuilder(
      init: MapSettingsController(),
      builder: (controller) {
        return SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ContainerCustom(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextCustom(title: controller.title.value, fontSize: 20, fontFamily: AppThemeData.bold),
                            spaceH(height: 2),
                            Row(children: [
                              GestureDetector(
                                  onTap: () => Get.offAllNamed(Routes.DASHBOARD_SCREEN),
                                  child: TextCustom(title: 'Dashboard'.tr, fontSize: 14, fontFamily: AppThemeData.medium, color: AppThemData.greyShade500)),
                              const TextCustom(title: ' / ', fontSize: 14, fontFamily: AppThemeData.medium, color: AppThemData.greyShade500),
                              TextCustom(title: 'Settings'.tr, fontSize: 14, fontFamily: AppThemeData.medium, color: AppThemData.greyShade500),
                              const TextCustom(title: ' / ', fontSize: 14, fontFamily: AppThemeData.medium, color: AppThemData.greyShade500),
                              TextCustom(title: ' ${controller.title.value} ', fontSize: 14, fontFamily: AppThemeData.medium, color: AppThemData.primary500)
                            ])
                          ],
                        ),
                      ],
                    ),
                    spaceH(height: 20),
                    ResponsiveWidget.isDesktop(context)
                        ? Column(
                            children: [
                              Padding(
                                padding: paddingEdgeInsets(),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: CustomTextFormField(
                                        maxLine: 1,
                                        title: "Google Map Key".tr,
                                        hintText: "Enter google map key".tr,
                                        obscureText: Constant.isDemo ? true : false,
                                        prefix: const Icon(Icons.key),
                                        controller: controller.googleMapKeyController.value,
                                      ),
                                    ),
                                    spaceW(width: 24),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          TextCustom(
                                            title: "Type",
                                            maxLine: 1,
                                            fontSize: 14,
                                          ),
                                          spaceH(height: 10),
                                          Obx(
                                            () => DropdownButtonFormField(
                                              isExpanded: true,
                                              style: TextStyle(
                                                fontFamily: AppThemeData.medium,
                                                color: themeChange.isDarkTheme() ? AppThemData.greyShade100 : AppThemData.greyShade800,
                                              ),
                                              dropdownColor: themeChange.isDarkTheme() ? AppThemData.greyShade950 : AppThemData.greyShade50,
                                              hint: TextCustom(title: "Select Map Type".tr),
                                              onChanged: (String? mapType) {
                                                controller.selectMap.value = mapType ?? "Google Map";
                                              },
                                              value: controller.selectMap.value,
                                              items: controller.mapType.map<DropdownMenuItem<String>>((String value) {
                                                return DropdownMenuItem(
                                                  value: value,
                                                  child: TextCustom(
                                                    title: value.tr,
                                                    fontFamily: AppThemeData.regular,
                                                    fontSize: 14,
                                                    color: themeChange.isDarkTheme() ? AppThemData.greyShade100 : AppThemData.greyShade800,
                                                  ),
                                                );
                                              }).toList(),
                                              decoration: Constant.DefaultInputDecoration(context),
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              spaceH(height: 24),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  CustomButtonWidget(
                                    padding: const EdgeInsets.symmetric(horizontal: 22),
                                    buttonTitle: "Save".tr,
                                    onPress: () async {
                                      if (Constant.isDemo) {
                                        DialogBox.demoDialogBox();
                                      } else {
                                        controller.saveData();
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ],
                          )
                        : Padding(
                            padding: paddingEdgeInsets(),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CustomTextFormField(
                                  maxLine: 1,
                                  title: "Google Map Key".tr,
                                  hintText: "Enter google map key".tr,
                                  obscureText: Constant.isDemo ? true : false,
                                  prefix: const Icon(Icons.key),
                                  controller: controller.googleMapKeyController.value,
                                ),
                                spaceH(height: 16),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    TextCustom(
                                      title: "Type",
                                      maxLine: 1,
                                      fontSize: 14,
                                    ),
                                    spaceH(height: 10),
                                    Obx(
                                      () => DropdownButtonFormField(
                                        isExpanded: true,
                                        style: TextStyle(
                                          fontFamily: AppThemeData.medium,
                                          color: themeChange.isDarkTheme() ? AppThemData.greyShade100 : AppThemData.greyShade800,
                                        ),
                                        dropdownColor: themeChange.isDarkTheme() ? AppThemData.greyShade950 : AppThemData.greyShade50,
                                        hint: TextCustom(title: "Select Map Type".tr),
                                        onChanged: (String? mapType) {
                                          controller.selectMap.value = mapType ?? "Google Map";
                                        },
                                        value: controller.selectMap.value,
                                        items: controller.mapType.map<DropdownMenuItem<String>>((String value) {
                                          return DropdownMenuItem(
                                            value: value,
                                            child: TextCustom(
                                              title: value.tr,
                                              fontFamily: AppThemeData.regular,
                                              fontSize: 14,
                                              color: themeChange.isDarkTheme() ? AppThemData.greyShade100 : AppThemData.greyShade800,
                                            ),
                                          );
                                        }).toList(),
                                        decoration: Constant.DefaultInputDecoration(context),
                                      ),
                                    ),
                                  ],
                                ),
                                spaceH(height: 24),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: CustomButtonWidget(
                                    padding: const EdgeInsets.symmetric(horizontal: 22),
                                    buttonTitle: "Save".tr,
                                    onPress: () async {
                                      if (Constant.isDemo) {
                                        DialogBox.demoDialogBox();
                                      } else {
                                        controller.saveData();
                                      }
                                    },
                                  ),
                                ),
                              ],
                            ),
                          )
                  ],
                ),
              )
            ],
          ),
        );
      },
    );
  }
}
