import 'package:admin/app/modules/zone_screen/controllers/zone_screen_controller.dart';
import 'package:get/get.dart';

class ZoneScreenBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ZoneScreenController>(() => ZoneScreenController());
  }
}
