import 'package:get/get.dart';

import '../controllers/email_template_controller.dart';

class EmailTemplateBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<EmailTemplateController>(
      () => EmailTemplateController(),
    );
  }
}
