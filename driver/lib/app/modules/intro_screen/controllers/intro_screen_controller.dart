// ignore_for_file: unnecessary_overrides

import 'package:driver/app/models/onboarding_model.dart';
import 'package:driver/utils/fire_store_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

class IntroScreenController extends GetxController {
  PageController pageController = PageController();
  RxInt currentPage = 0.obs;
  RxList<OnBoardingModel> onboardingList = <OnBoardingModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    getOnBoardings();
  }

  Future<void> getOnBoardings() async {
    await FireStoreUtils.getOnboarding().then((value) {
      onboardingList.value = value;
    });
  }
}
