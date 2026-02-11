import 'dart:developer';
import 'dart:io';

import 'package:admin/app/constant/collection_name.dart';
import 'package:admin/app/constant/constants.dart';
import 'package:admin/app/models/onBoarding_model.dart';
import 'package:admin/app/utils/fire_store_utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../constant/show_toast.dart';

class OnboardingScreenController extends GetxController {
  RxString title = "OnBoarding".tr.obs;

  Rx<TextEditingController> titleController = TextEditingController().obs;
  Rx<TextEditingController> descriptionController = TextEditingController().obs;
  Rx<TextEditingController> imageNameController = TextEditingController().obs;
  Rx<File> imageFile = File('').obs;
  RxString mimeType = 'image/png'.obs;
  RxBool isLoading = false.obs;
  RxList<OnboardingModel> onBoardingList = <OnboardingModel>[].obs;
  Rx<OnboardingModel> onBoardingModel = OnboardingModel().obs;

  RxString onBoardingType = "Customer".obs;
  final List<String> selectedType = ["Customer", "Driver"];
  RxBool isActive = false.obs;

  RxBool isEditing = false.obs;
  RxBool isImageUpdated = false.obs;
  RxString imageURL = "".obs;
  RxString editingId = "".obs;

  @override
  void onInit() {
    super.onInit();
    getData();
  }

  @override
  void onClose() {
    titleController.value.dispose();
    descriptionController.value.dispose();
    imageNameController.value.dispose();
    super.onClose();
  }

  Future<void> getData() async {
    isLoading.value = true;
    onBoardingList.clear();
    try {
      final onBoardings = await FireStoreUtils.getOnBoarding();
      onBoardingList.assignAll(onBoardings);
    } catch (e, stack) {
      log('Error fetching onBoardings: $e\n$stack');
      ShowToastDialog.errorToast('Failed to load onBoardings');
    } finally {
      isLoading.value = false;
    }
  }

  void setDefaultData() {
    titleController.value.text = "";
    descriptionController.value.text = "";
    imageNameController.value.text = "";
    isEditing.value = false;
    titleController.value.clear();
    descriptionController.value.clear();
    imageNameController.value.clear();
    imageFile.value = File('');
    mimeType.value = 'image/png';
    editingId.value = '';
    isActive.value = false;
    isImageUpdated.value = false;
    imageURL.value = '';
  }

  Future<void> updateOnBoarding(BuildContext context) async {
    Navigator.pop(context);
    isEditing.value = true;
    String docId = onBoardingModel.value.id!;
    String? imageUrl = onBoardingModel.value.image;
    if (imageFile.value.path.isNotEmpty) {
      imageUrl = await FireStoreUtils.uploadPic(PickedFile(imageFile.value.path), "onBoardingsImage", docId, mimeType.value);
      log('image url in update  $imageUrl');
      onBoardingModel.value.image = imageUrl;
    }
    onBoardingModel.value
      ..image = imageUrl
      ..title = titleController.value.text
      ..description = descriptionController.value.text
      ..status = isActive.value
      ..type = onBoardingType.value == "Driver" ? "driver" : "customer"
      ..createdAt = Timestamp.now();
    await FireStoreUtils.updateOnBoarding(onBoardingModel.value);
    setDefaultData();
    await getData();
    isEditing.value = false;
  }

  Future<void> addOnBoarding(BuildContext context) async {
    if (imageFile.value.path.isNotEmpty) {
      Navigator.pop(context);
      isLoading.value = true;
      String docId = Constant.getRandomString(20);
      String url = await FireStoreUtils.uploadPic(PickedFile(imageFile.value.path), "onBoardingsImage".tr, docId, mimeType.value);
      log('image url in addonBoardings  $url');
      onBoardingModel.value.id = docId;
      onBoardingModel.value.image = url;
      onBoardingModel.value.title = titleController.value.text;
      onBoardingModel.value.description = descriptionController.value.text;
      onBoardingModel.value.status = isActive.value;
      onBoardingModel.value.type = onBoardingType.value == "Driver" ? "driver" : "customer";
      onBoardingModel.value.createdAt = Timestamp.now();
      await FireStoreUtils.addOnBoarding(onBoardingModel.value);
      setDefaultData();
      await getData();
      isLoading.value = false;
    } else {
      ShowToastDialog.errorToast("Please select a valid onBoardings image".tr);
    }
  }

  Future<void> removeOnBoarding(OnboardingModel onBoardingModel) async {
    isLoading.value = true;
    await FirebaseFirestore.instance.collection(CollectionName.onBoarding).doc(onBoardingModel.id).delete().then((value) {
      ShowToastDialog.successToast("onBoarding deleted...!".tr);
    }).catchError((error) {
      ShowToastDialog.errorToast("Something went wrong".tr);
    });
    isLoading.value = false;
    getData();
  }
}
