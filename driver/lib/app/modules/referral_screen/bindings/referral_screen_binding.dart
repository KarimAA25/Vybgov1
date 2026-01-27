import 'package:get/get.dart';

import '../controllers/referral_screen_controller.dart';

class ReferralScreenBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ReferralScreenController>(
      () => ReferralScreenController(),
    );
  }
}
