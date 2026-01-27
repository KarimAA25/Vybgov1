import 'package:admin/app/constant/constants.dart';
import 'package:admin/app/constant/show_toast.dart';
import 'package:admin/app/models/constant_model.dart';
import 'package:admin/app/utils/fire_store_utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MapSettingsController extends GetxController {
  RxBool isLoading = false.obs;
  RxString title = "Map Settings".tr.obs;

  Rx<TextEditingController> googleMapKeyController = TextEditingController().obs;
  Rx<ConstantModel> constantModel = ConstantModel().obs;

  RxString selectMap = 'Google Map'.obs;
  List<String> mapType = ["Google Map", "OSM Map"];

  @override
  void onInit() {
    getData();
    super.onInit();
  }

  Future<void> getData() async {
    await FireStoreUtils.getGeneralSetting().then((value) {
      if (value != null) {
        constantModel.value = value;
        googleMapKeyController.value.text = constantModel.value.mapSettings!.googleMapKey!;
        selectMap.value = constantModel.value.mapSettings!.mapType!;
      }
    });
  }

  Future<void> saveData() async {
    if (googleMapKeyController.value.text.isEmpty || googleMapKeyController.value.text == "") {
      return ShowToastDialog.errorToast(" Please Add Google Map Key".tr);
    }
    Constant.waitingLoader();
    try {
      constantModel.value.mapSettings ??= MapSettingModel();
      constantModel.value.mapSettings!.googleMapKey = googleMapKeyController.value.text;
      constantModel.value.mapSettings!.mapType = selectMap.value;
      Get.back();
      await FireStoreUtils.setGeneralSetting(constantModel.value);
      ShowToastDialog.successToast("Information saved successfully.".tr);
    } catch (e) {
      ShowToastDialog.errorToast("Something went wrong: $e");
    } finally {
      ShowToastDialog.closeLoader();
    }
  }
}
