import 'package:admin/app/modules/business_model_setting/controllers/business_model_setting_controller.dart';
import 'package:get/get.dart';

class BusinessModelSettingBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<BusinessModelSettingController>(() => BusinessModelSettingController());
  }
}
