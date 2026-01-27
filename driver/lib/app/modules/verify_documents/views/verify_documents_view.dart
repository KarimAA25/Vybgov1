import 'package:driver/app/models/driver_user_model.dart';
import 'package:driver/app/modules/home/views/home_view.dart';
import 'package:driver/app/modules/permission/views/permission_view.dart';
import 'package:driver/app/modules/upload_documents/views/upload_documents_view.dart';
import 'package:driver/constant/constant.dart';
import 'package:driver/constant_widgets/round_shape_button.dart';
import 'package:driver/constant_widgets/show_toast_dialog.dart';
import 'package:driver/theme/app_them_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../constant_widgets/app_bar_with_border.dart';
import '../../../../utils/dark_theme_provider.dart';
import '../../../../utils/fire_store_utils.dart';
import '../controllers/verify_documents_controller.dart';

class VerifyDocumentsView extends GetView<VerifyDocumentsController> {
  final bool isFromDrawer;

  const VerifyDocumentsView({super.key, required this.isFromDrawer});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetX(
        init: VerifyDocumentsController(),
        builder: (controller) {
          return Scaffold(
            appBar: isFromDrawer
                ? null
                : AppBarWithBorder(
                    title: "Upload Documents".tr,
                    bgColor: themeChange.isDarkTheme() ? AppThemData.black : AppThemData.white,
                  ),
            backgroundColor: themeChange.isDarkTheme() ? AppThemData.black : AppThemData.white,
            floatingActionButton: isFromDrawer
                ? SizedBox()
                : RoundShapeButton(
                    size: const Size(200, 45),
                    title: "Check Status".tr,
                    buttonColor: AppThemData.primary500,
                    buttonTextColor: AppThemData.black,
                    onTap: () async {
                      ShowToastDialog.showLoader("Please Wait..".tr);
                      await controller.getData();
                      if (controller.userModel.value.verifyDocument == null || controller.userModel.value.verifyDocument!.isEmpty) {
                        ShowToastDialog.closeLoader();
                        ShowToastDialog.showToast("Please upload your documents!.".tr);
                        return;
                      }

                      DriverUserModel? userModel = await FireStoreUtils.getDriverUserProfile(FireStoreUtils.getCurrentUid());
                      bool isUserVerified = userModel!.isVerified ?? false;

                      int index = controller.userModel.value.verifyDocument!.indexWhere((element) => element.isVerify == false);
                      bool isDocumentVerified = index == -1;

                      if (isUserVerified && isDocumentVerified) {
                        controller.isVerified.value = true;
                        ShowToastDialog.showToast("Admin has already verified your account".tr);
                        bool permissionGiven = await Constant.isPermissionApplied();
                        if (permissionGiven) {
                          Get.offAll(const HomeView());
                        } else {
                          Get.offAll(const PermissionView());
                        }
                      } else {
                        controller.isVerified.value = false;
                        if (!isUserVerified) {
                          ShowToastDialog.showToast("User disabled by administrator, Please contact admin".tr);
                        }
                      }

                      ShowToastDialog.closeLoader();
                    },
                  ),
            floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
            body: Padding(
              padding: const EdgeInsets.all(20.0),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (isFromDrawer)
                      Padding(
                        padding: const EdgeInsets.only(left: 0, top: 16, bottom: 8),
                        child: Text(
                          "Upload Document".tr,
                          style: GoogleFonts.inter(
                            color: themeChange.isDarkTheme() ? AppThemData.white : AppThemData.black,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 26, top: 6),
                      child: Text(
                        "Securely upload required documents for identity verification and account authentication".tr,
                        style: GoogleFonts.inter(
                          color: themeChange.isDarkTheme() ? AppThemData.grey300 : AppThemData.grey500,
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                    Center(
                      child: Image.asset(
                        "assets/icon/gif_verify_details.gif",
                        height: 76.0,
                        width: 76.0,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ListView.builder(
                      itemCount: controller.documentList.length,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        return Obx(
                          () {
                            final document = controller.documentList[index];
                            bool isUploaded = controller.checkUploadedData(document.id.toString());
                            bool isVerified = controller.checkVerifiedData(document.id.toString());
                            return InkWell(
                              onTap: () async {
                                Get.to(UploadDocumentsView(), arguments: {"document": document, "isUploaded": isUploaded});

                                await controller.getData();
                                controller.update();
                              },
                              child: Container(
                                  padding: isUploaded ? const EdgeInsets.all(16) : EdgeInsets.zero,
                                  margin: const EdgeInsets.only(bottom: 16),
                                  decoration: ShapeDecoration(
                                    color: isUploaded
                                        ? themeChange.isDarkTheme()
                                            ? AppThemData.primary950
                                            : AppThemData.primary50
                                        : themeChange.isDarkTheme()
                                            ? AppThemData.black
                                            : AppThemData.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: isUploaded ? EdgeInsets.zero : const EdgeInsets.only(top: 16, bottom: 16),
                                        child: Row(
                                          children: [
                                            isUploaded
                                                ? SvgPicture.asset("assets/icon/ic_vehicle_details.svg")
                                                : SvgPicture.asset(
                                                    "assets/icon/ic_upload_document.svg",
                                                    colorFilter: ColorFilter.mode(
                                                      themeChange.isDarkTheme() ? AppThemData.white : AppThemData.black,
                                                      BlendMode.srcIn,
                                                    ),
                                                    // color: themeChange.isDarkTheme() ? AppThemData.white : AppThemData.black,
                                                  ),
                                            const SizedBox(width: 18),
                                            Expanded(
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    isUploaded ? document.title.toString() : "Upload_Document".trParams({"document": document.title.toString()}),
                                                    style: GoogleFonts.inter(
                                                      color: themeChange.isDarkTheme() ? AppThemData.grey25 : AppThemData.grey950,
                                                      fontSize: 16,
                                                      fontWeight: FontWeight.w400,
                                                    ),
                                                  ),
                                                  if (isUploaded) ...{
                                                    Row(
                                                      children: [
                                                        Text(
                                                          isVerified ? "Verified".tr : "Not Verified".tr,
                                                          style: GoogleFonts.inter(
                                                            color: isVerified ? AppThemData.success500 : AppThemData.danger500,
                                                            fontSize: 14,
                                                            fontWeight: FontWeight.w400,
                                                          ),
                                                        ),
                                                        Container(
                                                            width: 16,
                                                            height: 16,
                                                            margin: const EdgeInsets.only(left: 7),
                                                            clipBehavior: Clip.antiAlias,
                                                            decoration: BoxDecoration(
                                                              borderRadius: BorderRadius.circular(16),
                                                              color: isVerified ? AppThemData.success500 : AppThemData.danger500,
                                                            ),
                                                            child: Icon(
                                                              isVerified ? Icons.check : Icons.close,
                                                              size: 12,
                                                              color: AppThemData.white,
                                                            ))
                                                      ],
                                                    )
                                                  },
                                                ],
                                              ),
                                            ),
                                            const Icon(
                                              Icons.arrow_forward_ios_rounded,
                                              size: 20,
                                              color: AppThemData.grey500,
                                            )
                                          ],
                                        ),
                                      ),
                                      if (!isUploaded) ...{
                                        const Padding(
                                          padding: EdgeInsets.only(left: 40),
                                          child: Divider(
                                            color: AppThemData.grey100,
                                          ),
                                        )
                                      }
                                    ],
                                  )),
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }
}
