import 'package:admin/app/modules/create_zone_screen/controllers/create_zone_screen_controller.dart';
import 'package:get/get.dart';

class CreateZoneScreenBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CreateZoneScreenController>(() => CreateZoneScreenController());
  }
}
