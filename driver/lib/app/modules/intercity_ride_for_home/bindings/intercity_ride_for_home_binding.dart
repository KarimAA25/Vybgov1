import 'package:get/get.dart';

import '../controllers/intercity_ride_for_home_controller.dart';

class IntercityRideForHomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<IntercityRideForHomeController>(
      () => IntercityRideForHomeController(),
    );
  }
}
