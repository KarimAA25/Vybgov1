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
import 'package:country_code_picker/country_code_picker.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:provider/provider.dart';

import '../../../components/custom_button.dart';
import '../../../routes/app_pages.dart';
import '../../../utils/screen_size.dart';
import '../controllers/app_settings_controller.dart';

class AppSettingsView extends GetView<AppSettingsController> {
  const AppSettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetBuilder<AppSettingsController>(
      init: AppSettingsController(),
      builder: (appSettingsController) {
        return SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Obx(
                () => ContainerCustom(
                  child: controller.isLoading.value
                      ? Padding(
                          padding: paddingEdgeInsets(),
                          child: Constant.loader(),
                        )
                      : ResponsiveWidget.isDesktop(context)
                          ? Column(
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
                                Padding(
                                  padding: paddingEdgeInsets(horizontal: 24, vertical: 24),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                TextCustom(
                                                  title: "Enable Dynamic Map Interface".tr.toUpperCase(),
                                                  fontFamily: AppThemeData.bold,
                                                  fontSize: 20,
                                                ),
                                                InkWell(
                                                  onTap: () {
                                                    showDialog(
                                                      context: context,
                                                      builder: (context) => homeScreenInfoDialog(context),
                                                    );
                                                  },
                                                  child: SvgPicture.asset(
                                                    "assets/icons/ic_info.svg",
                                                    height: 20,
                                                    color: AppThemData.greyShade400,
                                                  ),
                                                ),
                                                // Tooltip(
                                                //   message:
                                                //       "Turn this on to activate the map-based home experience where users can view their current location and Rides.\nWhen turned off, customers will see the regular home screen layout without live map components.",
                                                //   child: SvgPicture.asset(
                                                //     "assets/icons/ic_info.svg",
                                                //     height: 20,
                                                //     color: AppThemData.greyShade400,
                                                //   ),
                                                // ),
                                              ],
                                            ),
                                            const SizedBox(
                                              height: 12,
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
                                                            groupValue: controller.isHomeFeatureEnable.value,
                                                            onChanged: (value) {
                                                              controller.isHomeFeatureEnable.value = value ?? Status.active;
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
                                                            groupValue: controller.isHomeFeatureEnable.value,
                                                            onChanged: (value) {
                                                              controller.isHomeFeatureEnable.value = value ?? Status.inactive;
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
                                      spaceW(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                TextCustom(title: "Country Code", fontSize: 14),
                                                Tooltip(
                                                  message: "Choose the default country code used for user sign-in and phone verification in your app.",
                                                  child: const Icon(
                                                    Icons.info_outline_rounded,
                                                    size: 20,
                                                    color: AppThemData.greyShade400,
                                                  ),
                                                )
                                              ],
                                            ),
                                            const SizedBox(height: 10),
                                            Container(
                                              width: double.infinity,
                                              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                                              decoration: BoxDecoration(
                                                  borderRadius: const BorderRadius.all(Radius.circular(8)),
                                                  border: Border.all(
                                                    color: themeChange.isDarkTheme() ? AppThemData.greyShade950 : AppThemData.greyShade100,
                                                  )),
                                              child: CountryCodePicker(
                                                enabled: true,
                                                showFlag: true,
                                                showCountryOnly: true,
                                                closeIcon: Icon(Icons.close_rounded, color: AppThemData.greyShade500),
                                                initialSelection: controller.countryCodeController.text,
                                                comparator: (a, b) => b.name!.compareTo(a.name.toString()),
                                                textStyle: TextStyle(
                                                    fontSize: 16,
                                                    fontFamily: AppThemeData.medium,
                                                    color: themeChange.isDarkTheme() ? AppThemData.greyShade100 : AppThemData.greyShade900),
                                                dialogBackgroundColor: themeChange.isDarkTheme() ? AppThemData.primaryBlack : AppThemData.primaryWhite,
                                                dialogTextStyle: TextStyle(fontSize: 16, fontFamily: AppThemeData.regular, color: AppThemData.greyShade500),
                                                dialogSize: Size(600, MediaQuery.of(context).size.height * 0.7),
                                                flagDecoration: const BoxDecoration(
                                                  borderRadius: BorderRadius.all(Radius.circular(2)),
                                                ),
                                                onChanged: (value) {
                                                  controller.countryCodeController.text = value.dialCode.toString();
                                                },
                                                builder: (p0) {
                                                  return Row(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      Container(
                                                        clipBehavior: Clip.hardEdge,
                                                        margin: const EdgeInsets.only(right: 8.0),
                                                        decoration: const BoxDecoration(
                                                          borderRadius: BorderRadius.all(Radius.circular(2)),
                                                        ),
                                                        child: Image.asset(
                                                          p0!.flagUri ?? '',
                                                          package: 'country_code_picker',
                                                          width: 26,
                                                          height: 26,
                                                        ),
                                                      ),
                                                      Text("${p0.name} (${p0.dialCode})",
                                                          style: TextStyle(
                                                            fontSize: 14,
                                                            color: themeChange.isDarkTheme() ? AppThemData.primaryWhite : AppThemData.greyShade950,
                                                            fontFamily: AppThemeData.medium,
                                                          )),
                                                      const SizedBox(width: 4),
                                                      const Icon(Icons.keyboard_arrow_down_rounded)
                                                    ],
                                                  );
                                                },
                                                searchStyle: TextStyle(
                                                    fontSize: 16,
                                                    fontFamily: AppThemeData.medium,
                                                    color: themeChange.isDarkTheme() ? AppThemData.greyShade100 : AppThemData.greyShade950),
                                                searchDecoration: InputDecoration(
                                                  hintText: 'Search country',
                                                  hintStyle: TextStyle(
                                                      fontSize: 14,
                                                      color: themeChange.isDarkTheme() ? AppThemData.greyShade400 : AppThemData.greyShade950,
                                                      fontWeight: FontWeight.w500,
                                                      fontFamily: AppThemeData.medium),
                                                  isDense: true,
                                                  filled: true,
                                                  fillColor: themeChange.isDarkTheme() ? AppThemData.primaryBlack : AppThemData.greyShade100,
                                                  contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                                                  prefixIcon: Icon(
                                                    Icons.search,
                                                    size: 20,
                                                    color: themeChange.isDarkTheme() ? AppThemData.greyShade300 : AppThemData.greyShade500,
                                                  ),
                                                  focusedBorder: OutlineInputBorder(
                                                    borderRadius: const BorderRadius.all(Radius.circular(8)),
                                                    borderSide: BorderSide(
                                                      color: themeChange.isDarkTheme() ? AppThemData.greyShade950 : AppThemData.greyShade100,
                                                    ),
                                                  ),
                                                  enabledBorder: OutlineInputBorder(
                                                    borderRadius: const BorderRadius.all(Radius.circular(8)),
                                                    borderSide: BorderSide(
                                                      color: themeChange.isDarkTheme() ? AppThemData.greyShade950 : AppThemData.greyShade100,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
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
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            TextCustom(
                                              title: "Refer & Earn".tr.toUpperCase(),
                                              fontFamily: AppThemeData.bold,
                                              fontSize: 20,
                                            ),
                                            spaceH(height: 12),
                                            CustomTextFormField(
                                                title: "Refer Credit".tr,
                                                hintText: "Enter referral credit amount".tr,
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
                                                controller: appSettingsController.referralAmountController.value),
                                          ],
                                        ),
                                      ),
                                      spaceW(width: 16),
                                      Expanded(
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            TextCustom(
                                              title: "EMERGENCY SOS".tr.toUpperCase(),
                                              fontFamily: AppThemeData.bold,
                                              fontSize: 20,
                                            ),
                                            spaceH(height: 12),
                                            CustomTextFormField(
                                                title: "Emergency Phone Number".tr,
                                                hintText: "Enter Emergency Phone Number".tr,
                                                inputFormatters: [
                                                  FilteringTextInputFormatter.allow(RegExp('[0-9.]')),
                                                ],
                                                prefix: Padding(
                                                  padding: paddingEdgeInsets(vertical: 10, horizontal: 10),
                                                  child: Icon(
                                                    Icons.phone_in_talk,
                                                    color: themeChange.isDarkTheme() ? AppThemData.primaryWhite : AppThemData.primaryBlack,
                                                    size: 20,
                                                  ),
                                                ),
                                                controller: appSettingsController.sosNumberController),
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
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            TextCustom(
                                              title: "Document Verification".tr.toUpperCase(),
                                              fontFamily: AppThemeData.bold,
                                              fontSize: 20,
                                            ),
                                            spaceH(height: 12),
                                            TextCustom(
                                              title: "Do you Want to Enable Document Verification Flow?".tr,
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
                                                            groupValue: controller.isDocumentVerificationActive.value,
                                                            onChanged: (value) {
                                                              controller.isDocumentVerificationActive.value = value ?? Status.active;
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
                                                            groupValue: controller.isDocumentVerificationActive.value,
                                                            onChanged: (value) {
                                                              controller.isDocumentVerificationActive.value = value ?? Status.inactive;
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
                                      spaceW(width: 16),
                                      Expanded(
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            TextCustom(
                                              title: "Driver Approved".tr.toUpperCase(),
                                              fontFamily: AppThemeData.bold,
                                              fontSize: 20,
                                            ),
                                            spaceH(height: 12),
                                            TextCustom(
                                              title: "Do you want to enable Driver Auto Approver?".tr,
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
                                                            groupValue: controller.isDriverApprovedActive.value,
                                                            onChanged: (value) {
                                                              controller.isDriverApprovedActive.value = value ?? Status.active;
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
                                                            groupValue: controller.isDriverApprovedActive.value,
                                                            onChanged: (value) {
                                                              controller.isDriverApprovedActive.value = value ?? Status.inactive;
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
                                        title: "Wallet Settings".tr.toUpperCase(),
                                        fontFamily: AppThemeData.bold,
                                        fontSize: 20,
                                      ),
                                      spaceH(height: 12),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: CustomTextFormField(
                                                title: "Minimum wallet amount to deposit".tr,
                                                // width: 0.35.sw,
                                                hintText: "Enter minimum wallet amount to deposit".tr,
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
                                                controller: appSettingsController.minimumDepositController.value),
                                          ),
                                          spaceW(width: 16),
                                          Expanded(
                                            child: CustomTextFormField(
                                                title: "Minimum wallet amount to withdrawal".tr,
                                                // width: 0.35.sw,
                                                hintText: "Enter minimum wallet amount to withdrawal".tr,
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
                                                controller: appSettingsController.minimumWithdrawalController.value),
                                          ),
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
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      TextCustom(
                                        title: "Driver Settings".tr.toUpperCase(),
                                        fontFamily: AppThemeData.bold,
                                        fontSize: 20,
                                      ),
                                      // spaceH(height: 8),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    SizedBox(
                                                      // width: ResponsiveWidget.isDesktop(context) ? 250 : 80,
                                                      child: TextCustom(
                                                        maxLine: 1,
                                                        title: "Global Distance Type".tr,
                                                        fontSize: 14,
                                                      ),
                                                    ),
                                                    Tooltip(
                                                      message: 'Calculation base on km and miles'.tr,
                                                      child: IconButton(
                                                        icon: const Icon(
                                                          Icons.info_outline_rounded,
                                                          size: 20,
                                                          color: AppThemData.greyShade400,
                                                        ),
                                                        onPressed: () {},
                                                      ),
                                                    )
                                                  ],
                                                ),
                                                Obx(
                                                  () => DropdownButtonFormField(
                                                    isExpanded: true,
                                                    dropdownColor: themeChange.isDarkTheme() ? AppThemData.greyShade950 : AppThemData.greyShade50,
                                                    style: TextStyle(
                                                      fontFamily: AppThemeData.medium,
                                                      color: themeChange.isDarkTheme() ? AppThemData.greyShade100 : AppThemData.greyShade800,
                                                    ),
                                                    hint: TextCustom(title: 'Global Distance Type'.tr),
                                                    onChanged: (String? taxType) {
                                                      appSettingsController.selectedDistanceType.value = taxType ?? "Km";
                                                    },
                                                    value: appSettingsController.selectedDistanceType.value,
                                                    items: appSettingsController.distanceType.map<DropdownMenuItem<String>>((String value) {
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
                                                tooltipsText: "Driver location update fro live tracking".tr,
                                                tooltipsShow: true,
                                                title: "Driver Location Update".tr,
                                                hintText: "Enter Driver Location Update".tr,
                                                inputFormatters: [
                                                  FilteringTextInputFormatter.allow(RegExp('[0-9.]')),
                                                ],
                                                prefix: Padding(
                                                  padding: paddingEdgeInsets(vertical: 10, horizontal: 10),
                                                  child: Icon(Icons.location_on, color: themeChange.isDarkTheme() ? AppThemData.primaryWhite : AppThemData.primaryBlack),
                                                ),
                                                controller: appSettingsController.globalDriverLocationUpdateController.value),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: CustomTextFormField(
                                                textInputType: TextInputType.name,
                                                tooltipsText: "Near by driver fide out radius ".tr,
                                                tooltipsShow: true,
                                                title: "Radius".tr,
                                                hintText: "Enter radius".tr,
                                                prefix: Padding(
                                                  padding: const EdgeInsets.all(10.0),
                                                  child: Icon(Icons.location_on, color: themeChange.isDarkTheme() ? AppThemData.primaryWhite : AppThemData.primaryBlack),
                                                ),
                                                inputFormatters: [
                                                  FilteringTextInputFormatter.allow(RegExp('[0-9.]')),
                                                ],
                                                controller: appSettingsController.globalRadiusController.value),
                                          ),
                                          spaceW(width: 16),
                                          Expanded(
                                            child: CustomTextFormField(
                                                title: "Minimum amount to accept ride".tr,
                                                tooltipsText: "Minimum amount to accept ride".tr,
                                                tooltipsShow: true,
                                                hintText: "Enter minimum amount to accept ride".tr,
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
                                                controller: appSettingsController.minimumAmountAcceptRideController.value),
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
                                        title: "Loyalty program".tr.toUpperCase(),
                                        fontFamily: AppThemeData.bold,
                                        fontSize: 20,
                                      ),
                                      spaceH(height: 8),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: CustomTextFormField(
                                                tooltipsText:
                                                    "The number of loyalty points a customer earns for each completed ride.\n\nExample: If you set this to 10, the user earns 10 points per ride.",
                                                // width: 0.35.sw,
                                                tooltipsShow: true,
                                                title: "Point Per Ride".tr,
                                                hintText: "Enter Point Per Ride".tr,
                                                inputFormatters: [
                                                  FilteringTextInputFormatter.allow(RegExp('[0-9.]')),
                                                ],
                                                prefix: Padding(
                                                  padding: paddingEdgeInsets(vertical: 10, horizontal: 10),
                                                  child: Icon(Icons.emoji_events, color: themeChange.isDarkTheme() ? AppThemData.primaryWhite : AppThemData.primaryBlack),
                                                  // child: TextCustom(
                                                  //   title: '${Constant.currencyModel!.symbol}',
                                                  //   fontSize: 18,
                                                  // ),
                                                ),
                                                controller: appSettingsController.loyaltyPointPerRideController.value),
                                          ),
                                          spaceW(width: 16),
                                          Expanded(
                                            child: CustomTextFormField(
                                                textInputType: TextInputType.name,
                                                tooltipsText:
                                                    "The value of each loyalty point in your currency.\n\nExample: If the conversion rate is 0.1, then 10 points = \$1.00.\n\nFormula: Wallet Value = Points × Conversion Rate",
                                                tooltipsShow: true,
                                                title: "Conversion Rate".tr,
                                                hintText: "e.g., 0.1".tr,
                                                prefix: Padding(
                                                  padding: const EdgeInsets.all(10.0),
                                                  child: Icon(Icons.swap_horiz, color: themeChange.isDarkTheme() ? AppThemData.primaryWhite : AppThemData.primaryBlack),
                                                ),
                                                inputFormatters: [
                                                  FilteringTextInputFormatter.allow(RegExp('[0-9.]')),
                                                ],
                                                controller: appSettingsController.loyaltyConversionRideController.value),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: CustomTextFormField(
                                                tooltipsText:
                                                    "The minimum number of points required before a user can redeem them for wallet balance.\n\nExample: If set to 100, users must collect at least 100 points to redeem.",
                                                tooltipsShow: true,
                                                title: "Minimum Redeemable Points".tr,
                                                hintText: "e.g., 100 points".tr,
                                                inputFormatters: [
                                                  FilteringTextInputFormatter.allow(RegExp('[0-9.]')),
                                                ],
                                                prefix: Padding(
                                                  padding: const EdgeInsets.all(10.0),
                                                  child: Icon(Icons.check_circle, color: themeChange.isDarkTheme() ? AppThemData.primaryWhite : AppThemData.primaryBlack),
                                                ),
                                                controller: appSettingsController.loyaltyMinimumRedeemablePointsController.value),
                                          ),
                                          spaceW(width: 16),
                                          Expanded(child: SizedBox())
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
                                        title: "Intercity Settings".tr.toUpperCase(),
                                        fontFamily: AppThemeData.bold,
                                        fontSize: 20,
                                      ),
                                      spaceH(height: 8),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: CustomTextFormField(
                                                textInputType: TextInputType.name,
                                                tooltipsText: "Near by ride fide out radius ".tr,
                                                tooltipsShow: true,
                                                title: "Radius".tr,
                                                hintText: "Enter radius".tr,
                                                prefix: Padding(
                                                  padding: const EdgeInsets.all(10.0),
                                                  child: Icon(Icons.location_on, color: themeChange.isDarkTheme() ? AppThemData.primaryWhite : AppThemData.primaryBlack),
                                                ),
                                                inputFormatters: [
                                                  FilteringTextInputFormatter.allow(RegExp('[0-9.]')),
                                                ],
                                                controller: appSettingsController.globalInterCityRadiusController.value),
                                          ),
                                          spaceW(width: 16),
                                          const Expanded(child: SizedBox()),
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
                                        title: "Night Timing".tr.toUpperCase(),
                                        fontFamily: AppThemeData.bold,
                                        fontSize: 20,
                                      ),
                                      spaceH(height: 8),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: CustomTextFormField(
                                                title: "Start Time".tr,
                                                // width: 0.35.sw,
                                                hintText: "Enter Start Time for Night".tr,
                                                maxLine: 1,
                                                controller: appSettingsController.nightStartTimeController.value,
                                                onPress: () async {
                                                  TimeOfDay? picked = await showTimePicker(
                                                    context: context,
                                                    initialTime: TimeOfDay.now(),
                                                    builder: (BuildContext context, Widget? child) {
                                                      return MediaQuery(
                                                        data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
                                                        child: child!,
                                                      );
                                                    },
                                                  );

                                                  if (picked != null) {
                                                    final now = DateTime.now();
                                                    final formattedTime = DateFormat("HH:mm").format(
                                                      DateTime(now.year, now.month, now.day, picked.hour, picked.minute),
                                                    );
                                                    controller.nightStartTimeController.value.text = formattedTime;
                                                  }
                                                },
                                                prefix: Padding(
                                                    padding: const EdgeInsets.all(10),
                                                    child: SvgPicture.asset(
                                                      "assets/icons/ic_clock.svg",
                                                      height: 16,
                                                      color: themeChange.isDarkTheme() ? AppThemData.primaryWhite : AppThemData.primaryBlack,
                                                    ))),
                                          ),
                                          spaceW(width: 16),
                                          Expanded(
                                            child: CustomTextFormField(
                                                title: "End Time".tr,
                                                // width: 0.35.sw,
                                                hintText: "Enter End Time for Night".tr,
                                                maxLine: 1,
                                                controller: appSettingsController.nightEndTimeController.value,
                                                onPress: () async {
                                                  TimeOfDay? picked = await showTimePicker(
                                                    context: context,
                                                    initialTime: TimeOfDay.now(),
                                                    builder: (BuildContext context, Widget? child) {
                                                      return MediaQuery(
                                                        data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
                                                        child: child!,
                                                      );
                                                    },
                                                  );

                                                  if (picked != null) {
                                                    final now = DateTime.now();
                                                    final formattedTime = DateFormat("HH:mm").format(
                                                      DateTime(now.year, now.month, now.day, picked.hour, picked.minute),
                                                    );
                                                    controller.nightEndTimeController.value.text = formattedTime;
                                                  }
                                                },
                                                prefix: Padding(
                                                    padding: const EdgeInsets.all(10),
                                                    child: SvgPicture.asset(
                                                      "assets/icons/ic_clock.svg",
                                                      height: 16,
                                                      color: themeChange.isDarkTheme() ? AppThemData.primaryWhite : AppThemData.primaryBlack,
                                                    ))),
                                          ),
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
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      TextCustom(
                                        title: "Ride Cancellation Timing".tr.toUpperCase(),
                                        fontFamily: AppThemeData.bold,
                                        fontSize: 20,
                                      ),
                                      spaceH(height: 8),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: CustomTextFormField(
                                                title: "Seconds".tr,
                                                // width: 0.35.sw,
                                                hintText: "Enter second for cancel Ride".tr,
                                                maxLine: 1,
                                                controller: appSettingsController.secondsForRideCancelController.value,
                                                tooltipsShow: true,
                                                tooltipsText: "Enter seconds to cancel ride when Driver not accept the Ride".tr,
                                                prefix: Padding(
                                                    padding: const EdgeInsets.all(10),
                                                    child: SvgPicture.asset(
                                                      "assets/icons/ic_clock.svg",
                                                      height: 16,
                                                      color: themeChange.isDarkTheme() ? AppThemData.primaryWhite : AppThemData.primaryBlack,
                                                    ))),
                                          ),
                                          spaceW(width: 16),
                                          const Expanded(child: SizedBox()),
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
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      TextCustom(
                                        title: "App Theme".tr.toUpperCase(),
                                        fontFamily: AppThemeData.bold,
                                        fontSize: 20,
                                      ),
                                      spaceH(height: 12),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: CustomTextFormField(
                                                title: "App Colors".tr,
                                                // width: 0.35.sw,
                                                hintText: "Select App Color".tr,
                                                maxLine: 1,
                                                prefix: Padding(
                                                  padding: const EdgeInsets.all(8.0),
                                                  child: InkWell(
                                                      onTap: () async {
                                                        Color newColor = await showColorPickerDialog(
                                                          context,
                                                          appSettingsController.selectedColor.value,
                                                          width: 40,
                                                          height: 40,
                                                          spacing: 0,
                                                          runSpacing: 0,
                                                          borderRadius: 0,
                                                          enableOpacity: true,
                                                          showColorCode: true,
                                                          colorCodeHasColor: true,
                                                          enableShadesSelection: false,
                                                          pickersEnabled: <ColorPickerType, bool>{
                                                            ColorPickerType.wheel: true,
                                                          },
                                                          copyPasteBehavior: const ColorPickerCopyPasteBehavior(
                                                            copyButton: true,
                                                            pasteButton: false,
                                                            longPressMenu: false,
                                                          ),
                                                          actionButtons: const ColorPickerActionButtons(
                                                            okButton: true,
                                                            closeButton: true,
                                                            dialogActionButtons: false,
                                                          ),
                                                        );
                                                        appSettingsController.colourCodeController.value.text = "#${newColor.hex}";
                                                        appSettingsController.selectedColor.value = newColor;
                                                      },
                                                      child: Obx(
                                                        () => ClipRRect(
                                                            borderRadius: const BorderRadius.all(Radius.circular(5)),
                                                            child: Container(
                                                              height: 12,
                                                              width: 80,
                                                              color: appSettingsController.selectedColor.value,
                                                            )),
                                                      )),
                                                ),
                                                controller: appSettingsController.colourCodeController.value),
                                          ),
                                          spaceW(width: 16),
                                          Expanded(
                                            child: CustomTextFormField(
                                                title: "App Name".tr,
                                                // width: 0.35.sw,
                                                hintText: "Enter App Name".tr,
                                                inputFormatters: [
                                                  FilteringTextInputFormatter.allow(RegExp('[a-zA-Z ]')),
                                                ],
                                                prefix: const Icon(Icons.drive_file_rename_outline_outlined),
                                                controller: appSettingsController.appNameController.value),
                                          ),
                                        ],
                                      ),
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
                                            controller.saveSettingData();
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
                                Padding(
                                  padding: paddingEdgeInsets(horizontal: 24, vertical: 24),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          TextCustom(
                                            title: "Enable Dynamic Map Interface".tr.toUpperCase(),
                                            fontFamily: AppThemeData.bold,
                                            fontSize: 20,
                                          ),
                                          InkWell(
                                            onTap: () {
                                              showDialog(
                                                context: context,
                                                builder: (context) => homeScreenInfoDialog(context),
                                              );
                                            },
                                            child: SvgPicture.asset(
                                              "assets/icons/ic_info.svg",
                                              height: 20,
                                              color: AppThemData.greyShade400,
                                            ),
                                          ),
                                          // Tooltip(
                                          //   message:
                                          //       "Turn this on to activate the map-based home experience where users can view their current location and Rides.\nWhen turned off, customers will see the regular home screen layout without live map components.",
                                          //   child: SvgPicture.asset(
                                          //     "assets/icons/ic_info.svg",
                                          //     height: 20,
                                          //     color: AppThemData.greyShade400,
                                          //   ),
                                          // ),
                                        ],
                                      ),
                                      const SizedBox(
                                        height: 12,
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
                                                      groupValue: controller.isHomeFeatureEnable.value,
                                                      onChanged: (value) {
                                                        controller.isHomeFeatureEnable.value = value ?? Status.active;
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
                                                      groupValue: controller.isHomeFeatureEnable.value,
                                                      onChanged: (value) {
                                                        controller.isHomeFeatureEnable.value = value ?? Status.inactive;
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
                                  height: 1,
                                  child: ContainerCustom(
                                    color: themeChange.isDarkTheme() ? AppThemData.greyShade900 : AppThemData.greyShade100,
                                  ),
                                ),
                                Padding(
                                    padding: paddingEdgeInsets(horizontal: 24, vertical: 24),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            TextCustom(title: "Country Code", fontSize: 14),
                                            Tooltip(
                                              message: "Choose the default country code used for user sign-in and phone verification in your app.".tr,
                                              child: const Icon(
                                                Icons.info_outline_rounded,
                                                size: 20,
                                                color: AppThemData.greyShade400,
                                              ),
                                            )
                                          ],
                                        ),
                                        const SizedBox(height: 10),
                                        Container(
                                          width: double.infinity,
                                          padding: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                                          decoration: BoxDecoration(
                                              borderRadius: const BorderRadius.all(Radius.circular(8)),
                                              border: Border.all(
                                                color: themeChange.isDarkTheme() ? AppThemData.greyShade950 : AppThemData.greyShade100,
                                              )),
                                          child: CountryCodePicker(
                                            enabled: true,
                                            showFlag: true,
                                            showCountryOnly: false,
                                            showOnlyCountryWhenClosed: false,
                                            closeIcon: Icon(Icons.close_rounded, color: AppThemData.greyShade500),
                                            initialSelection: controller.countryCodeController.text,
                                            comparator: (a, b) => b.name!.compareTo(a.name.toString()),
                                            textStyle: TextStyle(
                                                fontSize: 16,
                                                fontFamily: AppThemeData.medium,
                                                color: themeChange.isDarkTheme() ? AppThemData.greyShade100 : AppThemData.greyShade900),
                                            dialogBackgroundColor: themeChange.isDarkTheme() ? AppThemData.primaryBlack : AppThemData.primaryWhite,
                                            dialogTextStyle: TextStyle(fontSize: 16, fontFamily: AppThemeData.regular, color: AppThemData.greyShade500),
                                            dialogSize: Size(600, MediaQuery.of(context).size.height * 0.7),
                                            flagDecoration: const BoxDecoration(
                                              borderRadius: BorderRadius.all(Radius.circular(2)),
                                            ),
                                            onChanged: (value) {
                                              controller.countryCodeController.text = value.dialCode.toString();
                                            },
                                            builder: (p0) {
                                              return Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Container(
                                                    clipBehavior: Clip.hardEdge,
                                                    margin: const EdgeInsets.only(right: 8.0),
                                                    decoration: const BoxDecoration(
                                                      borderRadius: BorderRadius.all(Radius.circular(2)),
                                                    ),
                                                    child: Image.asset(
                                                      p0!.flagUri ?? '',
                                                      package: 'country_code_picker',
                                                      width: 26,
                                                      height: 26,
                                                    ),
                                                  ),
                                                  Text("${p0.name} (${p0.dialCode})",
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                        color: themeChange.isDarkTheme() ? AppThemData.primaryWhite : AppThemData.greyShade950,
                                                        fontFamily: AppThemeData.medium,
                                                      )),
                                                  const SizedBox(width: 4),
                                                  const Icon(Icons.keyboard_arrow_down_rounded)
                                                ],
                                              );
                                            },
                                            searchStyle: TextStyle(
                                                fontSize: 16,
                                                fontFamily: AppThemeData.medium,
                                                color: themeChange.isDarkTheme() ? AppThemData.greyShade100 : AppThemData.greyShade950),
                                            searchDecoration: InputDecoration(
                                              hintText: 'Search country'.tr,
                                              hintStyle: TextStyle(
                                                  fontSize: 14,
                                                  color: themeChange.isDarkTheme() ? AppThemData.greyShade400 : AppThemData.greyShade950,
                                                  fontWeight: FontWeight.w500,
                                                  fontFamily: AppThemeData.medium),
                                              isDense: true,
                                              filled: true,
                                              fillColor: themeChange.isDarkTheme() ? AppThemData.primaryBlack : AppThemData.greyShade100,
                                              contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                                              prefixIcon: Icon(
                                                Icons.search,
                                                size: 20,
                                                color: themeChange.isDarkTheme() ? AppThemData.greyShade300 : AppThemData.greyShade500,
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderRadius: const BorderRadius.all(Radius.circular(8)),
                                                borderSide: BorderSide(
                                                  color: themeChange.isDarkTheme() ? AppThemData.greyShade950 : AppThemData.greyShade100,
                                                ),
                                              ),
                                              enabledBorder: OutlineInputBorder(
                                                borderRadius: const BorderRadius.all(Radius.circular(8)),
                                                borderSide: BorderSide(
                                                  color: themeChange.isDarkTheme() ? AppThemData.greyShade950 : AppThemData.greyShade100,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    )),
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
                                        title: "Refer & Earn".tr.toUpperCase(),
                                        fontFamily: AppThemeData.bold,
                                        fontSize: 20,
                                      ),
                                      spaceH(),
                                      CustomTextFormField(
                                          title: "Refer Credit".tr,
                                          hintText: "Enter referral credit amount".tr,
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
                                          controller: appSettingsController.referralAmountController.value),
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
                                        title: "EMERGENCY SOS".tr,
                                        fontFamily: AppThemeData.bold,
                                        fontSize: 20,
                                      ),
                                      spaceH(height: 12),
                                      CustomTextFormField(
                                          title: "Emergency Phone Number".tr,
                                          hintText: "Enter Emergency Phone Number".tr,
                                          inputFormatters: [
                                            FilteringTextInputFormatter.allow(RegExp('[0-9.]')),
                                          ],
                                          prefix: Padding(
                                            padding: paddingEdgeInsets(vertical: 10, horizontal: 10),
                                            child: Icon(
                                              Icons.phone_in_talk,
                                              color: themeChange.isDarkTheme() ? AppThemData.primaryWhite : AppThemData.primaryBlack,
                                              size: 20,
                                            ),
                                          ),
                                          controller: appSettingsController.sosNumberController),
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
                                        title: "Document Verification".tr.toUpperCase(),
                                        fontFamily: AppThemeData.bold,
                                        fontSize: 20,
                                      ),
                                      spaceH(height: 12),
                                      TextCustom(
                                        title: "Do you Want to Enable Document Verification Flow?".tr,
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
                                                      groupValue: controller.isDocumentVerificationActive.value,
                                                      onChanged: (value) {
                                                        controller.isDocumentVerificationActive.value = value ?? Status.active;
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
                                                      groupValue: controller.isDocumentVerificationActive.value,
                                                      onChanged: (value) {
                                                        controller.isDocumentVerificationActive.value = value ?? Status.inactive;
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
                                        title: "Wallet Settings".tr.toUpperCase(),
                                        fontFamily: AppThemeData.bold,
                                        fontSize: 20,
                                      ),
                                      spaceH(),
                                      CustomTextFormField(
                                          title: "Minimum wallet amount to deposit".tr,
                                          // width: 0.35.sw,
                                          hintText: "Enter minimum wallet amount to deposit".tr,
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
                                          controller: appSettingsController.minimumDepositController.value),
                                      CustomTextFormField(
                                          title: "Minimum wallet amount to withdrawal".tr,
                                          // width: 0.35.sw,
                                          hintText: "Enter minimum wallet amount to withdrawal".tr,
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
                                          controller: appSettingsController.minimumWithdrawalController.value),
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
                                        title: "Driver Settings".tr.toUpperCase(),
                                        fontFamily: AppThemeData.bold,
                                        fontSize: 20,
                                      ),
                                      spaceH(height: 8),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              SizedBox(
                                                child: TextCustom(
                                                  maxLine: 1,
                                                  title: "Global Distance Type".tr,
                                                ),
                                              ),
                                              const Tooltip(
                                                message: 'Calculation base on km and miles',
                                                child: Icon(
                                                  Icons.info_outline_rounded,
                                                  size: 20,
                                                  color: AppThemData.greyShade400,
                                                ),
                                              )
                                            ],
                                          ),
                                          spaceH(height: 8),
                                          Obx(
                                            () => DropdownButtonFormField(
                                              isExpanded: true,
                                              dropdownColor: themeChange.isDarkTheme() ? AppThemData.greyShade950 : AppThemData.greyShade50,
                                              style: TextStyle(
                                                fontFamily: AppThemeData.medium,
                                                color: themeChange.isDarkTheme() ? AppThemData.greyShade100 : AppThemData.greyShade800,
                                              ),
                                              hint: TextCustom(title: 'Global Distance Type'.tr),
                                              onChanged: (String? taxType) {
                                                appSettingsController.selectedDistanceType.value = taxType ?? "Km";
                                              },
                                              value: appSettingsController.selectedDistanceType.value,
                                              items: appSettingsController.distanceType.map<DropdownMenuItem<String>>((String value) {
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
                                          spaceH(height: 12)
                                        ],
                                      ),
                                      CustomTextFormField(
                                          tooltipsText: "Driver location update fro live tracking".tr,
                                          tooltipsShow: true,
                                          textInputType: TextInputType.name,
                                          title: " Driver Location Update".tr,
                                          // width: 0.35.sw,
                                          hintText: "Enter Driver Location Update".tr,
                                          prefix: Padding(
                                            padding: const EdgeInsets.all(10.0),
                                            child: Icon(Icons.location_on, color: themeChange.isDarkTheme() ? AppThemData.primaryWhite : AppThemData.primaryBlack),
                                          ),
                                          inputFormatters: [
                                            FilteringTextInputFormatter.allow(RegExp('[0-9.]')),
                                          ],
                                          controller: appSettingsController.globalDriverLocationUpdateController.value),
                                      CustomTextFormField(
                                          textInputType: TextInputType.name,
                                          tooltipsText: "Near by driver fide out radius ".tr,
                                          tooltipsShow: true,
                                          title: "Radius".tr,
                                          hintText: "Enter radius".tr,
                                          prefix: Padding(
                                            padding: const EdgeInsets.all(10.0),
                                            child: Icon(Icons.location_on, color: themeChange.isDarkTheme() ? AppThemData.primaryWhite : AppThemData.primaryBlack),
                                          ),
                                          inputFormatters: [
                                            FilteringTextInputFormatter.allow(RegExp('[0-9.]')),
                                          ],
                                          controller: appSettingsController.globalRadiusController.value),
                                      CustomTextFormField(
                                          title: "Minimum amount to accept ride ".tr,
                                          tooltipsText: "Minimum amount to accept ride",
                                          tooltipsShow: true,
                                          hintText: "Enter minimum amount to accept ride".tr,
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
                                          controller: appSettingsController.minimumAmountAcceptRideController.value)
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
                                        title: "Loyalty program".tr.toUpperCase(),
                                        fontFamily: AppThemeData.bold,
                                        fontSize: 20,
                                      ),
                                      spaceH(height: 16),
                                      CustomTextFormField(
                                          tooltipsText:
                                              "The number of loyalty points a customer earns for each completed ride.\n\nExample: If you set this to 10, the user earns 10 points per ride.",
                                          // width: 0.35.sw,
                                          tooltipsShow: true,
                                          title: "Point Per Ride".tr,
                                          hintText: "Enter Point Per Ride".tr,
                                          inputFormatters: [
                                            FilteringTextInputFormatter.allow(RegExp('[0-9.]')),
                                          ],
                                          prefix: Padding(
                                            padding: paddingEdgeInsets(vertical: 10, horizontal: 10),
                                            child: Icon(Icons.emoji_events, color: themeChange.isDarkTheme() ? AppThemData.primaryWhite : AppThemData.primaryBlack),
                                            // child: TextCustom(
                                            //   title: '${Constant.currencyModel!.symbol}',
                                            //   fontSize: 18,
                                            // ),
                                          ),
                                          controller: appSettingsController.loyaltyPointPerRideController.value),
                                      CustomTextFormField(
                                          textInputType: TextInputType.name,
                                          tooltipsText:
                                              "The value of each loyalty point in your currency.\n\nExample: If the conversion rate is 0.1, then 10 points = \$1.00.\n\nFormula: Wallet Value = Points × Conversion Rate",
                                          tooltipsShow: true,
                                          title: "Conversion Rate".tr,
                                          hintText: "e.g., 0.1".tr,
                                          prefix: Padding(
                                            padding: const EdgeInsets.all(10.0),
                                            child: Icon(Icons.swap_horiz, color: themeChange.isDarkTheme() ? AppThemData.primaryWhite : AppThemData.primaryBlack),
                                          ),
                                          inputFormatters: [
                                            FilteringTextInputFormatter.allow(RegExp('[0-9.]')),
                                          ],
                                          controller: appSettingsController.loyaltyConversionRideController.value),
                                      CustomTextFormField(
                                          title: "Minimum Redeemable Points".tr,
                                          hintText: "e.g., 100 points".tr,
                                          tooltipsText:
                                              "The minimum number of points required before a user can redeem them for wallet balance.\n\nExample: If set to 100, users must collect at least 100 points to redeem.",
                                          tooltipsShow: true,
                                          inputFormatters: [
                                            FilteringTextInputFormatter.allow(RegExp('[0-9.]')),
                                          ],
                                          prefix: Padding(
                                            padding: const EdgeInsets.all(10.0),
                                            child: Icon(Icons.check_circle, color: themeChange.isDarkTheme() ? AppThemData.primaryWhite : AppThemData.primaryBlack),
                                          ),
                                          controller: appSettingsController.loyaltyMinimumRedeemablePointsController.value),
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
                                        title: "Intercity Settings".tr.toUpperCase(),
                                        fontFamily: AppThemeData.bold,
                                        fontSize: 20,
                                      ),
                                      spaceH(height: 16),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          // Row(
                                          //   children: [
                                          //     TextCustom(
                                          //       title: "Intercity Bid".tr,
                                          //       fontSize: 14,
                                          //     ),
                                          //     spaceW(width: 10),
                                          //     Row(
                                          //       children: [
                                          //         Radio(
                                          //           value: StatusInterCity.active,
                                          //           groupValue: appSettingsController.isInterBid.value,
                                          //           onChanged: (value) {
                                          //             appSettingsController.isInterBid.value = value ?? StatusInterCity.active;
                                          //           },
                                          //           activeColor: AppThemData.primary500,
                                          //         ),
                                          //         Text("Active".tr,
                                          //             style: const TextStyle(
                                          //               fontFamily: AppThemeData.regular,
                                          //               fontSize: 16,
                                          //               color: AppThemData.textGrey,
                                          //             ))
                                          //       ],
                                          //     ),
                                          //     spaceW(),
                                          //     Row(
                                          //       children: [
                                          //         Radio(
                                          //           value: StatusInterCity.inactive,
                                          //           groupValue: appSettingsController.isInterBid.value,
                                          //           onChanged: (value) {
                                          //             appSettingsController.isInterBid.value = value ?? StatusInterCity.inactive;
                                          //           },
                                          //           activeColor: AppThemData.primary500,
                                          //         ),
                                          //         Text("Inactive".tr,
                                          //             style: const TextStyle(
                                          //               fontFamily: AppThemeData.regular,
                                          //               fontSize: 16,
                                          //               color: AppThemData.textGrey,
                                          //             ))
                                          //       ],
                                          //     ),
                                          //   ],
                                          // ),
                                          // Row(
                                          //   children: [
                                          //     TextCustom(
                                          //       title: "Parcel Bid".tr,
                                          //       fontSize: 14,
                                          //     ),
                                          //     spaceW(width: 10),
                                          //     Row(
                                          //       children: [
                                          //         Radio(
                                          //           value: StatusParcel.active,
                                          //           groupValue: appSettingsController.isParcelBid.value,
                                          //           onChanged: (value) {
                                          //             appSettingsController.isParcelBid.value = value ?? StatusParcel.active;
                                          //           },
                                          //           activeColor: AppThemData.primary500,
                                          //         ),
                                          //         Text("Active".tr,
                                          //             style: const TextStyle(
                                          //               fontFamily: AppThemeData.regular,
                                          //               fontSize: 16,
                                          //               color: AppThemData.textGrey,
                                          //             ))
                                          //       ],
                                          //     ),
                                          //     spaceW(),
                                          //     Row(
                                          //       children: [
                                          //         Radio(
                                          //           value: StatusParcel.inactive,
                                          //           groupValue: appSettingsController.isParcelBid.value,
                                          //           onChanged: (value) {
                                          //             appSettingsController.isParcelBid.value = value ?? StatusParcel.inactive;
                                          //           },
                                          //           activeColor: AppThemData.primary500,
                                          //         ),
                                          //         Text("Inactive".tr,
                                          //             style: const TextStyle(
                                          //               fontFamily: AppThemeData.regular,
                                          //               fontSize: 16,
                                          //               color: AppThemData.textGrey,
                                          //             ))
                                          //       ],
                                          //     ),
                                          //   ],
                                          // )
                                          CustomTextFormField(
                                              textInputType: TextInputType.name,
                                              tooltipsText: "Near by ride fide out radius ",
                                              tooltipsShow: true,
                                              title: "Radius".tr,
                                              hintText: "Enter radius".tr,
                                              prefix: Padding(
                                                padding: const EdgeInsets.all(10.0),
                                                child: Icon(Icons.location_on, color: themeChange.isDarkTheme() ? AppThemData.primaryWhite : AppThemData.primaryBlack),
                                              ),
                                              inputFormatters: [
                                                FilteringTextInputFormatter.allow(RegExp('[0-9.]')),
                                              ],
                                              controller: appSettingsController.globalInterCityRadiusController.value),
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
                                        title: "Night Timing".tr.toUpperCase(),
                                        fontFamily: AppThemeData.bold,
                                        fontSize: 20,
                                      ),
                                      spaceH(height: 8),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: CustomTextFormField(
                                                title: "Start Time".tr,
                                                hintText: "Enter Start Time for Night".tr,
                                                maxLine: 1,
                                                controller: appSettingsController.nightStartTimeController.value,
                                                onPress: () async {
                                                  TimeOfDay? picked = await showTimePicker(
                                                    context: context,
                                                    initialTime: TimeOfDay.now(),
                                                    builder: (BuildContext context, Widget? child) {
                                                      return MediaQuery(
                                                        data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
                                                        child: child!,
                                                      );
                                                    },
                                                  );

                                                  if (picked != null) {
                                                    final now = DateTime.now();
                                                    final formattedTime = DateFormat("HH:mm").format(
                                                      DateTime(now.year, now.month, now.day, picked.hour, picked.minute),
                                                    );
                                                    controller.nightStartTimeController.value.text = formattedTime;
                                                  }
                                                },
                                                prefix: Padding(
                                                    padding: const EdgeInsets.all(10),
                                                    child: SvgPicture.asset(
                                                      "assets/icons/ic_clock.svg",
                                                      height: 16,
                                                      color: themeChange.isDarkTheme() ? AppThemData.primaryWhite : AppThemData.primaryBlack,
                                                    ))),
                                          ),
                                          spaceW(width: 16),
                                          Expanded(
                                            child: CustomTextFormField(
                                                title: "End Time".tr,
                                                hintText: "Enter End Time for Night".tr,
                                                maxLine: 1,
                                                controller: appSettingsController.nightEndTimeController.value,
                                                onPress: () async {
                                                  TimeOfDay? picked = await showTimePicker(
                                                    context: context,
                                                    initialTime: TimeOfDay.now(),
                                                    builder: (BuildContext context, Widget? child) {
                                                      return MediaQuery(
                                                        data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
                                                        child: child!,
                                                      );
                                                    },
                                                  );

                                                  if (picked != null) {
                                                    final now = DateTime.now();
                                                    final formattedTime = DateFormat("HH:mm").format(
                                                      DateTime(now.year, now.month, now.day, picked.hour, picked.minute),
                                                    );
                                                    controller.nightEndTimeController.value.text = formattedTime;
                                                  }
                                                },
                                                prefix: Padding(
                                                    padding: const EdgeInsets.all(10),
                                                    child: SvgPicture.asset(
                                                      "assets/icons/ic_clock.svg",
                                                      height: 16,
                                                      color: themeChange.isDarkTheme() ? AppThemData.primaryWhite : AppThemData.primaryBlack,
                                                    ))),
                                          ),
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
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      TextCustom(
                                        title: "Ride Cancellation Timing".tr.toUpperCase(),
                                        fontFamily: AppThemeData.bold,
                                        fontSize: 20,
                                      ),
                                      spaceH(height: 16),
                                      CustomTextFormField(
                                          title: "Seconds".tr,
                                          // width: 0.35.sw,
                                          hintText: "Enter second for cancel service".tr,
                                          maxLine: 1,
                                          controller: appSettingsController.secondsForRideCancelController.value,
                                          tooltipsShow: true,
                                          tooltipsText: "Enter seconds to cancel ride when Driver not accept the Ride".tr,
                                          prefix: Padding(
                                              padding: const EdgeInsets.all(10),
                                              child: SvgPicture.asset(
                                                "assets/icons/ic_clock.svg",
                                                height: 16,
                                                color: themeChange.isDarkTheme() ? AppThemData.primaryWhite : AppThemData.primaryBlack,
                                              ))),
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
                                        title: "App Theme".tr.toUpperCase(),
                                        fontFamily: AppThemeData.bold,
                                        fontSize: 20,
                                      ),
                                      spaceH(height: 16),
                                      CustomTextFormField(
                                          title: "App Colors".tr,
                                          // width: 0.35.sw,
                                          hintText: "Select App Color".tr,
                                          maxLine: 1,
                                          prefix: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: InkWell(
                                                onTap: () async {
                                                  Color newColor = await showColorPickerDialog(
                                                    context,
                                                    appSettingsController.selectedColor.value,
                                                    width: 40,
                                                    height: 40,
                                                    spacing: 0,
                                                    runSpacing: 0,
                                                    borderRadius: 0,
                                                    enableOpacity: true,
                                                    showColorCode: true,
                                                    colorCodeHasColor: true,
                                                    enableShadesSelection: false,
                                                    pickersEnabled: <ColorPickerType, bool>{
                                                      ColorPickerType.wheel: true,
                                                    },
                                                    copyPasteBehavior: const ColorPickerCopyPasteBehavior(
                                                      copyButton: true,
                                                      pasteButton: false,
                                                      longPressMenu: false,
                                                    ),
                                                    actionButtons: const ColorPickerActionButtons(
                                                      okButton: true,
                                                      closeButton: true,
                                                      dialogActionButtons: false,
                                                    ),
                                                  );
                                                  appSettingsController.colourCodeController.value.text = "#${newColor.hex}";
                                                  appSettingsController.selectedColor.value = newColor;
                                                },
                                                child: Obx(
                                                  () => ClipRRect(
                                                      borderRadius: const BorderRadius.all(Radius.circular(5)),
                                                      child: Container(
                                                        height: 12,
                                                        width: 80,
                                                        color: appSettingsController.selectedColor.value,
                                                      )),
                                                )),
                                          ),
                                          controller: appSettingsController.colourCodeController.value),
                                      spaceW(width: 16),
                                      CustomTextFormField(
                                          title: "App Name".tr,
                                          // width: 0.35.sw,
                                          hintText: "Enter App Name".tr,
                                          inputFormatters: [
                                            FilteringTextInputFormatter.allow(RegExp('[a-zA-Z ]')),
                                          ],
                                          prefix: const Icon(Icons.drive_file_rename_outline_outlined),
                                          controller: appSettingsController.appNameController.value),
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
                                            controller.saveSettingData();
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                ),
              )
            ],
          ),
        );
      },
    );
  }

  Dialog homeScreenInfoDialog(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return Dialog(
      backgroundColor: themeChange.isDarkTheme() ? AppThemData.greyShade950 : AppThemData.greyShade50,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8.0))),
      alignment: Alignment.center,
      child: SizedBox(
        width: ResponsiveWidget.isDesktop(context) ? MediaQuery.sizeOf(context).width * 0.4 : MediaQuery.sizeOf(context).width * 0.7,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.only(topLeft: Radius.circular(8.0), topRight: Radius.circular(8.0)),
                        color: themeChange.isDarkTheme() ? AppThemData.greyShade900 : AppThemData.greyShade100,
                      ),
                      child: Row(
                        children: [
                          TextCustom(title: "Dynamic Home Screen".tr, fontSize: 18).expand(),
                          10.width,
                          InkWell(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: Icon(
                              Icons.close,
                              size: 25,
                              color: themeChange.isDarkTheme() ? AppThemData.primaryWhite : AppThemData.primaryBlack,
                            ),
                          )
                        ],
                      )).expand(),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: [
                          TextCustom(
                            title:
                                "The map-based home experience where users can view their current location and Rides.\nWhen turned off, customers will see the regular home screen layout without live map components."
                                    .tr,
                            maxLine: 5,
                            fontSize: 16,
                            fontFamily: AppThemeData.medium,
                          ),
                          spaceH(height: 32),
                          ResponsiveWidget.isMobile(context)
                              ? Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    TextCustom(title: "Regular Home Screen".tr),
                                    spaceH(height: 10),
                                    Image.asset(
                                      "assets/image/home_screen_1.png",
                                      height: 350.h,
                                    ),
                                    spaceH(height: 24),
                                    TextCustom(title: "Map-based Home Screen".tr),
                                    spaceH(height: 10),
                                    Image.asset(
                                      "assets/image/home_screen_2.png",
                                      height: 350.h,
                                    ),
                                  ],
                                )
                              : Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        TextCustom(title: "Regular Home Screen".tr),
                                        spaceH(height: 10),
                                        Image.asset(
                                          "assets/image/home_screen_1.png",
                                          height: 350.h,
                                        ),
                                      ],
                                    ),
                                    spaceW(width: 32),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        TextCustom(title: "Map-based Home Screen".tr),
                                        spaceH(height: 10),
                                        Image.asset(
                                          "assets/image/home_screen_2.png",
                                          height: 350.h,
                                        ),
                                      ],
                                    )
                                  ],
                                )
                        ],
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
