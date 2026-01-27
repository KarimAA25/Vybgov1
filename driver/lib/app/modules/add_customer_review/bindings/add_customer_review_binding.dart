import 'package:driver/app/modules/add_customer_review/controllers/add_customer_review_controller.dart';
import 'package:get/get.dart';

class AddCustomerReviewBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AddCustomerReviewController>(() => AddCustomerReviewController());
  }
}
