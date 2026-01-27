import 'package:admin/app/components/custom_button.dart';
import 'package:admin/app/components/menu_widget.dart';
import 'package:admin/app/constant/constants.dart';
import 'package:admin/app/models/driver_user_model.dart';
import 'package:admin/app/models/emergency_number_model.dart';
import 'package:admin/app/models/sos_alerts_model.dart';
import 'package:admin/app/models/user_model.dart';
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
import 'package:nb_utils/nb_utils.dart';
import 'package:provider/provider.dart';

import '../../../routes/app_pages.dart';
import '../../../utils/fire_store_utils.dart';
import '../controllers/sos_alerts_controller.dart';

class SosAlertsView extends GetView<SosAlertsController> {
  const SosAlertsView({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetX(
      init: SosAlertsController(),
      builder: (controller) {
        return Scaffold(
            backgroundColor: themeChange.isDarkTheme() ? AppThemData.greyShade950 : AppThemData.greyShade50,
            appBar: AppBar(
              elevation: 0.0,
              toolbarHeight: 70,
              automaticallyImplyLeading: false,
              backgroundColor: themeChange.isDarkTheme() ? AppThemData.primaryBlack : AppThemData.primaryWhite,
              leadingWidth: 200,
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
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: paddingEdgeInsets(),
                        child: ContainerCustom(
                          child: Column(
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
                              spaceH(height: 20),
                              controller.isLoading.value
                                  ? Constant.loader()
                                  : controller.sosAlertsList.isEmpty
                                      ? Center(
                                          child: TextCustom(title: "No Alerts".tr),
                                        )
                                      : SingleChildScrollView(
                                          scrollDirection: Axis.horizontal,
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(12),
                                            child: DataTable(
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
                                                      columnTitle: "Id".tr, width: ResponsiveWidget.isMobile(context) ? 15 : MediaQuery.of(context).size.width * 0.05),
                                                  CommonUI.dataColumnWidget(context,
                                                      columnTitle: "Booking Id".tr, width: ResponsiveWidget.isMobile(context) ? 15 : MediaQuery.of(context).size.width * 0.1),
                                                  CommonUI.dataColumnWidget(context,
                                                      columnTitle: "SOS Type".tr, width: ResponsiveWidget.isMobile(context) ? 120 : MediaQuery.of(context).size.width * 0.10),
                                                  CommonUI.dataColumnWidget(context,
                                                      columnTitle: "Type".tr, width: ResponsiveWidget.isMobile(context) ? 150 : MediaQuery.of(context).size.width * 0.08),
                                                  CommonUI.dataColumnWidget(context,
                                                      columnTitle: "Status".tr, width: ResponsiveWidget.isMobile(context) ? 100 : MediaQuery.of(context).size.width * 0.05),
                                                  CommonUI.dataColumnWidget(context,
                                                      columnTitle: "Actions".tr, width: ResponsiveWidget.isMobile(context) ? 70 : MediaQuery.of(context).size.width * 0.05),
                                                ],
                                                rows: controller.sosAlertsList
                                                    .map((element) => DataRow(cells: [
                                                          DataCell(TextCustom(title: "#${element.id!.substring(0, 6)}")),
                                                          DataCell(TextCustom(title: element.bookingId.toString())),
                                                          DataCell(TextCustom(
                                                              title: element.emergencyType == "contacts"
                                                                  ? "Emergency Contacts".tr
                                                                  : "Call_sos".trParams({"callsos": Constant.sosAlertNumber.toString()}))),
                                                          DataCell(TextCustom(title: element.type == "customer" ? "Customer".tr : "Driver".tr)),
                                                          DataCell(Container(
                                                            padding: EdgeInsets.all(8),
                                                            decoration: BoxDecoration(
                                                                borderRadius: BorderRadius.circular(8),
                                                                color: element.status == "pending"
                                                                    ? AppThemData.blue500.withOpacity(0.2)
                                                                    : element.status == "cancelled"
                                                                        ? AppThemData.red500.withOpacity(0.2)
                                                                        : element.status == "in-progress"
                                                                            ? AppThemData.yellow600.withOpacity(.2)
                                                                            : AppThemData.green500.withOpacity(0.2)),
                                                            child: TextCustom(
                                                                title: element.status == "pending"
                                                                    ? "Pending".tr
                                                                    : element.status == "cancelled"
                                                                        ? "Cancelled".tr
                                                                        : element.status == "in-progress"
                                                                            ? "In Progress".tr
                                                                            : "Resolved".tr,
                                                                color: element.status == "pending"
                                                                    ? AppThemData.blue500
                                                                    : element.status == "cancelled"
                                                                        ? AppThemData.red500
                                                                        : element.status == "in-progress"
                                                                            ? AppThemData.yellow600
                                                                            : AppThemData.green500),
                                                          )),
                                                          DataCell(InkWell(
                                                              onTap: () {
                                                                showDialog(
                                                                  context: context,
                                                                  builder: (context) => openSOSDetailDialog(context, element, controller),
                                                                );
                                                              },
                                                              child: SvgPicture.asset("assets/icons/ic_eye.svg")))
                                                        ]))
                                                    .toList()),
                                          ),
                                        )
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ))
              ],
            ));
      },
    );
  }

  Dialog openSOSDetailDialog(BuildContext context, SOSAlertsModel sosAlerts, SosAlertsController controller) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return Dialog(
      backgroundColor: themeChange.isDarkTheme() ? AppThemData.greyShade950 : AppThemData.greyShade50,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8.0))),
      alignment: Alignment.topCenter,
      child: SizedBox(
        width: 600,
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
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextCustom(title: '${controller.title}'.tr, fontSize: 18),
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
                padding: const EdgeInsets.all(24),
                child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8), border: Border.all(color: themeChange.isDarkTheme() ? AppThemData.greyShade700 : AppThemData.greyShade200)),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                          child: Row(
                            children: [
                              Text(
                                "Id".tr,
                                style: TextStyle(
                                    fontSize: 14, color: themeChange.isDarkTheme() ? AppThemData.greyShade300 : AppThemData.greyShade600, fontFamily: AppThemeData.medium),
                              ).expand(),
                              spaceW(width: 10),
                              TextCustom(
                                title: "# ${sosAlerts.id}",
                                color: themeChange.isDarkTheme() ? AppThemData.greyShade25 : AppThemData.greyShade950,
                                fontSize: 16,
                                fontFamily: AppThemeData.medium,
                                maxLine: 2,
                              ).expand()
                            ],
                          ),
                        ),
                        Divider(
                          color: themeChange.isDarkTheme() ? AppThemData.greyShade700 : AppThemData.greyShade200,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                          child: Row(
                            children: [
                              Text(
                                "Booking Id".tr,
                                style: TextStyle(
                                    fontSize: 14, color: themeChange.isDarkTheme() ? AppThemData.greyShade300 : AppThemData.greyShade600, fontFamily: AppThemeData.medium),
                              ).expand(),
                              spaceW(width: 10),
                              TextCustom(
                                title: "#${sosAlerts.bookingId}",
                                color: themeChange.isDarkTheme() ? AppThemData.greyShade25 : AppThemData.greyShade950,
                                fontSize: 16,
                                fontFamily: AppThemeData.medium,
                                maxLine: 2,
                              ).expand()
                            ],
                          ),
                        ),
                        Divider(
                          color: themeChange.isDarkTheme() ? AppThemData.greyShade700 : AppThemData.greyShade200,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                          child: Row(
                            children: [
                              Text(
                                "User Name".tr,
                                style: TextStyle(
                                    fontSize: 14, color: themeChange.isDarkTheme() ? AppThemData.greyShade300 : AppThemData.greyShade600, fontFamily: AppThemeData.medium),
                              ).expand(),
                              FutureBuilder(
                                future: FireStoreUtils.getCustomerByCustomerID(sosAlerts.userId.toString()),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState == ConnectionState.waiting) {
                                    return Container();
                                  }
                                  if (!snapshot.hasData) {
                                    return Container();
                                  }
                                  UserModel? user = snapshot.data ?? UserModel();
                                  return TextCustom(
                                    title: user.fullName!.isEmpty ? "N/A" : user.fullName.toString(),
                                    color: themeChange.isDarkTheme() ? AppThemData.greyShade25 : AppThemData.greyShade950,
                                    fontSize: 16,
                                    fontFamily: AppThemeData.medium,
                                  );
                                },
                              )
                            ],
                          ),
                        ),
                        Divider(
                          color: themeChange.isDarkTheme() ? AppThemData.greyShade700 : AppThemData.greyShade200,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                          child: Row(
                            children: [
                              Text(
                                "Driver Name".tr,
                                style: TextStyle(
                                    fontSize: 14, color: themeChange.isDarkTheme() ? AppThemData.greyShade300 : AppThemData.greyShade600, fontFamily: AppThemeData.medium),
                              ).expand(),
                              FutureBuilder(
                                future: FireStoreUtils.getDriverByDriverID(sosAlerts.driverId.toString()),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState == ConnectionState.waiting) {
                                    return Container();
                                  }
                                  if (!snapshot.hasData) {
                                    return Container();
                                  }
                                  DriverUserModel? driver = snapshot.data ?? DriverUserModel();
                                  return TextCustom(
                                    title: driver.fullName!.isEmpty ? "N/A" : driver.fullName.toString(),
                                    color: themeChange.isDarkTheme() ? AppThemData.greyShade25 : AppThemData.greyShade950,
                                    fontSize: 16,
                                    fontFamily: AppThemeData.medium,
                                  );
                                },
                              )
                            ],
                          ),
                        ),
                        Divider(
                          color: themeChange.isDarkTheme() ? AppThemData.greyShade700 : AppThemData.greyShade200,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                          child: Row(
                            children: [
                              Text(
                                "Emergency Type".tr,
                                style: TextStyle(
                                    fontSize: 14, color: themeChange.isDarkTheme() ? AppThemData.greyShade300 : AppThemData.greyShade600, fontFamily: AppThemeData.medium),
                              ).expand(),
                              TextCustom(
                                title: sosAlerts.emergencyType == "contacts" ? "Emergency Contacts".tr : "Call_sos".trParams({"callsos": Constant.sosAlertNumber.toString()}),
                                color: themeChange.isDarkTheme() ? AppThemData.greyShade25 : AppThemData.greyShade950,
                                fontSize: 16,
                                fontFamily: AppThemeData.medium,
                              )
                            ],
                          ),
                        ),
                        Divider(
                          color: themeChange.isDarkTheme() ? AppThemData.greyShade700 : AppThemData.greyShade200,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                          child: Row(
                            children: [
                              Text(
                                "Type".tr,
                                style: TextStyle(
                                    fontSize: 14, color: themeChange.isDarkTheme() ? AppThemData.greyShade300 : AppThemData.greyShade600, fontFamily: AppThemeData.medium),
                              ).expand(),
                              TextCustom(
                                title: sosAlerts.type == "customer" ? "Customer".tr : "Driver".tr,
                                color: themeChange.isDarkTheme() ? AppThemData.greyShade25 : AppThemData.greyShade950,
                                fontSize: 16,
                                fontFamily: AppThemeData.medium,
                              )
                            ],
                          ),
                        ),
                        Divider(
                          color: themeChange.isDarkTheme() ? AppThemData.greyShade700 : AppThemData.greyShade200,
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                          child: Row(
                            children: [
                              Text(
                                "Status".tr,
                                style: TextStyle(
                                    fontSize: 14, color: themeChange.isDarkTheme() ? AppThemData.greyShade300 : AppThemData.greyShade600, fontFamily: AppThemeData.medium),
                              ).expand(),
                              Container(
                                padding: EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    color: sosAlerts.status == "pending"
                                        ? AppThemData.blue500.withOpacity(0.2)
                                        : sosAlerts.status == "cancelled"
                                            ? AppThemData.red500.withOpacity(0.2)
                                            : sosAlerts.status == "in-progress"
                                                ? AppThemData.yellow600.withOpacity(.2)
                                                : AppThemData.green500.withOpacity(0.2)),
                                child: TextCustom(
                                    title: sosAlerts.status == "pending"
                                        ? "Pending".tr
                                        : sosAlerts.status == "cancelled"
                                            ? "Cancelled".tr
                                            : sosAlerts.status == "in-progress"
                                                ? "In Progress".tr
                                                : "Resolved".tr,
                                    fontSize: 16,
                                    color: sosAlerts.status == "pending"
                                        ? AppThemData.blue500
                                        : sosAlerts.status == "cancelled"
                                            ? AppThemData.red500
                                            : sosAlerts.status == "in-progress"
                                                ? AppThemData.yellow600
                                                : AppThemData.green500),
                              )
                            ],
                          ),
                        ),
                        if (sosAlerts.contactIds != null && sosAlerts.contactIds!.isNotEmpty) ...[
                          Divider(
                            color: themeChange.isDarkTheme() ? AppThemData.greyShade700 : AppThemData.greyShade200,
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                            child: Row(
                              children: [
                                Text(
                                  "Emergency Contact Info".tr,
                                  style: TextStyle(
                                      fontSize: 14, color: themeChange.isDarkTheme() ? AppThemData.greyShade300 : AppThemData.greyShade600, fontFamily: AppThemeData.medium),
                                ).expand(),
                                ...sosAlerts.contactIds!.map(
                                  (contactId) => Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    child: FutureBuilder<EmergencyContactModel?>(
                                      future: FireStoreUtils.getEmergencyContactById(
                                        ownerId: sosAlerts.type == "customer" ? sosAlerts.userId! : sosAlerts.driverId!,
                                        contactId: contactId,
                                        ownerType: sosAlerts.type!,
                                      ),
                                      builder: (context, snapshot) {
                                        if (!snapshot.hasData) {
                                          return const SizedBox();
                                        }
                                        final contact = snapshot.data!;
                                        return TextCustom(
                                          title: "${contact.name} (${contact.countryCode} ${contact.phoneNumber})",
                                          fontSize: 15,
                                          fontFamily: AppThemeData.medium,
                                          color: themeChange.isDarkTheme() ? AppThemData.greyShade25 : AppThemData.greyShade950,
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        if (sosAlerts.location != null) ...[
                          Divider(
                            color: themeChange.isDarkTheme() ? AppThemData.greyShade700 : AppThemData.greyShade200,
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                            child: Row(
                              children: [
                                Text(
                                  "Location".tr,
                                  style: TextStyle(
                                      fontSize: 14, color: themeChange.isDarkTheme() ? AppThemData.greyShade300 : AppThemData.greyShade600, fontFamily: AppThemeData.medium),
                                ).expand(),
                                InkWell(
                                    onTap: () {
                                      final url = "https://www.google.com/maps/search/?api=1&query="
                                          "${sosAlerts.location!.latitude},${sosAlerts.location!.longitude}";
                                      controller.openMapUrl(url);
                                    },
                                    child: TextCustom(
                                      title: "View Location".tr,
                                      fontSize: 16,
                                      fontFamily: AppThemeData.medium,
                                      color: AppThemData.primary500,
                                      isUnderLine: true,
                                    )),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  spaceH(height: 24),
                  if (sosAlerts.status == "pending")
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        CustomButtonWidget(
                          buttonTitle: "Cancel".tr,
                          buttonColor: AppThemData.greyShade500,
                          textColor: Colors.white,
                          onPress: () {
                            Navigator.pop(context);
                          },
                        ),
                        spaceW(width: 16),
                        CustomButtonWidget(
                          buttonTitle: "In Progress".tr,
                          buttonColor: AppThemData.green500,
                          textColor: Colors.white,
                          onPress: () async {
                            await controller.updateStatus(sosAlerts.id!, "in-progress", sosAlerts);
                          },
                        ),
                      ],
                    ),
                  if (sosAlerts.status == "in-progress")
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        CustomButtonWidget(
                          buttonTitle: "Cancel".tr,
                          buttonColor: AppThemData.greyShade500,
                          textColor: Colors.white,
                          onPress: () {
                            Navigator.pop(context);
                          },
                        ),
                        spaceW(width: 16),
                        CustomButtonWidget(
                          buttonTitle: "Resolve".tr,
                          buttonColor: AppThemData.primary500,
                          textColor: Colors.white,
                          onPress: () async {
                            await controller.updateStatus(sosAlerts.id!, "resolved", sosAlerts);
                          },
                        ),
                      ],
                    ),
                ]),
              )
            ],
          ),
        ),
      ),
    );
  }
}
