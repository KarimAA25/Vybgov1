import 'package:get/get.dart';

import '../controllers/ask_for_otp_rental_controller.dart';

class AskForOtpRentalBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AskForOtpRentalController>(
      () => AskForOtpRentalController(),
    );
  }
}
