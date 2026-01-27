import 'package:get/get.dart';

import '../controllers/rental_reason_for_cancel_controller.dart';

class RentalReasonForCancelBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RentalReasonForCancelController>(
      () => RentalReasonForCancelController(),
    );
  }
}
