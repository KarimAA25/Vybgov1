import 'package:admin/app/constant/constants.dart';
import 'package:admin/app/modules/driver_detail_screen/controllers/driver_detail_screen_controller.dart';
import 'package:admin/app/utils/app_colors.dart';
import 'package:admin/app/utils/app_them_data.dart';
import 'package:admin/app/utils/dark_theme_provider.dart';
import 'package:admin/widget/common_ui.dart';
import 'package:admin/widget/container_custom.dart';
import 'package:admin/widget/global_widgets.dart';
import 'package:admin/widget/text_widget.dart';
import 'package:admin/widget/web_pagination.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../../../routes/app_pages.dart';

class DriverSubscriptionHistoryWidget extends GetView<DriverDetailScreenController> {
  const DriverSubscriptionHistoryWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);

    return GetX<DriverDetailScreenController>(
      init: DriverDetailScreenController(),
      builder: (controller) {
        return Scaffold(
          backgroundColor: themeChange.isDarkTheme() ? AppThemData.greyShade950 : AppThemData.greyShade50,
          body: SingleChildScrollView(
            child: ContainerCustom(
              color: themeChange.isDarkTheme() ? AppThemData.primaryBlack : AppThemData.primaryWhite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        TextCustom(title: controller.subscriptionHistoryTitle.value, fontSize: 20, fontFamily: AppThemeData.bold),
                        spaceH(height: 2),
                        Row(children: [
                          InkWell(
                              onTap: () => Get.offAllNamed(Routes.DASHBOARD_SCREEN),
                              child: TextCustom(title: "Dashboard".tr, fontSize: 14, fontFamily: AppThemeData.medium, color: AppThemData.greyShade500)),
                          TextCustom(title: ' / ', fontSize: 14, fontFamily: AppThemeData.medium, color: AppThemData.greyShade500),
                          TextCustom(title: ' ${controller.subscriptionHistoryTitle.value} ', fontSize: 14, fontFamily: AppThemeData.medium, color: AppThemData.primary500)
                        ])
                      ]),
                      Spacer(),
                      NumberOfRowsDropDown(
                        controller: controller,
                      ),
                    ],
                  ),
                  spaceH(height: 16),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      spaceH(height: 16),
                      Obx(
                        () => SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: controller.isLoading.value
                                ? Padding(
                                    padding: paddingEdgeInsets(),
                                    child: Constant.loader(),
                                  )
                                : controller.currentPageSubscriptionHistory.isEmpty
                                    ? TextCustom(title: "No Data available".tr)
                                    : DataTable(
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
                                          CommonUI.dataColumnWidget(context, columnTitle: "Id".tr, width: 150),
                                          CommonUI.dataColumnWidget(context, columnTitle: "Subscription Name".tr, width: 200),
                                          CommonUI.dataColumnWidget(context, columnTitle: "Price".tr, width: 100),
                                          CommonUI.dataColumnWidget(context, columnTitle: "Payment Type".tr, width: 160),
                                          CommonUI.dataColumnWidget(context, columnTitle: "Status".tr, width: 100),
                                          CommonUI.dataColumnWidget(context, columnTitle: "Expiry Date".tr, width: 160),
                                          CommonUI.dataColumnWidget(context, columnTitle: "Created Date".tr, width: 160),
                                        ],
                                        rows: controller.currentPageSubscriptionHistory
                                            .map((subscriptionHistory) => DataRow(cells: [
                                                  DataCell(
                                                    TextCustom(
                                                      title: subscriptionHistory.id!.isEmpty ? "N/A".tr : "#${subscriptionHistory.id!.substring(0, 8)}",
                                                    ),
                                                  ),
                                                  DataCell(
                                                    Container(
                                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                                        child: TextCustom(title: subscriptionHistory.subscriptionPlan!.title.toString())),
                                                  ),
                                                  DataCell(
                                                    Container(
                                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                                        child: TextCustom(title: Constant.amountShow(amount: subscriptionHistory.subscriptionPlan!.price.toString()))),
                                                  ),
                                                  DataCell(
                                                    Container(
                                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                                        child: TextCustom(
                                                            title: subscriptionHistory.paymentType == null || subscriptionHistory.paymentType!.isEmpty
                                                                ? "Free Plan"
                                                                : subscriptionHistory.paymentType!)),
                                                  ),
                                                  DataCell(
                                                    Container(
                                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                                        child: TextCustom(
                                                          title: (subscriptionHistory.expiryDate == null || subscriptionHistory.expiryDate!.toDate().isAfter(DateTime.now()))
                                                              ? "Active"
                                                              : "Expired",
                                                          color: (subscriptionHistory.expiryDate == null || subscriptionHistory.expiryDate!.toDate().isAfter(DateTime.now()))
                                                              ? AppThemData.green500
                                                              : AppThemData.red500,
                                                        )),
                                                  ),
                                                  DataCell(
                                                    Container(
                                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                                        child: TextCustom(
                                                            title: subscriptionHistory.expiryDate == null
                                                                ? "Unlimited Days"
                                                                : Constant.timestampToDateTime(subscriptionHistory.expiryDate!))),
                                                  ),
                                                  DataCell(
                                                    Container(
                                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                                        child: TextCustom(title: Constant.timestampToDateTime(subscriptionHistory.createdAt!))),
                                                  ),
                                                ]))
                                            .toList()),
                          ),
                        ),
                      ),
                      spaceH(),
                      Obx(
                        () => Visibility(
                          visible: controller.totalPage.value > 1,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Align(
                                alignment: Alignment.centerRight,
                                child: WebPagination(
                                    currentPage: controller.currentPage.value,
                                    totalPage: controller.totalPage.value,
                                    displayItemCount: controller.pageValue("5"),
                                    onPageChanged: (page) {
                                      controller.currentPage.value = page;
                                      controller.setPagination(controller.totalItemPerPage.value);
                                    }),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
