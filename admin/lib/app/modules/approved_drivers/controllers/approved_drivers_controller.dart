import 'dart:developer';

import 'package:admin/app/constant/constants.dart';
import 'package:admin/app/models/driver_user_model.dart';
import 'package:admin/app/utils/fire_store_utils.dart';
import 'package:get/get.dart';

class ApprovedDriversController extends GetxController {
  RxString title = "Approved Drivers".tr.obs;
  RxBool isLoading = true.obs;

  Rx<DriverUserModel> driverUserModel = DriverUserModel().obs;

  var currentPage = 1.obs;
  var startIndex = 1.obs;
  var endIndex = 1.obs;
  var totalPage = 1.obs;
  RxList<DriverUserModel> currentPageVerifyDriver = <DriverUserModel>[].obs;

  @override
  Future<void> onInit() async {
    getData();
    super.onInit();
  }

  Future<void> getData() async {
    totalItemPerPage.value = Constant.numOfPageIemList.first;
    await FireStoreUtils.countVerifiedDriver();
    setPagination(totalItemPerPage.value);
  }

  RxString totalItemPerPage = '0'.obs;

  Future<void> setPagination(String page) async {
    isLoading.value = true;
    totalItemPerPage.value = page;
    int itemPerPage = pageValue(page);
    totalPage.value = (Constant.verifiedDriverLength! / itemPerPage).ceil();
    startIndex.value = (currentPage.value - 1) * itemPerPage;
    endIndex.value = (currentPage.value * itemPerPage) > Constant.verifiedDriverLength! ? Constant.verifiedDriverLength! : (currentPage.value * itemPerPage);
    if (endIndex.value < startIndex.value) {
      currentPage.value = 1;
      setPagination(page);
    } else {
      try {
        List<DriverUserModel> currentPageDriverData = await FireStoreUtils.getVerifiedDriver(currentPage.value, itemPerPage, "", "");
        currentPageVerifyDriver.value = currentPageDriverData;
      } catch (error) {
        log(error.toString());
      }
    }
    update();
    isLoading.value = false;
  }

  int pageValue(String data) {
    if (data == 'All') {
      return Constant.verifiedDriverLength!;
    } else {
      return int.parse(data);
    }
  }
}
