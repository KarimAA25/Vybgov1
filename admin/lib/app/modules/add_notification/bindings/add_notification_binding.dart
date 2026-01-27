import 'package:get/get.dart';

import '../controllers/add_notification_controller.dart';

class AddNotificationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AddNotificationController>(
      () => AddNotificationController(),
    );
  }
}
