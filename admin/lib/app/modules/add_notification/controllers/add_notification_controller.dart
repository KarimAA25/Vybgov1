import 'dart:developer';

import 'package:admin/app/constant/collection_name.dart';
import 'package:admin/app/constant/constants.dart';
import 'package:admin/app/constant/send_notification.dart';
import 'package:admin/app/constant/show_toast.dart';
import 'package:admin/app/models/push_notification_model.dart';
import 'package:admin/app/utils/fire_store_utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddNotificationController extends GetxController {
  RxString title = 'Push Notification'.tr.obs;
  RxBool isLoading = false.obs;
  Rx<PushNotificationModel> notificationModel = PushNotificationModel().obs;
  RxList<PushNotificationModel> notificationScreenList = <PushNotificationModel>[].obs;
  Rx<TextEditingController> titleController = TextEditingController().obs;
  Rx<TextEditingController> descriptionController = TextEditingController().obs;
  List<String> userType = ["Customer", "Driver"];
  RxString selectedUserType = "Customer".obs;

  @override
  void onInit() {
    getData();
    super.onInit();
  }

  Future<void> getData() async {
    isLoading(true);
    notificationScreenList.clear();
    List<PushNotificationModel> data = await FireStoreUtils.getPushNotification();
    notificationScreenList.addAll(data);
    isLoading(false);
  }

  void setDefaultData() {
    titleController.value.text = "";
    descriptionController.value.text = "";
    selectedUserType.value = "Customer";
  }

  void getArgument(PushNotificationModel notification) {
    notificationModel.value = notification;
    titleController.value.text = notificationModel.value.title!;
    descriptionController.value.text = notificationModel.value.description!;
    selectedUserType.value = notificationModel.value.type == "customer" ? "Customer" : "Driver";
  }

  Future<void> addNotificationScreen() async {
    ShowToastDialog.showLoader("Please wait..".tr);
    notificationModel.value.id = Constant.getRandomString(20);
    notificationModel.value.title = titleController.value.text;
    notificationModel.value.description = descriptionController.value.text;
    notificationModel.value.type = selectedUserType.value == "Customer" ? "customer" : "driver";
    notificationModel.value.createdAt = Timestamp.now();

    await FireStoreUtils.addPushNotification(notificationModel.value).then((value) {
      if (value == true) {
        Get.back();
        getData();
        ShowToastDialog.closeLoader();
        ShowToastDialog.successToast("Notification Send Successfully.".tr);
        SendNotification.sendTopicNotification(
          topic: selectedUserType.value == "Customer" ? "mytaxi-customer" : "mytaxi-driver",
          title: titleController.value.text,
          body: descriptionController.value.text,
        );
        setDefaultData();
      }
    });
    isLoading.value = false;
  }

  Future<void> resendNotification(PushNotificationModel notification) async {
    ShowToastDialog.showLoader("Please wait..".tr);
    try {
      log("Resending notification to ${notification.type} users");
      // Just send the existing notification again
      SendNotification.sendTopicNotification(
        topic: notification.type == "customer" ? "mytaxi-customer" : "mytaxi-driver",
        title: notification.title ?? "",
        body: notification.description ?? "",
      );

      ShowToastDialog.closeLoader();
      ShowToastDialog.successToast("Notification Resent Successfully.".tr);
    } catch (e) {
      ShowToastDialog.closeLoader();
      ShowToastDialog.errorToast("Failed to resend notification.".tr);
    }
  }

  Future<void> removeNotification(PushNotificationModel notificationModel) async {
    ShowToastDialog.showLoader("Please wait..".tr);
    await FirebaseFirestore.instance.collection(CollectionName.notificationFromAdmin).doc(notificationModel.id).delete().then((value) {
      ShowToastDialog.closeLoader();
      getData();
      ShowToastDialog.successToast("Notification Screen  deleted...!".tr);
    }).catchError((error) {
      ShowToastDialog.closeLoader();
      ShowToastDialog.errorToast("An error occurred. Please try again.".tr);
    });
    isLoading = false.obs;
  }
}
