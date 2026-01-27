// ignore_for_file: depend_on_referenced_packages
import 'package:admin/app/constant/show_toast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:admin/app/constant/collection_name.dart';
import 'package:admin/app/constant/constants.dart';
import 'package:admin/app/models/language_model.dart';
import 'package:admin/app/modules/dashboard_screen/controllers/dashboard_screen_controller.dart';
import 'package:admin/app/utils/fire_store_utils.dart';

class LanguageController extends GetxController {
  RxString title = "Language".tr.obs;
  Rx<LanguageModel> languageModel = LanguageModel().obs;
  Rx<TextEditingController> languageController = TextEditingController().obs;
  Rx<TextEditingController> codeController = TextEditingController().obs;
  RxBool isEditing = false.obs;
  RxBool isLoading = false.obs;
  RxBool isActive = false.obs;
  RxBool isDefault = false.obs;
  RxList<LanguageModel> languageList = <LanguageModel>[].obs;
  final DashboardScreenController dashboardScreenController = Get.put(DashboardScreenController());

  @override
  void onInit() {
    super.onInit();
    fetchLanguages();
  }

  Future<void> fetchLanguages() async {
    isLoading.value = true;
    try {
      languageList.clear();
      final data = await FireStoreUtils.getLanguage();
      if (data.isNotEmpty) {
        languageList.addAll(data);
      }
    } catch (e) {
      ShowToastDialog.errorToast('Failed to load languages');
    } finally {
      isLoading.value = false;
    }
  }

  void setDefaultData() {
    languageController.value.clear();
    codeController.value.clear();
    isEditing.value = false;
    isActive.value = false;
    isDefault.value = false;
    languageModel.value = LanguageModel();
  }

  @override
  void onClose() {
    languageController.value.dispose();
    codeController.value.dispose();
    super.onClose();
  }

  Future<bool> setDefaultLanguage(LanguageModel selectedLang, bool value) async {
    // Turning OFF default
    if (!value) {
      final int defaultCount = languageList.where((e) => e.isDefault == true).length;

      // If this is the only default, don't allow turning it off
      if (defaultCount <= 1 && (selectedLang.isDefault ?? false)) {
        ShowToastDialog.errorToast(
          "At least one default language is required".tr,
        );
        return false;
      }

      selectedLang.isDefault = false;
      await FireStoreUtils.updateLanguage(selectedLang);
      await dashboardScreenController.getLanguage();
      await fetchLanguages();
      return true;
    }

    // Turning ON default => this one becomes default+active, all others not default
    for (final lang in languageList) {
      if (lang.id == selectedLang.id) {
        lang.isDefault = true;
        lang.active = true; // default must be active
      } else {
        lang.isDefault = false;
      }
      await FireStoreUtils.updateLanguage(lang);
    }

    await dashboardScreenController.getLanguage();
    await fetchLanguages();
    return true;
  }

  Future<void> updateLanguage() async {
    languageModel.value.name = languageController.value.text;
    languageModel.value.code = codeController.value.text;
    languageModel.value.active = isActive.value;
    languageModel.value.isDefault = isDefault.value;

    // First update this language
    await FireStoreUtils.updateLanguage(languageModel.value);

    if (languageModel.value.isDefault == true) {
      // Enforce only-one-default rule
      await setDefaultLanguage(languageModel.value, true);
    } else {
      await dashboardScreenController.getLanguage();
      await fetchLanguages();
    }

    ShowToastDialog.successToast("Language Updated successfully".tr);
  }

  Future<void> addLanguage() async {
    isLoading = true.obs;
    languageModel.value.id = Constant.getRandomString(20);
    languageModel.value.name = languageController.value.text;
    languageModel.value.code = codeController.value.text;
    languageModel.value.active = isActive.value;
    languageModel.value.isDefault = isDefault.value;

    await FireStoreUtils.addLanguage(languageModel.value);

    if (languageModel.value.isDefault == true) {
      await setDefaultLanguage(languageModel.value, true);
    } else {
      await dashboardScreenController.getLanguage();
      await fetchLanguages();
    }

    ShowToastDialog.successToast("Language added successfully".tr);
    isLoading = false.obs;
  }

  Future<void> removeLanguage(LanguageModel languageModel) async {
    isLoading = true.obs;

    final bool wasDefault = languageModel.isDefault ?? false;

    await FirebaseFirestore.instance.collection(CollectionName.languages).doc(languageModel.id).delete().then((value) {
      ShowToastDialog.successToast("Language deleted...!".tr);
    }).catchError((error) {
      ShowToastDialog.errorToast("Something went wrong".tr);
    });

    await fetchLanguages();

    if (wasDefault && languageList.isNotEmpty) {
      LanguageModel newDefault = languageList.firstWhere(
        (e) => e.active == true,
        orElse: () => languageList.first,
      );

      newDefault.isDefault = true;
      newDefault.active = true;
      await FireStoreUtils.updateLanguage(newDefault);
    }

    await dashboardScreenController.getLanguage();
    isLoading = false.obs;
  }
}
