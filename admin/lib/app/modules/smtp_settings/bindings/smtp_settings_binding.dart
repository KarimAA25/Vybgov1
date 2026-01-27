import 'package:get/get.dart';

import '../controllers/smtp_settings_controller.dart';

class SmtpSettingsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SmtpSettingsController>(
      () => SmtpSettingsController(),
    );
  }
}
