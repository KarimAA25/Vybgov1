import 'dart:convert';
import 'dart:developer';

import 'package:driver/app/models/currencies_model.dart';
import 'package:driver/app/models/driver_user_model.dart';
import 'package:driver/app/models/language_model.dart';
import 'package:driver/constant/constant.dart';
import 'package:driver/extension/hax_color_extension.dart';
import 'package:driver/theme/app_them_data.dart';
import 'package:driver/utils/fire_store_utils.dart';
import 'package:driver/utils/notification_service.dart';
import 'package:driver/utils/preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

import 'services/localization_service.dart';

class GlobalSettingController extends GetxController {
  RxBool isLoading = true.obs;

  @override
  void onInit() {
    getData();
    super.onInit();
  }

  Future<void> getData() async {
    notificationInit();
    await getInterCityService();
    await getCurrentCurrency();
    await getLanguage();
    isLoading.value = false;
    update();
  }

  Future<void> getInterCityService() async {
    await FireStoreUtils.fetchIntercityService();
  }

  Future<void> getCurrentCurrency() async {
    await FireStoreUtils().getCurrency().then((value) {
      if (value != null) {
        Constant.currencyModel = value;
      } else {
        Constant.currencyModel = CurrencyModel(id: "", code: "USD", decimalDigits: 2, active: true, name: "US Dollar", symbol: "\$", symbolAtRight: false);
      }
    });
    await FireStoreUtils().getAdminCommission();
    await FireStoreUtils().getPayment();
    await FireStoreUtils().getSettings();

    AppThemData.primary500 = HexColor.fromHex(Constant.appColor.toString());
  }

  NotificationService notificationService = NotificationService();

  void notificationInit() {
    notificationService.initInfo().then((_) async {
      String token = await NotificationService.getToken();
      log(":::::::TOKEN:::::: $token");
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        DriverUserModel? userModel = await FireStoreUtils.getDriverUserProfile(currentUser.uid);
        if (userModel != null) {
          userModel.fcmToken = token;
          Constant.userModel = userModel;
          await FireStoreUtils.updateDriverUser(userModel);
        }
      }
    });
  }

  Future<void> getLanguage() async {
    try {
      // 1. Check if user has already selected a language (saved in prefs)
      final langStr = await Preferences.getString(Preferences.languageCodeKey);

      if (langStr.isNotEmpty) {
        // Use user's selected language
        final Map<String, dynamic> map = jsonDecode(langStr);
        final LanguageModel languageModel = LanguageModel.fromJson(map);
        LocalizationService().changeLocale(languageModel.code ?? "en");
        return;
      }

      // 2. First time open → get default language from Firestore
      final langs = await FireStoreUtils.getLanguage();

      LanguageModel? defaultLang;

      if (langs.isNotEmpty) {
        // Find language with isDefault == true
        defaultLang = langs.firstWhere(
          (e) => e.isDefault == true,
          orElse: () => LanguageModel(
            id: "CcrGiUvJbPTXaU31s5l8",
            name: "English",
            code: "en",
            active: true,
            isDefault: true,
          ),
        );
      }

      // If still null (no langs at all), fallback to English
      defaultLang ??= LanguageModel(
        id: "CcrGiUvJbPTXaU31s5l8",
        name: "English",
        code: "en",
        active: true,
        isDefault: true,
      );

      // Save default language to Preferences for next time
      await Preferences.setString(
        Preferences.languageCodeKey,
        json.encode(defaultLang.toJson()),
      );

      // Apply language
      LocalizationService().changeLocale(defaultLang.code ?? "en");
    } catch (e) {
      // 3. On any error → fallback to English
      final LanguageModel en = LanguageModel(
        id: "CcrGiUvJbPTXaU31s5l8",
        name: "English",
        code: "en",
        active: true,
        isDefault: true,
      );

      LocalizationService().changeLocale("en");

      await Preferences.setString(
        Preferences.languageCodeKey,
        json.encode(en.toJson()),
      );
    }
  }
}
