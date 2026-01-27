import 'dart:developer';

import 'package:customer/app/models/referral_model.dart';
import 'package:customer/app/models/user_model.dart';
import 'package:customer/constant/constant.dart';
import 'package:customer/utils/fire_store_utils.dart';
import 'package:get/get.dart';

import '../../../../constant/collection_name.dart';

class ReferralScreenController extends GetxController {
  RxBool isLoading = true.obs;
  Rx<ReferralModel> referralModel = ReferralModel().obs;
  Rx<UserModel> userModel = UserModel().obs;

  @override
  void onInit() {
    getReferralCode();
    super.onInit();
  }

  Future<void> getReferralCode() async {
    try {
      await FireStoreUtils.getReferral().then((value) {
        if (value != null) {
          referralModel.value = value;
          log("Referral Code: ${referralModel.toJson()}");
          isLoading.value = false;
        } else {
          log("No referral data found");
          isLoading.value = false;
        }
      });
    } catch (e) {
      log("Error in referral code: $e");
      isLoading.value = false;
    }
  }

  Future<void> createReferEarnCode() async {
    isLoading.value = true;
    await FireStoreUtils.fireStore.collection(CollectionName.users).doc(FireStoreUtils.getCurrentUid()).get().then((value) {
      if (value.exists) {
        userModel.value = UserModel.fromJson(value.data()!);
      }
    });

    String firstTwoChar = userModel.value.fullName!.substring(0, 2).toUpperCase();

    ReferralModel referralModel =
        ReferralModel(userId: FireStoreUtils.getCurrentUid(), role: Constant.typeCustomer, referralRole: "", referralBy: "", referralCode: Constant.getReferralCode(firstTwoChar));
    await FireStoreUtils.referralAdd(referralModel);
    await getReferralCode();
    isLoading.value = false;
  }
}
