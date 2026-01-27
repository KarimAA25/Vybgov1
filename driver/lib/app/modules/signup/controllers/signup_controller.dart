// ignore_for_file: depend_on_referenced_packages

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:driver/app/models/driver_user_model.dart';
import 'package:driver/app/models/referral_model.dart';
import 'package:driver/app/models/user_model.dart';
import 'package:driver/app/models/wallet_transaction_model.dart';
import 'package:driver/app/modules/home/views/home_view.dart';
import 'package:driver/app/modules/login/views/login_view.dart';
import 'package:driver/app/modules/permission/views/permission_view.dart';
import 'package:driver/app/modules/subscription_plan/views/subscription_plan_view.dart';
import 'package:driver/constant/constant.dart';
import 'package:driver/constant_widgets/show_toast_dialog.dart';
import 'package:driver/extension/string_extensions.dart';
import 'package:driver/services/email_template_service.dart';
import 'package:driver/utils/fire_store_utils.dart';
import 'package:driver/utils/notification_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

class SignupController extends GetxController {
  Rx<GlobalKey<FormState>> formKey = GlobalKey<FormState>().obs;
  TextEditingController countryCodeController = TextEditingController(text: Constant.countryCode);
  TextEditingController phoneNumberController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController referralCodeController = TextEditingController();
  RxInt selectedGender = 1.obs;
  RxString loginType = "".obs;

  @override
  void onInit() {
    getArgument();
    super.onInit();
  }

  Rx<DriverUserModel> userModel = DriverUserModel().obs;

  Future<void> getArgument() async {
    dynamic argumentData = Get.arguments;
    if (argumentData != null) {
      userModel.value = argumentData['userModel'];
      loginType.value = userModel.value.loginType.toString();
      if (loginType.value == Constant.phoneLoginType) {
        phoneNumberController.text = userModel.value.phoneNumber.toString();
        countryCodeController.text = userModel.value.countryCode.toString();
      } else {
        emailController.text = userModel.value.email.toString();
        nameController.text = userModel.value.fullName.toString();
      }
    }
    update();
  }

  // Future<void> createAccount() async {
  //   String fcmToken = await NotificationService.getToken();
  //   String firstTwoChar = nameController.value.text.substring(0, 2).toUpperCase();
  //
  //   ShowToastDialog.showLoader("Please Wait..".tr);
  //   DriverUserModel userModelData = userModel.value;
  //   userModelData.fullName = nameController.value.text;
  //   userModelData.slug = nameController.value.text.toSlug(delimiter: "-");
  //   userModelData.email = emailController.value.text;
  //   userModelData.countryCode = countryCodeController.value.text;
  //   userModelData.phoneNumber = phoneNumberController.value.text;
  //   userModelData.gender = selectedGender.value == 1 ? "Male" : "Female";
  //   userModelData.profilePic = '';
  //   userModelData.fcmToken = fcmToken;
  //   userModelData.createdAt = Timestamp.now();
  //   userModelData.isActive = Constant.isDriverAutoApproved;
  //   userModelData.isVerified = Constant.isDocumentVerificationEnable == false ? true : false;
  //   userModelData.adminCommission = Constant.adminCommission;
  //   userModelData.status = "free";
  //   userModelData.bookingId = "";
  //   userModelData.searchNameKeywords = Constant.generateKeywords(nameController.value.text);
  //   userModelData.searchEmailKeywords = Constant.generateKeywords(emailController.value.text);
  //
  //   String referralCode = referralCodeController.value.text;
  //   if (referralCode.isNotEmpty) {
  //     bool? isValid = await FireStoreUtils.checkReferralCodeValidOrNot(referralCode);
  //     if (isValid == true) {
  //       ReferralModel? referrer = await FireStoreUtils.getReferralUserByCode(referralCode);
  //       if (referrer != null) {
  //         await addReferralAmount(referrer.userId.toString(), referrer.role.toString());
  //
  //         ReferralModel ownReferral = ReferralModel(
  //             userId: FireStoreUtils.getCurrentUid(), referralBy: referrer.userId, role: Constant.typeDriver, referralRole: referrer.role, referralCode: Constant.getReferralCode(firstTwoChar));
  //         await FireStoreUtils.referralAdd(ownReferral);
  //
  //         String? referrerEmail;
  //         String? referrerName;
  //         if (referrer.role == Constant.typeCustomer) {
  //           UserModel? user = await FireStoreUtils.getUserProfile(referrer.userId.toString());
  //           referrerEmail = user?.email;
  //           referrerName = user?.fullName;
  //         } else {
  //           DriverUserModel? driver = await FireStoreUtils.getDriverUserProfile(referrer.userId.toString());
  //           referrerEmail = driver?.email;
  //           referrerName = driver?.fullName;
  //         }
  //
  //         if (referrerEmail != null && referrerName != null) {
  //           await EmailTemplateService.sendEmail(
  //             type: "refer_and_earn",
  //             toEmail: referrerEmail,
  //             variables: {
  //               "name": referrerName,
  //               "referral_name": userModelData.fullName.toString(),
  //               "amount": Constant.amountToShow(amount: Constant.referralAmount),
  //             },
  //           );
  //         }
  //       }
  //     } else {
  //       ShowToastDialog.showToast("Invalid Referral Code".tr);
  //       ShowToastDialog.closeLoader();
  //       return;
  //     }
  //   } else {
  //     ReferralModel ownReferral =
  //         ReferralModel(userId: FireStoreUtils.getCurrentUid(), referralBy: "", role: Constant.typeDriver, referralRole: "", referralCode: Constant.getReferralCode(firstTwoChar));
  //     await FireStoreUtils.referralAdd(ownReferral);
  //   }
  //
  //   await FireStoreUtils.updateDriverUser(userModelData).then((value) async {
  //     await EmailTemplateService.sendEmail(
  //       type: "signup",
  //       toEmail: userModelData.email.toString(),
  //       variables: {"name": userModelData.fullName.toString()},
  //     );
  //     DriverUserModel? userModel = await FireStoreUtils.getDriverUserProfile(userModelData.id ?? '');
  //     if (userModel != null) {
  //       if (userModelData.isActive == true) {
  //         if (Constant.isSubscriptionEnable == true) {
  //           if (Constant.userModel!.subscriptionPlanId != null && Constant.userModel!.subscriptionPlanId!.isNotEmpty) {
  //             if (Constant.userModel!.subscriptionExpiryDate!.toDate().isAfter(DateTime.now())) {
  //               bool permissionGiven = await Constant.isPermissionApplied();
  //               if (permissionGiven) {
  //                 Get.offAll(const HomeView());
  //               } else {
  //                 Get.offAll(const PermissionView());
  //               }
  //             } else {
  //               Get.offAll(SubscriptionPlanView(isFromProfile: false,));
  //             }
  //           } else {
  //             Get.offAll(SubscriptionPlanView(isFromProfile: false,));
  //           }
  //         } else {
  //           Get.offAll(HomeView());
  //         }
  //       } else {
  //         Get.offAll(const LoginView());
  //         ShowToastDialog.showToast("Please wait until Admin verifies your account".tr);
  //       }
  //     }
  //     ShowToastDialog.closeLoader();
  //   });
  // }

  Future<void> createAccount() async {
    String fcmToken = await NotificationService.getToken();
    String firstTwoChar = nameController.value.text.substring(0, 2).toUpperCase();

    ShowToastDialog.showLoader("Please Wait..".tr);

    DriverUserModel userModelData = userModel.value;
    userModelData.fullName = nameController.value.text;
    userModelData.slug = nameController.value.text.toSlug(delimiter: "-");
    userModelData.email = emailController.value.text;
    userModelData.countryCode = countryCodeController.value.text;
    userModelData.phoneNumber = phoneNumberController.value.text;
    userModelData.gender = selectedGender.value == 1 ? "Male" : "Female";
    userModelData.profilePic = '';
    userModelData.fcmToken = fcmToken;
    userModelData.createdAt = Timestamp.now();
    userModelData.isActive = Constant.isDriverAutoApproved;
    userModelData.isVerified = Constant.isDocumentVerificationEnable == false ? true : false;
    userModelData.adminCommission = Constant.adminCommission;
    userModelData.status = "free";
    userModelData.bookingId = "";
    userModelData.searchNameKeywords = Constant.generateKeywords(nameController.value.text);
    userModelData.searchEmailKeywords = Constant.generateKeywords(emailController.value.text);

    String referralCode = referralCodeController.value.text;

    // ----------------- REFERRAL LOGIC (unchanged in behavior) -----------------
    if (referralCode.isNotEmpty) {
      bool? isValid = await FireStoreUtils.checkReferralCodeValidOrNot(referralCode);

      if (isValid == true) {
        ReferralModel? referrer = await FireStoreUtils.getReferralUserByCode(referralCode);

        if (referrer != null) {
          await addReferralAmount(
            referrer.userId.toString(),
            referrer.role.toString(),
          );

          ReferralModel ownReferral = ReferralModel(
            userId: FireStoreUtils.getCurrentUid(),
            referralBy: referrer.userId,
            role: Constant.typeDriver,
            referralRole: referrer.role,
            referralCode: Constant.getReferralCode(firstTwoChar),
          );
          await FireStoreUtils.referralAdd(ownReferral);

          // ⭐ Send refer_and_earn email in background (do not block user)
          unawaited(_sendReferralEmailToReferrer(referrer, userModelData));
        }
      } else {
        // invalid referral -> same behavior as before
        ShowToastDialog.showToast("Invalid Referral Code".tr);
        ShowToastDialog.closeLoader();
        return;
      }
    } else {
      ReferralModel ownReferral = ReferralModel(
        userId: FireStoreUtils.getCurrentUid(),
        referralBy: "",
        role: Constant.typeDriver,
        referralRole: "",
        referralCode: Constant.getReferralCode(firstTwoChar),
      );
      await FireStoreUtils.referralAdd(ownReferral);
    }

    // ----------------- SAVE DRIVER & NAVIGATE -----------------
    final success = await FireStoreUtils.updateDriverUser(userModelData);

    if (!success) {
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast("Something went wrong".tr);
      return;
    }

    // Send signup email in background – doesn't affect navigation
    unawaited(
      EmailTemplateService.sendEmail(
        type: "signup",
        toEmail: userModelData.email.toString(),
        variables: {"name": userModelData.fullName.toString()},
      ),
    );

    // Reload driver from Firestore (same as your code)
    DriverUserModel? fetchedUser = await FireStoreUtils.getDriverUserProfile(userModelData.id ?? '');
    if (fetchedUser != null) {
      if (userModelData.isActive == true) {
        if (Constant.isSubscriptionEnable == true) {
          if (Constant.userModel!.subscriptionPlanId != null && Constant.userModel!.subscriptionPlanId!.isNotEmpty) {
            if (Constant.userModel!.subscriptionExpiryDate!.toDate().isAfter(DateTime.now())) {
              bool permissionGiven = await Constant.isPermissionApplied();
              if (permissionGiven) {
                Get.offAll(const HomeView());
              } else {
                Get.offAll(const PermissionView());
              }
            } else {
              Get.offAll(SubscriptionPlanView(
                isFromProfile: false,
              ));
            }
          } else {
            Get.offAll(SubscriptionPlanView(
              isFromProfile: false,
            ));
          }
        } else {
          Get.offAll(HomeView());
        }
      } else {
        Get.offAll(const LoginView());
        ShowToastDialog.showToast("Please wait until Admin verifies your account".tr);
      }
    }
    ShowToastDialog.closeLoader();
  }

  Future<void> _sendReferralEmailToReferrer(
    ReferralModel referrer,
    DriverUserModel newDriver,
  ) async {
    String? referrerEmail;
    String? referrerName;
    if (referrer.role == Constant.typeCustomer) {
      UserModel? user = await FireStoreUtils.getUserProfile(referrer.userId.toString());
      referrerEmail = user?.email;
      referrerName = user?.fullName;
    } else {
      DriverUserModel? driver = await FireStoreUtils.getDriverUserProfile(referrer.userId.toString());
      referrerEmail = driver?.email;
      referrerName = driver?.fullName;
    }

    if (referrerEmail != null && referrerName != null) {
      await EmailTemplateService.sendEmail(
        type: "refer_and_earn",
        toEmail: referrerEmail,
        variables: {
          "name": referrerName,
          "referral_name": newDriver.fullName.toString(),
          "amount": Constant.amountToShow(amount: Constant.referralAmount),
        },
      );
    }
  }

  Future<void> addReferralAmount(String userId, String role) async {
    WalletTransactionModel walletTransaction = WalletTransactionModel(
        id: Constant.getUuid(),
        isCredit: true,
        amount: Constant.referralAmount.toString(),
        note: "Referral Amount Credited",
        paymentType: "wallet",
        userId: userId,
        type: role,
        createdDate: Timestamp.now());

    bool? isSuccess = await FireStoreUtils.setWalletTransaction(walletTransaction);
    if (isSuccess == true) {
      await FireStoreUtils.updateWalletForReferral(userId: userId, amount: double.parse(Constant.referralAmount!).toString(), role: role);
    }
  }
}
