import 'package:get/get.dart';

import '../controllers/parcel_ride_for_home_controller.dart';

class ParcelRideForHomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ParcelRideForHomeController>(
      () => ParcelRideForHomeController(),
    );
  }
}
