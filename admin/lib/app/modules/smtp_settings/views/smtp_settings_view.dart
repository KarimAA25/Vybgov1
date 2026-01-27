import 'package:admin/app/components/custom_button.dart';
import 'package:admin/app/components/custom_text_form_field.dart';
import 'package:admin/app/components/dialog_box.dart';
import 'package:admin/app/constant/constants.dart';
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
import '../controllers/smtp_settings_controller.dart';

class SmtpSettingsView extends GetView<SmtpSettingsController> {
  const SmtpSettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetBuilder<SmtpSettingsController>(
      init: SmtpSettingsController(),
      builder: (controller) {
        return SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ContainerCustom(
                child: controller.isLoading.value
                    ? Padding(
                        padding: paddingEdgeInsets(),
                        child: Constant.loader(),
                      )
                    : ResponsiveWidget.isDesktop(context)
                        ? Column(
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
                              spaceH(height: 20),
                              Padding(
                                  padding: paddingEdgeInsets(horizontal: 24, vertical: 24),
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(child: CustomTextFormField(title: "SMTP Host".tr, hintText: "Enter SMTP Host".tr, controller: controller.smtpHostController.value)),
                                          spaceW(width: 20),
                                          Expanded(child: CustomTextFormField(title: "SMTP Port".tr, hintText: "Enter SMTP Port".tr, controller: controller.smtpPortController.value)),
                                        ],
                                      ),
                                      spaceH(height: 12),
                                      Row(
                                        children: [
                                          Expanded(
                                              child: CustomTextFormField(
                                            title: "User Name".tr,
                                            hintText: "Enter User Name".tr,
                                            controller: controller.userNameController.value,
                                            obscureText: Constant.isDemo ? true : false,
                                          )),
                                          spaceW(width: 20),
                                          Expanded(
                                              child: CustomTextFormField(
                                            title: "Password".tr,
                                            hintText: "Enter Password".tr,
                                            controller: controller.passwordController.value,
                                            obscureText: Constant.isDemo ? true : false,
                                          )),
                                        ],
                                      ),
                                      spaceH(height: 12),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                TextCustom(
                                                  maxLine: 1,
                                                  title: "Encryption Type".tr,
                                                  fontFamily: AppThemeData.medium,
                                                  fontSize: 14,
                                                ),
                                                spaceH(),
                                                Obx(
                                                  () => DropdownButtonFormField(
                                                    isExpanded: true,
                                                    dropdownColor: themeChange.isDarkTheme() ? AppThemData.greyShade950 : AppThemData.greyShade50,
                                                    style: TextStyle(
                                                      fontFamily: AppThemeData.medium,
                                                      color: themeChange.isDarkTheme() ? AppThemData.greyShade100 : AppThemData.greyShade800,
                                                    ),
                                                    hint: TextCustom(title: 'Select EncryptionType Type'.tr),
                                                    onChanged: (String? encryptionType) {
                                                      controller.selectedEncryptionType.value = encryptionType ?? "SSL";
                                                    },
                                                    value: controller.selectedEncryptionType.value,
                                                    items: controller.encryptionType.map<DropdownMenuItem<String>>((String value) {
                                                      return DropdownMenuItem(
                                                        value: value,
                                                        child: TextCustom(
                                                          title: value,
                                                          fontFamily: AppThemeData.regular,
                                                          fontSize: 16,
                                                          color: themeChange.isDarkTheme() ? AppThemData.greyShade100 : AppThemData.greyShade800,
                                                        ),
                                                      );
                                                    }).toList(),
                                                    decoration: Constant.DefaultInputDecoration(context),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          spaceW(width: 20),
                                          Expanded(child: SizedBox())
                                        ],
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
                                  )),
                            ],
                          )
                        : Column(
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
                              spaceH(height: 20),
                              Padding(
                                padding: paddingEdgeInsets(horizontal: 24, vertical: 24),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    CustomTextFormField(title: "SMTP Host".tr, hintText: "Enter SMTP Host".tr, controller: controller.smtpHostController.value),
                                    spaceH(),
                                    CustomTextFormField(title: "SMTP Port".tr, hintText: "Enter SMTP Port".tr, controller: controller.smtpPortController.value),
                                    spaceH(),
                                    CustomTextFormField(
                                      title: "User Name".tr,
                                      hintText: "Enter User Name".tr,
                                      controller: controller.userNameController.value,
                                      obscureText: Constant.isDemo ? true : false,
                                    ),
                                    spaceH(),
                                    CustomTextFormField(
                                      title: "Password".tr,
                                      hintText: "Enter Password".tr,
                                      controller: controller.passwordController.value,
                                      obscureText: Constant.isDemo ? true : false,
                                    ),
                                    spaceH(),
                                    TextCustom(
                                      maxLine: 1,
                                      title: "Encryption Type".tr,
                                      fontFamily: AppThemeData.medium,
                                      fontSize: 14,
                                    ),
                                    spaceH(),
                                    Obx(
                                      () => DropdownButtonFormField(
                                        isExpanded: true,
                                        dropdownColor: themeChange.isDarkTheme() ? AppThemData.greyShade950 : AppThemData.greyShade50,
                                        style: TextStyle(
                                          fontFamily: AppThemeData.medium,
                                          color: themeChange.isDarkTheme() ? AppThemData.greyShade100 : AppThemData.greyShade800,
                                        ),
                                        hint: TextCustom(title: 'Select EncryptionType Type'.tr),
                                        onChanged: (String? encryptionType) {
                                          controller.selectedEncryptionType.value = encryptionType ?? "SSL";
                                        },
                                        value: controller.selectedEncryptionType.value,
                                        items: controller.encryptionType.map<DropdownMenuItem<String>>((String value) {
                                          return DropdownMenuItem(
                                            value: value,
                                            child: TextCustom(
                                              title: value,
                                              fontFamily: AppThemeData.regular,
                                              fontSize: 16,
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
              )
            ],
          ),
        );
      },
    );
  }
}
