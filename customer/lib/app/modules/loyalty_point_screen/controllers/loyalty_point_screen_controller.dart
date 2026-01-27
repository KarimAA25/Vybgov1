import 'dart:developer';

import 'package:customer/app/models/loyalty_point_transaction_model.dart';
import 'package:customer/app/models/user_model.dart';
import 'package:customer/constant_widgets/show_toast_dialog.dart';
import 'package:customer/utils/fire_store_utils.dart';
import 'package:get/get.dart';

class LoyaltyPointScreenController extends GetxController {
  RxBool isLoading = true.obs;
  Rx<UserModel> userModel = UserModel().obs;
  RxList<LoyaltyPointTransactionModel> loyaltyPointList = <LoyaltyPointTransactionModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    getData();
  }

  Future<void> getData() async {
    UserModel? data = await FireStoreUtils.getUserProfile(FireStoreUtils.getCurrentUid());
    if (data != null) {
      userModel.value = data;
      log("User Data: ${userModel.toJson()}");
      getLoyaltyPointTransactionsList();
    } else {
      ShowToastDialog.toast("No user data found for the current UID.".tr);
      log("No user data found for the current UID.");
    }
  }

  Future<void> getLoyaltyPointTransactionsList() async {
    final value = await FireStoreUtils.getLoyaltyPointTransaction();
    if (value != null) {
      loyaltyPointList.value = value;
    } else {
      loyaltyPointList.clear();
    }
    log("Loyalty Points: ${loyaltyPointList.length}");
  }
}
