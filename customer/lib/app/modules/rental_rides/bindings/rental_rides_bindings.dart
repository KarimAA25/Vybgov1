import 'package:customer/app/modules/rental_rides/controllers/rental_rides_controller.dart';
import 'package:get/get.dart';

class RentalRidesBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RentalRidesController>(
          () => RentalRidesController(),
    );
  }
}
