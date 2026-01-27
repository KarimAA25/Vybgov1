import 'dart:developer';
import 'dart:ui';

import 'package:customer/app/models/sos_alerts_model.dart';
import 'package:customer/theme/app_them_data.dart';
import 'package:customer/utils/fire_store_utils.dart';
import 'package:get/get.dart';

class SosRequestController extends GetxController {
  RxList<SOSAlertsModel> sosList = <SOSAlertsModel>[].obs;
  Rx<SOSAlertsModel> sosModel = SOSAlertsModel().obs;
  RxBool isLoading = true.obs;

  @override
  void onInit() {
    getSos();
    super.onInit();
  }

  Future<void> getSos() async {
    isLoading.value = true;
    await FireStoreUtils.getSOSRequest().then((value) {
      sosList.value = value!;
      log("ListSOS:::${sosList.length}");
    });
    isLoading.value = false;
  }

  Color getStatusColor(String status) {
    switch (status) {
      case "pending":
        return AppThemData.info500;
      case "cancelled":
        return AppThemData.danger_500p;
      case "in-progress":
        return AppThemData.warning500;
      default:
        return AppThemData.success08;
    }
  }

}
