import 'dart:convert';
import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:customer/app/models/currencies_model.dart';
import 'package:customer/app/models/language_model.dart';
import 'package:customer/constant/constant.dart';
import 'package:customer/extension/hax_color_extension.dart';
import 'package:customer/services/localization_service.dart';
import 'package:customer/theme/app_them_data.dart';
import 'package:customer/utils/preferences.dart';
import 'package:customer/utils/fire_store_utils.dart';
import 'package:customer/utils/notification_service.dart';

class GlobalSettingController extends GetxController {
  @override
  void onInit() {
    notificationInit();
    getCurrentCurrency();
    getLanguage();
    super.onInit();
  }

  Future<void> getCurrentCurrency() async {
    await FireStoreUtils().getSettings();
    await FireStoreUtils().getCurrency().then((value) {
      if (value != null) {
        Constant.currencyModel = value;
      } else {
        Constant.currencyModel = CurrencyModel(id: "", code: "USD", decimalDigits: 2, active: true, name: "US Dollar", symbol: "\$", symbolAtRight: false);
      }
    });
    await FireStoreUtils().getPayment();
    AppThemData.primary500 = HexColor.fromHex(Constant.appColor.toString());
  }

  NotificationService notificationService = NotificationService();

  void notificationInit() {
    notificationService.initInfo().then((value) async {
      String token = await NotificationService.getToken();
      log(":::::::TOKEN:::::: $token");
      if (FirebaseAuth.instance.currentUser != null) {
        final uid = FireStoreUtils.getCurrentUid();
        final userModel = await FireStoreUtils.getUserProfile(uid);
        if (userModel != null) {
          if (userModel.fcmToken != token) {
            userModel.fcmToken = token;
            Constant.userModel = userModel;
            await FireStoreUtils.updateUser(userModel);
          } else {
            Constant.userModel = userModel;
          }
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
