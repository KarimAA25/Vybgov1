// ignore_for_file: unnecessary_overrides

import 'dart:async';

import 'package:driver/app/modules/subscription_plan/views/subscription_plan_view.dart';
import 'package:get/get.dart';
import 'package:driver/app/models/driver_user_model.dart';
import 'package:driver/app/modules/home/views/home_view.dart';
import 'package:driver/app/modules/intro_screen/views/intro_screen_view.dart';
import 'package:driver/app/modules/login/views/login_view.dart';
import 'package:driver/app/modules/permission/views/permission_view.dart';
import 'package:driver/constant/constant.dart';
import 'package:driver/utils/fire_store_utils.dart';
import 'package:driver/utils/preferences.dart';

class SplashScreenController extends GetxController {
  @override
  void onInit() {
    Timer(const Duration(seconds: 8), () => redirectScreen());
    super.onInit();
  }

  Future<void> redirectScreen() async {
    // 1️⃣ Check if onboarding is finished
    bool isOnboardingFinished = await Preferences.getBoolean(Preferences.isFinishOnBoardingKey);
    if (!isOnboardingFinished) {
      Get.offAll(const IntroScreenView());
      return;
    }

    // 2️⃣ Check login status
    bool isLogin = await FireStoreUtils.isLogin();
    if (!isLogin) {
      Get.offAll(const LoginView());
      return;
    }

    // 3️⃣ Get user profile
    DriverUserModel? userModel = await FireStoreUtils.getDriverUserProfile(FireStoreUtils.getCurrentUid());
    if (userModel == null || userModel.isActive != true) {
      Get.offAll(const LoginView());
      return;
    }

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
  }
}
