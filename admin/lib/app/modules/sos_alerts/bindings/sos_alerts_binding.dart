import 'package:get/get.dart';

import '../controllers/sos_alerts_controller.dart';

class SosAlertsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SosAlertsController>(
      () => SosAlertsController(),
    );
  }
}
