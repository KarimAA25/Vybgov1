// ignore_for_file: depend_on_referenced_packages

import 'package:admin/app/components/custom_button.dart';
import 'package:admin/app/components/custom_text_form_field.dart';
import 'package:admin/app/components/dialog_box.dart';
import 'package:admin/app/constant/constants.dart';
import 'package:admin/app/modules/payment/controllers/payment_controller.dart';
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

class PaymentView extends GetView<PaymentController> {
  const PaymentView({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetBuilder<PaymentController>(
      init: PaymentController(),
      builder: (paymentController) {
        return SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Obx(
                () => controller.isLoading.value
                    ? Padding(
                        padding: paddingEdgeInsets(),
                        child: Constant.loader(),
                      )
                    : ContainerCustom(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
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
                            Padding(
                              padding: paddingEdgeInsets(horizontal: 24, vertical: 24),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  TextCustom(
                                    title: "MIDTRANS".tr,
                                    fontFamily: AppThemeData.bold,
                                    fontSize: 20,
                                  ),
                                  spaceH(height: 16),
                                  !ResponsiveWidget.isMobile(context)
                                      ? Row(
                                          children: [
                                            Expanded(
                                              child: CustomTextFormField(
                                                  maxLine: 1,
                                                  title: "Name".tr,
                                                  hintText: "Enter name".tr,
                                                  prefix: const Icon(Icons.abc_outlined),
                                                  controller: paymentController.midTransNameController.value),
                                            ),
                                            spaceW(width: 16),
                                            Expanded(
                                              child: CustomTextFormField(
                                                  maxLine: 1,
                                                  title: "Midtrans Merchant Id".tr,
                                                  hintText: "Enter Midtrans Merchant Id".tr,
                                                  obscureText: Constant.isDemo ? true : false,
                                                  prefix: const Icon(Icons.key),
                                                  controller: paymentController.midTransIdController.value),
                                            ),
                                            spaceW(width: 16),
                                            Expanded(
                                              child: CustomTextFormField(
                                                  maxLine: 1,
                                                  title: "Midtrans Client Key".tr,
                                                  hintText: "Enter Midtrans Client  Key".tr,
                                                  obscureText: Constant.isDemo ? true : false,
                                                  prefix: const Icon(Icons.key),
                                                  controller: paymentController.midTransClientKeyController.value),
                                            ),
                                          ],
                                        )
                                      : Column(
                                          children: [
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: CustomTextFormField(
                                                      maxLine: 1,
                                                      title: "Name".tr,
                                                      hintText: "Enter name".tr,
                                                      prefix: const Icon(Icons.abc_outlined),
                                                      controller: paymentController.midTransNameController.value),
                                                ),
                                              ],
                                            ),
                                            spaceH(height: 16),
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: CustomTextFormField(
                                                      maxLine: 1,
                                                      title: "Midtrans Merchant Id".tr,
                                                      hintText: "Enter Midtrans Merchant Id".tr,
                                                      obscureText: Constant.isDemo ? true : false,
                                                      prefix: const Icon(Icons.key),
                                                      controller: paymentController.midTransIdController.value),
                                                ),
                                              ],
                                            ),
                                            spaceH(height: 16),
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: CustomTextFormField(
                                                      maxLine: 1,
                                                      title: "Midtrans Client Key".tr,
                                                      hintText: "Enter Midtrans Client Key".tr,
                                                      obscureText: Constant.isDemo ? true : false,
                                                      prefix: const Icon(Icons.key),
                                                      controller: paymentController.midTransClientKeyController.value),
                                                ),
                                              ],
                                            ),
                                            spaceH(height: 16),
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: CustomTextFormField(
                                                      maxLine: 1,
                                                      title: "Midtrans Secret Key".tr,
                                                      hintText: "Enter Midtrans Secret Key".tr,
                                                      obscureText: Constant.isDemo ? true : false,
                                                      prefix: const Icon(Icons.key),
                                                      controller: paymentController.midTransSecretKeyController.value),
                                                ),
                                              ],
                                            )
                                          ],
                                        ),
                                  ResponsiveWidget.isMobile(context)
                                      ? Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            spaceH(height: 16),
                                            Obx(
                                              () => Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  TextCustom(
                                                    title: "Status".tr,
                                                    fontSize: 14,
                                                  ),
                                                  FittedBox(
                                                    child: Row(
                                                      children: [
                                                        Row(
                                                          children: [
                                                            Radio(
                                                              value: Status.active,
                                                              groupValue: paymentController.isMidTransActive.value,
                                                              onChanged: (value) {
                                                                paymentController.isMidTransActive.value = value ?? Status.active;
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
                                                              groupValue: paymentController.isMidTransActive.value,
                                                              onChanged: (value) {
                                                                paymentController.isMidTransActive.value = value ?? Status.inactive;
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
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            spaceH(height: 16),
                                            Obx(
                                              () => Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  TextCustom(
                                                    title: "SandBox".tr,
                                                    fontSize: 14,
                                                  ),
                                                  const SizedBox(
                                                    width: 20,
                                                  ),
                                                  FittedBox(
                                                    child: Row(
                                                      children: [
                                                        Row(
                                                          children: [
                                                            Radio(
                                                              value: Status.active,
                                                              groupValue: paymentController.isMidTransSandBox.value,
                                                              onChanged: (value) {
                                                                paymentController.isMidTransSandBox.value = value ?? Status.active;
                                                              },
                                                              activeColor: AppThemData.primary500,
                                                            ),
                                                            Text("Test".tr,
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
                                                              groupValue: paymentController.isMidTransSandBox.value,
                                                              onChanged: (value) {
                                                                paymentController.isMidTransSandBox.value = value ?? Status.inactive;
                                                              },
                                                              activeColor: AppThemData.primary500,
                                                            ),
                                                            Text("Live".tr,
                                                                style: const TextStyle(
                                                                  fontFamily: AppThemeData.regular,
                                                                  fontSize: 16,
                                                                  color: AppThemData.textGrey,
                                                                ))
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ),
                                            // spaceW(width: 16),
                                            // !ResponsiveWidget.isMobile(context) ? Expanded(child: Container()) : SizedBox(),
                                            spaceW(width: 16),
                                            !ResponsiveWidget.isMobile(context) ? Expanded(child: Container()) : const SizedBox(),
                                          ],
                                        )
                                      : Row(
                                          children: [
                                            Expanded(
                                              child: CustomTextFormField(
                                                  maxLine: 1,
                                                  title: "Midtrans Secret Key".tr,
                                                  hintText: "Enter Midtrans Secret Key".tr,
                                                  obscureText: Constant.isDemo ? true : false,
                                                  prefix: const Icon(Icons.key),
                                                  controller: paymentController.midTransSecretKeyController.value),
                                            ),
                                            spaceW(width: 16),
                                            Obx(
                                              () => Expanded(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    TextCustom(
                                                      title: "Status".tr,
                                                      fontSize: 14,
                                                    ),
                                                    FittedBox(
                                                      child: Row(
                                                        children: [
                                                          Row(
                                                            children: [
                                                              Radio(
                                                                value: Status.active,
                                                                groupValue: paymentController.isMidTransActive.value,
                                                                onChanged: (value) {
                                                                  paymentController.isMidTransActive.value = value ?? Status.active;
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
                                                                groupValue: paymentController.isMidTransActive.value,
                                                                onChanged: (value) {
                                                                  paymentController.isMidTransActive.value = value ?? Status.inactive;
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
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            spaceW(width: 16),
                                            Obx(
                                              () => Expanded(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    TextCustom(
                                                      title: "SandBox".tr,
                                                      fontSize: 14,
                                                    ),
                                                    const SizedBox(
                                                      width: 20,
                                                    ),
                                                    FittedBox(
                                                      child: Row(
                                                        children: [
                                                          Row(
                                                            children: [
                                                              Radio(
                                                                value: Status.active,
                                                                groupValue: paymentController.isMidTransSandBox.value,
                                                                onChanged: (value) {
                                                                  paymentController.isMidTransSandBox.value = value ?? Status.active;
                                                                },
                                                                activeColor: AppThemData.primary500,
                                                              ),
                                                              Text("Test".tr,
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
                                                                groupValue: paymentController.isMidTransSandBox.value,
                                                                onChanged: (value) {
                                                                  paymentController.isMidTransSandBox.value = value ?? Status.inactive;
                                                                },
                                                                activeColor: AppThemData.primary500,
                                                              ),
                                                              Text("Live".tr,
                                                                  style: const TextStyle(
                                                                    fontFamily: AppThemeData.regular,
                                                                    fontSize: 16,
                                                                    color: AppThemData.textGrey,
                                                                  ))
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ).paddingOnly(top: 16),
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
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  TextCustom(
                                    title: "XENDIT".tr,
                                    fontFamily: AppThemeData.bold,
                                    fontSize: 20,
                                  ),
                                  spaceH(height: 16),
                                  !ResponsiveWidget.isMobile(context)
                                      ? Row(
                                          children: [
                                            Expanded(
                                              child: CustomTextFormField(
                                                  maxLine: 1,
                                                  title: "Name".tr,
                                                  hintText: "Enter name".tr,
                                                  prefix: const Icon(Icons.abc_outlined),
                                                  controller: paymentController.xenditNameController.value),
                                            ),
                                            spaceW(width: 16),
                                            Expanded(
                                              child: CustomTextFormField(
                                                  maxLine: 1,
                                                  title: "Xendit Secret Key".tr,
                                                  hintText: "Enter Xendit Secret Key".tr,
                                                  obscureText: Constant.isDemo ? true : false,
                                                  prefix: const Icon(Icons.key),
                                                  controller: paymentController.xenditSecretKeyController.value),
                                            ),
                                          ],
                                        )
                                      : Column(
                                          children: [
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: CustomTextFormField(
                                                      maxLine: 1,
                                                      title: "Name".tr,
                                                      hintText: "Enter name".tr,
                                                      prefix: const Icon(Icons.abc_outlined),
                                                      controller: paymentController.xenditNameController.value),
                                                ),
                                              ],
                                            ),
                                            spaceH(height: 16),
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: CustomTextFormField(
                                                      maxLine: 1,
                                                      title: "Xendit Secret Key".tr,
                                                      hintText: "Enter Xendit Secret Key".tr,
                                                      obscureText: Constant.isDemo ? true : false,
                                                      prefix: const Icon(Icons.key),
                                                      controller: paymentController.xenditSecretKeyController.value),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                  ResponsiveWidget.isMobile(context)
                                      ? Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            spaceH(height: 16),
                                            Obx(
                                              () => Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  TextCustom(
                                                    title: "Status".tr,
                                                    fontSize: 14,
                                                  ),
                                                  FittedBox(
                                                    child: Row(
                                                      children: [
                                                        Row(
                                                          children: [
                                                            Radio(
                                                              value: Status.active,
                                                              groupValue: paymentController.isXenditActive.value,
                                                              onChanged: (value) {
                                                                paymentController.isXenditActive.value = value ?? Status.active;
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
                                                              groupValue: paymentController.isXenditActive.value,
                                                              onChanged: (value) {
                                                                paymentController.isXenditActive.value = value ?? Status.inactive;
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
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            spaceH(height: 16),
                                            Obx(
                                              () => Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  TextCustom(
                                                    title: "SandBox".tr,
                                                    fontSize: 14,
                                                  ),
                                                  const SizedBox(
                                                    width: 20,
                                                  ),
                                                  FittedBox(
                                                    child: Row(
                                                      children: [
                                                        Row(
                                                          children: [
                                                            Radio(
                                                              value: Status.active,
                                                              groupValue: paymentController.isXenditSandBox.value,
                                                              onChanged: (value) {
                                                                paymentController.isXenditSandBox.value = value ?? Status.active;
                                                              },
                                                              activeColor: AppThemData.primary500,
                                                            ),
                                                            Text("Test".tr,
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
                                                              groupValue: paymentController.isXenditSandBox.value,
                                                              onChanged: (value) {
                                                                paymentController.isXenditSandBox.value = value ?? Status.inactive;
                                                              },
                                                              activeColor: AppThemData.primary500,
                                                            ),
                                                            Text("Live".tr,
                                                                style: const TextStyle(
                                                                  fontFamily: AppThemeData.regular,
                                                                  fontSize: 16,
                                                                  color: AppThemData.textGrey,
                                                                ))
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ),
                                            // spaceW(width: 16),
                                            // !ResponsiveWidget.isMobile(context) ? Expanded(child: Container()) : SizedBox(),
                                            spaceW(width: 16),
                                            !ResponsiveWidget.isMobile(context) ? Expanded(child: Container()) : const SizedBox(),
                                          ],
                                        )
                                      : Row(
                                          children: [
                                            Obx(
                                              () => Expanded(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    TextCustom(
                                                      title: "Status".tr,
                                                      fontSize: 14,
                                                    ),
                                                    FittedBox(
                                                      child: Row(
                                                        children: [
                                                          Row(
                                                            children: [
                                                              Radio(
                                                                value: Status.active,
                                                                groupValue: paymentController.isXenditActive.value,
                                                                onChanged: (value) {
                                                                  paymentController.isXenditActive.value = value ?? Status.active;
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
                                                                groupValue: paymentController.isXenditActive.value,
                                                                onChanged: (value) {
                                                                  paymentController.isXenditActive.value = value ?? Status.inactive;
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
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            spaceW(width: 16),
                                            Obx(
                                              () => Expanded(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    TextCustom(
                                                      title: "SandBox".tr,
                                                      fontSize: 14,
                                                    ),
                                                    const SizedBox(
                                                      width: 20,
                                                    ),
                                                    FittedBox(
                                                      child: Row(
                                                        children: [
                                                          Row(
                                                            children: [
                                                              Radio(
                                                                value: Status.active,
                                                                groupValue: paymentController.isXenditSandBox.value,
                                                                onChanged: (value) {
                                                                  paymentController.isXenditSandBox.value = value ?? Status.active;
                                                                },
                                                                activeColor: AppThemData.primary500,
                                                              ),
                                                              Text("Test".tr,
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
                                                                groupValue: paymentController.isXenditSandBox.value,
                                                                onChanged: (value) {
                                                                  paymentController.isXenditSandBox.value = value ?? Status.inactive;
                                                                },
                                                                activeColor: AppThemData.primary500,
                                                              ),
                                                              Text("Live".tr,
                                                                  style: const TextStyle(
                                                                    fontFamily: AppThemeData.regular,
                                                                    fontSize: 16,
                                                                    color: AppThemData.textGrey,
                                                                  ))
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ).paddingOnly(top: 16),
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
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  TextCustom(
                                    title: "Paypal".tr.toUpperCase(),
                                    fontFamily: AppThemeData.bold,
                                    fontSize: 20,
                                  ),
                                  spaceH(height: 16),
                                  !ResponsiveWidget.isMobile(context)
                                      ? Row(
                                          children: [
                                            Expanded(
                                              child: CustomTextFormField(
                                                  maxLine: 1,
                                                  title: "Name".tr,
                                                  hintText: "Enter name".tr,
                                                  prefix: const Icon(Icons.abc_outlined),
                                                  controller: paymentController.paypalNameController.value),
                                            ),
                                            spaceW(width: 16),
                                            Expanded(
                                              child: CustomTextFormField(
                                                  maxLine: 1,
                                                  title: "Paypal Client Id".tr,
                                                  hintText: "Enter paypal client id".tr,
                                                  obscureText: Constant.isDemo ? true : false,
                                                  prefix: const Icon(Icons.key),
                                                  controller: paymentController.paypalClientKeyController.value),
                                            ),
                                            spaceW(width: 16),
                                            Expanded(
                                              child: CustomTextFormField(
                                                  maxLine: 1,
                                                  title: "Paypal Secret Id".tr,
                                                  hintText: "Enter paypal secret id".tr,
                                                  obscureText: Constant.isDemo ? true : false,
                                                  prefix: const Icon(Icons.key),
                                                  controller: paymentController.paypalSecretKeyController.value),
                                            ),
                                          ],
                                        )
                                      : Column(
                                          children: [
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: CustomTextFormField(
                                                      maxLine: 1,
                                                      title: "Name".tr,
                                                      hintText: "Enter name".tr,
                                                      prefix: const Icon(Icons.abc_outlined),
                                                      controller: paymentController.paypalNameController.value),
                                                ),
                                              ],
                                            ),
                                            spaceH(height: 16),
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: CustomTextFormField(
                                                      maxLine: 1,
                                                      title: "Paypal Client Id".tr,
                                                      hintText: "Enter paypal client id".tr,
                                                      obscureText: Constant.isDemo ? true : false,
                                                      prefix: const Icon(Icons.key),
                                                      controller: paymentController.paypalClientKeyController.value),
                                                ),
                                              ],
                                            ),
                                            spaceH(height: 16),
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: CustomTextFormField(
                                                      maxLine: 1,
                                                      title: "Paypal Secret Id".tr,
                                                      hintText: "Enter paypal secret id".tr,
                                                      obscureText: Constant.isDemo ? true : false,
                                                      prefix: const Icon(Icons.key),
                                                      controller: paymentController.paypalSecretKeyController.value),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                  ResponsiveWidget.isMobile(context)
                                      ? Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            spaceH(height: 16),
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
                                                  FittedBox(
                                                    child: Row(
                                                      children: [
                                                        Row(
                                                          children: [
                                                            Radio(
                                                              value: Status.active,
                                                              groupValue: paymentController.isPaypalActive.value,
                                                              onChanged: (value) {
                                                                paymentController.isPaypalActive.value = value ?? Status.active;
                                                                // Constant.paymentModel!.paypal!.isActive = true;
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
                                                              groupValue: paymentController.isPaypalActive.value,
                                                              onChanged: (value) {
                                                                paymentController.isPaypalActive.value = value ?? Status.inactive;
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
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ),
                                            spaceH(height: 16),
                                            Obx(
                                              () => Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  TextCustom(
                                                    title: "SandBox".tr,
                                                    fontSize: 14,
                                                  ),
                                                  const SizedBox(
                                                    width: 20,
                                                  ),
                                                  FittedBox(
                                                    child: Row(
                                                      children: [
                                                        Row(
                                                          children: [
                                                            Radio(
                                                              value: Status.active,
                                                              groupValue: paymentController.isPaypalSandBox.value,
                                                              onChanged: (value) {
                                                                paymentController.isPaypalSandBox.value = value ?? Status.active;
                                                              },
                                                              activeColor: AppThemData.primary500,
                                                            ),
                                                            Text("Test".tr,
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
                                                              groupValue: paymentController.isPaypalSandBox.value,
                                                              onChanged: (value) {
                                                                paymentController.isPaypalSandBox.value = value ?? Status.inactive;
                                                              },
                                                              activeColor: AppThemData.primary500,
                                                            ),
                                                            Text("Live".tr,
                                                                style: const TextStyle(
                                                                  fontFamily: AppThemeData.regular,
                                                                  fontSize: 16,
                                                                  color: AppThemData.textGrey,
                                                                ))
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ),
                                          ],
                                        )
                                      : Row(
                                          children: [
                                            Obx(
                                              () => Expanded(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    TextCustom(
                                                      title: "Status".tr,
                                                      fontSize: 14,
                                                    ),
                                                    const SizedBox(
                                                      width: 20,
                                                    ),
                                                    FittedBox(
                                                      child: Row(
                                                        children: [
                                                          Row(
                                                            children: [
                                                              Radio(
                                                                value: Status.active,
                                                                groupValue: paymentController.isPaypalActive.value,
                                                                onChanged: (value) {
                                                                  paymentController.isPaypalActive.value = value ?? Status.active;
                                                                  // Constant.paymentModel!.paypal!.isActive = true;
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
                                                                groupValue: paymentController.isPaypalActive.value,
                                                                onChanged: (value) {
                                                                  paymentController.isPaypalActive.value = value ?? Status.inactive;
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
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              ),
                                            ),
                                            spaceW(width: 16),
                                            Obx(
                                              () => Expanded(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    TextCustom(
                                                      title: "SandBox".tr,
                                                      fontSize: 14,
                                                    ),
                                                    const SizedBox(
                                                      width: 20,
                                                    ),
                                                    FittedBox(
                                                      child: Row(
                                                        children: [
                                                          Row(
                                                            children: [
                                                              Radio(
                                                                value: Status.active,
                                                                groupValue: paymentController.isPaypalSandBox.value,
                                                                onChanged: (value) {
                                                                  paymentController.isPaypalSandBox.value = value ?? Status.active;
                                                                },
                                                                activeColor: AppThemData.primary500,
                                                              ),
                                                              Text("Test".tr,
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
                                                                groupValue: paymentController.isPaypalSandBox.value,
                                                                onChanged: (value) {
                                                                  paymentController.isPaypalSandBox.value = value ?? Status.inactive;
                                                                },
                                                                activeColor: AppThemData.primary500,
                                                              ),
                                                              Text("Live".tr,
                                                                  style: const TextStyle(
                                                                    fontFamily: AppThemeData.regular,
                                                                    fontSize: 16,
                                                                    color: AppThemData.textGrey,
                                                                  ))
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              ),
                                            ),
                                            spaceW(width: 16),
                                            !ResponsiveWidget.isMobile(context) ? Expanded(child: Container()) : const SizedBox(),
                                          ],
                                        ).paddingOnly(top: 16),
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
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  TextCustom(
                                    title: "PAYSTACK".tr,
                                    fontFamily: AppThemeData.bold,
                                    fontSize: 20,
                                  ),
                                  spaceH(height: 16),
                                  !ResponsiveWidget.isMobile(context)
                                      ? Column(
                                          children: [
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: CustomTextFormField(
                                                      maxLine: 1,
                                                      title: "Name".tr,
                                                      hintText: "Enter name".tr,
                                                      prefix: const Icon(Icons.abc_outlined),
                                                      controller: paymentController.payStackNameController.value),
                                                ),
                                                spaceW(width: 16),
                                                Expanded(
                                                  child: CustomTextFormField(
                                                      maxLine: 1,
                                                      title: "PayStack Key".tr,
                                                      hintText: "Enter PayStack Key".tr,
                                                      obscureText: Constant.isDemo ? true : false,
                                                      prefix: const Icon(Icons.key),
                                                      controller: paymentController.payStackSecretKeyController.value),
                                                ),
                                                spaceW(width: 16),
                                                Expanded(
                                                  child: CustomTextFormField(
                                                      maxLine: 1,
                                                      title: "PayStack Callback Url".tr,
                                                      hintText: "Enter PayStack Callback Url".tr,
                                                      obscureText: Constant.isDemo ? true : false,
                                                      prefix: const Icon(Icons.key),
                                                      controller: paymentController.payStackCallbackUrlController.value),
                                                ),
                                              ],
                                            ),
                                            spaceH(height: 16),
                                            Row(
                                              children: [
                                                Obx(
                                                  () => Expanded(
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        TextCustom(
                                                          title: "Status".tr,
                                                          fontSize: 14,
                                                        ),
                                                        FittedBox(
                                                          child: Row(
                                                            children: [
                                                              Row(
                                                                children: [
                                                                  Radio(
                                                                    value: Status.active,
                                                                    groupValue: paymentController.isPayStackActive.value,
                                                                    onChanged: (value) {
                                                                      paymentController.isPayStackActive.value = value ?? Status.active;
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
                                                                    groupValue: paymentController.isPayStackActive.value,
                                                                    onChanged: (value) {
                                                                      paymentController.isPayStackActive.value = value ?? Status.inactive;
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
                                                          ),
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                spaceW(width: 16),
                                                Expanded(child: SizedBox()),
                                                spaceW(width: 16),
                                                Expanded(child: SizedBox()),
                                              ],
                                            )
                                          ],
                                        )
                                      : Column(
                                          children: [
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: CustomTextFormField(
                                                      maxLine: 1,
                                                      title: "Name".tr,
                                                      hintText: "Enter name".tr,
                                                      prefix: const Icon(Icons.abc_outlined),
                                                      controller: paymentController.payStackNameController.value),
                                                ),
                                              ],
                                            ),
                                            spaceH(height: 16),
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: CustomTextFormField(
                                                      maxLine: 1,
                                                      title: "PayStack Key".tr,
                                                      hintText: "Enter PayStack Key".tr,
                                                      obscureText: Constant.isDemo ? true : false,
                                                      prefix: const Icon(Icons.key),
                                                      controller: paymentController.payStackSecretKeyController.value),
                                                ),
                                              ],
                                            ),
                                            spaceH(height: 16),
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: CustomTextFormField(
                                                      maxLine: 1,
                                                      title: "PayStack Callback Url".tr,
                                                      hintText: "Enter PayStack Callback Url".tr,
                                                      obscureText: Constant.isDemo ? true : false,
                                                      prefix: const Icon(Icons.key),
                                                      controller: paymentController.payStackCallbackUrlController.value),
                                                ),
                                              ],
                                            ),
                                            spaceH(height: 16),
                                            Row(
                                              children: [
                                                Obx(
                                                  () => Expanded(
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        TextCustom(
                                                          title: "Status".tr,
                                                          fontSize: 14,
                                                        ),
                                                        FittedBox(
                                                          child: Row(
                                                            children: [
                                                              Row(
                                                                children: [
                                                                  Radio(
                                                                    value: Status.active,
                                                                    groupValue: paymentController.isRazorpayActive.value,
                                                                    onChanged: (value) {
                                                                      paymentController.isRazorpayActive.value = value ?? Status.active;
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
                                                                    groupValue: paymentController.isRazorpayActive.value,
                                                                    onChanged: (value) {
                                                                      paymentController.isRazorpayActive.value = value ?? Status.inactive;
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
                                                          ),
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            )
                                          ],
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
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  TextCustom(
                                    title: "RAZORPAY".tr,
                                    fontFamily: AppThemeData.bold,
                                    fontSize: 20,
                                  ),
                                  spaceH(height: 16),
                                  !ResponsiveWidget.isMobile(context)
                                      ? Row(
                                          children: [
                                            Expanded(
                                              child: CustomTextFormField(
                                                  maxLine: 1,
                                                  title: "Name".tr,
                                                  hintText: "Enter name".tr,
                                                  prefix: const Icon(Icons.abc_outlined),
                                                  controller: paymentController.razorpayNameController.value),
                                            ),
                                            spaceW(width: 16),
                                            Expanded(
                                              child: CustomTextFormField(
                                                  maxLine: 1,
                                                  title: "Razorpay Client Key".tr,
                                                  hintText: "Enter Razorpay client Key".tr,
                                                  obscureText: Constant.isDemo ? true : false,
                                                  prefix: const Icon(Icons.key),
                                                  controller: paymentController.razorpayKeyController.value),
                                            ),
                                            spaceW(width: 16),
                                            Expanded(
                                              child: CustomTextFormField(
                                                  maxLine: 1,
                                                  title: "Razorpay Secret Id".tr,
                                                  hintText: "Enter Razorpay secret id".tr,
                                                  obscureText: Constant.isDemo ? true : false,
                                                  prefix: const Icon(Icons.key),
                                                  controller: paymentController.razorpaySecretController.value),
                                            ),
                                          ],
                                        )
                                      : Column(
                                          children: [
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: CustomTextFormField(
                                                      maxLine: 1,
                                                      title: "Name".tr,
                                                      hintText: "Enter name".tr,
                                                      prefix: const Icon(Icons.abc_outlined),
                                                      controller: paymentController.razorpayNameController.value),
                                                ),
                                              ],
                                            ),
                                            spaceH(height: 16),
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: CustomTextFormField(
                                                      maxLine: 1,
                                                      title: "Razorpay Client Key".tr,
                                                      hintText: "Enter Razorpay Key".tr,
                                                      obscureText: Constant.isDemo ? true : false,
                                                      prefix: const Icon(Icons.key),
                                                      controller: paymentController.razorpayKeyController.value),
                                                ),
                                              ],
                                            ),
                                            spaceH(height: 16),
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: CustomTextFormField(
                                                      maxLine: 1,
                                                      title: "Razorpay Secret Id".tr,
                                                      hintText: "Enter Razorpay secret id".tr,
                                                      obscureText: Constant.isDemo ? true : false,
                                                      prefix: const Icon(Icons.key),
                                                      controller: paymentController.razorpaySecretController.value),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                  ResponsiveWidget.isMobile(context)
                                      ? Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            spaceH(height: 16),
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
                                                  FittedBox(
                                                    child: Row(
                                                      children: [
                                                        Row(
                                                          children: [
                                                            Radio(
                                                              value: Status.active,
                                                              groupValue: paymentController.isRazorpayActive.value,
                                                              onChanged: (value) {
                                                                paymentController.isRazorpayActive.value = value ?? Status.active;
                                                                // Constant.paymentModel!.paypal!.isActive = true;
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
                                                              groupValue: paymentController.isRazorpayActive.value,
                                                              onChanged: (value) {
                                                                paymentController.isRazorpayActive.value = value ?? Status.inactive;
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
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ),
                                            spaceH(height: 16),
                                            Obx(
                                              () => Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  TextCustom(
                                                    title: "SandBox".tr,
                                                    fontSize: 14,
                                                  ),
                                                  const SizedBox(
                                                    width: 20,
                                                  ),
                                                  FittedBox(
                                                    child: Row(
                                                      children: [
                                                        Row(
                                                          children: [
                                                            Radio(
                                                              value: Status.active,
                                                              groupValue: paymentController.isRazorPaySandBox.value,
                                                              onChanged: (value) {
                                                                paymentController.isRazorPaySandBox.value = value ?? Status.active;
                                                              },
                                                              activeColor: AppThemData.primary500,
                                                            ),
                                                            Text("Test".tr,
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
                                                              groupValue: paymentController.isRazorPaySandBox.value,
                                                              onChanged: (value) {
                                                                paymentController.isRazorPaySandBox.value = value ?? Status.inactive;
                                                              },
                                                              activeColor: AppThemData.primary500,
                                                            ),
                                                            Text("Live".tr,
                                                                style: const TextStyle(
                                                                  fontFamily: AppThemeData.regular,
                                                                  fontSize: 16,
                                                                  color: AppThemData.textGrey,
                                                                ))
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ),
                                          ],
                                        )
                                      : Row(
                                          children: [
                                            Obx(
                                              () => Expanded(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    TextCustom(
                                                      title: "Status".tr,
                                                      fontSize: 14,
                                                    ),
                                                    const SizedBox(
                                                      width: 20,
                                                    ),
                                                    FittedBox(
                                                      child: Row(
                                                        children: [
                                                          Row(
                                                            children: [
                                                              Radio(
                                                                value: Status.active,
                                                                groupValue: paymentController.isRazorpayActive.value,
                                                                onChanged: (value) {
                                                                  paymentController.isRazorpayActive.value = value ?? Status.active;
                                                                  // Constant.paymentModel!.paypal!.isActive = true;
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
                                                                groupValue: paymentController.isRazorpayActive.value,
                                                                onChanged: (value) {
                                                                  paymentController.isRazorpayActive.value = value ?? Status.inactive;
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
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              ),
                                            ),
                                            spaceW(width: 16),
                                            Obx(
                                              () => Expanded(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    TextCustom(
                                                      title: "SandBox".tr,
                                                      fontSize: 14,
                                                    ),
                                                    const SizedBox(
                                                      width: 20,
                                                    ),
                                                    FittedBox(
                                                      child: Row(
                                                        children: [
                                                          Row(
                                                            children: [
                                                              Radio(
                                                                value: Status.active,
                                                                groupValue: paymentController.isRazorPaySandBox.value,
                                                                onChanged: (value) {
                                                                  paymentController.isRazorPaySandBox.value = value ?? Status.active;
                                                                },
                                                                activeColor: AppThemData.primary500,
                                                              ),
                                                              Text("Test".tr,
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
                                                                groupValue: paymentController.isRazorPaySandBox.value,
                                                                onChanged: (value) {
                                                                  paymentController.isRazorPaySandBox.value = value ?? Status.inactive;
                                                                },
                                                                activeColor: AppThemData.primary500,
                                                              ),
                                                              Text("Live".tr,
                                                                  style: const TextStyle(
                                                                    fontFamily: AppThemeData.regular,
                                                                    fontSize: 16,
                                                                    color: AppThemData.textGrey,
                                                                  ))
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              ),
                                            ),
                                            spaceW(width: 16),
                                            !ResponsiveWidget.isMobile(context) ? Expanded(child: Container()) : const SizedBox(),
                                          ],
                                        ).paddingOnly(top: 16),
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
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  TextCustom(
                                    title: "Stripe".tr.toUpperCase(),
                                    fontFamily: AppThemeData.bold,
                                    fontSize: 20,
                                  ),
                                  spaceH(height: 16),
                                  !ResponsiveWidget.isMobile(context)
                                      ? Row(
                                          children: [
                                            Expanded(
                                              child: CustomTextFormField(
                                                  maxLine: 1,
                                                  title: "Name".tr,
                                                  hintText: "Enter name".tr,
                                                  prefix: const Icon(Icons.abc_outlined),
                                                  controller: paymentController.stripeNameController.value),
                                            ),
                                            spaceW(width: 16),
                                            Expanded(
                                              child: CustomTextFormField(
                                                  maxLine: 1,
                                                  title: "Stripe Client Publishable Key".tr,
                                                  hintText: "Enter Stripe Client Publishable Key".tr,
                                                  obscureText: Constant.isDemo ? true : false,
                                                  prefix: const Icon(Icons.key),
                                                  controller: paymentController.clientPublishableKeyController.value),
                                            ),
                                            spaceW(width: 16),
                                            Expanded(
                                              child: CustomTextFormField(
                                                  maxLine: 1,
                                                  title: "Stripe Secret Key".tr,
                                                  hintText: "Enter Stripe secret key".tr,
                                                  obscureText: Constant.isDemo ? true : false,
                                                  prefix: const Icon(Icons.key),
                                                  controller: paymentController.stripeSecretKeyController.value),
                                            ),
                                          ],
                                        )
                                      : Column(
                                          children: [
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: CustomTextFormField(
                                                      maxLine: 1,
                                                      title: "Name".tr,
                                                      hintText: "Enter name".tr,
                                                      prefix: const Icon(Icons.abc_outlined),
                                                      controller: paymentController.stripeNameController.value),
                                                ),
                                              ],
                                            ),
                                            spaceH(height: 16),
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: CustomTextFormField(
                                                      maxLine: 1,
                                                      title: "Stripe Secret Key".tr,
                                                      hintText: "Enter Stripe secret key".tr,
                                                      obscureText: Constant.isDemo ? true : false,
                                                      prefix: const Icon(Icons.key),
                                                      controller: paymentController.stripeSecretKeyController.value),
                                                ),
                                              ],
                                            ),
                                            spaceH(height: 16),
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: CustomTextFormField(
                                                      maxLine: 1,
                                                      title: "Stripe Secret Key".tr,
                                                      hintText: "Enter Stripe secret key".tr,
                                                      obscureText: Constant.isDemo ? true : false,
                                                      prefix: const Icon(Icons.key),
                                                      controller: paymentController.stripeSecretKeyController.value),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                  ResponsiveWidget.isMobile(context)
                                      ? Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            spaceH(height: 16),
                                            Obx(
                                              () => Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  TextCustom(
                                                    title: "Status".tr,
                                                    fontSize: 14,
                                                  ),
                                                  FittedBox(
                                                    child: Row(
                                                      children: [
                                                        Row(
                                                          children: [
                                                            Radio(
                                                              value: Status.active,
                                                              groupValue: paymentController.isStripeActive.value,
                                                              onChanged: (value) {
                                                                paymentController.isStripeActive.value = value ?? Status.active;
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
                                                              groupValue: paymentController.isStripeActive.value,
                                                              onChanged: (value) {
                                                                paymentController.isStripeActive.value = value ?? Status.inactive;
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
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            spaceH(height: 16),
                                            Obx(
                                              () => Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  TextCustom(
                                                    title: "SandBox".tr,
                                                    fontSize: 14,
                                                  ),
                                                  const SizedBox(
                                                    width: 20,
                                                  ),
                                                  FittedBox(
                                                    child: Row(
                                                      children: [
                                                        Row(
                                                          children: [
                                                            Radio(
                                                              value: Status.active,
                                                              groupValue: paymentController.isStripeSandBox.value,
                                                              onChanged: (value) {
                                                                paymentController.isStripeSandBox.value = value ?? Status.active;
                                                              },
                                                              activeColor: AppThemData.primary500,
                                                            ),
                                                            Text("Test".tr,
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
                                                              groupValue: paymentController.isStripeSandBox.value,
                                                              onChanged: (value) {
                                                                paymentController.isStripeSandBox.value = value ?? Status.inactive;
                                                              },
                                                              activeColor: AppThemData.primary500,
                                                            ),
                                                            Text("Live".tr,
                                                                style: const TextStyle(
                                                                  fontFamily: AppThemeData.regular,
                                                                  fontSize: 16,
                                                                  color: AppThemData.textGrey,
                                                                ))
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ),
                                          ],
                                        )
                                      : Row(
                                          children: [
                                            Obx(
                                              () => Expanded(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    TextCustom(
                                                      title: "Status".tr,
                                                      fontSize: 14,
                                                    ),
                                                    FittedBox(
                                                      child: Row(
                                                        children: [
                                                          Row(
                                                            children: [
                                                              Radio(
                                                                value: Status.active,
                                                                groupValue: paymentController.isStripeActive.value,
                                                                onChanged: (value) {
                                                                  paymentController.isStripeActive.value = value ?? Status.active;
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
                                                                groupValue: paymentController.isStripeActive.value,
                                                                onChanged: (value) {
                                                                  paymentController.isStripeActive.value = value ?? Status.inactive;
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
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            spaceW(width: 16),
                                            Obx(
                                              () => Expanded(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    TextCustom(
                                                      title: "SandBox".tr,
                                                      fontSize: 14,
                                                    ),
                                                    const SizedBox(
                                                      width: 20,
                                                    ),
                                                    FittedBox(
                                                      child: Row(
                                                        children: [
                                                          Row(
                                                            children: [
                                                              Radio(
                                                                value: Status.active,
                                                                groupValue: paymentController.isStripeSandBox.value,
                                                                onChanged: (value) {
                                                                  paymentController.isStripeSandBox.value = value ?? Status.active;
                                                                },
                                                                activeColor: AppThemData.primary500,
                                                              ),
                                                              Text("Test".tr,
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
                                                                groupValue: paymentController.isStripeSandBox.value,
                                                                onChanged: (value) {
                                                                  paymentController.isStripeSandBox.value = value ?? Status.inactive;
                                                                },
                                                                activeColor: AppThemData.primary500,
                                                              ),
                                                              Text("Live".tr,
                                                                  style: const TextStyle(
                                                                    fontFamily: AppThemeData.regular,
                                                                    fontSize: 16,
                                                                    color: AppThemData.textGrey,
                                                                  ))
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              ),
                                            ),
                                            // spaceW(width: 16),
                                            // !ResponsiveWidget.isMobile(context) ? Expanded(child: Container()) : SizedBox(),
                                            spaceW(width: 16),
                                            !ResponsiveWidget.isMobile(context) ? Expanded(child: Container()) : const SizedBox(),
                                          ],
                                        ).paddingOnly(top: 16),
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
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  TextCustom(
                                    title: "MERCADOPOGO".tr,
                                    fontFamily: AppThemeData.bold,
                                    fontSize: 20,
                                  ),
                                  spaceH(height: 16),
                                  !ResponsiveWidget.isMobile(context)
                                      ? Column(
                                          children: [
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: CustomTextFormField(
                                                      maxLine: 1,
                                                      title: "Name".tr,
                                                      hintText: "Enter name".tr,
                                                      prefix: const Icon(Icons.abc_outlined),
                                                      controller: paymentController.mercadoPogoNameController.value),
                                                ),
                                                spaceW(width: 16),
                                                Expanded(
                                                  child: CustomTextFormField(
                                                      maxLine: 1,
                                                      title: " Mercado PagoAccess Token".tr,
                                                      hintText: "Enter Mercado PagoAccess Token".tr,
                                                      obscureText: Constant.isDemo ? true : false,
                                                      prefix: const Icon(Icons.key),
                                                      controller: paymentController.mercadoPogoAccessTokenController.value),
                                                ),
                                                spaceW(width: 16),
                                                Expanded(
                                                  child: CustomTextFormField(
                                                      maxLine: 1,
                                                      title: " Mercado Pago Callback Url".tr,
                                                      hintText: "Enter Mercado Pago Callback Url".tr,
                                                      obscureText: Constant.isDemo ? true : false,
                                                      prefix: const Icon(Icons.key),
                                                      controller: paymentController.mercadoPogoCallbackUrlController.value),
                                                ),
                                              ],
                                            ),
                                            spaceH(height: 16),
                                            Row(
                                              children: [
                                                Obx(
                                                  () => Expanded(
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        TextCustom(
                                                          title: "Status".tr,
                                                          fontSize: 14,
                                                        ),
                                                        FittedBox(
                                                          child: Row(
                                                            children: [
                                                              Row(
                                                                children: [
                                                                  Radio(
                                                                    value: Status.active,
                                                                    groupValue: paymentController.isMercadoPogoActive.value,
                                                                    onChanged: (value) {
                                                                      paymentController.isMercadoPogoActive.value = value ?? Status.active;
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
                                                                    groupValue: paymentController.isMercadoPogoActive.value,
                                                                    onChanged: (value) {
                                                                      paymentController.isMercadoPogoActive.value = value ?? Status.inactive;
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
                                                          ),
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                spaceW(width: 16),
                                                Expanded(child: SizedBox()),
                                                spaceW(width: 16),
                                                Expanded(child: SizedBox()),
                                              ],
                                            )
                                          ],
                                        )
                                      : Column(
                                          children: [
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: CustomTextFormField(
                                                      maxLine: 1,
                                                      title: "Name".tr,
                                                      hintText: "Enter name".tr,
                                                      prefix: const Icon(Icons.abc_outlined),
                                                      controller: paymentController.mercadoPogoNameController.value),
                                                ),
                                              ],
                                            ),
                                            spaceH(height: 16),
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: CustomTextFormField(
                                                      maxLine: 1,
                                                      title: "MercadoPogo Key".tr,
                                                      hintText: "Enter MercadoPogo Key".tr,
                                                      obscureText: Constant.isDemo ? true : false,
                                                      prefix: const Icon(Icons.key),
                                                      controller: paymentController.mercadoPogoAccessTokenController.value),
                                                ),
                                              ],
                                            ),
                                            spaceH(height: 16),
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: CustomTextFormField(
                                                      maxLine: 1,
                                                      title: " Mercado Pago Callback Url".tr,
                                                      hintText: "Enter Mercado Pago Callback Url".tr,
                                                      obscureText: Constant.isDemo ? true : false,
                                                      prefix: const Icon(Icons.key),
                                                      controller: paymentController.mercadoPogoCallbackUrlController.value),
                                                ),
                                              ],
                                            ),
                                            spaceH(height: 16),
                                            Row(
                                              children: [
                                                Obx(
                                                  () => Expanded(
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        TextCustom(
                                                          title: "Status".tr,
                                                          fontSize: 14,
                                                        ),
                                                        FittedBox(
                                                          child: Row(
                                                            children: [
                                                              Row(
                                                                children: [
                                                                  Radio(
                                                                    value: Status.active,
                                                                    groupValue: paymentController.isMercadoPogoActive.value,
                                                                    onChanged: (value) {
                                                                      paymentController.isMercadoPogoActive.value = value ?? Status.active;
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
                                                                    groupValue: paymentController.isMercadoPogoActive.value,
                                                                    onChanged: (value) {
                                                                      paymentController.isMercadoPogoActive.value = value ?? Status.inactive;
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
                                                          ),
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            )
                                          ],
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
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  TextCustom(
                                    title: "PAYFAST".tr,
                                    fontFamily: AppThemeData.bold,
                                    fontSize: 20,
                                  ),
                                  spaceH(height: 16),
                                  !ResponsiveWidget.isMobile(context)
                                      ? Column(
                                          children: [
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: CustomTextFormField(
                                                      maxLine: 1,
                                                      title: "Name".tr,
                                                      hintText: "Enter name".tr,
                                                      prefix: const Icon(Icons.abc_outlined),
                                                      controller: paymentController.payFastNameController.value),
                                                ),
                                                spaceW(width: 16),
                                                Expanded(
                                                  child: CustomTextFormField(
                                                      maxLine: 1,
                                                      title: "PayFast Key".tr,
                                                      hintText: "Enter PayFast Key".tr,
                                                      obscureText: Constant.isDemo ? true : false,
                                                      prefix: const Icon(Icons.key),
                                                      controller: paymentController.payFastMerchantKeyController.value),
                                                ),
                                                spaceW(width: 16),
                                                Expanded(
                                                  child: CustomTextFormField(
                                                      maxLine: 1,
                                                      title: "PayFast Id".tr,
                                                      hintText: "Enter PayFast ID".tr,
                                                      obscureText: Constant.isDemo ? true : false,
                                                      prefix: const Icon(Icons.key),
                                                      controller: paymentController.payFastMerchantIDController.value),
                                                ),
                                              ],
                                            ),
                                            spaceH(height: 16),
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: CustomTextFormField(
                                                      maxLine: 1,
                                                      title: "PayFast Return url".tr,
                                                      hintText: "Enter PayFast Return url".tr,
                                                      prefix: const Icon(Icons.abc_outlined),
                                                      controller: paymentController.payFastReturnUrlController.value),
                                                ),
                                                spaceW(width: 16),
                                                Expanded(
                                                  child: CustomTextFormField(
                                                      maxLine: 1,
                                                      title: "PayFast Cancel Url".tr,
                                                      hintText: "PayFast Cancel Url".tr,
                                                      obscureText: Constant.isDemo ? true : false,
                                                      prefix: const Icon(Icons.key),
                                                      controller: paymentController.payFastCancelUrlController.value),
                                                ),
                                                spaceW(width: 16),
                                                Expanded(
                                                  child: CustomTextFormField(
                                                      maxLine: 1,
                                                      title: "PayFast Notify Url".tr,
                                                      hintText: "Enter Notify Url".tr,
                                                      obscureText: Constant.isDemo ? true : false,
                                                      prefix: const Icon(Icons.key),
                                                      controller: paymentController.payFastNotifyUrlController.value),
                                                ),
                                              ],
                                            ),
                                          ],
                                        )
                                      : Column(
                                          children: [
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: CustomTextFormField(
                                                      maxLine: 1,
                                                      title: "Name".tr,
                                                      hintText: "Enter name".tr,
                                                      prefix: const Icon(Icons.abc_outlined),
                                                      controller: paymentController.payFastNameController.value),
                                                ),
                                              ],
                                            ),
                                            spaceH(height: 16),
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: CustomTextFormField(
                                                      maxLine: 1,
                                                      title: "PayFast Key".tr,
                                                      hintText: "Enter PayFast Key".tr,
                                                      obscureText: Constant.isDemo ? true : false,
                                                      prefix: const Icon(Icons.key),
                                                      controller: paymentController.payFastMerchantKeyController.value),
                                                ),
                                              ],
                                            ),
                                            spaceH(height: 16),
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: CustomTextFormField(
                                                      maxLine: 1,
                                                      title: "PayFast Id".tr,
                                                      hintText: "Enter PayFast ID".tr,
                                                      obscureText: Constant.isDemo ? true : false,
                                                      prefix: const Icon(Icons.key),
                                                      controller: paymentController.payFastMerchantIDController.value),
                                                ),
                                              ],
                                            ),
                                            spaceH(height: 16),
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: CustomTextFormField(
                                                      maxLine: 1,
                                                      title: "PayFast Return Url".tr,
                                                      hintText: "Enter Return Url ".tr,
                                                      obscureText: Constant.isDemo ? true : false,
                                                      prefix: const Icon(Icons.key),
                                                      controller: paymentController.payFastReturnUrlController.value),
                                                ),
                                              ],
                                            ),
                                            spaceH(height: 16),
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: CustomTextFormField(
                                                      maxLine: 1,
                                                      title: "PayFast Cancel Url".tr,
                                                      hintText: "Enter Cancel Url ".tr,
                                                      obscureText: Constant.isDemo ? true : false,
                                                      prefix: const Icon(Icons.key),
                                                      controller: paymentController.payFastCancelUrlController.value),
                                                ),
                                              ],
                                            ),
                                            spaceH(height: 16),
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: CustomTextFormField(
                                                      maxLine: 1,
                                                      title: "PayFast Notify Url".tr,
                                                      hintText: "Enter Notify Url ".tr,
                                                      obscureText: Constant.isDemo ? true : false,
                                                      prefix: const Icon(Icons.key),
                                                      controller: paymentController.payFastNotifyUrlController.value),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                  ResponsiveWidget.isMobile(context)
                                      ? Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            spaceH(height: 16),
                                            Obx(
                                              () => Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  TextCustom(
                                                    title: "Status".tr,
                                                    fontSize: 14,
                                                  ),
                                                  FittedBox(
                                                    child: Row(
                                                      children: [
                                                        Row(
                                                          children: [
                                                            Radio(
                                                              value: Status.active,
                                                              groupValue: paymentController.isPayFastActive.value,
                                                              onChanged: (value) {
                                                                paymentController.isPayFastActive.value = value ?? Status.active;
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
                                                              groupValue: paymentController.isPayFastActive.value,
                                                              onChanged: (value) {
                                                                paymentController.isPayFastActive.value = value ?? Status.inactive;
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
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            spaceH(height: 16),
                                            Obx(
                                              () => Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  TextCustom(
                                                    title: "SandBox".tr,
                                                    fontSize: 14,
                                                  ),
                                                  const SizedBox(
                                                    width: 20,
                                                  ),
                                                  FittedBox(
                                                    child: Row(
                                                      children: [
                                                        Row(
                                                          children: [
                                                            Radio(
                                                              value: Status.active,
                                                              groupValue: paymentController.isPayFastSandBox.value,
                                                              onChanged: (value) {
                                                                paymentController.isPayFastSandBox.value = value ?? Status.active;
                                                              },
                                                              activeColor: AppThemData.primary500,
                                                            ),
                                                            Text("Test".tr,
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
                                                              groupValue: paymentController.isPayFastSandBox.value,
                                                              onChanged: (value) {
                                                                paymentController.isPayFastSandBox.value = value ?? Status.inactive;
                                                              },
                                                              activeColor: AppThemData.primary500,
                                                            ),
                                                            Text("Live".tr,
                                                                style: const TextStyle(
                                                                  fontFamily: AppThemeData.regular,
                                                                  fontSize: 16,
                                                                  color: AppThemData.textGrey,
                                                                ))
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ),
                                          ],
                                        )
                                      : Row(
                                          children: [
                                            Obx(
                                              () => Expanded(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    TextCustom(
                                                      title: "Status".tr,
                                                      fontSize: 14,
                                                    ),
                                                    FittedBox(
                                                      child: Row(
                                                        children: [
                                                          Row(
                                                            children: [
                                                              Radio(
                                                                value: Status.active,
                                                                groupValue: paymentController.isPayFastActive.value,
                                                                onChanged: (value) {
                                                                  paymentController.isPayFastActive.value = value ?? Status.active;
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
                                                                groupValue: paymentController.isPayFastActive.value,
                                                                onChanged: (value) {
                                                                  paymentController.isPayFastActive.value = value ?? Status.inactive;
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
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            spaceW(width: 16),
                                            Obx(
                                              () => Expanded(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    TextCustom(
                                                      title: "SandBox".tr,
                                                      fontSize: 14,
                                                    ),
                                                    const SizedBox(
                                                      width: 20,
                                                    ),
                                                    FittedBox(
                                                      child: Row(
                                                        children: [
                                                          Row(
                                                            children: [
                                                              Radio(
                                                                value: Status.active,
                                                                groupValue: paymentController.isPayFastSandBox.value,
                                                                onChanged: (value) {
                                                                  paymentController.isPayFastSandBox.value = value ?? Status.active;
                                                                },
                                                                activeColor: AppThemData.primary500,
                                                              ),
                                                              Text("Test".tr,
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
                                                                groupValue: paymentController.isPayFastSandBox.value,
                                                                onChanged: (value) {
                                                                  paymentController.isPayFastSandBox.value = value ?? Status.inactive;
                                                                },
                                                                activeColor: AppThemData.primary500,
                                                              ),
                                                              Text("Live".tr,
                                                                  style: const TextStyle(
                                                                    fontFamily: AppThemeData.regular,
                                                                    fontSize: 16,
                                                                    color: AppThemData.textGrey,
                                                                  ))
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              ),
                                            ),
                                            // spaceW(width: 16),
                                            // !ResponsiveWidget.isMobile(context) ? Expanded(child: Container()) : SizedBox(),
                                            spaceW(width: 16),
                                            !ResponsiveWidget.isMobile(context) ? Expanded(child: Container()) : const SizedBox(),
                                          ],
                                        ).paddingOnly(top: 16),
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
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  TextCustom(
                                    title: "FLUTTER WAVE".tr,
                                    fontFamily: AppThemeData.bold,
                                    fontSize: 20,
                                  ),
                                  spaceH(height: 16),
                                  !ResponsiveWidget.isMobile(context)
                                      ? Row(
                                          children: [
                                            Expanded(
                                              child: CustomTextFormField(
                                                  maxLine: 1,
                                                  title: "Name".tr,
                                                  hintText: "Enter name".tr,
                                                  prefix: const Icon(Icons.abc_outlined),
                                                  controller: paymentController.flutterWaveNameController.value),
                                            ),
                                            spaceW(width: 16),
                                            Expanded(
                                              child: CustomTextFormField(
                                                  maxLine: 1,
                                                  title: "FlutterWave Public Key".tr,
                                                  hintText: "Enter FlutterWave Public  Key".tr,
                                                  obscureText: Constant.isDemo ? true : false,
                                                  prefix: const Icon(Icons.key),
                                                  controller: paymentController.flutterWavePublicKeyKeyController.value),
                                            ),
                                            spaceW(width: 16),
                                            Expanded(
                                              child: CustomTextFormField(
                                                  maxLine: 1,
                                                  title: "FlutterWave Secret Key".tr,
                                                  hintText: "Enter FlutterWave Secret Key".tr,
                                                  obscureText: Constant.isDemo ? true : false,
                                                  prefix: const Icon(Icons.key),
                                                  controller: paymentController.flutterWaveSecretKeyKeyController.value),
                                            ),
                                          ],
                                        )
                                      : Column(
                                          children: [
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: CustomTextFormField(
                                                      maxLine: 1,
                                                      title: "Name".tr,
                                                      hintText: "Enter name".tr,
                                                      prefix: const Icon(Icons.abc_outlined),
                                                      controller: paymentController.flutterWaveNameController.value),
                                                ),
                                              ],
                                            ),
                                            spaceH(height: 16),
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: CustomTextFormField(
                                                      maxLine: 1,
                                                      title: "FlutterWave Public Key".tr,
                                                      hintText: "Enter FlutterWave Public Key".tr,
                                                      obscureText: Constant.isDemo ? true : false,
                                                      prefix: const Icon(Icons.key),
                                                      controller: paymentController.flutterWavePublicKeyKeyController.value),
                                                ),
                                              ],
                                            ),
                                            spaceH(height: 16),
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: CustomTextFormField(
                                                      maxLine: 1,
                                                      title: "FlutterWave Secret Key".tr,
                                                      hintText: "Enter FlutterWave Secret Key".tr,
                                                      obscureText: Constant.isDemo ? true : false,
                                                      prefix: const Icon(Icons.key),
                                                      controller: paymentController.flutterWaveSecretKeyKeyController.value),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                  ResponsiveWidget.isMobile(context)
                                      ? Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            spaceH(height: 16),
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: CustomTextFormField(
                                                      maxLine: 1,
                                                      title: "FlutterWave Callback Url".tr,
                                                      hintText: "Enter FlutterWave Callback Url".tr,
                                                      obscureText: Constant.isDemo ? true : false,
                                                      prefix: const Icon(Icons.key),
                                                      controller: paymentController.flutterWaveCallbackUrlController.value),
                                                ),
                                              ],
                                            ),
                                            spaceH(height: 16),
                                            Obx(
                                              () => Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  TextCustom(
                                                    title: "Status".tr,
                                                    fontSize: 14,
                                                  ),
                                                  FittedBox(
                                                    child: Row(
                                                      children: [
                                                        Row(
                                                          children: [
                                                            Radio(
                                                              value: Status.active,
                                                              groupValue: paymentController.isFlutterWaveActive.value,
                                                              onChanged: (value) {
                                                                paymentController.isFlutterWaveActive.value = value ?? Status.active;
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
                                                              groupValue: paymentController.isFlutterWaveActive.value,
                                                              onChanged: (value) {
                                                                paymentController.isFlutterWaveActive.value = value ?? Status.inactive;
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
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            spaceH(height: 16),
                                            Obx(
                                              () => Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  TextCustom(
                                                    title: "SandBox".tr,
                                                    fontSize: 14,
                                                  ),
                                                  const SizedBox(
                                                    width: 20,
                                                  ),
                                                  FittedBox(
                                                    child: Row(
                                                      children: [
                                                        Row(
                                                          children: [
                                                            Radio(
                                                              value: Status.active,
                                                              groupValue: paymentController.isFlutterWaveSandBox.value,
                                                              onChanged: (value) {
                                                                paymentController.isFlutterWaveSandBox.value = value ?? Status.active;
                                                              },
                                                              activeColor: AppThemData.primary500,
                                                            ),
                                                            Text("Test".tr,
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
                                                              groupValue: paymentController.isFlutterWaveSandBox.value,
                                                              onChanged: (value) {
                                                                paymentController.isFlutterWaveSandBox.value = value ?? Status.inactive;
                                                              },
                                                              activeColor: AppThemData.primary500,
                                                            ),
                                                            Text("Live".tr,
                                                                style: const TextStyle(
                                                                  fontFamily: AppThemeData.regular,
                                                                  fontSize: 16,
                                                                  color: AppThemData.textGrey,
                                                                ))
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ),
                                          ],
                                        )
                                      : Row(
                                          children: [
                                            Expanded(
                                              child: CustomTextFormField(
                                                  maxLine: 1,
                                                  title: "FlutterWave Callback Url".tr,
                                                  hintText: "Enter FlutterWave Callback Url".tr,
                                                  obscureText: Constant.isDemo ? true : false,
                                                  prefix: const Icon(Icons.key),
                                                  controller: paymentController.flutterWaveCallbackUrlController.value),
                                            ),
                                            spaceW(width: 16),
                                            Obx(
                                              () => Expanded(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    TextCustom(
                                                      title: "Status".tr,
                                                      fontSize: 14,
                                                    ),
                                                    FittedBox(
                                                      child: Row(
                                                        children: [
                                                          Row(
                                                            children: [
                                                              Radio(
                                                                value: Status.active,
                                                                groupValue: paymentController.isFlutterWaveActive.value,
                                                                onChanged: (value) {
                                                                  paymentController.isFlutterWaveActive.value = value ?? Status.active;
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
                                                                groupValue: paymentController.isFlutterWaveActive.value,
                                                                onChanged: (value) {
                                                                  paymentController.isFlutterWaveActive.value = value ?? Status.inactive;
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
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            spaceW(width: 16),
                                            Obx(
                                              () => Expanded(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    TextCustom(
                                                      title: "SandBox".tr,
                                                      fontSize: 14,
                                                    ),
                                                    const SizedBox(
                                                      width: 20,
                                                    ),
                                                    FittedBox(
                                                      child: Row(
                                                        children: [
                                                          Row(
                                                            children: [
                                                              Radio(
                                                                value: Status.active,
                                                                groupValue: paymentController.isFlutterWaveSandBox.value,
                                                                onChanged: (value) {
                                                                  paymentController.isFlutterWaveSandBox.value = value ?? Status.active;
                                                                },
                                                                activeColor: AppThemData.primary500,
                                                              ),
                                                              Text("Test".tr,
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
                                                                groupValue: paymentController.isFlutterWaveSandBox.value,
                                                                onChanged: (value) {
                                                                  paymentController.isFlutterWaveSandBox.value = value ?? Status.inactive;
                                                                },
                                                                activeColor: AppThemData.primary500,
                                                              ),
                                                              Text("Live".tr,
                                                                  style: const TextStyle(
                                                                    fontFamily: AppThemeData.regular,
                                                                    fontSize: 16,
                                                                    color: AppThemData.textGrey,
                                                                  ))
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ).paddingOnly(top: 16),
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
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  TextCustom(
                                    title: "Cash".tr.toUpperCase(),
                                    fontFamily: AppThemeData.bold,
                                    fontSize: 20,
                                  ),
                                  spaceH(height: 16),
                                  CustomTextFormField(
                                      maxLine: 1,
                                      title: "Name".tr,
                                      hintText: "Enter name".tr,
                                      prefix: const Icon(Icons.abc_outlined),
                                      controller: paymentController.cashNameController.value),
                                  spaceW(width: 16),
                                  spaceH(height: 16),
                                  Row(
                                    children: [
                                      Obx(
                                        () => Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              TextCustom(
                                                title: "Status".tr,
                                                fontSize: 14,
                                              ),
                                              FittedBox(
                                                child: Row(
                                                  children: [
                                                    Row(
                                                      children: [
                                                        Radio(
                                                          value: Status.active,
                                                          groupValue: paymentController.isCashActive.value,
                                                          onChanged: (value) {
                                                            paymentController.isCashActive.value = value ?? Status.active;
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
                                                          groupValue: paymentController.isCashActive.value,
                                                          onChanged: (value) {
                                                            paymentController.isCashActive.value = value ?? Status.inactive;
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
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                      spaceW(width: 16),
                                    ],
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
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  TextCustom(
                                    title: "Wallet".tr.toUpperCase(),
                                    fontFamily: AppThemeData.bold,
                                    fontSize: 20,
                                  ),
                                  spaceH(height: 16),
                                  CustomTextFormField(
                                      maxLine: 1,
                                      title: "Name".tr,
                                      hintText: "Enter name".tr,
                                      prefix: const Icon(Icons.abc_outlined),
                                      controller: paymentController.walletNameController.value),
                                  spaceH(height: 16),
                                  Row(
                                    children: [
                                      Obx(
                                        () => Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              TextCustom(
                                                title: "Status".tr,
                                                fontSize: 14,
                                              ),
                                              FittedBox(
                                                child: Row(
                                                  children: [
                                                    Row(
                                                      children: [
                                                        Radio(
                                                          value: Status.active,
                                                          groupValue: paymentController.isWalletActive.value,
                                                          onChanged: (value) {
                                                            paymentController.isWalletActive.value = value ?? Status.active;
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
                                                          groupValue: paymentController.isWalletActive.value,
                                                          onChanged: (value) {
                                                            paymentController.isWalletActive.value = value ?? Status.inactive;
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
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
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
                                      controller.savePayment();
                                    }
                                  },
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}
