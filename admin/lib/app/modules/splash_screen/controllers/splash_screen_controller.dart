import 'dart:developer';
import 'dart:ui';

import 'package:admin/app/constant/constants.dart';
import 'package:admin/app/models/language_model.dart';
import 'package:admin/app/utils/fire_store_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../../../routes/app_pages.dart';

class SplashScreenController extends GetxController {
  RxBool isLoading = true.obs;
  RxList<LanguageModel> languageList = <LanguageModel>[].obs;
  Rx<LanguageModel> selectedLanguage = LanguageModel().obs;

  @visibleForTesting
  static String routeForLoginState({required bool isLoggedIn}) {
    return isLoggedIn ? Routes.DASHBOARD_SCREEN : Routes.LOGIN_PAGE;
  }

  @override
  Future<void> onInit() async {
    await getData();
    Constant.getLanguageData();
    getLanguage();
    super.onInit();
  }

  Future<void> getData() async {
    isLoading.value = true;
    await FireStoreUtils.getSettings();
    await FireStoreUtils.getPayment();
    bool isLogin = await FireStoreUtils.isLogin();

    final targetRoute = routeForLoginState(isLoggedIn: isLogin);

    if (!isLogin && Get.currentRoute != Routes.LOGIN_PAGE) {
      Get.offAllNamed(targetRoute);
    } else if (isLogin) {
      final admin = await FireStoreUtils.getAdmin();
      if (admin != null) {
        Constant.isDemoSet(admin);
      }
      // Only navigate if currently in splash
      if (Get.currentRoute == Routes.SPLASH_SCREEN || Get.currentRoute.isEmpty) {
        Get.offAllNamed(targetRoute);
      }
    }

    isLoading.value = false;
  }

  Future<void> getLanguage() async {
    isLoading.value = true;

    try {
      // 1) Load all languages from Firestore
      languageList.value = await FireStoreUtils.getLanguage();

      if (languageList.isEmpty) {
        isLoading.value = false;
        return;
      }

      // 2) Find default language from Firestore
      LanguageModel? selected = languageList.firstWhere(
        (l) => l.isDefault == true,
        orElse: () => languageList.first,
      );

      // 3) Set selected language
      selectedLanguage.value = selected;

      // 4) Update Locale
      try {
        final locale = Locale(selected.code ?? "en");
        Get.updateLocale(locale);
      } catch (e) {
        log("Locale update error: $e");
      }
    } catch (e) {
      log("error in getLanguage: $e");
    }

    isLoading.value = false;
  }
}
