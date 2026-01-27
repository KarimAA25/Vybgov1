// ignore_for_file: deprecated_member_use

import 'package:admin/app/components/network_image_widget.dart';
import 'package:admin/app/constant/constants.dart';
import 'package:admin/app/models/documents_model.dart';
import 'package:admin/app/models/vehicle_type_model.dart';
import 'package:admin/app/modules/driver_detail_screen/controllers/driver_detail_screen_controller.dart';
import 'package:admin/app/modules/verify_driver_screen/views/verify_driver_screen_view.dart';
import 'package:admin/app/utils/app_colors.dart';
import 'package:admin/app/utils/app_them_data.dart';
import 'package:admin/app/utils/dark_theme_provider.dart';
import 'package:admin/app/utils/fire_store_utils.dart';
import 'package:admin/app/utils/responsive.dart';
import 'package:admin/widget/container_custom.dart';
import 'package:admin/widget/global_widgets.dart';
import 'package:admin/widget/text_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import '../../../../../widget/common_ui.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DriverInformationWidget extends StatelessWidget {
  const DriverInformationWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetX(
        init: DriverDetailScreenController(),
        builder: (controller) {
          return Scaffold(
              backgroundColor: themeChange.isDarkTheme() ? AppThemData.greyShade950 : AppThemData.greyShade50,
              body: ResponsiveWidget(
                mobile: controller.isLoading.value
                    ? Constant.loader()
                    : ContainerCustom(
                        color: themeChange.isDarkTheme() ? AppThemData.primaryBlack : AppThemData.primaryWhite,
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              TextCustom(
                                title: "Driver Details".tr,
                                fontSize: 20,
                                fontFamily: AppThemeData.bold,
                              ),
                              spaceH(height: 16),
                              Container(
                                padding: paddingEdgeInsets(horizontal: 20, vertical: 20),
                                decoration: BoxDecoration(
                                  color: themeChange.isDarkTheme() ? AppThemData.greyShade950 : AppThemData.greyShade50,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    detailView(title: "Driver Name", value: controller.driverUserModel.value.fullName.toString(), themeChange: themeChange),
                                    spaceH(height: 16),
                                    detailView(title: "Email ", value: Constant.maskEmail(email: controller.driverUserModel.value.email.toString()), themeChange: themeChange),
                                    spaceH(height: 16),
                                    detailView(
                                        title: "Phone Number",
                                        value: Constant.maskMobileNumber(
                                            mobileNumber: controller.driverUserModel.value.phoneNumber.toString(),
                                            countryCode: controller.driverUserModel.value.countryCode.toString()),
                                        themeChange: themeChange),
                                    spaceH(height: 16),
                                    detailView(title: "Gender", value: controller.driverUserModel.value.gender.toString(), themeChange: themeChange),
                                  ],
                                ),
                              ),
                              spaceH(height: 24),
                              TextCustom(
                                title: "Vehicle Details".tr,
                                fontSize: 20,
                                fontFamily: AppThemeData.bold,
                              ),
                              spaceH(height: 16),
                              Container(
                                padding: paddingEdgeInsets(horizontal: 20, vertical: 20),
                                decoration: BoxDecoration(
                                  color: themeChange.isDarkTheme() ? AppThemData.greyShade950 : AppThemData.greyShade50,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    FutureBuilder(
                                      future: FireStoreUtils.getVehicleByVehicleID(controller.driverUserModel.value.driverVehicleDetails!.vehicleTypeId.toString()),
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState == ConnectionState.waiting) {
                                          return Container();
                                        }
                                        if (!snapshot.hasData) {
                                          return Container();
                                        }
                                        VehicleTypeModel? vehicle = snapshot.data ?? VehicleTypeModel();
                                        return NetworkImageWidget(imageUrl: vehicle.image.toString(), height: 100, width: 100).paddingOnly(right: 24);
                                      },
                                    ),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          detailView(
                                              title: "Brand Name", value: controller.driverUserModel.value.driverVehicleDetails!.brandName.toString(), themeChange: themeChange),
                                          spaceH(height: 16),
                                          detailView(
                                              title: "Model Name", value: controller.driverUserModel.value.driverVehicleDetails!.modelName.toString(), themeChange: themeChange),
                                          spaceH(height: 16),
                                          detailView(
                                              title: "Vehicle Number",
                                              value: controller.driverUserModel.value.driverVehicleDetails!.vehicleNumber.toString(),
                                              themeChange: themeChange),
                                          spaceH(height: 16),
                                          detailView(
                                              title: "Vehicle Type Name",
                                              value: controller.driverUserModel.value.driverVehicleDetails!.vehicleTypeName.toString(),
                                              themeChange: themeChange),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              controller.bankList.isNotEmpty
                                  ? Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        TextCustom(
                                          title: "Bank Details".tr,
                                          fontSize: 20,
                                          fontFamily: AppThemeData.bold,
                                        ),
                                        spaceH(height: 16),
                                        SingleChildScrollView(
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
                                              headingRowColor: MaterialStateColor.resolveWith(
                                                (states) => themeChange.isDarkTheme() ? AppThemData.greyShade900 : AppThemData.greyShade100,
                                              ),
                                              columns: [
                                                CommonUI.dataColumnWidget(context,
                                                    columnTitle: "Bank Name".tr, width: ResponsiveWidget.isMobile(context) ? 200 : MediaQuery.of(context).size.width * .1),
                                                CommonUI.dataColumnWidget(context,
                                                    columnTitle: "Account Holder Name".tr,
                                                    width: ResponsiveWidget.isMobile(context) ? 200 : MediaQuery.of(context).size.width * .1),
                                                CommonUI.dataColumnWidget(context, columnTitle: "Account Number".tr, width: 150),
                                                CommonUI.dataColumnWidget(context, columnTitle: "IFSC Code".tr, width: 150),
                                                CommonUI.dataColumnWidget(context, columnTitle: "Swift Code".tr, width: 150),
                                                CommonUI.dataColumnWidget(context, columnTitle: "City".tr, width: 100),
                                                CommonUI.dataColumnWidget(context, columnTitle: "Country".tr, width: 100),
                                              ],
                                              rows: controller.bankList
                                                  .map((bank) => DataRow(cells: [
                                                        DataCell(TextCustom(title: bank.bankName.toString())),
                                                        DataCell(TextCustom(title: bank.holderName.toString())),
                                                        DataCell(TextCustom(title: bank.accountNumber.toString())),
                                                        DataCell(TextCustom(title: bank.ifscCode.toString())),
                                                        DataCell(TextCustom(title: bank.swiftCode.toString())),
                                                        DataCell(TextCustom(title: bank.branchCity.toString())),
                                                        DataCell(TextCustom(title: bank.branchCountry.toString())),
                                                      ]))
                                                  .toList(),
                                            ),
                                          ),
                                        )
                                      ],
                                    ).paddingOnly(top: 24)
                                  : SizedBox(),
                              controller.driverUserModel.value.verifyDocument != null && controller.driverUserModel.value.verifyDocument!.isNotEmpty
                                  ? Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        TextCustom(
                                          title: "Uploaded Documents".tr,
                                          fontSize: 20,
                                          fontFamily: AppThemeData.bold,
                                        ),
                                        spaceH(height: 16),
                                        SingleChildScrollView(
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
                                              headingRowColor: MaterialStateColor.resolveWith(
                                                (states) => themeChange.isDarkTheme() ? AppThemData.greyShade900 : AppThemData.greyShade100,
                                              ),
                                              columns: [
                                                CommonUI.dataColumnWidget(context,
                                                    columnTitle: "Name".tr, width: ResponsiveWidget.isMobile(context) ? 200 : MediaQuery.of(context).size.width * .1),
                                                CommonUI.dataColumnWidget(context, columnTitle: "Image".tr, width: 150),
                                                CommonUI.dataColumnWidget(context, columnTitle: "Status".tr, width: 100),
                                              ],
                                              rows: controller.driverUserModel.value.verifyDocument!
                                                  .map((document) => DataRow(cells: [
                                                        DataCell(
                                                          FutureBuilder<DocumentsModel?>(
                                                            future: FireStoreUtils.getDocumentByDocumentId(document.documentId.toString()),
                                                            builder: (
                                                              BuildContext context,
                                                              AsyncSnapshot<DocumentsModel?> snapshot,
                                                            ) {
                                                              switch (snapshot.connectionState) {
                                                                case ConnectionState.waiting:
                                                                  return const SizedBox();
                                                                default:
                                                                  if (snapshot.hasError) {
                                                                    return TextCustom(
                                                                      title: 'Error: ${snapshot.error}',
                                                                    );
                                                                  } else {
                                                                    DocumentsModel documentModel = snapshot.data!;
                                                                    return Container(
                                                                      alignment: Alignment.centerLeft,
                                                                      padding: const EdgeInsets.symmetric(
                                                                        horizontal: 8,
                                                                        vertical: 8,
                                                                      ),
                                                                      child: TextButton(
                                                                        onPressed: () {},
                                                                        child: TextCustom(
                                                                          title: documentModel.title.isEmpty ? "N/A".tr : documentModel.title.toString(),
                                                                        ),
                                                                      ),
                                                                    );
                                                                  }
                                                              }
                                                            },
                                                          ),
                                                        ),
                                                        DataCell(
                                                          GestureDetector(
                                                            onTap: () {
                                                              viewURLImage(
                                                                document.documentImage!.first.toString(),
                                                              );
                                                            },
                                                            child: Container(
                                                              alignment: Alignment.centerLeft,
                                                              padding: const EdgeInsets.symmetric(
                                                                horizontal: 8,
                                                                vertical: 8,
                                                              ),
                                                              child: NetworkImageWidget(
                                                                imageUrl: document.documentImage!.isEmpty ? Constant.userPlaceHolder : '${document.documentImage!.first}',
                                                                borderRadius: 10,
                                                                height: 40,
                                                                width: 100,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        DataCell(TextCustom(
                                                          title: document.isVerify == true ? "Verify" : "Not Verify",
                                                          color: document.isVerify == true ? AppThemData.green500 : AppThemData.red500,
                                                        )),
                                                      ]))
                                                  .toList(),
                                            ),
                                          ),
                                        )
                                      ],
                                    ).paddingOnly(top: 24)
                                  : SizedBox(),
                            ],
                          ),
                        ),
                      ),
                tablet: controller.isLoading.value
                    ? Constant.loader()
                    : ContainerCustom(
                        child: SingleChildScrollView(
                            child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            TextCustom(
                              title: "Driver Details".tr,
                              fontSize: 20,
                              fontFamily: AppThemeData.bold,
                            ),
                            spaceH(height: 16),
                            Container(
                              padding: paddingEdgeInsets(horizontal: 20, vertical: 20),
                              decoration: BoxDecoration(
                                color: themeChange.isDarkTheme() ? AppThemData.greyShade950 : AppThemData.greyShade50,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  detailView(title: "Driver Name", value: controller.driverUserModel.value.fullName.toString(), themeChange: themeChange),
                                  spaceH(height: 16),
                                  detailView(title: "Email ", value: Constant.maskEmail(email: controller.driverUserModel.value.email.toString()), themeChange: themeChange),
                                  spaceH(height: 16),
                                  detailView(
                                      title: "Phone Number",
                                      value: Constant.maskMobileNumber(
                                          mobileNumber: controller.driverUserModel.value.phoneNumber.toString(),
                                          countryCode: controller.driverUserModel.value.countryCode.toString()),
                                      themeChange: themeChange),
                                  spaceH(height: 16),
                                  detailView(title: "Gender", value: controller.driverUserModel.value.gender.toString(), themeChange: themeChange),
                                ],
                              ),
                            ),
                            spaceH(height: 24),
                            TextCustom(
                              title: "Vehicle Details".tr,
                              fontSize: 20,
                              fontFamily: AppThemeData.bold,
                            ),
                            spaceH(height: 16),
                            Container(
                              padding: paddingEdgeInsets(horizontal: 20, vertical: 20),
                              decoration: BoxDecoration(
                                color: themeChange.isDarkTheme() ? AppThemData.greyShade950 : AppThemData.greyShade50,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  FutureBuilder(
                                    future: FireStoreUtils.getVehicleByVehicleID(controller.driverUserModel.value.driverVehicleDetails!.vehicleTypeId.toString()),
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState == ConnectionState.waiting) {
                                        return Container();
                                      }
                                      if (!snapshot.hasData) {
                                        return Container();
                                      }
                                      VehicleTypeModel? vehicle = snapshot.data ?? VehicleTypeModel();
                                      return NetworkImageWidget(imageUrl: vehicle.image.toString(), height: 100, width: 100).paddingOnly(right: 24);
                                    },
                                  ),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        detailView(
                                            title: "Brand Name", value: controller.driverUserModel.value.driverVehicleDetails!.brandName.toString(), themeChange: themeChange),
                                        spaceH(height: 16),
                                        detailView(
                                            title: "Model Name", value: controller.driverUserModel.value.driverVehicleDetails!.modelName.toString(), themeChange: themeChange),
                                        spaceH(height: 16),
                                        detailView(
                                            title: "Vehicle Number",
                                            value: controller.driverUserModel.value.driverVehicleDetails!.vehicleNumber.toString(),
                                            themeChange: themeChange),
                                        spaceH(height: 16),
                                        detailView(
                                            title: "Vehicle Type Name",
                                            value: controller.driverUserModel.value.driverVehicleDetails!.vehicleTypeName.toString(),
                                            themeChange: themeChange),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            controller.bankList.isNotEmpty
                                ? Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      TextCustom(
                                        title: "Bank Details".tr,
                                        fontSize: 20,
                                        fontFamily: AppThemeData.bold,
                                      ),
                                      spaceH(height: 16),
                                      SingleChildScrollView(
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
                                            headingRowColor: MaterialStateColor.resolveWith(
                                              (states) => themeChange.isDarkTheme() ? AppThemData.greyShade900 : AppThemData.greyShade100,
                                            ),
                                            columns: [
                                              CommonUI.dataColumnWidget(context,
                                                  columnTitle: "Bank Name".tr, width: ResponsiveWidget.isMobile(context) ? 200 : MediaQuery.of(context).size.width * .1),
                                              CommonUI.dataColumnWidget(context,
                                                  columnTitle: "Account Holder Name".tr, width: ResponsiveWidget.isMobile(context) ? 200 : MediaQuery.of(context).size.width * .1),
                                              CommonUI.dataColumnWidget(context, columnTitle: "Account Number".tr, width: 150),
                                              CommonUI.dataColumnWidget(context, columnTitle: "IFSC Code".tr, width: 150),
                                              CommonUI.dataColumnWidget(context, columnTitle: "Swift Code".tr, width: 150),
                                              CommonUI.dataColumnWidget(context, columnTitle: "City".tr, width: 100),
                                              CommonUI.dataColumnWidget(context, columnTitle: "Country".tr, width: 100),
                                            ],
                                            rows: controller.bankList
                                                .map((bank) => DataRow(cells: [
                                                      DataCell(TextCustom(title: bank.bankName.toString())),
                                                      DataCell(TextCustom(title: bank.holderName.toString())),
                                                      DataCell(TextCustom(title: bank.accountNumber.toString())),
                                                      DataCell(TextCustom(title: bank.ifscCode.toString())),
                                                      DataCell(TextCustom(title: bank.swiftCode.toString())),
                                                      DataCell(TextCustom(title: bank.branchCity.toString())),
                                                      DataCell(TextCustom(title: bank.branchCountry.toString())),
                                                    ]))
                                                .toList(),
                                          ),
                                        ),
                                      )
                                    ],
                                  ).paddingOnly(top: 24)
                                : SizedBox(),
                            controller.driverUserModel.value.verifyDocument != null && controller.driverUserModel.value.verifyDocument!.isNotEmpty
                                ? Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      TextCustom(
                                        title: "Uploaded Documents".tr,
                                        fontSize: 20,
                                        fontFamily: AppThemeData.bold,
                                      ),
                                      spaceH(height: 16),
                                      SingleChildScrollView(
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
                                            headingRowColor: MaterialStateColor.resolveWith(
                                              (states) => themeChange.isDarkTheme() ? AppThemData.greyShade900 : AppThemData.greyShade100,
                                            ),
                                            columns: [
                                              CommonUI.dataColumnWidget(context,
                                                  columnTitle: "Name".tr, width: ResponsiveWidget.isMobile(context) ? 200 : MediaQuery.of(context).size.width * .1),
                                              CommonUI.dataColumnWidget(context, columnTitle: "Image".tr, width: 150),
                                              CommonUI.dataColumnWidget(context, columnTitle: "Status".tr, width: 100),
                                            ],
                                            rows: controller.driverUserModel.value.verifyDocument!
                                                .map((document) => DataRow(cells: [
                                                      DataCell(
                                                        FutureBuilder<DocumentsModel?>(
                                                          future: FireStoreUtils.getDocumentByDocumentId(document.documentId.toString()),
                                                          builder: (
                                                            BuildContext context,
                                                            AsyncSnapshot<DocumentsModel?> snapshot,
                                                          ) {
                                                            switch (snapshot.connectionState) {
                                                              case ConnectionState.waiting:
                                                                return const SizedBox();
                                                              default:
                                                                if (snapshot.hasError) {
                                                                  return TextCustom(
                                                                    title: 'Error: ${snapshot.error}',
                                                                  );
                                                                } else {
                                                                  DocumentsModel documentModel = snapshot.data!;
                                                                  return Container(
                                                                    alignment: Alignment.centerLeft,
                                                                    padding: const EdgeInsets.symmetric(
                                                                      horizontal: 8,
                                                                      vertical: 8,
                                                                    ),
                                                                    child: TextButton(
                                                                      onPressed: () {},
                                                                      child: TextCustom(
                                                                        title: documentModel.title.isEmpty ? "N/A".tr : documentModel.title.toString(),
                                                                      ),
                                                                    ),
                                                                  );
                                                                }
                                                            }
                                                          },
                                                        ),
                                                      ),
                                                      DataCell(
                                                        GestureDetector(
                                                          onTap: () {
                                                            viewURLImage(
                                                              document.documentImage!.first.toString(),
                                                            );
                                                          },
                                                          child: Container(
                                                            alignment: Alignment.centerLeft,
                                                            padding: const EdgeInsets.symmetric(
                                                              horizontal: 8,
                                                              vertical: 8,
                                                            ),
                                                            child: NetworkImageWidget(
                                                              imageUrl: document.documentImage!.isEmpty ? Constant.userPlaceHolder : '${document.documentImage!.first}',
                                                              borderRadius: 10,
                                                              height: 40,
                                                              width: 100,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      DataCell(TextCustom(
                                                        title: document.isVerify == true ? "Verify" : "Not Verify",
                                                        color: document.isVerify == true ? AppThemData.green500 : AppThemData.red500,
                                                      )),
                                                    ]))
                                                .toList(),
                                          ),
                                        ),
                                      )
                                    ],
                                  ).paddingOnly(top: 24)
                                : SizedBox(),
                          ],
                        )),
                      ),
                desktop: controller.isLoading.value
                    ? Constant.loader()
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          ContainerCustom(
                            color: themeChange.isDarkTheme() ? AppThemData.primaryBlack : AppThemData.primaryWhite,
                            child: SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        flex: 1,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            TextCustom(
                                              title: "Driver Details".tr,
                                              fontSize: 20,
                                              fontFamily: AppThemeData.bold,
                                            ),
                                            spaceH(height: 16),
                                            Container(
                                              padding: paddingEdgeInsets(horizontal: 20, vertical: 20),
                                              decoration: BoxDecoration(
                                                color: themeChange.isDarkTheme() ? AppThemData.greyShade950 : AppThemData.greyShade50,
                                                borderRadius: BorderRadius.circular(10),
                                              ),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  detailView(title: "Driver Name", value: controller.driverUserModel.value.fullName.toString(), themeChange: themeChange),
                                                  spaceH(height: 16),
                                                  detailView(
                                                      title: "Email ",
                                                      value: Constant.maskEmail(email: controller.driverUserModel.value.email.toString()),
                                                      themeChange: themeChange),
                                                  spaceH(height: 16),
                                                  detailView(
                                                      title: "Phone Number",
                                                      value: Constant.maskMobileNumber(
                                                          mobileNumber: controller.driverUserModel.value.phoneNumber.toString(),
                                                          countryCode: controller.driverUserModel.value.countryCode.toString()),
                                                      themeChange: themeChange),
                                                  spaceH(height: 16),
                                                  detailView(title: "Gender", value: controller.driverUserModel.value.gender.toString(), themeChange: themeChange),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(
                                        width: 24,
                                      ),
                                      Expanded(
                                        flex: 1,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            TextCustom(
                                              title: "Vehicle Details".tr,
                                              fontSize: 20,
                                              fontFamily: AppThemeData.bold,
                                            ),
                                            spaceH(height: 16),
                                            Container(
                                              padding: paddingEdgeInsets(horizontal: 20, vertical: 20),
                                              decoration: BoxDecoration(
                                                color: themeChange.isDarkTheme() ? AppThemData.greyShade950 : AppThemData.greyShade50,
                                                borderRadius: BorderRadius.circular(10),
                                              ),
                                              child: Row(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  FutureBuilder(
                                                    future: FireStoreUtils.getVehicleByVehicleID(controller.driverUserModel.value.driverVehicleDetails!.vehicleTypeId.toString()),
                                                    builder: (context, snapshot) {
                                                      if (snapshot.connectionState == ConnectionState.waiting) {
                                                        return Container();
                                                      }
                                                      if (!snapshot.hasData) {
                                                        return Container();
                                                      }
                                                      VehicleTypeModel? vehicle = snapshot.data ?? VehicleTypeModel();
                                                      return NetworkImageWidget(imageUrl: vehicle.image.toString(), height: 100, width: 100).paddingOnly(right: 24);
                                                    },
                                                  ),
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      mainAxisSize: MainAxisSize.min,
                                                      children: [
                                                        detailView(
                                                            title: "Brand Name",
                                                            value: controller.driverUserModel.value.driverVehicleDetails!.brandName.toString(),
                                                            themeChange: themeChange),
                                                        spaceH(height: 16),
                                                        detailView(
                                                            title: "Model Name",
                                                            value: controller.driverUserModel.value.driverVehicleDetails!.modelName.toString(),
                                                            themeChange: themeChange),
                                                        spaceH(height: 16),
                                                        detailView(
                                                            title: "Vehicle Number",
                                                            value: controller.driverUserModel.value.driverVehicleDetails!.vehicleNumber.toString(),
                                                            themeChange: themeChange),
                                                        spaceH(height: 16),
                                                        detailView(
                                                            title: "Vehicle Type Name",
                                                            value: controller.driverUserModel.value.driverVehicleDetails!.vehicleTypeName.toString(),
                                                            themeChange: themeChange),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  spaceH(height: 16),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      controller.bankList.isNotEmpty
                                          ? Expanded(
                                              flex: 1,
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  TextCustom(
                                                    title: "Bank Details".tr,
                                                    fontSize: 20,
                                                    fontFamily: AppThemeData.bold,
                                                  ),
                                                  spaceH(height: 16),
                                                  SingleChildScrollView(
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
                                                        headingRowColor: MaterialStateColor.resolveWith(
                                                          (states) => themeChange.isDarkTheme() ? AppThemData.greyShade900 : AppThemData.greyShade100,
                                                        ),
                                                        columns: [
                                                          CommonUI.dataColumnWidget(context,
                                                              columnTitle: "Bank Name".tr,
                                                              width: ResponsiveWidget.isMobile(context) ? 200 : MediaQuery.of(context).size.width * .1),
                                                          CommonUI.dataColumnWidget(context,
                                                              columnTitle: "Account Holder Name".tr,
                                                              width: ResponsiveWidget.isMobile(context) ? 200 : MediaQuery.of(context).size.width * .1),
                                                          CommonUI.dataColumnWidget(context, columnTitle: "Account Number".tr, width: 150),
                                                          CommonUI.dataColumnWidget(context, columnTitle: "IFSC Code".tr, width: 150),
                                                          CommonUI.dataColumnWidget(context, columnTitle: "Swift Code".tr, width: 150),
                                                          CommonUI.dataColumnWidget(context, columnTitle: "City".tr, width: 100),
                                                          CommonUI.dataColumnWidget(context, columnTitle: "Country".tr, width: 100),
                                                        ],
                                                        rows: controller.bankList
                                                            .map((bank) => DataRow(cells: [
                                                                  DataCell(TextCustom(title: bank.bankName.toString())),
                                                                  DataCell(TextCustom(title: bank.holderName.toString())),
                                                                  DataCell(TextCustom(title: bank.accountNumber.toString())),
                                                                  DataCell(TextCustom(title: bank.ifscCode.toString())),
                                                                  DataCell(TextCustom(title: bank.swiftCode.toString())),
                                                                  DataCell(TextCustom(title: bank.branchCity.toString())),
                                                                  DataCell(TextCustom(title: bank.branchCountry.toString())),
                                                                ]))
                                                            .toList(),
                                                      ),
                                                    ),
                                                  )
                                                ],
                                              ))
                                          : SizedBox(),
                                      Expanded(
                                        flex: 1,
                                        child: controller.driverUserModel.value.verifyDocument != null && controller.driverUserModel.value.verifyDocument!.isNotEmpty
                                            ? Row(
                                                children: [
                                                  SizedBox(width: 16),
                                                  Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      TextCustom(
                                                        title: "Uploaded Documents".tr,
                                                        fontSize: 20,
                                                        fontFamily: AppThemeData.bold,
                                                      ),
                                                      spaceH(height: 16),
                                                      SingleChildScrollView(
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
                                                            headingRowColor: MaterialStateColor.resolveWith(
                                                              (states) => themeChange.isDarkTheme() ? AppThemData.greyShade900 : AppThemData.greyShade100,
                                                            ),
                                                            columns: [
                                                              CommonUI.dataColumnWidget(context,
                                                                  columnTitle: "Name".tr, width: ResponsiveWidget.isMobile(context) ? 200 : MediaQuery.of(context).size.width * .1),
                                                              CommonUI.dataColumnWidget(context, columnTitle: "Image".tr, width: 150),
                                                              CommonUI.dataColumnWidget(context, columnTitle: "Status".tr, width: 100),
                                                            ],
                                                            rows: controller.driverUserModel.value.verifyDocument!
                                                                .map((document) => DataRow(cells: [
                                                                      DataCell(
                                                                        FutureBuilder<DocumentsModel?>(
                                                                          future: FireStoreUtils.getDocumentByDocumentId(document.documentId.toString()),
                                                                          builder: (
                                                                            BuildContext context,
                                                                            AsyncSnapshot<DocumentsModel?> snapshot,
                                                                          ) {
                                                                            switch (snapshot.connectionState) {
                                                                              case ConnectionState.waiting:
                                                                                return const SizedBox();
                                                                              default:
                                                                                if (snapshot.hasError) {
                                                                                  return TextCustom(
                                                                                    title: 'Error: ${snapshot.error}',
                                                                                  );
                                                                                } else {
                                                                                  DocumentsModel documentModel = snapshot.data!;
                                                                                  return Container(
                                                                                    alignment: Alignment.centerLeft,
                                                                                    padding: const EdgeInsets.symmetric(
                                                                                      horizontal: 8,
                                                                                      vertical: 8,
                                                                                    ),
                                                                                    child: TextButton(
                                                                                      onPressed: () {},
                                                                                      child: TextCustom(
                                                                                        title: documentModel.title.isEmpty ? "N/A".tr : documentModel.title.toString(),
                                                                                      ),
                                                                                    ),
                                                                                  );
                                                                                }
                                                                            }
                                                                          },
                                                                        ),
                                                                      ),
                                                                      DataCell(
                                                                        GestureDetector(
                                                                          onTap: () {
                                                                            viewURLImage(
                                                                              document.documentImage!.first.toString(),
                                                                            );
                                                                          },
                                                                          child: Container(
                                                                            alignment: Alignment.centerLeft,
                                                                            padding: const EdgeInsets.symmetric(
                                                                              horizontal: 8,
                                                                              vertical: 8,
                                                                            ),
                                                                            child: NetworkImageWidget(
                                                                              imageUrl:
                                                                                  document.documentImage!.isEmpty ? Constant.userPlaceHolder : '${document.documentImage!.first}',
                                                                              borderRadius: 10,
                                                                              height: 40,
                                                                              width: 100,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      DataCell(TextCustom(
                                                                        title: document.isVerify == true ? "Verify" : "Not Verify",
                                                                        color: document.isVerify == true ? AppThemData.green500 : AppThemData.red500,
                                                                      )),
                                                                    ]))
                                                                .toList(),
                                                          ),
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                ],
                                              )
                                            : SizedBox(),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
              ));
        });
  }
}

Column detailView({required String title, required String value, required themeChange}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      TextCustom(
        title: title.tr,
        fontSize: 16,
        fontFamily: AppThemeData.medium,
        color: themeChange.isDarkTheme() ? AppThemData.greyShade50 : AppThemData.greyShade950,
      ),
      spaceH(height: 6),
      Container(
        width: double.infinity,
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: themeChange.isDarkTheme() ? AppThemData.greyShade900 : AppThemData.greyShade100,
            )),
        child: TextCustom(
          title: value,
          fontSize: 14,
          fontFamily: AppThemeData.regular,
          color: themeChange.isDarkTheme() ? AppThemData.greyShade50 : AppThemData.greyShade950,
        ),
      ),
    ],
  );
}
