import 'package:get/get.dart';

import '../controllers/loyalty_point_screen_controller.dart';

class LoyaltyPointScreenBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LoyaltyPointScreenController>(
      () => LoyaltyPointScreenController(),
    );
  }
}
