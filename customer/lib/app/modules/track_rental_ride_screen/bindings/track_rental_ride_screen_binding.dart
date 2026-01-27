import 'package:get/get.dart';

import '../controllers/track_rental_ride_screen_controller.dart';

class TrackRentalRideScreenBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TrackRentalRideScreenController>(
      () => TrackRentalRideScreenController(),
    );
  }
}
