import 'package:get/get.dart';

import '../controllers/rental_select_location_controller.dart';

class RentalLocationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RentalSelectLocationController>(
      () => RentalSelectLocationController(),
    );
  }
}
