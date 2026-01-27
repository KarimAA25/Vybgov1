import 'dart:developer';
import 'dart:io';

import 'package:driver/constant/constant.dart';
import 'package:get/get.dart';
import 'package:driver/app/modules/home/views/home_view.dart';
import 'package:driver/constant_widgets/show_toast_dialog.dart';
import 'package:location/location.dart' as loc;
import 'package:permission_handler/permission_handler.dart' as perm;

class PermissionController extends GetxController {
  Future<void> forceRequestPermissions() async {
    log("---> Requesting permissions");

    loc.Location location = loc.Location();

    // Request location permission
    loc.PermissionStatus permissionStatus = await location.requestPermission();
    bool serviceEnabled = await Constant.isLocationServiceEnabled();

    if (permissionStatus == loc.PermissionStatus.granted && serviceEnabled) {
      bool isBackgroundPermissionGranted =
          await requestBackgroundLocationPermission();

      if (isBackgroundPermissionGranted) {
        if (Platform.isAndroid) {
          location.enableBackgroundMode(enable: true).then((value) {
            if (value) {
              ShowToastDialog.showToast(
                  "All permissions granted and background mode enabled.".tr);
              Get.offAll(const HomeView());
            } else {
              ShowToastDialog.showToast(
                  "Background mode is not enabled. Please enable it in settings."
                      .tr);
            }
          });
        } else {
          ShowToastDialog.showToast("All permissions granted.".tr);
          Get.offAll(const HomeView());
        }
      } else {
        ShowToastDialog.showToast(
          "Background location permission is denied. Please allow 'Always' access for full functionality."
              .tr,
        );
      }
    } else {
      if (!serviceEnabled) {
        ShowToastDialog.showToast(
          "Location services are disabled. Please turn on GPS to continue.".tr,
        );
      } else {
        ShowToastDialog.showToast(
          "Location permission denied. Please allow access to continue.".tr,
        );
      }
    }

    update();
  }

  Future<bool> requestBackgroundLocationPermission() async {
    if (Platform.isAndroid) {
      perm.PermissionStatus backgroundPermissionStatus =
          await perm.Permission.locationAlways.status;

      if (backgroundPermissionStatus != perm.PermissionStatus.granted) {
        backgroundPermissionStatus =
            await perm.Permission.locationAlways.request();
      }

      return backgroundPermissionStatus == perm.PermissionStatus.granted;
    } else {
      return true;
    }
  }
}
