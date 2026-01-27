import 'package:driver/app/models/driver_user_model.dart';
import 'package:driver/app/modules/home/views/home_view.dart';
import 'package:driver/app/modules/permission/views/permission_view.dart';
import 'package:driver/app/modules/signup/views/signup_view.dart';
import 'package:driver/app/modules/subscription_plan/views/subscription_plan_view.dart';
import 'package:driver/constant/constant.dart';
import 'package:driver/constant_widgets/round_shape_button.dart';
import 'package:driver/constant_widgets/show_toast_dialog.dart';
import 'package:driver/theme/app_them_data.dart';
import 'package:driver/utils/dark_theme_provider.dart';
import 'package:driver/utils/fire_store_utils.dart';
import 'package:driver/utils/notification_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pinput/pinput.dart';
import 'package:provider/provider.dart';

import '../../login/views/login_view.dart';
import '../controllers/verify_otp_controller.dart';

class VerifyOtpView extends StatelessWidget {
  const VerifyOtpView({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetBuilder<VerifyOtpController>(
        init: VerifyOtpController(),
        builder: (controller) {
          return GestureDetector(
            onTap: () {
              bool isFocus = FocusScope.of(context).hasFocus;
              if (isFocus) {
                FocusScope.of(context).unfocus();
              }
            },
            child: Scaffold(
              backgroundColor: themeChange.isDarkTheme() ? AppThemData.black : AppThemData.white,
              appBar: AppBar(
                forceMaterialTransparency: true,
                backgroundColor: themeChange.isDarkTheme() ? AppThemData.black : AppThemData.white,
                centerTitle: true,
                automaticallyImplyLeading: false,
                leading: InkWell(
                    onTap: () {
                      Get.back();
                    },
                    child: const Icon(Icons.arrow_back_rounded)),
                iconTheme: IconThemeData(color: themeChange.isDarkTheme() ? AppThemData.white : AppThemData.black),
              ),
              body: Padding(
                padding: const EdgeInsets.only(left: 20, right: 20, top: 31),
                child: Column(
                  children: [
                    Text(
                      "Verify Your Phone Number".tr,
                      style: GoogleFonts.inter(fontSize: 24, color: themeChange.isDarkTheme() ? AppThemData.white : AppThemData.black, fontWeight: FontWeight.w700),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 8, bottom: 33),
                      child: Text(
                        "Enter  6-digit code sent to your mobile number to complete verification.".tr,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(fontSize: 14, color: themeChange.isDarkTheme() ? AppThemData.white : AppThemData.black, fontWeight: FontWeight.w400),
                      ),
                    ),
                    Pinput(
                      length: 6,
                      showCursor: true,
                      defaultPinTheme: PinTheme(
                        width: 52,
                        height: 52,
                        textStyle: TextStyle(
                          fontSize: 16,
                          color: themeChange.isDarkTheme() ? AppThemData.white : AppThemData.grey950,
                          fontWeight: FontWeight.w500,
                          fontFamily: GoogleFonts.inter().fontFamily,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.transparent, // no fill color
                          border: Border.all(color: AppThemData.grey100),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      focusedPinTheme: PinTheme(
                        width: 52,
                        height: 52,
                        textStyle: TextStyle(
                          fontSize: 16,
                          color: themeChange.isDarkTheme() ? AppThemData.white : AppThemData.grey950,
                          fontWeight: FontWeight.w500,
                          fontFamily: GoogleFonts.inter().fontFamily,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.transparent, // no fill color
                          border: Border.all(color: AppThemData.primary500),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onCompleted: (pin) async {
                        if (pin.length == 6) {
                          ShowToastDialog.showLoader("Verify OTP".tr);
                          PhoneAuthCredential credential = PhoneAuthProvider.credential(verificationId: controller.verificationId.value, smsCode: pin);
                          await FirebaseAuth.instance.signInWithCredential(credential).then((value) async {
                            if (value.additionalUserInfo!.isNewUser) {
                              String fcmToken = await NotificationService.getToken();
                              DriverUserModel userModel = DriverUserModel();
                              userModel.id = value.user!.uid;
                              userModel.countryCode = controller.countryCode.value;
                              userModel.phoneNumber = controller.phoneNumber.value;
                              userModel.loginType = Constant.phoneLoginType;
                              userModel.fcmToken = fcmToken;

                              ShowToastDialog.closeLoader();
                              Get.off(const SignupView(), arguments: {
                                "userModel": userModel,
                              });
                            } else {
                              await FireStoreUtils.userExistOrNot(value.user!.uid).then((userExit) async {
                                ShowToastDialog.closeLoader();
                                if (userExit == true) {
                                  DriverUserModel? userModel = await FireStoreUtils.getDriverUserProfile(value.user!.uid);
                                  if (userModel != null) {
                                    if (userModel.isActive == true) {
                                      // 4️⃣ Handle subscription logic
                                      if (Constant.isSubscriptionEnable == true) {
                                        bool hasValidSubscription = userModel.subscriptionPlanId != null &&
                                            userModel.subscriptionPlanId!.isNotEmpty &&
                                            userModel.subscriptionExpiryDate != null &&
                                            userModel.subscriptionExpiryDate!.toDate().isAfter(DateTime.now());

                                        if (!hasValidSubscription) {
                                          Get.offAll(SubscriptionPlanView(isFromProfile: false,));
                                          return;
                                        }
                                      }

                                      // 5️⃣ Check permissions (if subscription is valid or disabled)
                                      bool permissionGiven = await Constant.isPermissionApplied();
                                      if (permissionGiven) {
                                        Get.offAll(const HomeView());
                                      } else {
                                        Get.offAll(const PermissionView());
                                      }
                                    } else {
                                      ShowToastDialog.showToast("user_disable_admin_contact".tr);
                                      Get.offAll(const LoginView());
                                    }
                                  }
                                } else {
                                  String fcmToken = await NotificationService.getToken();
                                  DriverUserModel userModel = DriverUserModel();
                                  userModel.id = value.user!.uid;
                                  userModel.countryCode = controller.countryCode.value;
                                  userModel.phoneNumber = controller.phoneNumber.value;
                                  userModel.loginType = Constant.phoneLoginType;
                                  userModel.fcmToken = fcmToken;

                                  Get.off(const SignupView(), arguments: {
                                    "userModel": userModel,
                                  });
                                }
                              });
                            }
                          }).catchError((error) {
                            ShowToastDialog.closeLoader();
                            ShowToastDialog.showToast("invalid_code".tr);
                          });
                        } else {
                          controller.otpCode.value = pin;
                        }
                      },
                    ),
                    const SizedBox(height: 90),
                    RoundShapeButton(
                        size: const Size(200, 45),
                        title: "Verify OTP".tr,
                        buttonColor: AppThemData.primary500,
                        buttonTextColor: AppThemData.black,
                        onTap: () async {
                          if (controller.otpCode.value.length == 6) {
                            ShowToastDialog.showLoader("Verify OTP".tr);
                            PhoneAuthCredential credential = PhoneAuthProvider.credential(verificationId: controller.verificationId.value, smsCode: controller.otpCode.value);
                            String fcmToken = await NotificationService.getToken();
                            await FirebaseAuth.instance.signInWithCredential(credential).then((value) async {
                              if (value.additionalUserInfo!.isNewUser) {
                                DriverUserModel userModel = DriverUserModel();
                                userModel.id = value.user!.uid;
                                userModel.countryCode = controller.countryCode.value;
                                userModel.phoneNumber = controller.phoneNumber.value;
                                userModel.loginType = Constant.phoneLoginType;
                                userModel.fcmToken = fcmToken;

                                ShowToastDialog.closeLoader();
                                Get.off(const SignupView(), arguments: {
                                  "userModel": userModel,
                                });
                              } else {
                                await FireStoreUtils.userExistOrNot(value.user!.uid).then((userExit) async {
                                  ShowToastDialog.closeLoader();
                                  if (userExit == true) {
                                    DriverUserModel? userModel = await FireStoreUtils.getDriverUserProfile(value.user!.uid);
                                    if (userModel != null) {
                                      if (userModel.isActive == true) {
                                        // 4️⃣ Handle subscription logic
                                        if (Constant.isSubscriptionEnable == true) {
                                          bool hasValidSubscription = userModel.subscriptionPlanId != null &&
                                              userModel.subscriptionPlanId!.isNotEmpty &&
                                              userModel.subscriptionExpiryDate != null &&
                                              userModel.subscriptionExpiryDate!.toDate().isAfter(DateTime.now());

                                          if (!hasValidSubscription) {
                                            Get.offAll(SubscriptionPlanView(isFromProfile: false,));
                                            return;
                                          }
                                        }

                                        // 5️⃣ Check permissions (if subscription is valid or disabled)
                                        bool permissionGiven = await Constant.isPermissionApplied();
                                        if (permissionGiven) {
                                          Get.offAll(const HomeView());
                                        } else {
                                          Get.offAll(const PermissionView());
                                        }
                                      } else {
                                        ShowToastDialog.showToast("user_disable_admin_contact".tr);
                                        Get.offAll(const LoginView());
                                      }
                                    }
                                  } else {
                                    DriverUserModel userModel = DriverUserModel();
                                    userModel.id = value.user!.uid;
                                    userModel.countryCode = controller.countryCode.value;
                                    userModel.phoneNumber = controller.phoneNumber.value;

                                    userModel.loginType = Constant.phoneLoginType;
                                    userModel.fcmToken = fcmToken;

                                    Get.off(const SignupView(), arguments: {
                                      "userModel": userModel,
                                    });
                                  }
                                });
                              }
                            }).catchError((error) {
                              ShowToastDialog.closeLoader();
                              ShowToastDialog.showToast("invalid_code".tr);
                            });
                          } else {
                            ShowToastDialog.showToast("user_disable_admin_contact".tr);
                          }
                        }),
                    const SizedBox(height: 24),
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: "Did’t Receive a code ?".tr,
                            style: GoogleFonts.inter(fontSize: 14, color: AppThemData.grey400, fontWeight: FontWeight.w400),
                          ),
                          TextSpan(
                              text: ' ${"Resend Code".tr}',
                              style: GoogleFonts.inter(fontSize: 14, color: themeChange.isDarkTheme() ? AppThemData.white : AppThemData.grey950, fontWeight: FontWeight.w600),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  controller.sendOTP();
                                }),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          );
        });
  }
}
