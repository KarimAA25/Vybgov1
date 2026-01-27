import 'dart:developer';

import 'package:admin/app/utils/fire_store_utils.dart';
import 'package:get/get.dart';
import 'package:html_editor_enhanced/html_editor.dart';

class LandingPageController extends GetxController {
  RxBool isLoading = true.obs;

  RxString title = "Landing Page".obs;
  Rx<HtmlEditorController> htmlEditorController = HtmlEditorController().obs;
  RxString landingPageData = ''.obs;

  @override
  void onInit() {
    getSettingData();
    super.onInit();
  }

  Future<void> getSettingData() async {
    await FireStoreUtils.getLandingPage().then((value) {
      if (value != null) {
        landingPageData.value = value;
        htmlEditorController.value.clear();
        htmlEditorController.value.insertHtml(landingPageData.value);
        log("Landing Page Data : ${landingPageData.value}");
      }
    });
    isLoading.value = false;
    update();
  }
}
