// ignore_for_file: depend_on_referenced_packages

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:customer/app/models/driver_user_model.dart';
import 'package:customer/app/models/referral_model.dart';
import 'package:customer/app/models/user_model.dart';
import 'package:customer/app/modules/home/views/home_view.dart';
import 'package:customer/constant/constant.dart';
import 'package:customer/constant_widgets/show_toast_dialog.dart';
import 'package:customer/extension/string_extensions.dart';
import 'package:customer/services/email_template_service.dart';
import 'package:customer/utils/fire_store_utils.dart';
import 'package:customer/utils/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../models/wallet_transaction_model.dart';

class SignupController extends GetxController {
  Rx<GlobalKey<FormState>> formKey = GlobalKey<FormState>().obs;

  TextEditingController countryCodeController = TextEditingController(text: Constant.countryCode);
  TextEditingController phoneNumberController = TextEditingController();
  TextEditingController referralCodeController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  RxInt selectedGender = 1.obs;
  RxString loginType = "".obs;

  @override
  void onInit() {
    final argumentData = Get.arguments;
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
    super.onInit();
  }

  Rx<UserModel> userModel = UserModel().obs;

  Future<void> createAccount() async {
    String fcmToken = await NotificationService.getToken();
    String firstTwoChar = nameController.value.text.substring(0, 2).toUpperCase();

    ShowToastDialog.showLoader("Please wait".tr);
    UserModel userModelData = userModel.value;
    userModelData.fullName = nameController.value.text;
    userModelData.slug = nameController.value.text.toSlug(delimiter: "-");
    userModelData.email = emailController.value.text;
    userModelData.countryCode = countryCodeController.value.text;
    userModelData.phoneNumber = phoneNumberController.value.text;
    userModelData.gender = selectedGender.value == 1 ? "Male" : "Female";
    userModelData.profilePic = '';
    userModelData.fcmToken = fcmToken;
    userModelData.createdAt = Timestamp.now();
    userModelData.isActive = true;
    userModelData.searchNameKeywords = Constant.generateKeywords(nameController.value.text);
    userModelData.searchEmailKeywords = Constant.generateKeywords(emailController.value.text);

    String referralCode = referralCodeController.value.text;
    if (referralCode.isNotEmpty) {
      bool? isValid = await FireStoreUtils.checkReferralCodeValidOrNot(referralCode);
      if (isValid == true) {
        ReferralModel? referrer = await FireStoreUtils.getReferralUserByCode(referralCode);
        if (referrer != null) {
          await addReferralAmount(referrer.userId.toString(), referrer.role.toString());

          ReferralModel ownReferral = ReferralModel(
              userId: FireStoreUtils.getCurrentUid(),
              referralBy: referrer.userId,
              role: Constant.typeCustomer,
              referralRole: referrer.role,
              referralCode: Constant.getReferralCode(firstTwoChar));
          await FireStoreUtils.referralAdd(ownReferral);

          unawaited(_sendReferralEmailToReferrer(referrer, userModelData));
          // String? referrerEmail;
          // String? referrerName;
          // if (referrer.role == Constant.typeCustomer) {
          //   UserModel? user = await FireStoreUtils.getUserProfile(referrer.userId.toString());
          //   referrerEmail = user?.email;
          //   referrerName = user?.fullName;
          // } else {
          //   DriverUserModel? driver = await FireStoreUtils.getDriverUserProfile(referrer.userId.toString());
          //   referrerEmail = driver?.email;
          //   referrerName = driver?.fullName;
          // }
          //
          // if (referrerEmail != null && referrerName != null) {
          //   await EmailTemplateService.sendEmail(
          //     type: "refer_and_earn",
          //     toEmail: referrerEmail,
          //     variables: {
          //       "name": referrerName,
          //       "referral_name": userModelData.fullName.toString(),
          //       "amount": Constant.amountToShow(amount: Constant.referralAmount),
          //     },
          //   );
          // }
        }
      } else {
        ShowToastDialog.showToast("Invalid Referral Code".tr);
        ShowToastDialog.closeLoader();
        return;
      }
    } else {
      ReferralModel ownReferral = ReferralModel(
          userId: FireStoreUtils.getCurrentUid(), referralBy: "", role: Constant.typeCustomer, referralRole: "", referralCode: Constant.getReferralCode(firstTwoChar));
      await FireStoreUtils.referralAdd(ownReferral);
    }

    final value = await FireStoreUtils.updateUser(userModelData);
    ShowToastDialog.closeLoader();
    if (value == true) {
      Get.offAll(const HomeView());
    }

    EmailTemplateService.sendEmail(
      type: "signup",
      toEmail: userModelData.email.toString(),
      variables: {"name": userModelData.fullName.toString()},
    );
  }

  Future<void> _sendReferralEmailToReferrer(
    ReferralModel referrer,
    UserModel newUser,
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
          "referral_name": newUser.fullName.toString(),
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
