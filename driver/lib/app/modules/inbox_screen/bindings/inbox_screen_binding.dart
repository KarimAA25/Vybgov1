import 'package:get/get.dart';

import '../controllers/inbox_screen_controller.dart';


class InboxScreenBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<InboxScreenController>(
      () => InboxScreenController(),
    );
  }
}
