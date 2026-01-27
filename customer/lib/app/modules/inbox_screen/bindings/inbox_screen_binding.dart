import 'package:customer/app/modules/inbox_screen/controllers/inbox_screen_controller.dart';
import 'package:get/get.dart';


class InboxScreenBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<InboxScreenController>(
      () => InboxScreenController(),
    );
  }
}
