// views/payment_webview.dart
// ignore_for_file: depend_on_referenced_packages

import 'package:driver/payments/xendit/xendit_controller.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:get/get.dart';

class XenditPaymentScreen extends StatelessWidget {
  final String? invoiceUrl;
  final String? transId;
  final String? apiKey;

  const XenditPaymentScreen({super.key, this.invoiceUrl, this.transId, this.apiKey});

  @override
  Widget build(BuildContext context) {
    return GetX(
      init: XenditController(invoiceUrl: invoiceUrl.toString(), transId: transId.toString(), apiKey: apiKey.toString()),
      builder: (controller) {
        return Scaffold(
          appBar: AppBar(title: Text("Xendit Payment")),
          body: controller.isLoading.value ? CircularProgressIndicator() : WebViewWidget(controller: controller.webViewController),
        );
      },
    );
  }
}
