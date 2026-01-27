import 'package:admin/app/components/custom_button.dart';
import 'package:admin/app/components/custom_text_form_field.dart';
import 'package:admin/app/components/dialog_box.dart';
import 'package:admin/app/constant/constants.dart';
import 'package:admin/app/modules/business_model_setting/controllers/business_model_setting_controller.dart';
import 'package:admin/app/utils/app_colors.dart';
import 'package:admin/app/utils/app_them_data.dart';
import 'package:admin/app/utils/dark_theme_provider.dart';
import 'package:admin/app/utils/responsive.dart';
import 'package:admin/app/utils/screen_size.dart';
import 'package:admin/widget/container_custom.dart';
import 'package:admin/widget/global_widgets.dart';
import 'package:admin/widget/text_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../../routes/app_pages.dart';

class BusinessModelSettingView extends GetView<BusinessModelSettingController> {
  const BusinessModelSettingView({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);

    return GetX<BusinessModelSettingController>(
        init: BusinessModelSettingController(),
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
                                crossAxisAlignment: CrossAxisAlignment.start,
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
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        TextCustom(
                                          title: "Admin Commission".tr.toUpperCase(),
                                          fontFamily: AppThemeData.bold,
                                          fontSize: 20,
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
                                                    title: "Commission Type".tr,
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
                                                      hint: TextCustom(title: 'Select Tax Type'.tr),
                                                      onChanged: (String? taxType) {
                                                        controller.selectedAdminCommissionType.value = taxType ?? "Fix";
                                                      },
                                                      value: controller.selectedAdminCommissionType.value,
                                                      items: controller.adminCommissionType.map<DropdownMenuItem<String>>((String value) {
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
                                                  spaceH(height: 16)
                                                ],
                                              ),
                                            ),
                                            spaceW(width: 16),
                                            Expanded(
                                              child: CustomTextFormField(
                                                  title: "Admin Commission".tr,
                                                  hintText: "Enter admin commission".tr,
                                                  inputFormatters: [
                                                    FilteringTextInputFormatter.allow(RegExp('[0-9.]')),
                                                  ],
                                                  prefix: Padding(
                                                    padding: paddingEdgeInsets(vertical: 10, horizontal: 10),
                                                    child: TextCustom(
                                                      title: '${Constant.currencyModel!.symbol}',
                                                      fontSize: 18,
                                                    ),
                                                  ),
                                                  controller: controller.adminCommissionController.value),
                                            ),
                                          ],
                                        ),
                                        Obx(
                                          () => Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              TextCustom(
                                                title: "Status".tr,
                                                fontSize: 14,
                                              ),
                                              const SizedBox(
                                                width: 20,
                                              ),
                                              Row(
                                                children: [
                                                  Row(
                                                    children: [
                                                      Radio(
                                                        value: Status.active,
                                                        groupValue: controller.isActiveAdminCommission.value,
                                                        onChanged: (value) {
                                                          controller.isActiveAdminCommission.value = value ?? Status.active;
                                                        },
                                                        activeColor: AppThemData.primary500,
                                                      ),
                                                      Text("Active".tr,
                                                          style: const TextStyle(
                                                            fontFamily: AppThemeData.regular,
                                                            fontSize: 16,
                                                            color: AppThemData.textGrey,
                                                          ))
                                                    ],
                                                  ),
                                                  spaceW(),
                                                  Row(
                                                    children: [
                                                      Radio(
                                                        value: Status.inactive,
                                                        groupValue: controller.isActiveAdminCommission.value,
                                                        onChanged: (value) {
                                                          controller.isActiveAdminCommission.value = value ?? Status.inactive;
                                                        },
                                                        activeColor: AppThemData.primary500,
                                                      ),
                                                      Text("Inactive".tr,
                                                          style: const TextStyle(
                                                            fontFamily: AppThemeData.regular,
                                                            fontSize: 16,
                                                            color: AppThemData.textGrey,
                                                          ))
                                                    ],
                                                  ),
                                                ],
                                              )
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    height: 1,
                                    child: ContainerCustom(
                                      color: themeChange.isDarkTheme() ? AppThemData.greyShade900 : AppThemData.greyShade100,
                                    ),
                                  ),
                                  Padding(
                                    padding: paddingEdgeInsets(horizontal: 24, vertical: 24),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        TextCustom(
                                          title: "Ride cancellation charge".tr.toUpperCase(),
                                          fontFamily: AppThemeData.bold,
                                          fontSize: 20,
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
                                                    title: "Cancellation Charge Type".tr,
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
                                                      hint: TextCustom(title: 'Select Tax Type'.tr),
                                                      onChanged: (String? taxType) {
                                                        controller.selectedCancellationChargeType.value = taxType ?? "Fix";
                                                      },
                                                      value: controller.selectedCancellationChargeType.value,
                                                      items: controller.cancellationChargeType.map<DropdownMenuItem<String>>((String value) {
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
                                                  spaceH(height: 16)
                                                ],
                                              ),
                                            ),
                                            spaceW(width: 16),
                                            Expanded(
                                              child: CustomTextFormField(
                                                  title: "Cancellation Charge".tr,
                                                  hintText: "Enter Cancellation Charge".tr,
                                                  inputFormatters: [
                                                    FilteringTextInputFormatter.allow(RegExp('[0-9.]')),
                                                  ],
                                                  prefix: Padding(
                                                    padding: paddingEdgeInsets(vertical: 10, horizontal: 10),
                                                    child: TextCustom(
                                                      title: '${Constant.currencyModel!.symbol}',
                                                      fontSize: 18,
                                                    ),
                                                  ),
                                                  controller: controller.cancellationChargeController.value),
                                            ),
                                          ],
                                        ),
                                        Obx(
                                          () => Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              TextCustom(
                                                title: "Status".tr,
                                                fontSize: 14,
                                              ),
                                              const SizedBox(
                                                width: 20,
                                              ),
                                              Row(
                                                children: [
                                                  Row(
                                                    children: [
                                                      Radio(
                                                        value: Status.active,
                                                        groupValue: controller.isActiveCancellationCharge.value,
                                                        onChanged: (value) {
                                                          controller.isActiveCancellationCharge.value = value ?? Status.active;
                                                        },
                                                        activeColor: AppThemData.primary500,
                                                      ),
                                                      Text("Active".tr,
                                                          style: const TextStyle(
                                                            fontFamily: AppThemeData.regular,
                                                            fontSize: 16,
                                                            color: AppThemData.textGrey,
                                                          ))
                                                    ],
                                                  ),
                                                  spaceW(),
                                                  Row(
                                                    children: [
                                                      Radio(
                                                        value: Status.inactive,
                                                        groupValue: controller.isActiveCancellationCharge.value,
                                                        onChanged: (value) {
                                                          controller.isActiveCancellationCharge.value = value ?? Status.inactive;
                                                        },
                                                        activeColor: AppThemData.primary500,
                                                      ),
                                                      Text("Inactive".tr,
                                                          style: const TextStyle(
                                                            fontFamily: AppThemeData.regular,
                                                            fontSize: 16,
                                                            color: AppThemData.textGrey,
                                                          ))
                                                    ],
                                                  ),
                                                ],
                                              )
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    height: 1,
                                    child: ContainerCustom(
                                      color: themeChange.isDarkTheme() ? AppThemData.greyShade900 : AppThemData.greyShade100,
                                    ),
                                  ),
                                  Padding(
                                    padding: paddingEdgeInsets(horizontal: 24, vertical: 24),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        TextCustom(
                                          title: "OTP Service".tr.toUpperCase(),
                                          fontFamily: AppThemeData.bold,
                                          fontSize: 20,
                                        ),
                                        spaceH(height: 12),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  TextCustom(
                                                    title: "Do you want to enable OTP verification for ride bookings?".tr,
                                                    fontSize: 14,
                                                  ),
                                                  const SizedBox(
                                                    width: 20,
                                                  ),
                                                  Obx(
                                                    () => Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        const SizedBox(
                                                          width: 20,
                                                        ),
                                                        Row(
                                                          children: [
                                                            Row(
                                                              children: [
                                                                Radio(
                                                                  value: Status.active,
                                                                  groupValue: controller.isOTPActive.value,
                                                                  onChanged: (value) {
                                                                    controller.isOTPActive.value = value ?? Status.active;
                                                                    // controller.constantModel.value.isSubscriptionEnable = true;
                                                                  },
                                                                  activeColor: AppThemData.primary500,
                                                                ),
                                                                const Text("Active",
                                                                    style: TextStyle(
                                                                      fontFamily: AppThemeData.regular,
                                                                      fontSize: 16,
                                                                      color: AppThemData.textGrey,
                                                                    ))
                                                              ],
                                                            ),
                                                            const SizedBox(
                                                              width: 16,
                                                            ),
                                                            Row(
                                                              children: [
                                                                Radio(
                                                                  value: Status.inactive,
                                                                  groupValue: controller.isOTPActive.value,
                                                                  onChanged: (value) {
                                                                    controller.isOTPActive.value = value ?? Status.inactive;
                                                                  },
                                                                  activeColor: AppThemData.primary500,
                                                                ),
                                                                const Text("Inactive",
                                                                    style: TextStyle(
                                                                      fontFamily: AppThemeData.regular,
                                                                      fontSize: 16,
                                                                      color: AppThemData.textGrey,
                                                                    ))
                                                              ],
                                                            ),
                                                          ],
                                                        )
                                                      ],
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ),
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    height: 1,
                                    child: ContainerCustom(
                                      color: themeChange.isDarkTheme() ? AppThemData.greyShade900 : AppThemData.greyShade100,
                                    ),
                                  ),
                                  Padding(
                                    padding: paddingEdgeInsets(horizontal: 24, vertical: 24),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        TextCustom(
                                          title: "Subscription Plan".tr.toUpperCase(),
                                          fontFamily: AppThemeData.bold,
                                          fontSize: 20,
                                        ),
                                        spaceH(height: 12),
                                        TextCustom(
                                          title: "Do you Want to Enable Subscription Plan?".tr,
                                          fontSize: 14,
                                        ),
                                        const SizedBox(
                                          width: 20,
                                        ),
                                        Obx(
                                          () => Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              const SizedBox(
                                                width: 20,
                                              ),
                                              Row(
                                                children: [
                                                  Row(
                                                    children: [
                                                      Radio(
                                                        value: Status.active,
                                                        groupValue: controller.isSubscriptionActive.value,
                                                        onChanged: (value) {
                                                          controller.isSubscriptionActive.value = value ?? Status.active;
                                                          // controller.constantModel.value.isSubscriptionEnable = true;
                                                        },
                                                        activeColor: AppThemData.primary500,
                                                      ),
                                                      const Text("Active",
                                                          style: TextStyle(
                                                            fontFamily: AppThemeData.regular,
                                                            fontSize: 16,
                                                            color: AppThemData.textGrey,
                                                          ))
                                                    ],
                                                  ),
                                                  const SizedBox(
                                                    width: 16,
                                                  ),
                                                  Row(
                                                    children: [
                                                      Radio(
                                                        value: Status.inactive,
                                                        groupValue: controller.isSubscriptionActive.value,
                                                        onChanged: (value) {
                                                          controller.isSubscriptionActive.value = value ?? Status.inactive;
                                                        },
                                                        activeColor: AppThemData.primary500,
                                                      ),
                                                      const Text("Inactive",
                                                          style: TextStyle(
                                                            fontFamily: AppThemeData.regular,
                                                            fontSize: 16,
                                                            color: AppThemData.textGrey,
                                                          ))
                                                    ],
                                                  ),
                                                ],
                                              )
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    width: ScreenSize.width(100, context),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        // Spacer(),
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
                                  ),
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
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        TextCustom(
                                          title: "Admin Commission".tr.toUpperCase(),
                                          fontFamily: AppThemeData.bold,
                                          fontSize: 20,
                                        ),
                                        spaceH(height: 12),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            TextCustom(
                                              maxLine: 1,
                                              title: "Commission Type".tr,
                                              fontFamily: AppThemeData.medium,
                                              fontSize: 12,
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
                                                hint: TextCustom(title: 'Select Tax Type'.tr),
                                                onChanged: (String? taxType) {
                                                  controller.selectedAdminCommissionType.value = taxType ?? "Fix";
                                                },
                                                value: controller.selectedAdminCommissionType.value,
                                                items: controller.adminCommissionType.map<DropdownMenuItem<String>>((String value) {
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
                                            spaceH(height: 16)
                                          ],
                                        ),
                                        spaceW(width: 16),
                                        CustomTextFormField(
                                            title: "Admin Commission".tr,
                                            hintText: "Enter admin commission".tr,
                                            inputFormatters: [
                                              FilteringTextInputFormatter.allow(RegExp('[0-9.]')),
                                            ],
                                            prefix: Padding(
                                              padding: paddingEdgeInsets(vertical: 10, horizontal: 10),
                                              child: TextCustom(
                                                title: '${Constant.currencyModel!.symbol}',
                                                fontSize: 18,
                                              ),
                                            ),
                                            controller: controller.adminCommissionController.value),
                                        Obx(
                                          () => Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              TextCustom(
                                                title: "Status".tr,
                                                fontSize: 14,
                                              ),
                                              const SizedBox(
                                                width: 20,
                                              ),
                                              Row(
                                                children: [
                                                  Row(
                                                    children: [
                                                      Radio(
                                                        value: Status.active,
                                                        groupValue: controller.isActiveAdminCommission.value,
                                                        onChanged: (value) {
                                                          controller.isActiveAdminCommission.value = value ?? Status.active;
                                                        },
                                                        activeColor: AppThemData.primary500,
                                                      ),
                                                      Text("Active".tr,
                                                          style: const TextStyle(
                                                            fontFamily: AppThemeData.regular,
                                                            fontSize: 16,
                                                            color: AppThemData.textGrey,
                                                          ))
                                                    ],
                                                  ),
                                                  spaceW(),
                                                  Row(
                                                    children: [
                                                      Radio(
                                                        value: Status.inactive,
                                                        groupValue: controller.isActiveAdminCommission.value,
                                                        onChanged: (value) {
                                                          controller.isActiveAdminCommission.value = value ?? Status.inactive;
                                                        },
                                                        activeColor: AppThemData.primary500,
                                                      ),
                                                      Text("Inactive".tr,
                                                          style: const TextStyle(
                                                            fontFamily: AppThemeData.regular,
                                                            fontSize: 16,
                                                            color: AppThemData.textGrey,
                                                          ))
                                                    ],
                                                  ),
                                                ],
                                              )
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    height: 1,
                                    child: ContainerCustom(
                                      color: themeChange.isDarkTheme() ? AppThemData.greyShade900 : AppThemData.greyShade100,
                                    ),
                                  ),
                                  Padding(
                                    padding: paddingEdgeInsets(horizontal: 24, vertical: 24),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        TextCustom(
                                          title: "Ride cancellation charge".tr.toUpperCase(),
                                          fontFamily: AppThemeData.bold,
                                          fontSize: 20,
                                        ),
                                        spaceH(height: 12),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            TextCustom(
                                              maxLine: 1,
                                              title: "Cancellation Charge Type".tr,
                                              fontFamily: AppThemeData.medium,
                                              fontSize: 12,
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
                                                hint: TextCustom(title: 'Select Tax Type'.tr),
                                                onChanged: (String? taxType) {
                                                  controller.selectedCancellationChargeType.value = taxType ?? "Fix";
                                                },
                                                value: controller.selectedCancellationChargeType.value,
                                                items: controller.cancellationChargeType.map<DropdownMenuItem<String>>((String value) {
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
                                            spaceH(height: 16)
                                          ],
                                        ),
                                        spaceW(width: 16),
                                        CustomTextFormField(
                                            title: "Cancellation Charge".tr,
                                            hintText: "Enter Cancellation Charge".tr,
                                            inputFormatters: [
                                              FilteringTextInputFormatter.allow(RegExp('[0-9.]')),
                                            ],
                                            prefix: Padding(
                                              padding: paddingEdgeInsets(vertical: 10, horizontal: 10),
                                              child: TextCustom(
                                                title: '${Constant.currencyModel!.symbol}',
                                                fontSize: 18,
                                              ),
                                            ),
                                            controller: controller.cancellationChargeController.value),
                                        Obx(
                                          () => Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              TextCustom(
                                                title: "Status".tr,
                                                fontSize: 14,
                                              ),
                                              const SizedBox(
                                                width: 20,
                                              ),
                                              Row(
                                                children: [
                                                  Row(
                                                    children: [
                                                      Radio(
                                                        value: Status.active,
                                                        groupValue: controller.isActiveCancellationCharge.value,
                                                        onChanged: (value) {
                                                          controller.isActiveCancellationCharge.value = value ?? Status.active;
                                                        },
                                                        activeColor: AppThemData.primary500,
                                                      ),
                                                      Text("Active".tr,
                                                          style: const TextStyle(
                                                            fontFamily: AppThemeData.regular,
                                                            fontSize: 16,
                                                            color: AppThemData.textGrey,
                                                          ))
                                                    ],
                                                  ),
                                                  spaceW(),
                                                  Row(
                                                    children: [
                                                      Radio(
                                                        value: Status.inactive,
                                                        groupValue: controller.isActiveCancellationCharge.value,
                                                        onChanged: (value) {
                                                          controller.isActiveCancellationCharge.value = value ?? Status.inactive;
                                                        },
                                                        activeColor: AppThemData.primary500,
                                                      ),
                                                      Text("Inactive".tr,
                                                          style: const TextStyle(
                                                            fontFamily: AppThemeData.regular,
                                                            fontSize: 16,
                                                            color: AppThemData.textGrey,
                                                          ))
                                                    ],
                                                  ),
                                                ],
                                              )
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    height: 1,
                                    child: ContainerCustom(
                                      color: themeChange.isDarkTheme() ? AppThemData.greyShade900 : AppThemData.greyShade100,
                                    ),
                                  ),
                                  Padding(
                                    padding: paddingEdgeInsets(horizontal: 24, vertical: 24),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        TextCustom(
                                          title: "Subscription Plan".tr.toUpperCase(),
                                          fontFamily: AppThemeData.bold,
                                          fontSize: 20,
                                        ),
                                        spaceH(height: 12),
                                        TextCustom(
                                          title: "Do you Want to Enable Subscription Plan?".tr,
                                          fontSize: 14,
                                        ),
                                        const SizedBox(
                                          width: 20,
                                        ),
                                        Obx(
                                          () => Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              const SizedBox(
                                                width: 20,
                                              ),
                                              Row(
                                                children: [
                                                  Row(
                                                    children: [
                                                      Radio(
                                                        value: Status.active,
                                                        groupValue: controller.isSubscriptionActive.value,
                                                        onChanged: (value) {
                                                          controller.isSubscriptionActive.value = value ?? Status.active;
                                                          // controller.constantModel.value.isSubscriptionEnable = true;
                                                        },
                                                        activeColor: AppThemData.primary500,
                                                      ),
                                                      const Text("Active",
                                                          style: TextStyle(
                                                            fontFamily: AppThemeData.regular,
                                                            fontSize: 16,
                                                            color: AppThemData.textGrey,
                                                          ))
                                                    ],
                                                  ),
                                                  const SizedBox(
                                                    width: 16,
                                                  ),
                                                  Row(
                                                    children: [
                                                      Radio(
                                                        value: Status.inactive,
                                                        groupValue: controller.isSubscriptionActive.value,
                                                        onChanged: (value) {
                                                          controller.isSubscriptionActive.value = value ?? Status.inactive;
                                                        },
                                                        activeColor: AppThemData.primary500,
                                                      ),
                                                      const Text("Inactive",
                                                          style: TextStyle(
                                                            fontFamily: AppThemeData.regular,
                                                            fontSize: 16,
                                                            color: AppThemData.textGrey,
                                                          ))
                                                    ],
                                                  ),
                                                ],
                                              )
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    width: ScreenSize.width(100, context),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        // Spacer(),
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
                                  ),
                                ],
                              ))
              ],
            ),
          );
        });
  }
}
