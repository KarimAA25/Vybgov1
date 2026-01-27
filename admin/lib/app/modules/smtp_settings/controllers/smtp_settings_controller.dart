import 'package:admin/app/constant/show_toast.dart';
import 'package:admin/app/models/smtp_setting_model.dart';
import 'package:admin/app/utils/fire_store_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

class SmtpSettingsController extends GetxController {
  RxBool isLoading = false.obs;
  RxString title = "SMTP Settings".tr.obs;

  Rx<SMTPSettingModel> smtpSettingModel = SMTPSettingModel().obs;

  Rx<TextEditingController> smtpHostController = TextEditingController().obs;
  Rx<TextEditingController> smtpPortController = TextEditingController().obs;
  Rx<TextEditingController> userNameController = TextEditingController().obs;
  Rx<TextEditingController> passwordController = TextEditingController().obs;

  List<String> encryptionType = ['SSL', 'TLS'];
  RxString selectedEncryptionType = "SSL".obs;

  @override
  void onInit() {
    getData();
    super.onInit();
  }

  Future<void> getData() async {
    await FireStoreUtils.getSMTPSettings().then((value) {
      if (value != null) {
        smtpSettingModel.value = value;
        smtpHostController.value.text = smtpSettingModel.value.smtpHost!;
        smtpPortController.value.text = smtpSettingModel.value.smtpPort!;
        userNameController.value.text = smtpSettingModel.value.username!;
        passwordController.value.text = smtpSettingModel.value.password!;
        selectedEncryptionType.value = smtpSettingModel.value.encryption!;
      }
    });
  }

  void saveData() {
    if (selectedEncryptionType.isEmpty) {
      return ShowToastDialog.errorToast("Please Select Encryption Type.".tr);
    } else if (smtpHostController.value.text.isEmpty || smtpHostController.value.text == "") {
      return ShowToastDialog.errorToast("Please Add SMTP Host.".tr);
    } else if (smtpPortController.value.text.isEmpty || smtpPortController.value.text == "") {
      return ShowToastDialog.errorToast("Please Add SMTP Port.".tr);
    } else if (userNameController.value.text.isEmpty || userNameController.value.text == "") {
      return ShowToastDialog.errorToast("Please Add User Name.".tr);
    } else if (passwordController.value.text.isEmpty || passwordController.value.text == "") {
      return ShowToastDialog.errorToast("Please Add Password.".tr);
    } else {
      smtpSettingModel.value.smtpHost = smtpHostController.value.text;
      smtpSettingModel.value.smtpPort = smtpPortController.value.text;
      smtpSettingModel.value.username = userNameController.value.text;
      smtpSettingModel.value.password = passwordController.value.text;
      smtpSettingModel.value.encryption = selectedEncryptionType.value;

      FireStoreUtils.setSMTPSettings(smtpSettingModel.value);
      ShowToastDialog.successToast('Information Saved'.tr);
    }
  }
}
