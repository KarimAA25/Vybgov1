import 'package:get/get.dart';

import '../controllers/sos_request_controller.dart';

class SosRequestBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SosRequestController>(
      () => SosRequestController(),
    );
  }
}
