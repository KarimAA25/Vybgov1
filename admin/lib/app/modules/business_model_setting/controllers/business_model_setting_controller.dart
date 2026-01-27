import 'package:admin/app/constant/constants.dart';
import 'package:admin/app/constant/show_toast.dart';
import 'package:admin/app/models/admin_commission_model.dart';
import 'package:admin/app/models/cancellation_charge_model.dart';
import 'package:admin/app/models/constant_model.dart';
import 'package:admin/app/utils/fire_store_utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BusinessModelSettingController extends GetxController {
  RxBool isLoading = false.obs;
  RxString title = "Business Model Setting".tr.obs;

  Rx<Status> isActiveAdminCommission = Status.active.obs;
  List<String> adminCommissionType = ["Fix", "Percentage"];
  RxString selectedAdminCommissionType = "Fix".obs;
  Rx<AdminCommission> adminCommissionModel = AdminCommission().obs;
  Rx<TextEditingController> adminCommissionController = TextEditingController().obs;

  Rx<Status> isActiveCancellationCharge = Status.active.obs;
  List<String> cancellationChargeType = ["Fix", "Percentage"];
  RxString selectedCancellationChargeType = "Fix".obs;
  Rx<CancellationChargeModel> cancellationChargeModel = CancellationChargeModel().obs;
  Rx<TextEditingController> cancellationChargeController = TextEditingController().obs;

  Rx<Status> isSubscriptionActive = Status.active.obs;
  Rx<ConstantModel> constantModel = ConstantModel().obs;

  Rx<Status> isOTPActive = Status.active.obs;

  @override
  void onInit() {
    getData();
    super.onInit();
  }

  Future<void> getData() async {
    isLoading(true);
    await getSettingData();
    await getAdminCommissionData();
    await getRideCancellationChargeData();
    isLoading(false);
  }

  Future<void> getAdminCommissionData() async {
    await FireStoreUtils.getAdminCommission().then((value) {
      if (value != null) {
        adminCommissionModel.value = value;
        adminCommissionController.value.text = adminCommissionModel.value.value!;
        selectedAdminCommissionType.value = adminCommissionModel.value.isFix == true ? "Fix" : "Percentage";
        isActiveAdminCommission.value = adminCommissionModel.value.active == true ? Status.active : Status.inactive;
      }
    });
  }

  Future<void> getRideCancellationChargeData() async {
    await FireStoreUtils.getRideCancellationCharge().then((value) {
      if (value != null) {
        cancellationChargeModel.value = value;
        cancellationChargeController.value.text = cancellationChargeModel.value.charge!;
        selectedCancellationChargeType.value = cancellationChargeModel.value.isFix == true ? "Fix" : "Percentage";
        isActiveCancellationCharge.value = cancellationChargeModel.value.active == true ? Status.active : Status.inactive;
      }
    });
  }

  Future<void> getSettingData() async {
    await FireStoreUtils.getGeneralSetting().then((value) {
      if (value != null) {
        constantModel.value = value;
        isSubscriptionActive.value = constantModel.value.isSubscriptionEnable == true ? Status.active : Status.inactive;
        isOTPActive.value = constantModel.value.isOTPEnable == true ? Status.active : Status.inactive;
      }
    });
  }

  dynamic saveData() {
    if (selectedAdminCommissionType.isEmpty) {
      return ShowToastDialog.errorToast(" Please Add Information".tr);
    } else if (adminCommissionController.value.text.isEmpty || adminCommissionController.value.text == "") {
      return ShowToastDialog.errorToast(" Please Add Admin Commission".tr);
    } else if (cancellationChargeController.value.text.isEmpty || cancellationChargeController.value.text == "") {
      return ShowToastDialog.errorToast(" Please Add Ride Cancellation Charge".tr);
    } else {
      adminCommissionModel.value.active = isActiveAdminCommission.value == Status.inactive ? false : true;
      adminCommissionModel.value.isFix = selectedAdminCommissionType.value == "Fix" ? true : false;
      adminCommissionModel.value.value = adminCommissionController.value.text;

      cancellationChargeModel.value.active = isActiveCancellationCharge.value == Status.inactive ? false : true;
      cancellationChargeModel.value.isFix = selectedCancellationChargeType.value == "Fix" ? true : false;
      cancellationChargeModel.value.charge = cancellationChargeController.value.text;

      constantModel.value.isSubscriptionEnable = isSubscriptionActive.value == Status.inactive ? false : true;
      constantModel.value.isOTPEnable = isOTPActive.value == Status.inactive ? false : true;

      FireStoreUtils.setAdminCommission(adminCommissionModel.value);
      FireStoreUtils.setRideCancellationCharge(cancellationChargeModel.value);
      FireStoreUtils.setGeneralSetting(constantModel.value);
      ShowToastDialog.successToast('Information Saved'.tr);
    }
  }
}
