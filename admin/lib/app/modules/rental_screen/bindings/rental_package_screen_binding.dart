import 'package:get/get.dart';

import '../controllers/rental_package_screen_controller.dart';

class RentalPackageScreenBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RentalPackageScreenController>(
      () => RentalPackageScreenController(),
    );
  }
}
