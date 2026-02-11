// ignore_for_file: unnecessary_overrides, depend_on_referenced_packages

import 'package:customer/app/modules/intro_screen/views/intro_screen_view.dart';
import 'package:customer/app/modules/login/views/login_view.dart';
import 'package:customer/constant_widgets/round_shape_button.dart';
import 'package:customer/theme/app_them_data.dart';
import 'package:customer/utils/preferences.dart';
import 'package:customer/utils/fire_store_utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:customer/app/modules/home/views/home_view.dart';
import 'package:customer/constant_widgets/show_toast_dialog.dart';
import 'package:location/location.dart' as loc;

class PermissionController extends GetxController with WidgetsBindingObserver {
  final RxBool _wasInSettings = false.obs;
  loc.Location location = loc.Location();

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void onClose() {
    super.onClose();
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_wasInSettings.value && state == AppLifecycleState.resumed) {
      _wasInSettings.value = false;
      requestPermission();
    }
  }

  Future<void> requestPermission() async {
    ShowToastDialog.showLoader("Please wait".tr);

    /// 1. Check if location service is enabled
    bool isServiceEnabled = await location.serviceEnabled();
    if (!isServiceEnabled) {
      isServiceEnabled = await location.requestService();
      if (!isServiceEnabled) {
        ShowToastDialog.closeLoader();
        _showEnableGPSDialog();
        return;
      }
    }

    /// 2. Check location permission
    loc.PermissionStatus permissionGranted = await location.hasPermission();
    if (permissionGranted == loc.PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
    }

    /// 3. Handle permission granted
    if (permissionGranted == loc.PermissionStatus.granted || permissionGranted == loc.PermissionStatus.grantedLimited) {
      ShowToastDialog.closeLoader();

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
      ShowToastDialog.closeLoader();
      _showPermissionDeniedDialog();
    }
  }

  void _showPermissionDeniedDialog() {
    Get.defaultDialog(
      title: "Permission Required".tr,
      middleText: "We need your location to find nearby drivers and get the current location.".tr,
      barrierDismissible: true,
      confirm: RoundShapeButton(
        title: "Allow Location".tr,
        buttonColor: AppThemData.primary500,
        buttonTextColor: AppThemData.black,
        onTap: () async {
          if (Navigator.of(Get.overlayContext!, rootNavigator: true).canPop()) {
            Navigator.of(Get.overlayContext!, rootNavigator: true).pop();
          }
          _wasInSettings.value = true;
          await location.requestPermission();
        },
        size: const Size(200, 48),
      ),
    );
  }

  void _showEnableGPSDialog() {
    Get.defaultDialog(
      title: "Enable GPS".tr,
      middleText: "GPS is required for this app. Please enable location services.".tr,
      barrierDismissible: true,
      confirm: RoundShapeButton(
        title: "Allow GPS".tr,
        buttonColor: AppThemData.primary500,
        buttonTextColor: AppThemData.black,
        onTap: () async {
          if (Navigator.of(Get.overlayContext!, rootNavigator: true).canPop()) {
            Navigator.of(Get.overlayContext!, rootNavigator: true).pop();
          }
          _wasInSettings.value = true;
          await location.requestService();
        },
        size: const Size(200, 48),
      ),
    );
  }
}
