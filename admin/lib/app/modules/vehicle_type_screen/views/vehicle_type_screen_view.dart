import 'dart:io';

import 'package:admin/app/components/menu_widget.dart';
import 'package:admin/app/models/zone_model.dart';
import 'package:admin/app/utils/fire_store_utils.dart';
import 'package:admin/widget/container_custom.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:provider/provider.dart';
import '../../../../widget/common_ui.dart';
import '../../../../widget/global_widgets.dart';
import '../../../../widget/text_widget.dart';
import '../../../components/custom_button.dart';
import '../../../components/custom_text_form_field.dart';
import '../../../components/dialog_box.dart';
import '../../../components/network_image_widget.dart';
import '../../../constant/constants.dart';
import '../../../constant/show_toast.dart';
import '../../../routes/app_pages.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_them_data.dart';
import '../../../utils/dark_theme_provider.dart';
import '../../../utils/responsive.dart';
import '../controllers/vehicle_type_screen_controller.dart';

class VehicleTypeScreenView extends GetView<VehicleTypeScreenController> {
  const VehicleTypeScreenView({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetBuilder<VehicleTypeScreenController>(
      init: VehicleTypeScreenController(),
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
                child: Padding(
                  padding: paddingEdgeInsets(),
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
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
                                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                    TextCustom(title: controller.title.value.tr, fontSize: 20, fontFamily: AppThemeData.bold),
                                    spaceH(height: 2),
                                    Row(children: [
                                      GestureDetector(
                                          onTap: () => Get.offAllNamed(Routes.DASHBOARD_SCREEN),
                                          child: TextCustom(title: 'Dashboard'.tr, fontSize: 14, fontFamily: AppThemeData.medium, color: AppThemData.greyShade500)),
                                      const TextCustom(title: ' / ', fontSize: 14, fontFamily: AppThemeData.medium, color: AppThemData.greyShade500),
                                      TextCustom(title: ' ${controller.title.value.tr} ', fontSize: 14, fontFamily: AppThemeData.medium, color: AppThemData.primary500)
                                    ])
                                  ]),
                                  CustomButtonWidget(
                                    padding: const EdgeInsets.symmetric(horizontal: 22),
                                    buttonTitle: "+ Add Vehicle Type".tr,
                                    borderRadius: 10,
                                    onPress: () {
                                      controller.setDefaultData();
                                      showDialog(context: context, builder: (context) => const VehicleTypeDialog());
                                    },
                                  ),
                                ],
                              ),
                              spaceH(height: 20),
                              Obx(() => SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: controller.isLoading.value
                                            ? Padding(
                                                padding: paddingEdgeInsets(),
                                                child: Constant.loader(),
                                              )
                                            : controller.vehicleTypeList.isEmpty
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
                                                          columnTitle: "Sr. No.".tr, width: ResponsiveWidget.isMobile(context) ? 50 : MediaQuery.of(context).size.width * 0.1),
                                                      CommonUI.dataColumnWidget(context,
                                                          columnTitle: "Title".tr, width: ResponsiveWidget.isMobile(context) ? 50 : MediaQuery.of(context).size.width * 0.15),
                                                      CommonUI.dataColumnWidget(context,
                                                          columnTitle: "Vehicle type Image".tr,
                                                          width: ResponsiveWidget.isMobile(context) ? 120 : MediaQuery.of(context).size.width * 0.15),
                                                      // CommonUI.dataColumnWidget(context, columnTitle: "Minimum Charges".tr, width: ResponsiveWidget.isMobile(context) ? 120 : MediaQuery.of(context).size.width * 0.10),
                                                      // CommonUI.dataColumnWidget(context, columnTitle: "MiniCharges Within Km".tr, width: ResponsiveWidget.isMobile(context) ? 120 : MediaQuery.of(context).size.width * 0.10),
                                                      // CommonUI.dataColumnWidget(context, columnTitle: "Per Km".tr, width: ResponsiveWidget.isMobile(context) ? 120 : MediaQuery.of(context).size.width * 0.10),
                                                      CommonUI.dataColumnWidget(context,
                                                          columnTitle: "Active".tr, width: ResponsiveWidget.isMobile(context) ? 100 : MediaQuery.of(context).size.width * 0.1),
                                                      // CommonUI.dataColumnWidget(context, columnTitle: "TimeSlot".tr, width: ResponsiveWidget.isMobile(context) ? 100 : MediaQuery.of(context).size.width * 0.05),
                                                      CommonUI.dataColumnWidget(context,
                                                          columnTitle: "Persons".tr, width: ResponsiveWidget.isMobile(context) ? 100 : MediaQuery.of(context).size.width * 0.1),
                                                      CommonUI.dataColumnWidget(context,
                                                          columnTitle: "Actions".tr, width: ResponsiveWidget.isMobile(context) ? 70 : MediaQuery.of(context).size.width * 0.1),
                                                    ],
                                                    rows: controller.vehicleTypeList.asMap().entries.map((entry) {
                                                      int index = entry.key + 1; // Sr. No. starts from 1
                                                      var vehicleTypeModel = entry.value;

                                                      return DataRow(cells: [
                                                        DataCell(TextCustom(title: index.toString())), // Sr. No.
                                                        DataCell(TextCustom(title: vehicleTypeModel.title.toString())),
                                                        DataCell(
                                                          Container(
                                                            alignment: Alignment.center,
                                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                                            child: NetworkImageWidget(
                                                              imageUrl: vehicleTypeModel.image.toString(),
                                                              borderRadius: 10,
                                                              fit: BoxFit.contain,
                                                              height: 40,
                                                              width: 100,
                                                            ),
                                                          ),
                                                        ),
                                                        DataCell(
                                                          Transform.scale(
                                                            scale: 0.8,
                                                            child: CupertinoSwitch(
                                                              activeTrackColor: AppThemData.primary500,
                                                              value: vehicleTypeModel.isActive!,
                                                              onChanged: (value) async {
                                                                if (Constant.isDemo) {
                                                                  DialogBox.demoDialogBox();
                                                                } else {
                                                                  vehicleTypeModel.isActive = value;
                                                                  await FireStoreUtils.updateVehicleType(vehicleTypeModel);
                                                                  controller.getData();
                                                                }
                                                              },
                                                            ),
                                                          ),
                                                        ),
                                                        DataCell(TextCustom(title: vehicleTypeModel.persons.toString())),
                                                        DataCell(
                                                          Container(
                                                            alignment: Alignment.center,
                                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                                            child: Row(
                                                              mainAxisAlignment: MainAxisAlignment.start,
                                                              children: [
                                                                InkWell(
                                                                  onTap: () {
                                                                    controller.getArgument(vehicleTypeModel);
                                                                    showDialog(context: context, builder: (context) => const VehicleTypeDialog());
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
                                                                      // controller.removeVehicleTypeModel(vehicleTypeModel);
                                                                      // controller.getData();
                                                                      bool confirmDelete = await DialogBox.showConfirmationDeleteDialog(context);
                                                                      if (confirmDelete) {
                                                                        await controller.removeVehicleTypeModel(vehicleTypeModel);
                                                                        controller.getData();
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
                                                        ), // Actions
                                                      ]);
                                                    }).toList(),
                                                  )),
                                  ))
                            ],
                          ),
                        )
                        // Your widgets here
                      ],
                    ),
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

class VehicleTypeDialog extends StatelessWidget {
  const VehicleTypeDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetX<VehicleTypeScreenController>(
        init: VehicleTypeScreenController(),
        builder: (controller) {
          return Dialog(
              backgroundColor: themeChange.isDarkTheme() ? AppThemData.greyShade950 : AppThemData.greyShade50,
              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8.0))),
              alignment: Alignment.topCenter,
              child: SizedBox(
                width: ResponsiveWidget.isDesktop(context) ? MediaQuery.sizeOf(context).width * 0.5 : MediaQuery.sizeOf(context).width * 0.8,
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                                padding: const EdgeInsets.all(24),
                                child: Row(
                                  children: [
                                    TextCustom(title: '${controller.title}', fontSize: 18).expand(),
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
                        spaceH(height: 16),
                        Visibility(
                          visible: controller.isEditing.value,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "✍ Edit your VehicleType here".tr,
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
                        const TextCustom(title: 'Upload Vehicle image', fontSize: 16),
                        spaceH(),
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
                                              File imageFile = File(img.path);
                                              controller.vehicleTypeImage.value.text = img.name;
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
                                              File imageFile = File(img.path);
                                              controller.vehicleTypeImage.value.text = img.name;
                                              controller.imageFile.value = imageFile;
                                              controller.mimeType.value = "${img.mimeType}";
                                              controller.isImageUpdated.value = true;
                                            }
                                          }
                                        },
                                        child: controller.imageFile.value.path.isEmpty
                                            ? Row(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      'upload image'.tr,
                                                      style: const TextStyle(fontSize: 16, color: AppThemData.greyShade500, fontFamily: AppThemeData.medium),
                                                      textAlign: TextAlign.center, // Center the text within the Expanded widget
                                                    ),
                                                  ),
                                                  const SizedBox(
                                                    width: 4,
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
                        spaceH(),
                        Row(
                          children: [
                            Expanded(
                              child: SizedBox(
                                child: CustomTextFormField(title: "Title".tr, hintText: "Enter Title".tr, controller: controller.vehicleTitle.value),
                              ),
                            ),
                            spaceW(),
                            Expanded(
                                child: CustomTextFormField(
                              title: "Person".tr,
                              hintText: "Enter Person".tr,
                              controller: controller.person.value,
                              maxLine: 1,
                            )),
                          ],
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Column(
                              children: [
                                TextCustom(
                                  title: 'Status'.tr,
                                  fontSize: 12,
                                ),
                                spaceH(height: 10),
                                Transform.scale(
                                  scale: 0.8,
                                  child: CupertinoSwitch(
                                    activeTrackColor: AppThemData.primary500,
                                    value: controller.isEnable.value,
                                    onChanged: (value) {
                                      controller.isEnable.value = value;
                                    },
                                  ),
                                ),
                                spaceH(height: 16),
                              ],
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const TextCustom(
                              title: "Zone Charges",
                              fontSize: 16,
                              fontFamily: AppThemeData.medium,
                            ),
                            GestureDetector(
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (context) => fareCalculationInfoDialog(context),
                                );
                              },
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.info_outline,
                                    size: 18,
                                    color: themeChange.isDarkTheme() ? AppThemData.primary500 : AppThemData.primary500,
                                  ),
                                  spaceW(width: 4),
                                  TextCustom(
                                    title: "Fare Calculation Info".tr,
                                    fontSize: 14,
                                    fontFamily: AppThemeData.medium,
                                    color: themeChange.isDarkTheme() ? AppThemData.primary500 : AppThemData.primary500,
                                    isUnderLine: true,
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                        spaceH(height: 16),
                        Obx(
                          () => ListView.builder(
                            shrinkWrap: true,
                            itemCount: controller.zoneList.length,
                            itemBuilder: (context, index) {
                              ZoneModel zone = controller.zoneList[index];
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(zone.name.toString(), style: TextStyle(fontSize: 18, color: AppThemData.primary500, fontFamily: AppThemeData.medium)),
                                  spaceH(height: 10),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: CustomTextFormField(
                                          hintText: "Enter Minimum Distance (in ${Constant.distanceType})",
                                          controller: zone.minDistanceController,
                                          title: "Minimum Distance (in ${Constant.distanceType})",
                                          onChanged: (value) {
                                            zone.charges!.fareMinimumChargesWithinKm = value;
                                          },
                                        ),
                                      ),
                                      spaceW(),
                                      Expanded(
                                        child: CustomTextFormField(
                                          hintText: "Enter Minimum Distance Charge".tr,
                                          controller: zone.minFareController,
                                          title: "Minimum Distance Charge".tr,
                                          onChanged: (value) {
                                            zone.charges!.farMinimumCharges = value;
                                          },
                                        ),
                                      ),
                                      spaceW(),
                                      Expanded(
                                        child: CustomTextFormField(
                                          hintText: "Enter Per ${Constant.distanceType} Charge",
                                          controller: zone.perKmController,
                                          title: "Per ${Constant.distanceType} Charge",
                                          onChanged: (value) {
                                            zone.charges!.farePerKm = value;
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: CustomTextFormField(
                                          hintText: "Enter Hold Charge".tr,
                                          controller: zone.holdChargeController,
                                          title: "Hold Charge".tr,
                                          onChanged: (value) {
                                            zone.charges!.holdCharge = value;
                                          },
                                        ),
                                      ),
                                      spaceW(),
                                      Expanded(
                                        child: CustomTextFormField(
                                          hintText: "Enter Minute Charge".tr,
                                          controller: zone.minuteChargeController,
                                          title: "Minute Charge".tr,
                                          onChanged: (value) {
                                            zone.charges!.minuteCharge = value;
                                          },
                                        ),
                                      ),
                                      spaceW(),
                                      Expanded(
                                        child: CustomTextFormField(
                                          hintText: "Enter Increment for Night Charge (in %)".tr,
                                          controller: zone.nightChargeController,
                                          title: "Increment for Night Charge (in %)".tr,
                                          tooltipsShow: true,
                                          onChanged: (value) {
                                            zone.charges!.incrementOfNightCharge = value;
                                          },
                                          tooltipsText: "Increment for Night Charge will be applied as a percentage of the base fare during night hours.",
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (index != controller.zoneList.length - 1)
                                    Divider(
                                      color: AppThemData.greyShade500,
                                    ).paddingOnly(bottom: 16)
                                ],
                              );
                            },
                          ),
                        ),
                        spaceH(height: 20),
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
                                  if (controller.vehicleTitle.value.text.isNotEmpty &&
                                      controller.vehicleTypeImage.value.text.isNotEmpty &&
                                      controller.person.value.text.isNotEmpty) {
                                    for (int i = 0; i < controller.zoneList.length; i++) {
                                      final zoneName = controller.zoneList[i].name ?? "Zone ${i + 1}";
                                      final minDistance = controller.zoneList[i].charges?.fareMinimumChargesWithinKm ?? '';
                                      final minDistanceFare = controller.zoneList[i].charges?.farMinimumCharges ?? '';
                                      final ratePerExtraKm = controller.zoneList[i].charges?.farePerKm ?? '';
                                      final holdCharge = controller.zoneList[i].charges?.holdCharge ?? '';
                                      final minuteCharge = controller.zoneList[i].charges?.minuteCharge ?? '';
                                      final incrementOfNightCharge = controller.zoneList[i].charges?.incrementOfNightCharge ?? '';
                                      if (minDistance.isEmpty ||
                                          minDistanceFare.isEmpty ||
                                          ratePerExtraKm.isEmpty ||
                                          holdCharge.isEmpty ||
                                          minuteCharge.isEmpty ||
                                          incrementOfNightCharge.isEmpty) {
                                        ShowToastDialog.toast("Please fill all charges for $zoneName".tr);
                                        controller.isLoading = false.obs;
                                        return;
                                      }
                                    }
                                    controller.isEditing.value ? controller.isEditing(true) : controller.isLoading(true);
                                    controller.isEditing.value ? controller.updateVehicleType() : controller.addVehicleType();

                                    Navigator.pop(context);
                                  } else {
                                    ShowToastDialog.toast("All Fields are Required...".tr);
                                    controller.isLoading = false.obs;
                                  }
                                }
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ));
        });
  }

  Dialog fareCalculationInfoDialog(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    final fares = Constant.distanceType == "Km"
        ? {"minDistance": 10, "minFare": 14, "perDistanceCharge": 12, "holdCharge": 4, "minuteCharge": 2}
        : {"minDistance": 6, "minFare": 20, "perDistanceCharge": 15, "holdCharge": 5, "minuteCharge": 3};
    final int belowMinDistance = fares['minDistance']! - 2;
    final int aboveMinDistance = fares['minDistance']! + 5;
    return Dialog(
      backgroundColor: themeChange.isDarkTheme() ? AppThemData.greyShade950 : AppThemData.greyShade50,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8.0))),
      alignment: Alignment.center,
      child: SizedBox(
        width: ResponsiveWidget.isDesktop(context) ? MediaQuery.sizeOf(context).width * 0.4 : MediaQuery.sizeOf(context).width * 0.7,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(8.0),
                  topRight: Radius.circular(8.0),
                ),
                color: themeChange.isDarkTheme() ? AppThemData.greyShade900 : AppThemData.greyShade100,
              ),
              child: Row(
                children: [
                  TextCustom(
                    title: "Fare Calculation Info".tr,
                    fontSize: 18,
                  ).expand(),
                  10.width,
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    child: Icon(
                      Icons.close,
                      size: 25,
                      color: themeChange.isDarkTheme() ? AppThemData.primaryWhite : AppThemData.primaryBlack,
                    ),
                  )
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextCustom(
                    title: "• If the ride distance is less than or equal to the Minimum Distance, "
                            "a fixed Minimum Fare will be charged.\n\n"
                            "• If the ride distance is greater than the Minimum Distance, "
                            "the Per ${Constant.distanceType} Charge will be applied to the total distance.\n\n"
                            "• Increment for Night Charge will be applied as a percentage of the base fare during night hours.\n\n"
                            "• Hold Charge applies when the ride is paused or held after it has started.\n"
                            "  It is added based on the number of minutes the ride remains on hold.\n\n"
                            "• Minute Charge applies to the total duration of the ride."
                        .tr,
                    fontSize: 14,
                    fontFamily: AppThemeData.medium,
                    maxLine: 20,
                    color: themeChange.isDarkTheme() ? AppThemData.greyShade400 : AppThemData.greyShade700,
                  ),
                  spaceH(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: themeChange.isDarkTheme() ? AppThemData.greyShade900 : AppThemData.greyShade100,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: RichText(
                      text: TextSpan(
                        style: TextStyle(
                            fontSize: 14, color: themeChange.isDarkTheme() ? AppThemData.greyShade400 : AppThemData.greyShade700, height: 1.4, fontFamily: AppThemeData.regular),
                        children: [
                          TextSpan(text: "💡 Example:\n".tr, style: TextStyle(color: AppThemData.primary500)),
                          TextSpan(text: "Minimum Distance: ", style: TextStyle(fontFamily: AppThemeData.medium)),
                          TextSpan(text: "${fares['minDistance']} ${Constant.distanceType}\n"),
                          TextSpan(text: "Minimum Fare: ", style: TextStyle(fontFamily: AppThemeData.medium)),
                          TextSpan(text: "${Constant.amountShow(amount: '${fares['minFare']}')}\n"),
                          TextSpan(text: "Per ${Constant.distanceType} Charge: ", style: TextStyle(fontFamily: AppThemeData.medium)),
                          TextSpan(text: "${Constant.amountShow(amount: '${fares['perDistanceCharge']}')}\n"),
                          TextSpan(text: "Hold Charge: ", style: TextStyle(fontFamily: AppThemeData.medium)),
                          TextSpan(text: "${Constant.amountShow(amount: '${fares['holdCharge']}')} ${"per minute (only when ride is paused)\n".tr}"),
                          TextSpan(text: "Minute Charge: ", style: TextStyle(fontFamily: AppThemeData.medium)),
                          TextSpan(text: "${Constant.amountShow(amount: '${fares['minuteCharge']}')} ${"per minute (total ride duration)\n\n".tr}"),
                          TextSpan(text: "Ride Distance : $belowMinDistance ${Constant.distanceType} → ", style: TextStyle(fontFamily: AppThemeData.medium)),
                          TextSpan(text: "${Constant.amountShow(amount: '${fares['minFare']}')} ${"(minimum fare)\n".tr}"),
                          TextSpan(text: "Ride Distance : $aboveMinDistance ${Constant.distanceType} → ", style: TextStyle(fontFamily: AppThemeData.medium)),
                          TextSpan(
                              text: "${Constant.amountShow(amount: '${aboveMinDistance * fares['perDistanceCharge']!}')}"
                                  " ($aboveMinDistance × ${fares['perDistanceCharge']})\n"),
                          TextSpan(text: "Hold for 2 min → ", style: TextStyle(fontFamily: AppThemeData.medium)),
                          TextSpan(text: "+${Constant.amountShow(amount: '${2 * fares['holdCharge']!}')}\n"),
                          TextSpan(text: "Ride time 20 min → ", style: TextStyle(fontFamily: AppThemeData.medium)),
                          TextSpan(text: "+${Constant.amountShow(amount: '${20 * fares['minuteCharge']!}')}")
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
