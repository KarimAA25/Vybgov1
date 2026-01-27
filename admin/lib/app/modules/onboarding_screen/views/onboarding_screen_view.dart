import 'dart:io';

import 'package:admin/app/components/custom_button.dart';
import 'package:admin/app/components/custom_text_form_field.dart';
import 'package:admin/app/components/dialog_box.dart';
import 'package:admin/app/components/menu_widget.dart';
import 'package:admin/app/components/network_image_widget.dart';
import 'package:admin/app/constant/constants.dart';
import 'package:admin/app/constant/show_toast.dart';
import 'package:admin/app/utils/app_colors.dart';
import 'package:admin/app/utils/app_them_data.dart';
import 'package:admin/app/utils/dark_theme_provider.dart';
import 'package:admin/app/utils/fire_store_utils.dart';
import 'package:admin/app/utils/responsive.dart';
import 'package:admin/widget/common_ui.dart';
import 'package:admin/widget/container_custom.dart';
import 'package:admin/widget/global_widgets.dart';
import 'package:admin/widget/text_widget.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../../routes/app_pages.dart';
import '../controllers/onboarding_screen_controller.dart';

class OnboardingScreenView extends GetView<OnboardingScreenController> {
  const OnboardingScreenView({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetX<OnboardingScreenController>(
      init: OnboardingScreenController(),
      builder: (controller) {
        return Scaffold(
          backgroundColor: themeChange.isDarkTheme() ? AppThemData.greyShade950 : AppThemData.greyShade50,
          appBar: AppBar(
            elevation: 0.0,
            toolbarHeight: 70,
            automaticallyImplyLeading: false,
            backgroundColor: themeChange.isDarkTheme() ? AppThemData.primaryBlack : AppThemData.primaryWhite,
            leadingWidth: 200,
            // title: title,
            leading: Builder(
              builder: (BuildContext context) {
                return GestureDetector(
                  onTap: () {
                    if (!ResponsiveWidget.isDesktop(context)) {
                      Scaffold.of(context).openDrawer();
                    }
                  },
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: !ResponsiveWidget.isDesktop(context)
                        ? Padding(
                            padding: const EdgeInsets.only(left: 10),
                            child: Icon(
                              Icons.menu,
                              size: 30,
                              color: themeChange.isDarkTheme() ? AppThemData.primary500 : AppThemData.primary500,
                            ),
                          )
                        : SizedBox(
                            height: 45,
                            child: InkWell(
                              onTap: () {
                                Get.toNamed(Routes.DASHBOARD_SCREEN);
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    "assets/image/logo.png",
                                    height: 45,
                                    color: AppThemData.primary500,
                                  ),
                                  spaceW(),
                                  const TextCustom(
                                    title: 'My Taxi',
                                    color: AppThemData.primary500,
                                    fontSize: 30,
                                    fontFamily: AppThemeData.semiBold,
                                    fontWeight: FontWeight.w700,
                                  )
                                ],
                              ),
                            ),
                          ),
                  ),
                );
              },
            ),
            actions: [
              GestureDetector(
                onTap: () {
                  if (themeChange.darkTheme == 1) {
                    themeChange.darkTheme = 0;
                  } else if (themeChange.darkTheme == 0) {
                    themeChange.darkTheme = 1;
                  } else if (themeChange.darkTheme == 2) {
                    themeChange.darkTheme = 0;
                  } else {
                    themeChange.darkTheme = 2;
                  }
                },
                child: themeChange.isDarkTheme()
                    ? SvgPicture.asset(
                        "assets/icons/ic_sun.svg",
                        color: AppThemData.yellow600,
                        height: 20,
                        width: 20,
                      )
                    : SvgPicture.asset(
                        "assets/icons/ic_moon.svg",
                        color: AppThemData.blue400,
                        height: 20,
                        width: 20,
                      ),
              ),
              spaceW(),
              const LanguagePopUp(),
              spaceW(),
              ProfilePopUp()
            ],
          ),
          drawer: Drawer(
            // key: scaffoldKey,
            width: 270,
            backgroundColor: themeChange.isDarkTheme() ? AppThemData.primaryBlack : AppThemData.primaryWhite,
            child: const MenuWidget(),
          ),
          body: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (ResponsiveWidget.isDesktop(context)) ...{const MenuWidget()},
              Expanded(
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(mainAxisSize: MainAxisSize.min, mainAxisAlignment: MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Padding(
                      padding: paddingEdgeInsets(),
                      child: ContainerCustom(
                        child: controller.isLoading.value
                            ? Padding(
                                padding: paddingEdgeInsets(),
                                child: Constant.loader(),
                              )
                            : Column(children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                      TextCustom(title: controller.title.value, fontSize: 20, fontFamily: AppThemeData.bold),
                                      spaceH(height: 2),
                                      Row(children: [
                                        GestureDetector(
                                            onTap: () => Get.offAllNamed(Routes.DASHBOARD_SCREEN),
                                            child: TextCustom(title: 'Dashboard'.tr, fontSize: 14, fontFamily: AppThemeData.medium, color: AppThemData.greyShade500)),
                                        const TextCustom(title: ' / ', fontSize: 14, fontFamily: AppThemeData.medium, color: AppThemData.greyShade500),
                                        TextCustom(title: ' ${controller.title.value} ', fontSize: 14, fontFamily: AppThemeData.medium, color: AppThemData.primary500)
                                      ])
                                    ]),
                                    CustomButtonWidget(
                                      padding: const EdgeInsets.symmetric(horizontal: 22),
                                      buttonTitle: " + Add OnBoarding".tr,
                                      borderRadius: 10,
                                      onPress: () {
                                        controller.setDefaultData();
                                        showDialog(context: context, builder: (context) => const OnBoardingDialog());
                                      },
                                    ),
                                  ],
                                ),
                                spaceH(height: 20),
                                SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: controller.isLoading.value
                                        ? Padding(
                                            padding: paddingEdgeInsets(),
                                            child: Constant.loader(),
                                          )
                                        : controller.onBoardingList.isEmpty
                                            ? TextCustom(title: "No Data available".tr)
                                            : DataTable(
                                                horizontalMargin: 20,
                                                columnSpacing: 30,
                                                dataRowMaxHeight: 65,
                                                headingRowHeight: 65,
                                                border: TableBorder.all(
                                                  color: themeChange.isDarkTheme() ? AppThemData.greyShade900 : AppThemData.greyShade100,
                                                  borderRadius: BorderRadius.circular(12),
                                                ),
                                                headingRowColor:
                                                    WidgetStateColor.resolveWith((states) => themeChange.isDarkTheme() ? AppThemData.greyShade900 : AppThemData.greyShade100),
                                                columns: [
                                                  CommonUI.dataColumnWidget(context,
                                                      columnTitle: "Image".tr, width: ResponsiveWidget.isMobile(context) ? 120 : MediaQuery.of(context).size.width * 0.03),
                                                  CommonUI.dataColumnWidget(context,
                                                      columnTitle: "Title".tr, width: ResponsiveWidget.isMobile(context) ? 150 : MediaQuery.of(context).size.width * 0.14),
                                                  CommonUI.dataColumnWidget(context,
                                                      columnTitle: "Description".tr, width: ResponsiveWidget.isMobile(context) ? 150 : MediaQuery.of(context).size.width * 0.20),
                                                  CommonUI.dataColumnWidget(context,
                                                      columnTitle: "Type".tr, width: ResponsiveWidget.isMobile(context) ? 150 : MediaQuery.of(context).size.width * 0.06),
                                                  CommonUI.dataColumnWidget(context,
                                                      columnTitle: "Status".tr, width: ResponsiveWidget.isMobile(context) ? 100 : MediaQuery.of(context).size.width * 0.05),
                                                  CommonUI.dataColumnWidget(context,
                                                      columnTitle: "Actions".tr, width: ResponsiveWidget.isMobile(context) ? 70 : MediaQuery.of(context).size.width * 0.08),
                                                ],
                                                rows: controller.onBoardingList
                                                    .map((onBoardingModel) => DataRow(cells: [
                                                          DataCell(
                                                            Container(
                                                              alignment: Alignment.center,
                                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                                              child: NetworkImageWidget(
                                                                imageUrl: '${onBoardingModel.image}',
                                                                borderRadius: 10,
                                                                width: 100,
                                                                height: 60,
                                                                fit: BoxFit.fill,
                                                              ),
                                                            ),
                                                          ),
                                                          DataCell(TextCustom(title: onBoardingModel.title ?? "N/A".tr)),
                                                          DataCell(TextCustom(title: onBoardingModel.description ?? "N/A".tr, maxLine: 2)),
                                                          DataCell(TextCustom(title: onBoardingModel.type == "customer" ? 'Customer'.tr : 'Driver'.tr)),
                                                          DataCell(
                                                            Transform.scale(
                                                              scale: 0.8,
                                                              child: CupertinoSwitch(
                                                                activeTrackColor: AppThemData.primary500,
                                                                value: onBoardingModel.status!,
                                                                onChanged: (value) async {
                                                                  if (Constant.isDemo) {
                                                                    DialogBox.demoDialogBox();
                                                                  } else {
                                                                    onBoardingModel.status = value;
                                                                    await FireStoreUtils.updateOnBoarding(onBoardingModel);
                                                                    controller.getData();
                                                                  }
                                                                },
                                                              ),
                                                            ),
                                                          ),
                                                          DataCell(
                                                            Container(
                                                              alignment: Alignment.center,
                                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                                              child: Row(
                                                                mainAxisAlignment: MainAxisAlignment.start,
                                                                children: [
                                                                  InkWell(
                                                                    onTap: () {
                                                                      controller.isEditing.value = true;
                                                                      controller.onBoardingModel.value = onBoardingModel;
                                                                      controller.titleController.value.text = onBoardingModel.title ?? "";
                                                                      controller.descriptionController.value.text = onBoardingModel.description ?? "";
                                                                      controller.onBoardingType.value = onBoardingModel.type == 'customer' ? "Customer" : "Driver";
                                                                      controller.isActive.value = onBoardingModel.status ?? false;

                                                                      if (onBoardingModel.image != null && onBoardingModel.image!.isNotEmpty) {
                                                                        controller.imageNameController.value.text = onBoardingModel.image!;
                                                                        controller.imageURL.value = onBoardingModel.image!;
                                                                      } else {
                                                                        controller.imageURL.value = '';
                                                                      }
                                                                      showDialog(
                                                                        context: context,
                                                                        builder: (context) => const OnBoardingDialog(),
                                                                      );
                                                                    },
                                                                    child: SvgPicture.asset(
                                                                      "assets/icons/ic_edit.svg",
                                                                      color: AppThemData.greyShade400,
                                                                      height: 16,
                                                                      width: 16,
                                                                    ),
                                                                  ),
                                                                  spaceW(width: 20),
                                                                  InkWell(
                                                                    onTap: () async {
                                                                      if (Constant.isDemo) {
                                                                        DialogBox.demoDialogBox();
                                                                      } else {
                                                                        // controller.removeBanner(onBoardingModel);
                                                                        // controller.getData();
                                                                        bool confirmDelete = await DialogBox.showConfirmationDeleteDialog(context);
                                                                        if (confirmDelete) {
                                                                          await controller.removeOnBoarding(onBoardingModel);
                                                                        }
                                                                      }
                                                                    },
                                                                    child: SvgPicture.asset(
                                                                      "assets/icons/ic_delete.svg",
                                                                      color: AppThemData.red500,
                                                                      height: 16,
                                                                      width: 16,
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                        ]))
                                                    .toList()),
                                  ),
                                ),
                                spaceH(),
                              ]),
                      ),
                    )
                  ]),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class OnBoardingDialog extends StatelessWidget {
  const OnBoardingDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetX<OnboardingScreenController>(
      init: OnboardingScreenController(),
      builder: (controller) {
        return CustomDialog(
          title: controller.title.value,
          widgetList: [
            Visibility(
              visible: controller.isEditing.value,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "✍ Edit your Banner here".tr,
                    style: TextStyle(
                      fontFamily: AppThemeData.bold,
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                      color: AppThemData.primaryBlack,
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                ],
              ),
            ),
            controller.isEditing.value == true
                ? Container(
                    height: 0.18.sh,
                    width: 0.30.sw,
                    decoration: BoxDecoration(
                      color: themeChange.isDarkTheme() ? AppThemData.greyShade900 : AppThemData.greyShade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: CachedNetworkImage(
                            fit: BoxFit.contain,
                            height: 0.18.sh,
                            width: 0.30.sw,
                            imageUrl: controller.imageFile.value.path.isEmpty ? controller.imageURL.value : controller.imageFile.value.path,
                          ),
                        ),
                        Center(
                          child: InkWell(
                            onTap: () async {
                              if (Constant.isDemo) {
                                DialogBox.demoDialogBox();
                              } else {
                                ImagePicker picker = ImagePicker();
                                final img = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
                                if (img != null) {
                                  final allowedExtensions = ['jpg', 'jpeg', 'png'];
                                  String fileExtension = img.name.split('.').last.toLowerCase();

                                  if (!allowedExtensions.contains(fileExtension)) {
                                    ShowToastDialog.errorToast("Invalid file type. Please select a .jpg, .jpeg, or .png image.".tr);
                                    return;
                                  }

                                  File imageFile = File(img.path);
                                  controller.imageNameController.value.text = img.name;
                                  controller.imageFile.value = imageFile;
                                  controller.mimeType.value = "${img.mimeType}";
                                  controller.isImageUpdated.value = true;
                                }
                              }
                            },
                            child: controller.imageFile.value.path.isEmpty
                                ? const Icon(
                                    Icons.add,
                                    color: AppThemData.greyShade500,
                                  )
                                : const SizedBox(),
                          ),
                        ),
                      ],
                    ),
                  )
                : Container(
                    height: 0.18.sh,
                    width: 0.30.sw,
                    decoration: BoxDecoration(
                      color: themeChange.isDarkTheme() ? AppThemData.greyShade900 : AppThemData.greyShade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Stack(
                      children: [
                        if (controller.imageFile.value.path.isNotEmpty)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: CachedNetworkImage(
                              fit: BoxFit.contain,
                              height: 0.18.sh,
                              width: 0.30.sw,
                              imageUrl: controller.imageFile.value.path,
                            ),
                          ),
                        Center(
                          child: InkWell(
                            onTap: () async {
                              if (Constant.isDemo) {
                                DialogBox.demoDialogBox();
                              } else {
                                ImagePicker picker = ImagePicker();
                                final img = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
                                if (img != null) {
                                  final allowedExtensions = ['jpg', 'jpeg', 'png'];
                                  String fileExtension = img.name.split('.').last.toLowerCase();

                                  if (!allowedExtensions.contains(fileExtension)) {
                                    ShowToastDialog.errorToast("Invalid file type. Please select a .jpg, .jpeg, or .png image.".tr);
                                    return;
                                  }

                                  File imageFile = File(img.path);
                                  controller.imageNameController.value.text = img.name;
                                  controller.imageFile.value = imageFile;
                                  controller.mimeType.value = "${img.mimeType}";
                                  controller.isImageUpdated.value = true;
                                }
                              }
                            },
                            child: controller.imageFile.value.path.isEmpty
                                ? Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        'upload image'.tr,
                                        style: const TextStyle(fontSize: 16, color: AppThemData.greyShade500, fontFamily: AppThemeData.medium),
                                      ),
                                      const SizedBox(
                                        width: 12,
                                      ),
                                      const Icon(
                                        Icons.file_upload_outlined,
                                        color: AppThemData.greyShade500,
                                      ),
                                    ],
                                  )
                                : const SizedBox(),
                          ),
                        ),
                      ],
                    ),
                  ),
            spaceH(height: 16),
            SizedBox(
              child: CustomTextFormField(title: "Title".tr, hintText: "Enter Title".tr, controller: controller.titleController.value),
            ),
            spaceH(),
            SizedBox(
              child: CustomTextFormField(
                title: "Description".tr,
                hintText: "Enter Description".tr,
                controller: controller.descriptionController.value,
                maxLine: 3,
              ),
            ),
            spaceH(),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextCustom(
                        maxLine: 1,
                        title: "OnBoarding Type".tr,
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
                          hint: TextCustom(title: 'Select OnBoarding Type'.tr),
                          onChanged: (String? couponType) {
                            controller.onBoardingType.value = couponType ?? "Driver".tr;
                          },
                          value: controller.onBoardingType.value,
                          items: controller.selectedType.map<DropdownMenuItem<String>>((String value) {
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
                spaceW(width: 24),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextCustom(
                        title: 'Status'.tr,
                        fontSize: 12,
                      ),
                      spaceH(),
                      Transform.scale(
                        scale: 0.8,
                        child: CupertinoSwitch(
                          activeTrackColor: AppThemData.primary500,
                          value: controller.isActive.value,
                          onChanged: (value) {
                            controller.isActive.value = value;
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            )
          ],
          bottomWidgetList: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CustomButtonWidget(
                  buttonTitle: "Close".tr,
                  buttonColor: themeChange.isDarkTheme() ? AppThemData.greyShade900 : AppThemData.greyShade100,
                  onPress: () {
                    controller.setDefaultData();
                    Navigator.pop(context);
                  },
                ),
                spaceW(),
                CustomButtonWidget(
                  buttonTitle: controller.isEditing.value ? "Save".tr : "Save".tr,
                  onPress: () {
                    if (Constant.isDemo) {
                      DialogBox.demoDialogBox();
                    } else {
                      if (controller.titleController.value.text.isNotEmpty &&
                          controller.imageNameController.value.text.isNotEmpty &&
                          controller.descriptionController.value.text.isNotEmpty) {
                        controller.isEditing.value ? controller.isEditing(true) : controller.isLoading(true);
                        controller.isEditing.value ? controller.updateOnBoarding(context) : controller.addOnBoarding(context);
                      } else {
                        ShowToastDialog.errorToast("All Fields are Required...".tr);
                      }
                    }
                  },
                ),
              ],
            ),
          ],
          controller: controller,
        );
      },
    );
  }
}
