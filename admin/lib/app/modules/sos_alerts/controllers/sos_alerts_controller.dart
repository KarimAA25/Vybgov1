import 'dart:developer';

import 'package:admin/app/components/dialog_box.dart';
import 'package:admin/app/constant/collection_name.dart';
import 'package:admin/app/constant/constants.dart';
import 'package:admin/app/constant/send_notification.dart';
import 'package:admin/app/constant/show_toast.dart';
import 'package:admin/app/models/sos_alerts_model.dart';
import 'package:admin/app/utils/fire_store_utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'dart:html' as html;
import 'package:url_launcher/url_launcher.dart';

class SosAlertsController extends GetxController {
  RxBool isLoading = true.obs;
  RxString title = "SOS Alerts".tr.obs;

  RxList<SOSAlertsModel> sosAlertsList = <SOSAlertsModel>[].obs;

  @override
  void onInit() {
    getData();
    super.onInit();
  }

  Future<void> getData() async {
    FirebaseFirestore.instance.collection(CollectionName.sosAlerts).orderBy('createdAt', descending: true).snapshots().listen((snapshot) {
      sosAlertsList.value = snapshot.docs.map((doc) => SOSAlertsModel.fromJson(doc.data())).toList();

      isLoading.value = false;
    });
  }

  Future<void> openMapUrl(String url) async {
    if (kIsWeb) {
      // ✅ Flutter Web
      // ignore: undefined_prefixed_name
      html.window.open(url, '_blank');
    } else {
      // ✅ Mobile (Android / iOS)
      final Uri uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
      }
    }
  }

  Future<void> updateStatus(String id, String status, SOSAlertsModel sosAlerts) async {
    ShowToastDialog.showLoader("Please wait..".tr);
    if (Constant.isDemo) {
      DialogBox.demoDialogBox();
      return;
    }

    try {
      isLoading.value = true;
      await FirebaseFirestore.instance.collection(CollectionName.sosAlerts).doc(id).update({'status': status});
      await sendSosNotification(
        sosAlerts: sosAlerts,
        status: status,
      );

      ShowToastDialog.successToast("SOS status updated".tr);
      getData();
      ShowToastDialog.closeLoader();
      Get.back();
    } catch (e) {
      ShowToastDialog.errorToast("Something went wrong".tr);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> sendSosNotification({
    required SOSAlertsModel sosAlerts,
    required String status,
  }) async {
    Map<String, dynamic> payload = {
      "bookingId": sosAlerts.bookingId ?? "",
      "type": "sos",
    };

    String title = "SOS Update";
    String body = "";

    switch (status) {
      case "in-progress":
        body = "Your SOS request #${sosAlerts.id!.substring(0, 5)} is being handled by the admin.";
        break;
      case "resolved":
        body = "Your SOS request #${sosAlerts.id!.substring(0, 5)} has been resolved successfully.";
        break;
      case "cancelled":
        body = "Your SOS request #${sosAlerts.id!.substring(0, 5)} has been cancelled by the admin.";
        break;
      default:
        body = "SOS status updated.";
    }

    // 🔹 CUSTOMER SOS
    if (sosAlerts.type == "customer") {
      final user = await FireStoreUtils.getCustomerByCustomerID(
        sosAlerts.userId.toString(),
      );

      if (user?.fcmToken != null && user!.fcmToken!.isNotEmpty) {
        await SendNotification.sendOneNotification(
          isBooking: false,
          token: user.fcmToken!,
          title: title,
          body: body,
          type: "sos-$status",
          payload: payload,
          senderId: FireStoreUtils.getCurrentUid(),
          bookingId: sosAlerts.bookingId ?? "",
        );
      }
    }

    // 🔹 DRIVER SOS
    if (sosAlerts.type == "driver") {
      final driver = await FireStoreUtils.getDriverByDriverID(
        sosAlerts.driverId.toString(),
      );

      if (driver?.fcmToken != null && driver!.fcmToken!.isNotEmpty) {
        await SendNotification.sendOneNotification(
          isBooking: false,
          token: driver.fcmToken!,
          title: title,
          body: body,
          type: "sos-$status",
          payload: payload,
          senderId: FireStoreUtils.getCurrentUid(),
          driverId: driver.id.toString(),
          bookingId: sosAlerts.bookingId ?? "",
        );
      }
    }
  }
}
