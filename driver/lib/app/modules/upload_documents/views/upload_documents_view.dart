// ignore_for_file: equal_elements_in_set, avoid_types_as_parameter_names, deprecated_member_use

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:driver/constant/constant.dart';
import 'package:driver/constant_widgets/app_bar_with_border.dart';
import 'package:driver/constant_widgets/round_shape_button.dart';
import 'package:driver/constant_widgets/show_toast_dialog.dart';
import 'package:driver/constant_widgets/text_field_with_title.dart';
import 'package:driver/theme/app_them_data.dart';
import 'package:driver/theme/responsive.dart';
import 'package:driver/utils/dark_theme_provider.dart';
import 'package:driver/utils/extension/date_time_extension.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../controllers/upload_documents_controller.dart';

class UploadDocumentsView extends StatelessWidget {
  const UploadDocumentsView({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetBuilder(
        init: UploadDocumentsController(),
        builder: (controller) {
          return Scaffold(
            backgroundColor: themeChange.isDarkTheme() ? AppThemData.black : AppThemData.white,
            appBar: AppBarWithBorder(title: controller.document.value.title.toString(), bgColor: themeChange.isDarkTheme() ? AppThemData.black : AppThemData.white),
            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      children: [
                        Text(
                          "Upload".tr + controller.document.value.title.toString(),
                          style: GoogleFonts.inter(
                            color: themeChange.isDarkTheme() ? AppThemData.grey25 : AppThemData.grey950,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 12),
                        controller.isUploaded.value
                            ? Obx(
                                () => SizedBox(
                                  height: 250.95,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      SizedBox(
                                        height: 220.95,
                                        child: PageView(
                                          scrollDirection: Axis.horizontal,
                                          controller: controller.controller,
                                          onPageChanged: (num) {
                                            controller.pageIndex.value = num;
                                          },
                                          children: controller.imageWidgetList,
                                        ),
                                      ),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: controller.imageList.map((element) => _indicator(controller, element)).toList(),
                                      )
                                    ],
                                  ),
                                ),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  InkWell(
                                    onTap: () {
                                      buildBottomSheet(context, controller, 0);
                                    },
                                    child: Obx(
                                      () => Container(
                                        width: Responsive.width(42, context),
                                        height: 200,
                                        padding: const EdgeInsets.all(20),
                                        decoration: ShapeDecoration(
                                          color: themeChange.isDarkTheme() ? AppThemData.primary950 : AppThemData.primary50,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          image: controller.verifyDocument.value.documentImage[0].isNotEmpty
                                              ? DecorationImage(
                                                  image: FileImage(
                                                    File(controller.verifyDocument.value.documentImage[0]),
                                                  ),
                                                  fit: BoxFit.cover)
                                              : null,
                                        ),
                                        child: Visibility(
                                          visible: controller.verifyDocument.value.documentImage[0].isEmpty,
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.cloud_upload_outlined,
                                                color: AppThemData.primary500,
                                              ),
                                              const SizedBox(height: 14),
                                              Column(
                                                mainAxisSize: MainAxisSize.min,
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    controller.document.value.isTwoSide == true
                                                        ? '${"Upload".tr} ${controller.document.value.title} ${"Front Side".tr}'
                                                        : '${"Upload".tr} ${controller.document.value.title}',
                                                    textAlign: TextAlign.center,
                                                    style: GoogleFonts.inter(
                                                      color: themeChange.isDarkTheme() ? AppThemData.grey25 : AppThemData.grey950,
                                                      fontSize: 14,
                                                      fontWeight: FontWeight.w400,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 2),
                                                  Text(
                                                    "Browse".tr,
                                                    textAlign: TextAlign.center,
                                                    style: GoogleFonts.inter(
                                                      color: AppThemData.primary500,
                                                      fontSize: 14,
                                                      fontWeight: FontWeight.w500,
                                                      decoration: TextDecoration.underline,
                                                      decorationColor: AppThemData.primary500,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () {
                                      buildBottomSheet(context, controller, 1);
                                    },
                                    child: Obx(
                                      () => Visibility(
                                        visible: controller.document.value.isTwoSide == true,
                                        child: InkWell(
                                          onTap: () {
                                            buildBottomSheet(context, controller, 1);
                                          },
                                          child: Container(
                                            width: Responsive.width(42, context),
                                            height: 200,
                                            padding: const EdgeInsets.all(20),
                                            decoration: ShapeDecoration(
                                              color: themeChange.isDarkTheme() ? AppThemData.primary950 : AppThemData.primary50,
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                              image: controller.verifyDocument.value.documentImage[1].isNotEmpty
                                                  ? DecorationImage(
                                                      image: FileImage(
                                                        File(controller.verifyDocument.value.documentImage[1]),
                                                      ),
                                                      fit: BoxFit.cover)
                                                  : null,
                                            ),
                                            child: Visibility(
                                              visible: controller.verifyDocument.value.documentImage[1].isEmpty,
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                children: [
                                                  Icon(
                                                    Icons.cloud_upload_outlined,
                                                    color: AppThemData.primary500,
                                                  ),
                                                  const SizedBox(height: 14),
                                                  SizedBox(
                                                    width: Responsive.width(40, context),
                                                    child: Column(
                                                      mainAxisSize: MainAxisSize.min,
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      crossAxisAlignment: CrossAxisAlignment.center,
                                                      children: [
                                                        Text(
                                                          '${"Upload".tr} ${controller.document.value.title} ${"Back Side".tr}',
                                                          textAlign: TextAlign.center,
                                                          style: GoogleFonts.inter(
                                                            color: themeChange.isDarkTheme() ? AppThemData.grey25 : AppThemData.grey950,
                                                            fontSize: 14,
                                                            fontWeight: FontWeight.w400,
                                                          ),
                                                        ),
                                                        const SizedBox(height: 2),
                                                        Text(
                                                          "Browse".tr,
                                                          textAlign: TextAlign.center,
                                                          style: GoogleFonts.inter(
                                                            color: AppThemData.primary500,
                                                            fontSize: 14,
                                                            fontWeight: FontWeight.w500,
                                                            decoration: TextDecoration.underline,
                                                            decorationColor: AppThemData.primary500,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                        const SizedBox(height: 16),
                        if (!controller.isUploaded.value) ...{
                          Row(
                            children: [
                              const Icon(
                                Icons.check,
                                color: AppThemData.success500,
                              ),
                              Expanded(
                                child: Container(
                                  margin: const EdgeInsets.only(left: 10),
                                  width: Responsive.width(80, context),
                                  child: Text(
                                    "Upload_Title".trParams({"documentTitle": controller.document.value.title ?? ""}),
                                    //"${"Upload clear pictures of both sides of ".tr} ${controller.document.value.title}",
                                    style: GoogleFonts.inter(
                                      color: themeChange.isDarkTheme() ? AppThemData.grey25 : AppThemData.grey950,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              const Icon(
                                Icons.check,
                                color: AppThemData.success500,
                              ),
                              Expanded(
                                child: Container(
                                  margin: const EdgeInsets.only(left: 10),
                                  width: Responsive.width(80, context),
                                  child: Text(
                                    "Photo_Detail".trParams({"photo": controller.document.value.title.toString()}),
                                    // "${"Ensure that the photo is clear and all details on the ".tr}${controller.document.value.title} ${"are visible.".tr}",
                                    style: GoogleFonts.inter(
                                      color: themeChange.isDarkTheme() ? AppThemData.grey25 : AppThemData.grey950,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              const Icon(
                                Icons.check,
                                color: AppThemData.success500,
                              ),
                              Expanded(
                                child: Container(
                                  margin: const EdgeInsets.only(left: 10),
                                  width: Responsive.width(80, context),
                                  child: Text(
                                    "The uploaded image should be in .jpg, .png, or .pdf format.".tr,
                                    style: GoogleFonts.inter(
                                      color: themeChange.isDarkTheme() ? AppThemData.grey25 : AppThemData.grey950,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                          const SizedBox(height: 22),
                        },
                      ],
                    ),
                    TextFieldWithTitle(
                      title: "Name".tr,
                      hintText: "Enter Name".tr,
                      keyboardType: TextInputType.name,
                      controller: controller.nameController,
                      isEnable: !controller.isUploaded.value,
                      inputFormatters: [FilteringTextInputFormatter.allow(RegExp("[a-zA-Z ]"))],
                    ),
                    const SizedBox(height: 16),
                    TextFieldWithTitle(
                      title: "Number".trParams({"number": controller.document.value.title.toString()}),
                      // "${controller.document.value.title.toString().tr} number",
                      hintText: "Enter_Number".trParams({"number": controller.document.value.title.toString()}),
                      //"Enter ${controller.document.value.title} number".tr,
                      keyboardType: TextInputType.text,
                      controller: controller.numberController,
                      isEnable: !controller.isUploaded.value,
                    ),
                    const SizedBox(height: 16),
                    InkWell(
                      onTap: controller.isUploaded.value
                          ? null
                          : () async {
                              DateTime? datetime = await Constant.selectDate(context, false);
                              if (datetime != null) {
                                controller.dobController.text = datetime.dateMonthYear();
                              } else {
                                controller.dobController.text = '';
                              }
                            },
                      child: TextFieldWithTitle(
                        title: "Date of Birth".tr,
                        hintText: "Enter Date of Birth".tr,
                        keyboardType: TextInputType.text,
                        controller: controller.dobController,
                        suffixIcon: const Icon(
                          Icons.calendar_month_outlined,
                          size: 20,
                        ),
                        isEnable: false,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Visibility(
                      visible: !controller.isUploaded.value,
                      child: Center(
                        child: RoundShapeButton(
                          size: const Size(200, 45),
                          title: "Submit".tr,
                          buttonColor: AppThemData.primary500,
                          buttonTextColor: AppThemData.black,
                          onTap: () {
                            List<dynamic> list = controller.verifyDocument.value.documentImage;
                            list.removeWhere((element) => element.isEmpty);

                            if (controller.nameController.text.isNotEmpty &&
                                controller.numberController.text.isNotEmpty &&
                                controller.dobController.text.isNotEmpty &&
                                list.isNotEmpty &&
                                (list.length == (controller.document.value.isTwoSide == true ? 2 : 1))) {
                              controller.uploadDocument(controller.document.value);
                            } else {
                              controller.verifyDocument.value.documentImage.add('');
                              controller.verifyDocument.value.documentImage.add('');
                              ShowToastDialog.showToast("Please enter a valid details".tr);
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }

  Widget _indicator(UploadDocumentsController controller, int element) {
    return SizedBox(
      height: 10,
      child: Obx(
        () => AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          margin: const EdgeInsets.symmetric(horizontal: 4.0),
          height: controller.imageList.indexOf(element) == controller.pageIndex.value ? 10 : 8.0,
          width: controller.imageList.indexOf(element) == controller.pageIndex.value ? 12 : 8.0,
          decoration: BoxDecoration(
            boxShadow: [
              controller.imageList.indexOf(element) == controller.pageIndex.value
                  ? BoxShadow(
                      color: AppThemData.primary50.withOpacity(0.72),
                      blurRadius: 4.0,
                      spreadRadius: 1.0,
                      offset: const Offset(
                        0.0,
                        0.0,
                      ),
                    )
                  : const BoxShadow(
                      color: Colors.transparent,
                    )
            ],
            shape: BoxShape.circle,
            color: controller.imageWidgetList.indexOf(element) == controller.pageIndex.value ? AppThemData.primary50 : AppThemData.primary500,
          ),
        ),
      ),
    );
  }

  Future buildBottomSheet(BuildContext context, UploadDocumentsController controller, int index) {
    return showModalBottomSheet(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return SizedBox(
              height: Responsive.height(22, context),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 15),
                    child: Text(
                      "Please Select".tr,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(18.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            IconButton(
                                onPressed: () => controller.pickFile(source: ImageSource.camera, index: index),
                                icon: const Icon(
                                  Icons.camera_alt,
                                  size: 32,
                                )),
                            Padding(
                              padding: const EdgeInsets.only(top: 3),
                              child: Text(
                                "camera".tr,
                                style: const TextStyle(),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(18.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            IconButton(
                                onPressed: () => controller.pickFile(source: ImageSource.gallery, index: index),
                                icon: const Icon(
                                  Icons.photo_library_sharp,
                                  size: 32,
                                )),
                            Padding(
                              padding: const EdgeInsets.only(top: 3),
                              child: Text(
                                "gallery".tr,
                                style: const TextStyle(),
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ],
              ),
            );
          });
        });
  }
}
