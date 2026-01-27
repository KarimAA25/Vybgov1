import 'package:get/get.dart';

import '../controllers/otp_rental_screen_controller.dart';

class OtpRentalScreenBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<OtpRentalScreenController>(
      () => OtpRentalScreenController(),
    );
  }
}
