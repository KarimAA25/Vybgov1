import 'package:admin/app/constant/constants.dart';
import 'package:admin/app/modules/driver_detail_screen/controllers/driver_detail_screen_controller.dart';
import 'package:admin/app/utils/app_colors.dart';
import 'package:admin/app/utils/app_them_data.dart';
import 'package:admin/app/utils/dark_theme_provider.dart';
import 'package:admin/widget/container_custom.dart';
import 'package:admin/widget/global_widgets.dart';
import 'package:admin/widget/text_widget.dart';
import 'package:admin/widget/web_pagination.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../../../../widget/common_ui.dart';
import '../../../../routes/app_pages.dart';

class DriverWalletTransactionWidget extends GetView<DriverDetailScreenController> {
  const DriverWalletTransactionWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);

    return GetBuilder<DriverDetailScreenController>(
      init: DriverDetailScreenController(),
      builder: (controller) {
        return Scaffold(
          backgroundColor: themeChange.isDarkTheme() ? AppThemData.greyShade950 : AppThemData.greyShade50,
          body: SingleChildScrollView(
            child: ContainerCustom(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 24),
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
                        TextCustom(title: controller.walletTransactionTitle.value, fontSize: 20, fontFamily: AppThemeData.bold),
                        spaceH(height: 2),
                        Row(children: [
                          InkWell(
                              onTap: () => Get.offAllNamed(Routes.DASHBOARD_SCREEN),
                              child: TextCustom(title: "Dashboard".tr, fontSize: 14, fontFamily: AppThemeData.medium, color: AppThemData.greyShade500)),
                          TextCustom(title: ' / ', fontSize: 14, fontFamily: AppThemeData.medium, color: AppThemData.greyShade500),
                          TextCustom(title: ' ${controller.walletTransactionTitle.value} ', fontSize: 14, fontFamily: AppThemeData.medium, color: AppThemData.primary500)
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
                                : controller.currentPageWalletTransaction.isEmpty
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
                                        headingRowColor:
                                            WidgetStateColor.resolveWith((states) => themeChange.isDarkTheme() ? AppThemData.greyShade800 : AppThemData.greyShade100),
                                        columns: [
                                          CommonUI.dataColumnWidget(context, columnTitle: "Transaction Id".tr, width: 150),
                                          CommonUI.dataColumnWidget(context, columnTitle: "Amount".tr, width: 200),
                                          CommonUI.dataColumnWidget(context, columnTitle: "Payment Type".tr, width: 100),
                                          CommonUI.dataColumnWidget(context, columnTitle: "Note".tr, width: 100),
                                          CommonUI.dataColumnWidget(context, columnTitle: "Created At".tr, width: 160),
                                        ],
                                        rows: controller.currentPageWalletTransaction
                                            .map((transaction) => DataRow(cells: [
                                                  DataCell(
                                                    TextCustom(
                                                      title: transaction.id!.isEmpty ? "N/A".tr : "#${transaction.id!.substring(0, 8)}",
                                                    ),
                                                  ),
                                                  DataCell(
                                                    Container(
                                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                                        child: TextCustom(
                                                          title: Constant.amountShow(amount: transaction.amount.toString()),
                                                          color: transaction.isCredit == true ? AppThemData.green500 : AppThemData.red500,
                                                        )),
                                                  ),
                                                  DataCell(
                                                    Container(
                                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                                        child: TextCustom(title: transaction.paymentType.toString())),
                                                  ),
                                                  DataCell(
                                                    Container(
                                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8), child: TextCustom(title: transaction.note.toString())),
                                                  ),
                                                  DataCell(
                                                    Container(
                                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                                        child: TextCustom(title: Constant.timestampToDateTime(transaction.createdDate!))),
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
