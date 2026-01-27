
import 'package:driver/app/models/driver_user_model.dart';
import 'package:driver/app/models/referral_model.dart';
import 'package:driver/constant/collection_name.dart';
import 'package:driver/constant/constant.dart';
import 'package:driver/utils/fire_store_utils.dart';
import 'package:get/get.dart';

class ReferralScreenController extends GetxController {
  RxBool isLoading = true.obs;
  Rx<ReferralModel> referralModel = ReferralModel().obs;
  Rx<DriverUserModel> driverUserModel = DriverUserModel().obs;

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
          isLoading.value = false;
        } else {
          isLoading.value = false;
        }
      });
    } catch (e) {
      isLoading.value = false;
    }
  }

  Future<void> createReferEarnCode() async {
    isLoading.value = true;
    await FireStoreUtils.fireStore.collection(CollectionName.drivers).doc(FireStoreUtils.getCurrentUid()).get().then((value) {
      if (value.exists) {
        driverUserModel.value = DriverUserModel.fromJson(value.data()!);
      }
    });

    String firstTwoChar = driverUserModel.value.fullName!.substring(0, 2).toUpperCase();

    ReferralModel referralModel =
        ReferralModel(userId: FireStoreUtils.getCurrentUid(), role: Constant.typeDriver, referralRole: "", referralBy: "", referralCode: Constant.getReferralCode(firstTwoChar));
    await FireStoreUtils.referralAdd(referralModel);
    await getReferralCode();
    isLoading.value = false;
  }
}
