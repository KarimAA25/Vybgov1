import 'package:driver/app/modules/reason_for_cancel_rental_ride/controllers/reason_for_cancel_rental_ride_controller.dart';
import 'package:get/get.dart';

class ReasonForCancelRentalRideBinding extends Bindings{
  @override
  void dependencies() {
    Get.lazyPut<ReasonForCancelRentalRideController>(()=>ReasonForCancelRentalRideController());
  }
}