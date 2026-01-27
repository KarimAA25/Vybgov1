// ignore_for_file: deprecated_member_use
import 'package:admin/app/components/custom_button.dart';
import 'package:admin/app/components/menu_widget.dart';
import 'package:admin/app/models/rental_package_model.dart';
import 'package:admin/app/models/vehicle_type_model.dart';
import 'package:admin/app/utils/app_colors.dart';
import 'package:admin/app/utils/app_them_data.dart';
import 'package:admin/app/utils/dark_theme_provider.dart';
import 'package:admin/app/utils/fire_store_utils.dart';
import 'package:admin/app/utils/responsive.dart';
import 'package:admin/widget/common_ui.dart';
import 'package:admin/widget/container_custom.dart';
import 'package:admin/widget/global_widgets.dart';
import 'package:admin/widget/text_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../../components/custom_text_form_field.dart';
import '../../../components/dialog_box.dart';
import '../../../constant/constants.dart';
import '../../../constant/show_toast.dart';
import '../../../routes/app_pages.dart';
import '../controllers/rental_package_screen_controller.dart';

class RentalPackageScreenView extends GetView<RentalPackageScreenController> {
  const RentalPackageScreenView({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetX<RentalPackageScreenController>(
      init: RentalPackageScreenController(),
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
                      child: Column(mainAxisSize: MainAxisSize.min, mainAxisAlignment: MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.start, children: [
                        ContainerCustom(
                          child: Column(children: [
                            ResponsiveWidget.isDesktop(context)
                                ? Row(
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
                                      spaceH(),
                                      Row(
                                        children: [
                                          CustomButtonWidget(
                                            borderRadius: 10,
                                            padding: const EdgeInsets.symmetric(horizontal: 22),
                                            buttonTitle: "+ Add Rental Package".tr,
                                            onPress: () {
                                              controller.setDefaultData();
                                              showDialog(context: context, builder: (context) => RentalDialog());
                                            },
                                          ),
                                        ],
                                      )
                                    ],
                                  )
                                : Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
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
                                      spaceH(),
                                    ],
                                  ),
                            spaceH(height: 20),
                            controller.isLoading.value
                                ? Constant.loader()
                                : (controller.rentalPackageList.isEmpty)
                                    ? const Center(
                                        child: TextCustom(
                                        title: "No Available Rental Packages",
                                      ))
                                    : Align(
                                        alignment: Alignment.centerLeft,
                                        child: SingleChildScrollView(
                                          scrollDirection: Axis.horizontal,
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(12),
                                            child: DataTable(
                                                horizontalMargin: 20,
                                                columnSpacing: 30,
                                                dataRowMaxHeight: 65,
                                                headingRowHeight: 65,
                                                border: TableBorder.all(
                                                  color: themeChange.isDarkTheme() ? AppThemData.greyShade800 : AppThemData.greyShade100,
                                                  borderRadius: BorderRadius.circular(12),
                                                ),
                                                headingRowColor:
                                                    MaterialStateColor.resolveWith((states) => themeChange.isDarkTheme() ? AppThemData.greyShade800 : AppThemData.greyShade100),
                                                columns: [
                                                  CommonUI.dataColumnWidget(context, columnTitle: "Id".tr, width: 100),
                                                  CommonUI.dataColumnWidget(context, columnTitle: "Title".tr, width: 150),
                                                  CommonUI.dataColumnWidget(context, columnTitle: "Base Fare".tr, width: 100),
                                                  CommonUI.dataColumnWidget(context, columnTitle: "Extra Km Fare".tr, width: 100),
                                                  CommonUI.dataColumnWidget(context, columnTitle: "Extra Hour Fare".tr, width: 100),
                                                  CommonUI.dataColumnWidget(context, columnTitle: "Included Distance".tr, width: 100),
                                                  CommonUI.dataColumnWidget(context, columnTitle: "Included Hours".tr, width: 100),
                                                  CommonUI.dataColumnWidget(context, columnTitle: "Vehicle type".tr, width: 100),
                                                  CommonUI.dataColumnWidget(context, columnTitle: "Actions".tr, width: 100),
                                                ],
                                                rows: controller.rentalPackageList
                                                    .map((rentalPackageModel) => DataRow(cells: [
                                                          DataCell(
                                                            Container(
                                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                                                child: TextCustom(title: rentalPackageModel.id!.substring(0, 8))),
                                                          ),
                                                          DataCell(
                                                            Container(
                                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                                              child: TextCustom(
                                                                title: rentalPackageModel.title ?? "N/A",
                                                              ),
                                                            ),
                                                          ),
                                                          DataCell(
                                                            Container(
                                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                                                child: TextCustom(title: Constant.amountShow(amount: rentalPackageModel.baseFare.toString()))),
                                                          ),
                                                          DataCell(
                                                            Container(
                                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                                              child: TextCustom(title: Constant.amountShow(amount: rentalPackageModel.extraKmFare.toString())),
                                                            ),
                                                          ),
                                                          DataCell(
                                                            Container(
                                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                                                child: TextCustom(title: Constant.amountShow(amount: rentalPackageModel.extraHourFare.toString()))),
                                                          ),
                                                          DataCell(
                                                            Container(
                                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                                                child: TextCustom(title: rentalPackageModel.includedDistance.toString())),
                                                          ),
                                                          DataCell(
                                                            Container(
                                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                                                child: TextCustom(
                                                                  title: rentalPackageModel.includedHours.toString(),
                                                                )),
                                                          ),
                                                          DataCell(
                                                            FutureBuilder<VehicleTypeModel?>(
                                                              future: FireStoreUtils.getVehicleByVehicleID(rentalPackageModel.vehicleId ?? ''),
                                                              builder: (context, snapshot) {
                                                                if (snapshot.connectionState == ConnectionState.waiting) {
                                                                  return const SizedBox(
                                                                    width: 20,
                                                                    height: 20,
                                                                    child: CircularProgressIndicator(strokeWidth: 2),
                                                                  );
                                                                } else if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
                                                                  return const Text('N/A');
                                                                } else {
                                                                  final vehicle = snapshot.data!;
                                                                  return TextCustom(title: vehicle.title ?? 'Unknown');
                                                                }
                                                              },
                                                            ),
                                                          ),
                                                          DataCell(
                                                            Container(
                                                              alignment: Alignment.center,
                                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                                              child: Row(
                                                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                                children: [
                                                                  IconButton(
                                                                    onPressed: () async {
                                                                      if (Constant.isDemo) {
                                                                        DialogBox.demoDialogBox();
                                                                      } else {
                                                                        controller.isEditing.value = true;
                                                                        controller.editingId.value = rentalPackageModel.id!;
                                                                        controller.titleController.value.text = rentalPackageModel.title!;
                                                                        controller.baseFareController.value.text = rentalPackageModel.baseFare!;
                                                                        controller.extraKmFareController.value.text = rentalPackageModel.extraKmFare!;
                                                                        controller.extraHourFareController.value.text = rentalPackageModel.extraHourFare!;
                                                                        controller.includedHoursController.value.text = rentalPackageModel.includedHours!;
                                                                        controller.includedDistanceController.value.text = rentalPackageModel.includedDistance!;
                                                                        controller.selectedVehicleId.value.id = rentalPackageModel.vehicleId;
                                                                        showDialog(
                                                                            context: context,
                                                                            builder: (context) => RentalDialog(
                                                                                  rentalPackageModel: rentalPackageModel,
                                                                                ));
                                                                      }
                                                                    },
                                                                    icon: SvgPicture.asset(
                                                                      "assets/icons/ic_edit.svg",
                                                                      color: AppThemData.greyShade400,
                                                                      height: 16,
                                                                      width: 16,
                                                                    ),
                                                                  ),
                                                                  IconButton(
                                                                    onPressed: () async {
                                                                      DialogBox.commonDialogBox(
                                                                        context: Get.context!,
                                                                        description: 'This action will permanently delete this RentalPackage.'.tr,
                                                                        deleteOnPress: () async {
                                                                          Get.back();
                                                                          if (Constant.isDemo) {
                                                                            DialogBox.demoDialogBox();
                                                                          } else {
                                                                            controller.isLoading.value = true;
                                                                            bool isDeleted = await controller.removeRentalPackage(rentalPackageModel.id ?? "");
                                                                            if (isDeleted) {
                                                                              controller.getData();
                                                                              ShowToastDialog.successToast("Rental Package Deleted".tr);
                                                                            } else {
                                                                              ShowToastDialog.errorToast("Something went wrong!");
                                                                              controller.isLoading.value = false;
                                                                            }
                                                                          }
                                                                        },
                                                                      );
                                                                    },
                                                                    icon: SvgPicture.asset(
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
                                      )
                          ]),
                        )
                      ]),
                    )),
              ),
            ],
          ),
        );
      },
    );
  }
}

class RentalDialog extends StatelessWidget {
  final RentalPackageModel? rentalPackageModel;

  const RentalDialog({super.key, this.rentalPackageModel});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);

    return GetX<RentalPackageScreenController>(
      init: RentalPackageScreenController(),
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
            spaceH(height: 16),
            SizedBox(child: CustomTextFormField(title: "Title".tr, hintText: "Enter Title".tr, controller: controller.titleController.value)),
            Row(
              children: [
                Expanded(
                    child: SizedBox(
                        child: CustomTextFormField(
                            title: "Base Fare".tr,
                            hintText: "Enter Base Fare".tr,
                            controller: controller.baseFareController.value,
                            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                            prefix: Padding(
                                padding: paddingEdgeInsets(vertical: 10, horizontal: 10),
                                child: TextCustom(
                                  title: '${Constant.currencyModel!.symbol}',
                                  fontSize: 18,
                                ))))),
                spaceW(width: 16),
                Expanded(
                    child: SizedBox(
                        child: CustomTextFormField(
                  title: "Included Hours".tr,
                  hintText: "Enter Included Hours".tr,
                  controller: controller.includedHoursController.value,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ))),
              ],
            ),
            Row(
              children: [
                Expanded(
                    child: SizedBox(
                        child: CustomTextFormField(
                  title: "Included Distance".tr,
                  hintText: "Enter Included Distance".tr,
                  controller: controller.includedDistanceController.value,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ))),
                spaceW(width: 16),
                Expanded(
                    child: SizedBox(
                        child: CustomTextFormField(
                            title: "Extra Km Fare".tr,
                            hintText: "Enter Extra Km Fare".tr,
                            controller: controller.extraKmFareController.value,
                            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                            prefix: Padding(
                                padding: paddingEdgeInsets(vertical: 10, horizontal: 10),
                                child: TextCustom(
                                  title: '${Constant.currencyModel!.symbol}',
                                  fontSize: 18,
                                ))))),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: [
                Expanded(
                  child: SizedBox(
                    child: CustomTextFormField(
                      title: "Extra Hour Fare".tr,
                      hintText: "Enter Extra Hour Fare".tr,
                      controller: controller.extraHourFareController.value,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      prefix: Padding(
                        padding: paddingEdgeInsets(vertical: 10, horizontal: 10),
                        child: TextCustom(
                          title: '${Constant.currencyModel!.symbol}',
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                ),
                spaceW(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextCustom(
                        title: 'Vehicle Type'.tr,
                        fontSize: 12,
                      ),
                      spaceH(height: 10),
                      Obx(
                        () => DropdownButtonFormField<VehicleTypeModel>(
                          isExpanded: true,
                          dropdownColor: themeChange.isDarkTheme() ? AppThemData.greyShade950 : AppThemData.greyShade50,
                          style: TextStyle(
                            fontFamily: AppThemeData.medium,
                            color: themeChange.isDarkTheme() ? AppThemData.greyShade100 : AppThemData.greyShade800,
                          ),
                          iconEnabledColor: themeChange.isDarkTheme() ? AppThemData.primaryWhite : AppThemData.primaryBlack,
                          hint: TextCustom(
                            title: 'Select Vehicle type'.tr,
                            fontSize: 14,
                            // color: themeChange.isDarkTheme() ? AppThemData.greyShade500 : AppThemData.greyShade800,
                            fontFamily: AppThemeData.medium,
                          ),
                          onChanged: (vehicleType) {
                            controller.selectedVehicleId.value = vehicleType!;
                          },
                          value: controller.vehicleList.firstWhereOrNull(
                            (v) => v.id == controller.selectedVehicleId.value.id,
                          ),
                          items: controller.vehicleList.map((value) {
                            return DropdownMenuItem<VehicleTypeModel>(
                              value: value,
                              child: Text(
                                value.title.toString(),
                                style: TextStyle(
                                  fontFamily: AppThemeData.regular,
                                  fontSize: 16,
                                  color: themeChange.isDarkTheme() ? AppThemData.greyShade100 : AppThemData.greyShade800,
                                ),
                              ),
                            );
                          }).toList(),
                          decoration: Constant.DefaultInputDecoration(context),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            spaceH(),
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
                          controller.baseFareController.value.text.isNotEmpty &&
                          controller.includedHoursController.value.text.isNotEmpty &&
                          controller.includedDistanceController.value.text.isNotEmpty &&
                          controller.extraHourFareController.value.text.isNotEmpty &&
                          controller.extraKmFareController.value.text.isNotEmpty &&
                          controller.selectedVehicleId.value.id != null &&
                          controller.selectedVehicleId.value.id!.isNotEmpty) {
                        controller.isEditing.value ? controller.isEditing(true) : controller.isLoading(true);
                        controller.isEditing.value == true ? controller.updateRentalPackage(rentalPackageModel!) : controller.addRentalPackage(context);
                      } else {
                        ShowToastDialog.toast("All Fields are Required...".tr);
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
