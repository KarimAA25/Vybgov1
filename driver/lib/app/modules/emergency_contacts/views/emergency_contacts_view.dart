import 'package:driver/app/models/emergency_number_model.dart';
import 'package:driver/constant/constant.dart';
import 'package:driver/constant_widgets/app_bar_with_border.dart';
import 'package:driver/constant_widgets/custom_dialog_box.dart';
import 'package:driver/constant_widgets/round_shape_button.dart';
import 'package:driver/constant_widgets/show_toast_dialog.dart';
import 'package:driver/constant_widgets/text_field_with_title.dart';
import 'package:driver/theme/app_them_data.dart';
import 'package:driver/theme/responsive.dart';
import 'package:driver/utils/dark_theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../controllers/emergency_contacts_controller.dart';

class EmergencyContactsView extends GetView<EmergencyContactsController> {
  final bool isFromDrawer;

  const EmergencyContactsView({super.key, this.isFromDrawer = false});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetX(
      init: EmergencyContactsController(),
      builder: (controller) {
        return Scaffold(
            backgroundColor: themeChange.isDarkTheme() ? AppThemData.black : AppThemData.white,
            appBar: isFromDrawer == false
                ? AppBarWithBorder(
                    title: "Emergency Contacts".tr,
                    bgColor: themeChange.isDarkTheme() ? AppThemData.black : AppThemData.white,
                  )
                : null,
            bottomNavigationBar: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              child: RoundShapeButton(
                title: "Add Emergency Contact".tr,
                buttonColor: AppThemData.primary500,
                buttonTextColor: AppThemData.white,
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    builder: (context) {
                      return SizedBox(
                        height: MediaQuery.of(context).size.height * 0.7,
                        child: emergencyContactsBottomSheet(context, themeChange),
                      );
                    },
                  );
                },
                size: Size(Responsive.width(100, context), 52),
              ),
            ),
            body: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: controller.isLoading.value
                  ? Constant.loader()
                  : controller.totalEmergencyContacts.isEmpty
                      ? Constant.showEmptyView(message: "No Emergency Contacts".tr)
                      : ListView.builder(
                          shrinkWrap: true,
                          itemCount: controller.totalEmergencyContacts.length,
                          itemBuilder: (context, index) {
                            EmergencyContactModel emergencyContact = controller.totalEmergencyContacts[index];
                            return Container(
                              margin: EdgeInsets.only(bottom: index == controller.totalEmergencyContacts.length - 1 ? 0 : 12),
                              padding: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: themeChange.isDarkTheme() ? AppThemData.grey900 : AppThemData.grey50,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        emergencyContact.name.toString(),
                                        style: GoogleFonts.inter(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                          color: themeChange.isDarkTheme() ? AppThemData.grey25 : AppThemData.grey950,
                                        ),
                                      ),
                                      SizedBox(height: 2),
                                      Text(
                                        "${emergencyContact.countryCode} ${emergencyContact.phoneNumber}",
                                        style: GoogleFonts.inter(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w400,
                                          color: themeChange.isDarkTheme() ? AppThemData.grey400 : AppThemData.grey600,
                                        ),
                                      )
                                    ],
                                  ),
                                  GestureDetector(
                                      onTap: () {
                                        showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return CustomDialogBox(
                                                  themeChange: themeChange,
                                                  title: "Delete Emergency Contact".tr,
                                                  descriptions: "Are you sure you want to delete this emergency contact?".tr,
                                                  positiveString: "Delete".tr,
                                                  negativeString: "Cancel".tr,
                                                  positiveClick: () async {
                                                    Navigator.pop(context);
                                                    await controller.deleteEmergencyContact(emergencyContact.id!);
                                                  },
                                                  negativeClick: () {
                                                    Navigator.pop(context);
                                                  },
                                                  img: SvgPicture.asset(
                                                    "assets/icon/ic_delete.svg",
                                                    height: 40,
                                                  ));
                                            });
                                      },
                                      child: SvgPicture.asset("assets/icon/ic_delete.svg")),
                                ],
                              ),
                            );
                          },
                        ),
            ));
      },
    );
  }

  Container emergencyContactsBottomSheet(BuildContext context, themeChange) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: themeChange.isDarkTheme() ? AppThemData.grey950 : AppThemData.grey50,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 44,
            height: 5,
            margin: const EdgeInsets.only(top: 10, bottom: 16),
            decoration: ShapeDecoration(
              color: themeChange.isDarkTheme() ? AppThemData.grey700 : AppThemData.grey200,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(100),
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Emergency Contacts".tr,
                    style: GoogleFonts.inter(
                      color: themeChange.isDarkTheme() ? AppThemData.grey25 : AppThemData.grey950,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 24),
                  TextFieldWithTitle(
                    title: "Name".tr,
                    hintText: "Enter Name".tr,
                    controller: controller.nameController.value,
                    prefixIcon: SvgPicture.asset(
                      "assets/icon/ic_profile.svg",
                      colorFilter: ColorFilter.mode(AppThemData.grey500, BlendMode.srcIn),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "Phone Number".tr,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: themeChange.isDarkTheme() ? AppThemData.white : AppThemData.grey950,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  const SizedBox(height: 8),
                  MobileNumberTextField(
                    enableCountryPicker: true,
                    countryCodeController: controller.countryCodeController.value,
                    controller: controller.phoneNumberController.value,
                    onCountryCodeChanged: (value) {
                      controller.countryCodeController.value.text = value;
                      controller.phoneNumberController.value.clear();
                    },
                  ),

                  const SizedBox(height: 100), // space above fixed button
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: RoundShapeButton(
              title: "Add Emergency Contact".tr,
              buttonColor: AppThemData.primary500,
              buttonTextColor: AppThemData.white,
              size: Size(Responsive.width(100, context), 52),
              onTap: () {
                if (controller.nameController.value.text.isEmpty) {
                  ShowToastDialog.showToast("Please Enter Name".tr);
                } else if (controller.phoneNumberController.value.text.isEmpty) {
                  ShowToastDialog.showToast("Please Enter Mobile Number".tr);
                } else {
                  Get.back();
                  controller.addEmergencyContact();
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
