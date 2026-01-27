// ignore_for_file: depend_on_referenced_packages, strict_top_level_inference

import 'dart:developer';

import 'package:admin/app/constant/constants.dart';
import 'package:admin/app/constant/show_toast.dart';
import 'package:admin/app/models/driver_user_model.dart';
import 'package:admin/app/models/verify_driver_model.dart';
import 'package:admin/app/utils/fire_store_utils.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class VerifyDriverScreenController extends GetxController {
  RxString title = "Approval Pending Drivers".tr.obs;
  RxBool isLoading = true.obs;

  RxList<VerifyDocumentModel> verifyDocumentList = <VerifyDocumentModel>[].obs;
  Rx<DriverUserModel> driverUserModel = DriverUserModel().obs;

  var currentPage = 1.obs;
  var startIndex = 1.obs;
  var endIndex = 1.obs;
  var totalPage = 1.obs;
  RxList<DriverUserModel> currentPageVerifyDriver = <DriverUserModel>[].obs;

  Rx<TextEditingController> dateFiledController = TextEditingController().obs;
  RxString editingVerifyDocumentId = "".obs;

  @override
  void onInit() {
    totalItemPerPage.value = Constant.numOfPageIemList.first;
    getData();
    dateFiledController.value.text = "${DateFormat('yyyy-MM-dd').format(selectedDate.value.start)} to ${DateFormat('yyyy-MM-dd').format(selectedDate.value.end)}";
    super.onInit();
  }

  void getArgument(DriverUserModel driverModel) {
    driverUserModel.value = driverModel;
    editingVerifyDocumentId.value = driverUserModel.value.id!;
    verifyDocumentList.value = driverUserModel.value.verifyDocument!;
  }

  Future<void> getData() async {
    isLoading.value = true;
    await FireStoreUtils.countUnVerifiedDriver();
    setPagination(totalItemPerPage.value);
    isLoading.value = false;
  }

  Future<void> setPagination(String page) async {
    isLoading.value = true;
    totalItemPerPage.value = page;
    int itemPerPage = pageValue(page);
    totalPage.value = (Constant.unVerifiedDriverLength! / itemPerPage).ceil();
    startIndex.value = (currentPage.value - 1) * itemPerPage;
    endIndex.value = (currentPage.value * itemPerPage) > Constant.unVerifiedDriverLength! ? Constant.unVerifiedDriverLength! : (currentPage.value * itemPerPage);
    if (endIndex.value < startIndex.value) {
      currentPage.value = 1;
      setPagination(page);
    } else {
      try {
        List<DriverUserModel> currentPageDriverData = await FireStoreUtils.getUnverifiedDriver(currentPage.value, itemPerPage, "", "");
        currentPageVerifyDriver.value = currentPageDriverData;
      } catch (error) {
        log(error.toString());
      }
    }
    update();
    isLoading.value = false;
  }

  Rx<DateTimeRange> selectedDate =
      DateTimeRange(start: DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 0, 0, 0), end: DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 23, 59, 0))
          .obs;

  RxString totalItemPerPage = '0'.obs;

  int pageValue(String data) {
    if (data == 'All') {
      return Constant.unVerifiedDriverLength!;
    } else {
      return int.parse(data);
    }
  }

  Future<void> saveData() async {
    isLoading.value = true;
    int trueCount = verifyDocumentList.where((e) => e.isVerify == true).length;

    driverUserModel.update((val) {
      if (val == null) return;
      val.isVerified = (trueCount == verifyDocumentList.length);
    });

    await FireStoreUtils.updateDriver(driverUserModel.value);

    isLoading.value = false;
    ShowToastDialog.successToast("Status Updated".tr);
    getData();
  }
}
