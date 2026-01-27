// ignore_for_file: use_build_context_synchronously
import 'package:admin/app/constant/constants.dart';
import 'package:admin/app/components/custom_button.dart';
import 'package:admin/app/modules/zone_screen/controllers/zone_screen_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:flutter/cupertino.dart';
import '../../../../widget/common_ui.dart';
import '../../../../widget/container_custom.dart';
import '../../../../widget/global_widgets.dart';
import '../../../../widget/text_widget.dart';
import '../../../components/dialog_box.dart';
import '../../../components/menu_widget.dart';
import '../../../routes/app_pages.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_them_data.dart';
import '../../../utils/dark_theme_provider.dart';
import '../../../utils/fire_store_utils.dart';
import '../../../utils/responsive.dart';

class ZoneScreenView extends GetView<ZoneScreenController> {
  const ZoneScreenView({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetX<ZoneScreenController>(
      init: ZoneScreenController(),
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
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
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
                                        Row(
                                          children: [
                                            CustomButtonWidget(
                                              padding: const EdgeInsets.symmetric(horizontal: 22),
                                              buttonTitle: " + Add Zone".tr,
                                              borderRadius: 10,
                                              onPress: () {
                                                Get.toNamed(Routes.CREATE_ZONE_SCREEN)!.then((value) {
                                                  if (value == true) {
                                                    controller.getData();
                                                  }
                                                });
                                              },
                                            ),
                                          ],
                                        )
                                      ],
                                    )
                                  : Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        Row(
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
                                            Spacer(),
                                            CustomButtonWidget(
                                              padding: const EdgeInsets.symmetric(horizontal: 22),
                                              buttonTitle: " + Add Zone".tr,
                                              borderRadius: 10,
                                              onPress: () {
                                                Get.toNamed(Routes.CREATE_ZONE_SCREEN);
                                              },
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                              spaceH(height: 20),
                              Obx(() {
                                if (controller.isLoading.value) {
                                  return Constant.loader();
                                } else if (controller.zoneList.isEmpty) {
                                  return TextCustom(title: "No Data available".tr);
                                } else {
                                  return SingleChildScrollView(
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
                                        headingRowColor: WidgetStateColor.resolveWith((states) => themeChange.isDarkTheme() ? AppThemData.greyShade800 : AppThemData.greyShade100),
                                        columns: [
                                          CommonUI.dataColumnWidget(context, columnTitle: "Id".tr, width: 100),
                                          CommonUI.dataColumnWidget(context, columnTitle: "Name".tr, width: 180),
                                          CommonUI.dataColumnWidget(context, columnTitle: "Status".tr, width: 100),
                                          CommonUI.dataColumnWidget(context, columnTitle: "Created Date".tr, width: 160),
                                          CommonUI.dataColumnWidget(context, columnTitle: "Actions".tr, width: 100),
                                        ],
                                        rows: controller.zoneList
                                            .map((zoneList) => DataRow(cells: [
                                                  DataCell(
                                                    Container(
                                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                                        child: TextCustom(title: "#${zoneList.id!.substring(0, 8)}")),
                                                  ),
                                                  DataCell(
                                                    Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8), child: TextCustom(title: "${zoneList.name}")),
                                                  ),
                                                  DataCell(
                                                    Transform.scale(
                                                      scale: 0.8,
                                                      child: CupertinoSwitch(
                                                        activeTrackColor: AppThemData.primary500,
                                                        value: zoneList.status!,
                                                        onChanged: (value) async {
                                                          if (Constant.isDemo) {
                                                            DialogBox.demoDialogBox();
                                                          } else {
                                                            zoneList.status = value;
                                                            await FireStoreUtils.updateZone(zoneList);
                                                            controller.getData();
                                                          }
                                                        },
                                                      ),
                                                    ),
                                                  ),
                                                  DataCell(
                                                    Container(
                                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                                        child: TextCustom(title: Constant.timestampToDateTime(zoneList.createdAt!))),
                                                  ),
                                                  DataCell(Row(
                                                    children: [
                                                      InkWell(
                                                        onTap: () async {
                                                          final result = await Get.toNamed('${Routes.CREATE_ZONE_SCREEN}/${zoneList.id}');
                                                          if (result == true) {
                                                            controller.getData();
                                                          }
                                                        },
                                                        child: SvgPicture.asset(
                                                          "assets/icons/ic_edit.svg",
                                                          color: AppThemData.greyShade400,
                                                          height: 16,
                                                          width: 16,
                                                        ),
                                                      ),
                                                      spaceW(width: 16),
                                                      InkWell(
                                                        onTap: () async {
                                                          if (Constant.isDemo) {
                                                            DialogBox.demoDialogBox();
                                                          } else {
                                                            bool confirmDelete = await DialogBox.showConfirmationDeleteDialog(context);
                                                            if (confirmDelete) {
                                                              await controller.removeZone(zoneList);
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
                                                  )),
                                                ]))
                                            .toList(),
                                      ),
                                    ),
                                  );
                                }
                              }),
                            ],
                          ),
                        ),
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
