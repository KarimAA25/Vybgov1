import 'package:admin/app/components/custom_button.dart';
import 'package:admin/app/components/custom_text_form_field.dart';
import 'package:admin/app/components/dialog_box.dart';
import 'package:admin/app/components/menu_widget.dart';
import 'package:admin/app/constant/constants.dart';
import 'package:admin/app/constant/show_toast.dart';
import 'package:admin/app/models/push_notification_model.dart';
import 'package:admin/app/utils/app_colors.dart';
import 'package:admin/app/utils/app_them_data.dart';
import 'package:admin/app/utils/dark_theme_provider.dart';
import 'package:admin/app/utils/responsive.dart';
import 'package:admin/widget/common_ui.dart';
import 'package:admin/widget/container_custom.dart';
import 'package:admin/widget/global_widgets.dart';
import 'package:admin/widget/text_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../../routes/app_pages.dart';
import '../controllers/add_notification_controller.dart';

class AddNotificationView extends GetView<AddNotificationController> {
  const AddNotificationView({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetX<AddNotificationController>(
      init: AddNotificationController(),
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
                                      buttonTitle: "+ New Notification".tr,
                                      borderRadius: 10,
                                      onPress: () {
                                        controller.setDefaultData();
                                        showDialog(context: context, builder: (context) => const AddNotificationDialog());
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
                                        : controller.notificationScreenList.isEmpty
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
                                                      columnTitle: "Title".tr, width: ResponsiveWidget.isMobile(context) ? 150 : MediaQuery.of(context).size.width * 0.14),
                                                  CommonUI.dataColumnWidget(context,
                                                      columnTitle: "Description".tr, width: ResponsiveWidget.isMobile(context) ? 150 : MediaQuery.of(context).size.width * 0.20),
                                                  CommonUI.dataColumnWidget(context,
                                                      columnTitle: "Type".tr, width: ResponsiveWidget.isMobile(context) ? 150 : MediaQuery.of(context).size.width * 0.06),
                                                  CommonUI.dataColumnWidget(context,
                                                      columnTitle: "Actions".tr, width: ResponsiveWidget.isMobile(context) ? 40 : MediaQuery.of(context).size.width * 0.04),
                                                ],
                                                rows: controller.notificationScreenList
                                                    .map((notificationModel) => DataRow(cells: [
                                                          DataCell(TextCustom(title: notificationModel.title ?? "N/A".tr)),
                                                          DataCell(TextCustom(
                                                            title: notificationModel.description ?? "N/A".tr,
                                                            maxLine: 2,
                                                          )),
                                                          DataCell(TextCustom(title: notificationModel.type == "customer" ? "Customer".tr : "Driver")),
                                                          DataCell(
                                                            Container(
                                                              alignment: Alignment.center,
                                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                                              child: Row(
                                                                mainAxisAlignment: MainAxisAlignment.start,
                                                                children: [
                                                                  CustomButtonWidget(
                                                                    padding: const EdgeInsets.symmetric(horizontal: 22),
                                                                    height: 40,
                                                                    width: 30,
                                                                    buttonTitle: "Resend".tr,
                                                                    borderRadius: 10,
                                                                    onPress: () {
                                                                      if (Constant.isDemo) {
                                                                        DialogBox.demoDialogBox();
                                                                      } else {
                                                                        controller.resendNotification(notificationModel);
                                                                      }
                                                                    },
                                                                  ),
                                                                  spaceW(),
                                                                  InkWell(
                                                                    onTap: () async {
                                                                      if (Constant.isDemo) {
                                                                        DialogBox.demoDialogBox();
                                                                      } else {
                                                                        bool confirmDelete = await DialogBox.showConfirmationDeleteDialog(context);
                                                                        if (confirmDelete) {
                                                                          await controller.removeNotification(notificationModel);
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

class AddNotificationDialog extends StatelessWidget {
  final PushNotificationModel? notificationScreenModel;

  const AddNotificationDialog({super.key, this.notificationScreenModel});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetX(
        init: AddNotificationController(),
        builder: (controller) {
          return CustomDialog(
            controller: controller,
            title: controller.title.value,
            widgetList: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: CustomTextFormField(
                      hintText: "Enter Title",
                      title: "Title",
                      controller: controller.titleController.value,
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextCustom(
                          title: 'User Type'.tr,
                          fontSize: 14,
                        ),
                        SizedBox(height: 10),
                        Obx(
                          () => SizedBox(
                            height: 50,
                            child: DropdownButtonFormField(
                              isExpanded: true,
                              dropdownColor: themeChange.isDarkTheme() ? AppThemData.greyShade950 : AppThemData.greyShade50,
                              style: TextStyle(
                                fontFamily: AppThemeData.medium,
                                color: themeChange.isDarkTheme() ? AppThemData.greyShade100 : AppThemData.greyShade800,
                              ),
                              hint: TextCustom(
                                title: 'Select User Type'.tr,
                              ),
                              onChanged: (String? userType) {
                                controller.selectedUserType.value = userType ?? "Customer";
                              },
                              value: controller.selectedUserType.value,
                              icon: const Icon(Icons.keyboard_arrow_down_outlined),
                              items: controller.userType.map<DropdownMenuItem<String>>((String value) {
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
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              spaceH(height: 20),
              CustomTextFormField(
                hintText: "Enter Description",
                title: "Description",
                controller: controller.descriptionController.value,
                maxLine: 2,
              ),
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
                    buttonTitle: "Send".tr,
                    onPress: () {
                      if (Constant.isDemo) {
                        DialogBox.demoDialogBox();
                      } else {
                        if (controller.titleController.value.text.isNotEmpty && controller.descriptionController.value.text.isNotEmpty) {
                          controller.addNotificationScreen();
                        } else {
                          ShowToastDialog.errorToast("All fields are required.".tr);
                        }
                      }
                    },
                  ),
                ],
              ),
            ],
          );
        });
  }
}
