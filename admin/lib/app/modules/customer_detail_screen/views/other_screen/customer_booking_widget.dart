import 'package:admin/app/components/dialog_box.dart';
import 'package:admin/app/constant/constants.dart';
import 'package:admin/app/models/user_model.dart';
import 'package:admin/app/modules/customer_detail_screen/controllers/customer_detail_screen_controller.dart';
import 'package:admin/app/utils/fire_store_utils.dart';
import 'package:admin/app/utils/responsive.dart';
import 'package:admin/widget/web_pagination.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../../../../widget/common_ui.dart';
import '../../../../../widget/container_custom.dart';
import '../../../../../widget/global_widgets.dart';
import '../../../../../widget/text_widget.dart';
import '../../../../routes/app_pages.dart';
import '../../../../utils/app_colors.dart';
import '../../../../utils/app_them_data.dart';
import '../../../../utils/dark_theme_provider.dart';

class CustomerBookingWidget extends StatelessWidget {
  const CustomerBookingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetBuilder(
        init: CustomerDetailScreenController(),
        builder: (controller) {
          return Scaffold(
            backgroundColor: themeChange.isDarkTheme() ? AppThemData.greyShade950 : AppThemData.greyShade50,
            body: SingleChildScrollView(
              child: ContainerCustom(
                color: themeChange.isDarkTheme() ? AppThemData.primaryBlack : AppThemData.primaryWhite,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                TextCustom(title: controller.bookingTitle.value, fontSize: 20, fontFamily: AppThemeData.bold),
                                spaceH(height: 2),
                                Row(children: [
                                  InkWell(
                                      onTap: () => Get.offAllNamed(Routes.DASHBOARD_SCREEN),
                                      child: TextCustom(title: "Dashboard".tr, fontSize: 14, fontFamily: AppThemeData.medium, color: AppThemData.greyShade500)),
                                  TextCustom(title: ' / ', fontSize: 14, fontFamily: AppThemeData.medium, color: AppThemData.greyShade500),
                                  TextCustom(title: ' ${controller.bookingTitle.value} ', fontSize: 14, fontFamily: AppThemeData.medium, color: AppThemData.primary500)
                                ])
                              ]),
                              Spacer(),
                              SizedBox(
                                width: 120,
                                child: Obx(
                                  () => DropdownButtonFormField(
                                    borderRadius: BorderRadius.circular(15),
                                    isExpanded: true,
                                    dropdownColor: themeChange.isDarkTheme() ? AppThemData.greyShade950 : AppThemData.greyShade50,
                                    style: TextStyle(
                                      fontFamily: AppThemeData.medium,
                                      color: themeChange.isDarkTheme() ? AppThemData.greyShade100 : AppThemData.greyShade800,
                                    ),
                                    hint: TextCustom(title: 'Payment Status'.tr),
                                    onChanged: (String? taxType) {
                                      controller.selectedPayoutStatus.value = taxType ?? "All";
                                      controller.getBookingDataForConverter();
                                    },
                                    value: controller.selectedPayoutStatus.value,
                                    items: controller.payoutStatus.map<DropdownMenuItem<String>>((String value) {
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
                              spaceW(),
                              NumberOfRowsDropDown(
                                controller: controller,
                              ),
                            ],
                          ),
                          spaceH(height: 16),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
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
                                        : controller.currentPageBooking.isEmpty
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
                                                  CommonUI.dataColumnWidget(context, columnTitle: "Order Id".tr, width: 150),
                                                  CommonUI.dataColumnWidget(context,
                                                      columnTitle: "Customer Name".tr, width: ResponsiveWidget.isMobile(context) ? 150 : MediaQuery.of(context).size.width * 0.15),
                                                  CommonUI.dataColumnWidget(context,
                                                      columnTitle: "Booking Date".tr, width: ResponsiveWidget.isMobile(context) ? 220 : MediaQuery.of(context).size.width * 0.17),
                                                  CommonUI.dataColumnWidget(context,
                                                      columnTitle: "Booking Status".tr, width: ResponsiveWidget.isMobile(context) ? 220 : MediaQuery.of(context).size.width * 0.10),
                                                  CommonUI.dataColumnWidget(context,
                                                      columnTitle: "Payment Status".tr, width: ResponsiveWidget.isMobile(context) ? 220 : MediaQuery.of(context).size.width * 0.07),

                                                  CommonUI.dataColumnWidget(context, columnTitle: "Total".tr, width: 140),
                                                  // CommonUI.dataColumnWidget(context,
                                                  //     columnTitle: "Status", width: ResponsiveWidget.isMobile(context) ? 100 : MediaQuery.of(context).size.width * 0.10),
                                                  CommonUI.dataColumnWidget(
                                                    context,
                                                    columnTitle: "Action".tr,
                                                    width: 100,
                                                  ),
                                                ],
                                                rows: controller.currentPageBooking
                                                    .map((bookingModel) => DataRow(cells: [
                                                          DataCell(
                                                            TextCustom(
                                                              title: bookingModel.id!.isEmpty ? "N/A".tr : "#${bookingModel.id!.substring(0, 8)}",
                                                            ),
                                                          ),
                                                          DataCell(
                                                            FutureBuilder<UserModel?>(
                                                                future: FireStoreUtils.getUserByUserID(bookingModel.customerId.toString()), // async work
                                                                builder: (BuildContext context, AsyncSnapshot<UserModel?> snapshot) {
                                                                  switch (snapshot.connectionState) {
                                                                    case ConnectionState.waiting:
                                                                      // return Center(child: Constant.loader());
                                                                      return const SizedBox();
                                                                    default:
                                                                      if (snapshot.hasError) {
                                                                        return TextCustom(
                                                                          title: 'Error: ${snapshot.error}',
                                                                        );
                                                                      } else {
                                                                        UserModel userModel = snapshot.data!;
                                                                        return Container(
                                                                          alignment: Alignment.centerLeft,
                                                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                                                          child: TextCustom(
                                                                            title: userModel.fullName!.isEmpty || userModel.fullName == null
                                                                                ? "N/A".tr
                                                                                : userModel.fullName.toString() == "Unknown User"
                                                                                    ? "User Deleted".tr
                                                                                    : userModel.fullName.toString(),
                                                                          ),
                                                                        );
                                                                      }
                                                                  }
                                                                }),
                                                          ),
                                                          DataCell(TextCustom(title: bookingModel.createAt == null ? '' : Constant.timestampToDate(bookingModel.createAt!))),
                                                          DataCell(TextCustom(title: bool.parse(bookingModel.paymentStatus!.toString()) ? "Paid".tr : "Unpaid".tr)),
                                                          DataCell(
                                                            // e.bookingStatus.toString()
                                                            Constant.bookingStatusText(context, bookingModel.bookingStatus.toString()),
                                                          ),
                                                          DataCell(TextCustom(title: Constant.amountShow(amount: bookingModel.subTotal))),
                                                          DataCell(
                                                            Container(
                                                              alignment: Alignment.center,
                                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                                              child: Row(
                                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                children: [
                                                                  InkWell(
                                                                    onTap: () async {
                                                                      Get.toNamed('${Routes.CAB_DETAIL}/${bookingModel.id}');
                                                                    },
                                                                    child: SvgPicture.asset(
                                                                      "assets/icons/ic_eye.svg",
                                                                      color: AppThemData.greyShade400,
                                                                      height: 16,
                                                                      width: 16,
                                                                    ),
                                                                  ),
                                                                  InkWell(
                                                                    onTap: () async {
                                                                      if (Constant.isDemo) {
                                                                        DialogBox.demoDialogBox();
                                                                      } else {
                                                                        bool confirmDelete = await DialogBox.showConfirmationDeleteDialog(context);
                                                                        if (confirmDelete) {
                                                                          await controller.removeBooking(bookingModel);
                                                                          controller.getBookings();
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
                  ],
                ),
              ),
            ),
          );
        });
  }
}
