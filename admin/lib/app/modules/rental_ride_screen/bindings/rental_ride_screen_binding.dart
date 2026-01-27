import 'package:admin/app/modules/rental_ride_screen/controllers/rental_ride_screen_controller.dart';
import 'package:get/get.dart';

class RentalRideScreenBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RentalRideScreenController>(() => RentalRideScreenController());
  }
}
