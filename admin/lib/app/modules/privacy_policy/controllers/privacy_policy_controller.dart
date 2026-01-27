import 'dart:developer';
import 'package:admin/app/utils/fire_store_utils.dart';
import 'package:get/get.dart';
import 'package:html_editor_enhanced/html_editor.dart';

class PrivacyPolicyController extends GetxController {

   Rx<HtmlEditorController> htmlEditorController = HtmlEditorController().obs;


  RxBool isLoading = true.obs;
  RxString title = "Privacy Policy".tr.obs;

  RxString privacyPolicy = ''.obs;
  RxString selectedUserType = 'Customer'.obs;
  List<String> userTypeList = ["Customer", "Driver"];

  @override
  void onInit() {
    getSettingData();
    super.onInit();
  }

  Future<void> getSettingData() async {
    log("getSettingData : ${selectedUserType.value.toLowerCase()}");
    await FireStoreUtils.getPrivacyPolicy(selectedUserType.value.toLowerCase()).then((value) {
      if (value != null) {
        privacyPolicy.value = value;
        htmlEditorController.value.clear();
        htmlEditorController.value.insertHtml(privacyPolicy.value);
        log("privacyPolicy : ${privacyPolicy.value}");
      }
    });
    isLoading.value = false;
    update();
  }
}
