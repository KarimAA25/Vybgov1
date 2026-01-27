import 'package:admin/app/modules/approved_drivers/controllers/approved_drivers_controller.dart';
import 'package:get/get.dart';

class ApprovedDriversBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ApprovedDriversController>(
      () => ApprovedDriversController(),
    );
  }
}
