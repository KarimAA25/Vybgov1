import 'package:get/get.dart';

import '../controllers/map_settings_controller.dart';

class MapSettingsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MapSettingsController>(
      () => MapSettingsController(),
    );
  }
}
