import 'package:admin/app/modules/rental_ride_details/controllers/rental_ride_details_controller.dart';
import 'package:get/get.dart';

class RentalRideDetailsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RentalRideDetailsController>(() => RentalRideDetailsController());
  }
}
