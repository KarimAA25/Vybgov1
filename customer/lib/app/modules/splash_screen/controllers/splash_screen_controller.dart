// ignore_for_file: unnecessary_overrides, depend_on_referenced_packages

import 'dart:async';

import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:customer/app/modules/home/views/home_view.dart';
import 'package:customer/app/modules/intro_screen/views/intro_screen_view.dart';
import 'package:customer/app/modules/login/views/login_view.dart';
import 'package:customer/app/modules/permission/views/permission_view.dart';
import 'package:customer/utils/fire_store_utils.dart';
import 'package:customer/utils/preferences.dart';

class SplashScreenController extends GetxController {
  @override
  void onInit() {
    Timer(const Duration(seconds: 3), () => redirectScreen());
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {}

  Future<bool> _checkLocationPermission() async {
    bool isLocationEnable;
    bool isLocationServiceEnabled = await Geolocator.isLocationServiceEnabled();

    if (isLocationServiceEnabled == false) {
      isLocationEnable = false;
    } else {
      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.always || permission == LocationPermission.whileInUse) {
        isLocationEnable = true;
      } else {
        isLocationEnable = false;
      }
    }

    return isLocationEnable;
  }

  Future<void> redirectScreen() async {
    bool isLocationPermission = await _checkLocationPermission();

    if (isLocationPermission) {
      if ((await Preferences.getBoolean(Preferences.isFinishOnBoardingKey)) == false) {
        Get.offAll(const IntroScreenView());
      } else {
        bool isLogin = await FireStoreUtils.isLogin();
        if (isLogin == true) {
          Get.offAll(() => const HomeView());
        } else {
          Get.offAll(const LoginView());
        }
      }
    } else {
      Get.offAll(() => const PermissionView());
    }
  }
}
