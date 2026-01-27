// ignore_for_file: depend_on_referenced_packages

import 'dart:developer';

import 'package:driver/app/models/user_model.dart';
import 'package:driver/app/modules/add_customer_review/controllers/add_customer_review_controller.dart';
import 'package:driver/constant/constant.dart';
import 'package:driver/constant_widgets/app_bar_with_border.dart';
import 'package:driver/constant_widgets/network_image_widget.dart';
import 'package:driver/constant_widgets/round_shape_button.dart';
import 'package:driver/constant_widgets/show_toast_dialog.dart';
import 'package:driver/theme/app_them_data.dart';
import 'package:driver/utils/dark_theme_provider.dart';
import 'package:driver/utils/fire_store_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddCustomerReviewView extends GetView<AddCustomerReviewController> {
  const AddCustomerReviewView({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetBuilder(
        init: AddCustomerReviewController(),
        builder: (controller) {
          return Scaffold(
            backgroundColor: themeChange.isDarkTheme() ? AppThemData.black : AppThemData.white,
            appBar: AppBarWithBorder(
              title: "Rate The Customer".tr,
              bgColor: themeChange.isDarkTheme() ? AppThemData.black : AppThemData.white,
            ),
            body: (controller.isLoading.value)
                ? Constant.loader()
                : Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Center(
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(50),
                              child: NetworkImageWidget(
                                height: 60,
                                width: 60,
                                fit: BoxFit.cover,
                                imageUrl: controller.userModel.value.profilePic == null || controller.userModel.value.profilePic == ""
                                    ? Constant.profileConstant
                                    : controller.userModel.value.profilePic.toString(),
                                errorWidget: Image.asset(
                                  Constant.placeHolder,
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Text(
                              controller.userModel.value.fullName.toString(),
                              style: GoogleFonts.inter(
                                color: themeChange.isDarkTheme() ? Colors.white : AppThemData.black,
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            Container(
                              decoration: BoxDecoration(
                                  border: Border.all(color: themeChange.isDarkTheme() ? AppThemData.grey800 : AppThemData.grey100, width: 1),
                                  borderRadius: BorderRadius.circular(12)),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "Rate Your Experience".tr,
                                      style: GoogleFonts.inter(
                                        color: themeChange.isDarkTheme() ? AppThemData.grey50 : AppThemData.grey950,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(
                                      "Help us improve by sharing your feedback! Your input helps us improve our service for all passengers.".tr,
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.inter(
                                        color: themeChange.isDarkTheme() ? AppThemData.grey50 : AppThemData.grey950,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                    Center(
                                      child: Padding(
                                        padding: const EdgeInsets.only(top: 15, bottom: 20),
                                        child: RatingBar.builder(
                                          glow: true,
                                          initialRating: controller.rating.value,
                                          minRating: 0,
                                          direction: Axis.horizontal,
                                          allowHalfRating: true,
                                          itemCount: 5,
                                          itemSize: 32,
                                          itemPadding: const EdgeInsets.symmetric(horizontal: 2.0),
                                          itemBuilder: (context, _) => Icon(
                                            Icons.star,
                                            color: AppThemData.primary500,
                                          ),
                                          onRatingUpdate: (rating) {
                                            controller.rating(rating);
                                          },
                                        ),
                                      ),
                                    ),
                                    Obx(
                                      () => TextFormField(
                                        controller: controller.commentController.value,
                                        textAlign: TextAlign.start,
                                        minLines: 3,
                                        maxLines: 5,
                                        decoration: InputDecoration(
                                            filled: true,
                                            hintText: "Add Comment...".tr,
                                            fillColor: themeChange.isDarkTheme() ? AppThemData.grey900 : AppThemData.grey50,
                                            enabledBorder: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(10.0),
                                                borderSide: BorderSide(color: themeChange.isDarkTheme() ? AppThemData.grey800 : AppThemData.grey100, width: 1)),
                                            focusedBorder: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(10.0),
                                                borderSide: BorderSide(color: themeChange.isDarkTheme() ? AppThemData.grey800 : AppThemData.grey100, width: 1)),
                                            border: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(10.0),
                                                borderSide: BorderSide(color: themeChange.isDarkTheme() ? AppThemData.grey800 : AppThemData.grey100, width: 1))),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            Center(
                              child: RoundShapeButton(
                                title: "Submit".tr,
                                buttonColor: AppThemData.primary500,
                                buttonTextColor: AppThemData.black,
                                onTap: () async {
                                  ShowToastDialog.showLoader("Please Wait..".tr);
                                  await FireStoreUtils.getUserProfile(controller.customerId.value).then((value) async {
                                    if (value != null) {
                                      UserModel userModel = value;
                                      if (controller.reviewModel.value.id != null) {
                                        userModel.reviewsSum =
                                            (double.parse(userModel.reviewsSum.toString()) - double.parse(controller.reviewModel.value.rating.toString())).toString();
                                        userModel.reviewsCount = (double.parse(userModel.reviewsCount.toString()) - 1).toString();
                                      }
                                      userModel.reviewsSum = (double.parse(userModel.reviewsSum.toString()) + double.parse(controller.rating.value.toString())).toString();
                                      userModel.reviewsCount = (double.parse(userModel.reviewsCount.toString()) + 1).toString();
                                      await FireStoreUtils.updateUser(userModel);
                                      log("+++++++++++++> User Model : ${userModel.toJson()}");
                                    }
                                  });
                                  controller.reviewModel.value.id = Constant.getRandomString(15);
                                  controller.reviewModel.value.bookingId = controller.bookingId.value;
                                  controller.reviewModel.value.rating = controller.rating.value.toString();
                                  controller.reviewModel.value.customerId = controller.customerId.value;
                                  controller.reviewModel.value.driverId = FireStoreUtils.getCurrentUid();
                                  controller.reviewModel.value.comment = controller.commentController.value.text;
                                  controller.reviewModel.value.type = "customer";
                                  controller.reviewModel.value.date = Timestamp.now();

                                  log("+++++++++++++> ${controller.reviewModel.value.toJson()}");
                                  await FireStoreUtils.setReview(controller.reviewModel.value).then((value) {
                                    if (value != null && value == true) {
                                      ShowToastDialog.closeLoader();
                                      ShowToastDialog.showToast("Review submit successfully".tr);
                                      Get.back();
                                    }
                                  });
                                },
                                size: const Size(208, 52),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
          );
        });
  }
}
