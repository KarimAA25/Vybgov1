
import 'dart:async';

import 'package:customer/app/models/emergency_number_model.dart';
import 'package:customer/constant/constant.dart';
import 'package:customer/constant_widgets/show_toast_dialog.dart';
import 'package:customer/utils/fire_store_utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class EmergencyContactsController extends GetxController {
  StreamSubscription? _emergencySub;
  RxBool isLoading = true.obs;
  RxList<EmergencyContactModel> totalEmergencyContacts = <EmergencyContactModel>[].obs;
  Rx<EmergencyContactModel> contactModel = EmergencyContactModel().obs;

  Rx<TextEditingController> nameController = TextEditingController().obs;
  Rx<TextEditingController> phoneNumberController = TextEditingController().obs;
  Rx<TextEditingController> countryCodeController = TextEditingController(text: Constant.countryCode).obs;
  RxString countryCode = '+91'.obs;

  @override
  void onInit() {
    getEmergencyContacts();
    super.onInit();
  }

  void getEmergencyContacts() {
    isLoading.value = true;
    _emergencySub?.cancel();
    _emergencySub = FireStoreUtils.getEmergencyContacts((updatedList) {
      final uniquePersons = <String, EmergencyContactModel>{};

      for (final person in updatedList) {
        final id = person.id;
        if (id != null && id.isNotEmpty) {
          uniquePersons[id] = person;
        }
      }

      totalEmergencyContacts.value = uniquePersons.values.toList();

      isLoading.value = false;
      update();
    });
  }

  @override
  void onClose() {
    _emergencySub?.cancel();
    super.onClose();
  }

  Future<void> addEmergencyContact() async {
    ShowToastDialog.showLoader("Please wait..".tr);
    final name = nameController.value.text.trim();
    final number = phoneNumberController.value.text.trim();
    if (number.isNotEmpty && totalEmergencyContacts.any((p) => p.phoneNumber == number)) {
      ShowToastDialog.showToast("Person with this number already exists".tr);
      ShowToastDialog.closeLoader();
      return;
    }
    contactModel.value.id = Constant.getUuid();
    contactModel.value.name = name;
    contactModel.value.phoneNumber = number;
    contactModel.value.countryCode = countryCodeController.value.text;
    await FireStoreUtils.addEmergencyContact(contactModel.value).then(
      (value) {
        nameController.value.clear();
        phoneNumberController.value.clear();
        countryCodeController.value.text = Constant.countryCode!;
        ShowToastDialog.showToast("Emergency Contact Added..".tr);
        ShowToastDialog.closeLoader();
        getEmergencyContacts();
      },
    );
  }

  Future<void> deleteEmergencyContact(String personId) async {
    ShowToastDialog.showLoader("Please wait..".tr);

    try {
      final value = await FireStoreUtils.deleteEmergencyContact(personId);

      ShowToastDialog.closeLoader();

      if (value == true) {
        ShowToastDialog.showToast("Emergency Contact Deleted..".tr);
        getEmergencyContacts();
      } else {
        ShowToastDialog.showToast("Failed to delete contact".tr);
      }
    } catch (e) {
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast("Something went wrong".tr);
    }
  }
}
