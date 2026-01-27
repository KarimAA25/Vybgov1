import 'package:get/get.dart';

import '../controllers/online_driver_controller.dart';

class OnlineDriverBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<OnlineDriverController>(
      () => OnlineDriverController(),
    );
  }
}
