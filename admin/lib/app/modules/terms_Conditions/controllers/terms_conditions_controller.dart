import 'package:admin/app/utils/fire_store_utils.dart';
import 'package:get/get.dart';
import 'package:html_editor_enhanced/html_editor.dart';

class TermsConditionsController extends GetxController {
  Rx<HtmlEditorController> htmlEditorController = HtmlEditorController().obs;

  RxBool isLoading = true.obs;
  RxString title = "Terms & Condition".tr.obs;

  RxString termsConditionText = ''.obs;
  RxString selectedUserType = 'Customer'.obs;
  List<String> userTypeList = ["Customer", "Driver"];

  @override
  void onInit() {
    getSettingData();
    super.onInit();
  }

  Future<void> getSettingData() async {
    await FireStoreUtils.getTermsAndCondition(selectedUserType.value.toLowerCase()).then((value) {
      if (value != null) {
        termsConditionText.value = value;
        htmlEditorController.value.clear();
        htmlEditorController.value.insertHtml(termsConditionText.value);
      }
    });
    isLoading.value = false;
    update();
  }
}
