// ignore_for_file: deprecated_member_use, depend_on_referenced_packages

import 'package:admin/app/components/custom_button.dart';
import 'package:admin/app/components/custom_text_form_field.dart';
import 'package:admin/app/components/dialog_box.dart';
import 'package:admin/app/constant/constants.dart';
import 'package:admin/app/constant/show_toast.dart';
import 'package:admin/app/models/zone_model.dart';
import 'package:admin/app/utils/app_colors.dart';
import 'package:admin/app/utils/app_them_data.dart';
import 'package:admin/app/utils/dark_theme_provider.dart';
import 'package:admin/app/utils/responsive.dart';
import 'package:admin/widget/common_ui.dart';
import 'package:admin/widget/container_custom.dart';
import 'package:admin/widget/global_widgets.dart';
import 'package:admin/widget/text_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:provider/provider.dart';

import '../../../components/menu_widget.dart';
import '../../../routes/app_pages.dart';
import '../controllers/intercity_service_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class InterCityServiceScreenView extends GetView<IntercityServiceController> {
  const InterCityServiceScreenView({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetBuilder<IntercityServiceController>(
      init: IntercityServiceController(),
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
                  child: Obx(
                    () => SingleChildScrollView(
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
                                    ],
                                  )
                                : Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
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
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: controller.isLoading.value
                                      ? Padding(
                                          padding: paddingEdgeInsets(),
                                          child: Constant.loader(),
                                        )
                                      : Obx(() {
                                          if (controller.isLoading.value) {
                                            return const Center(child: CircularProgressIndicator());
                                          }

                                          if (controller.intercityDocuments.isEmpty) {
                                            return TextCustom(title: "No Data Available".tr);
                                          }

                                          return DataTable(
                                            horizontalMargin: 20,
                                            columnSpacing: 30,
                                            dataRowMaxHeight: 65,
                                            headingRowHeight: 65,
                                            border: TableBorder.all(
                                              color: themeChange.isDarkTheme() ? AppThemData.greyShade900 : AppThemData.greyShade100,
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            headingRowColor: MaterialStateColor.resolveWith(
                                              (states) => themeChange.isDarkTheme() ? AppThemData.greyShade900 : AppThemData.greyShade100,
                                            ),
                                            columns: [
                                              CommonUI.dataColumnWidget(context, columnTitle: "Title".tr, width: MediaQuery.of(context).size.width * 0.2),
                                              CommonUI.dataColumnWidget(context, columnTitle: "Bid Status".tr, width: MediaQuery.of(context).size.width * 0.2),
                                              CommonUI.dataColumnWidget(context, columnTitle: "Status".tr, width: MediaQuery.of(context).size.width * 0.2),
                                              CommonUI.dataColumnWidget(context, columnTitle: "Actions".tr, width: MediaQuery.of(context).size.width * 0.1),
                                            ],
                                            rows: controller.intercityDocuments.map((doc) {
                                              return DataRow(cells: [
                                                DataCell(TextCustom(
                                                    title: doc.id == "cab"
                                                        ? "Cab Service"
                                                        : doc.id == "intercity_sharing"
                                                            ? 'Intercity Sharing'
                                                            : doc.id == "intercity"
                                                                ? 'Intercity Personal'
                                                                : doc.id == "parcel"
                                                                    ? "Parcel"
                                                                    : "Rental")),
                                                DataCell(
                                                  (doc.id == "cab" || doc.id == "rental")
                                                      ? SizedBox.shrink()
                                                      : Transform.scale(
                                                          scale: 0.8,
                                                          child: CupertinoSwitch(
                                                            activeColor: AppThemData.primary500,
                                                            value: doc.isBidEnable,
                                                            onChanged: (value) async {
                                                              if (Constant.isDemo) {
                                                                DialogBox.demoDialogBox();
                                                              } else {
                                                                await FirebaseFirestore.instance.collection("intercity_service").doc(doc.id).update({"isBidEnable": value});
                                                                doc.isBidEnable = value;
                                                                controller.intercityDocuments.refresh();
                                                              }
                                                            },
                                                          ),
                                                        ),
                                                ),
                                                DataCell(
                                                  Transform.scale(
                                                    scale: 0.8,
                                                    child: CupertinoSwitch(
                                                      activeColor: AppThemData.primary500,
                                                      value: doc.isAvailable,
                                                      onChanged: (value) async {
                                                        if (Constant.isDemo) {
                                                          DialogBox.demoDialogBox();
                                                        } else {
                                                          await FirebaseFirestore.instance.collection("intercity_service").doc(doc.id).update({"isAvailable": value});

                                                          doc.isAvailable = value;
                                                          controller.intercityDocuments.refresh();
                                                        }
                                                      },
                                                    ),
                                                  ),
                                                ),
                                                DataCell(
                                                  (doc.id == "cab" || doc.id == "rental")
                                                      ? SizedBox.shrink()
                                                      : Row(
                                                          children: [
                                                            InkWell(
                                                              onTap: () {
                                                                controller.loadZoneCharge(doc);
                                                                showDialog(
                                                                  context: context,
                                                                  builder: (context) => InterCityServiceDialog(docId: doc.id),
                                                                );
                                                              },
                                                              child: SvgPicture.asset(
                                                                "assets/icons/ic_edit.svg",
                                                                color: AppThemData.greyShade400,
                                                                height: 16,
                                                                width: 16,
                                                              ),
                                                            ),
                                                            const SizedBox(width: 20),
                                                          ],
                                                        ),
                                                ),
                                              ]);
                                            }).toList(),
                                          );
                                        })),
                            ),
                            spaceH(),
                          ]),
                        )
                      ]),
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

class InterCityServiceDialog extends StatelessWidget {
  late final String docId;
  final IntercityServiceController controller = Get.find();

  InterCityServiceDialog({super.key, required this.docId});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return Dialog(
      backgroundColor: themeChange.isDarkTheme() ? AppThemData.greyShade950 : AppThemData.greyShade50,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8.0))),
      alignment: Alignment.topCenter,
      child: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        return SizedBox(
          width: MediaQuery.sizeOf(context).width * 0.5,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  spaceH(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                          "${docId == "intercity_sharing" ? 'Intercity Sharing' : docId == 'intercity' ? 'Intercity Personal' : docId == 'parcel' ? "Parcel" : ""} Service Settings",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: themeChange.isDarkTheme() ? AppThemData.primaryWhite : AppThemData.primaryBlack)),
                      GestureDetector(
                        onTap: () {
                          Get.back();
                        },
                        child: Padding(
                          padding: EdgeInsets.only(right: 12),
                          child: Icon(
                            Icons.close,
                            size: 24,
                            color: themeChange.isDarkTheme() ? AppThemData.primaryWhite : AppThemData.primaryBlack,
                          ),
                        ),
                      )
                    ],
                  ),
                  spaceH(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const TextCustom(
                        title: 'Zone Charges',
                        fontSize: 16,
                        fontFamily: AppThemeData.medium,
                      ),
                      GestureDetector(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) => fareCalculationInfoDialog(context, docId: docId),
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
                      ),
                    ],
                  ),
                  spaceH(height: 16),
                  ListView.builder(
                    shrinkWrap: true,
                    itemCount: controller.zoneList.length,
                    itemBuilder: (context, index) {
                      ZoneModel zone = controller.zoneList[index];
                      return Obx(
                        () => Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(zone.name.toString(), style: TextStyle(fontSize: 18, color: AppThemData.primary500, fontFamily: AppThemeData.medium)),
                            spaceH(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  child: CustomTextFormField(
                                    hintText: "Enter Minimum Distance (in ${Constant.distanceType})".tr,
                                    controller: zone.minDistanceController,
                                    title: "Minimum Distance (in ${Constant.distanceType})".tr,
                                    onChanged: (value) {
                                      zone.charges!.fareMinimumChargesWithinKm = value;
                                    },
                                  ),
                                ),
                                spaceW(),
                                Expanded(
                                  child: CustomTextFormField(
                                    hintText: "Enter Minimum Distance Fare".tr,
                                    controller: zone.minFareController,
                                    title: "Minimum Distance Fare".tr,
                                    onChanged: (value) {
                                      zone.charges!.farMinimumCharges = value;
                                    },
                                  ),
                                ),
                                spaceW(),
                                Expanded(
                                  child: CustomTextFormField(
                                    hintText: "Enter Rate per Extra ${Constant.distanceType}".tr,
                                    controller: zone.perKmController,
                                    title: "Rate per Extra ${Constant.distanceType}".tr,
                                    onChanged: (value) {
                                      zone.charges!.farePerKm = value;
                                    },
                                  ),
                                ),
                              ],
                            ),
                            docId != 'parcel'
                                ? Row(
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
                                          hintText: "Enter Increment for Night Charge (in %)".tr,
                                          controller: zone.nightChargeController,
                                          title: "Increment for Night Charge (in %)".tr,
                                          tooltipsShow: true,
                                          tooltipsText: "Increment for Night Charge will be applied as a percentage of the base fare during night hours.",
                                          onChanged: (value) {
                                            zone.charges!.incrementOfNightCharge = value;
                                          },
                                        ),
                                      ),
                                      spaceW(),
                                      Expanded(child: SizedBox())
                                    ],
                                  )
                                : SizedBox(),
                            if (index != controller.zoneList.length - 1)
                              Divider(
                                color: AppThemData.greyShade500,
                              ).paddingOnly(bottom: 16)
                          ],
                        ),
                      );
                    },
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      CustomButtonWidget(buttonTitle: "Close".tr, onPress: () => Get.back()),
                      spaceW(),
                      CustomButtonWidget(
                          buttonTitle: "Save".tr,
                          onPress: () {
                            if (Constant.isDemo) {
                              DialogBox.demoDialogBox();
                            } else {
                              for (int i = 0; i < controller.zoneList.length; i++) {
                                final zone = controller.zoneList[i];
                                final zoneName = zone.name ?? "Zone ${i + 1}";

                                final minDistance = zone.charges?.fareMinimumChargesWithinKm ?? '';
                                final minDistanceFare = zone.charges?.farMinimumCharges ?? '';
                                final ratePerExtraKm = zone.charges?.farePerKm ?? '';
                                final incrementOfNightCharge = controller.selectedDocId.value != "parcel" ? (zone.charges?.incrementOfNightCharge ?? '') : null;
                                final holdCharge = controller.selectedDocId.value != "parcel" ? (zone.charges?.holdCharge ?? '') : null;

                                if (minDistance.isEmpty ||
                                    minDistanceFare.isEmpty ||
                                    ratePerExtraKm.isEmpty ||
                                    (incrementOfNightCharge != null && incrementOfNightCharge.isEmpty) ||
                                    (holdCharge != null && holdCharge.isEmpty)) {
                                  ShowToastDialog.toast("Please fill all charges for $zoneName".tr);
                                  controller.isLoading.value = false;
                                  return;
                                }
                              }
                              controller.saveToFirestore();
                            }
                          }),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  Dialog fareCalculationInfoDialog(BuildContext context, {required String docId}) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    final bool isParcel = docId == 'parcel';
    final fares = Constant.distanceType == "Km"
        ? {"minDistance": 10, "minFare": 14, "perDistanceCharge": 12, "holdCharge": 4, "minuteCharge": 2}
        : {"minDistance": 6, "minFare": 20, "perDistanceCharge": 15, "holdCharge": 5, "minuteCharge": 3};
    final int belowMinDistance = fares['minDistance']! - 2;
    final int aboveMinDistance = fares['minDistance']! + 5;

    return Dialog(
      backgroundColor: themeChange.isDarkTheme() ? AppThemData.greyShade950 : AppThemData.greyShade50,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8))),
      alignment: Alignment.center,
      child: SizedBox(
        width: ResponsiveWidget.isDesktop(context) ? MediaQuery.sizeOf(context).width * 0.4 : MediaQuery.sizeOf(context).width * 0.7,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(8), topRight: Radius.circular(8)),
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
                  // Description
                  TextCustom(
                    title: isParcel
                        ? ("• If the parcel distance is less than or equal to the Minimum Distance, "
                                "a fixed Minimum Distance Fare will be charged.\n\n"
                                "• If the parcel distance is greater than the Minimum Distance, "
                                "the Per ${Constant.distanceType} Charge will be applied to the total distance.\n\n"
                                "• Hold Charge and Night Charge are not applicable for parcel rides."
                            .tr)
                        : ("• If the ride distance is less than or equal to the Minimum Distance, "
                                "a fixed Minimum Distance Fare will be charged.\n\n"
                                "• If the ride distance is greater than the Minimum Distance, "
                                "the Per ${Constant.distanceType} Charge will be applied to the total distance.\n\n"
                                "• Increment for Night Charge will be applied as a percentage of the base fare during night hours.\n\n"
                                "• Hold Charge applies when the ride is paused or held after it has started. "
                                "It is added based on the number of minutes the ride remains on hold."
                            .tr),
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
                          fontSize: 14,
                          color: themeChange.isDarkTheme() ? AppThemData.greyShade400 : AppThemData.greyShade700,
                          height: 1.4,
                          fontFamily: AppThemeData.regular,
                        ),
                        children: [
                          TextSpan(text: "💡 Example:\n".tr, style: TextStyle(color: AppThemData.primary500)),
                          TextSpan(text: "Minimum Distance: ".tr, style: TextStyle(fontFamily: AppThemeData.medium)),
                          TextSpan(text: "${fares['minDistance']} ${Constant.distanceType}\n"),
                          TextSpan(text: "Minimum Fare: ".tr, style: TextStyle(fontFamily: AppThemeData.medium)),
                          TextSpan(text: "${Constant.amountShow(amount: '${fares['minFare']}')}\n"),
                          TextSpan(text: "Rate per Extra ${Constant.distanceType}: ".tr, style: TextStyle(fontFamily: AppThemeData.medium)),
                          TextSpan(text: "${Constant.amountShow(amount: '${fares['perDistanceCharge']}')}\n"),
                          if (!isParcel) ...[
                            TextSpan(text: "Hold Charge: ".tr, style: TextStyle(fontFamily: AppThemeData.medium)),
                            TextSpan(text: "${Constant.amountShow(amount: '${fares['holdCharge']}')} ${"per minute (only when ride is paused)\n".tr}"),
                          ] else
                            const TextSpan(text: "\n"),
                          TextSpan(
                              text: isParcel
                                  ? "Parcel Distance: $belowMinDistance ${Constant.distanceType} → ".tr
                                  : "Ride Distance: $belowMinDistance ${Constant.distanceType} → ".tr,
                              style: TextStyle(fontFamily: AppThemeData.medium)),
                          TextSpan(text: "${Constant.amountShow(amount: '${fares['minFare']}')} ${"(minimum fare)\n".tr}"),
                          TextSpan(
                              text: isParcel
                                  ? "Parcel Distance: $aboveMinDistance ${Constant.distanceType} → ".tr
                                  : "Ride Distance: $aboveMinDistance ${Constant.distanceType} → ".tr,
                              style: TextStyle(fontFamily: AppThemeData.medium)),
                          TextSpan(
                              text:
                                  "${Constant.amountShow(amount: '${aboveMinDistance * fares['perDistanceCharge']!}')} ${"($aboveMinDistance × ${fares['perDistanceCharge']})\n".tr}"),
                          if (!isParcel) ...[
                            TextSpan(text: "Hold for 2 min → ".tr, style: TextStyle(fontFamily: AppThemeData.medium)),
                            TextSpan(text: "+${Constant.amountShow(amount: '${2 * fares['holdCharge']!}')} ${"(2 × ${fares['holdCharge']})\n".tr}"),
                            TextSpan(text: "\nIf a Night Charge increment (e.g., 20%) is set, it will be applied on the base fare during night hours.".tr),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
