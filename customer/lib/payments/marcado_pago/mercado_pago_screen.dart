// ignore_for_file: depend_on_referenced_packages, deprecated_member_use

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';

class MercadoPagoScreen extends StatefulWidget {
  final String initialURl;
  final String callBackUrl;

  const MercadoPagoScreen({
    super.key,
    required this.initialURl, required this.callBackUrl,
  });

  @override
  State<MercadoPagoScreen> createState() => _MercadoPagoScreenState();
}

class _MercadoPagoScreenState extends State<MercadoPagoScreen> {
  WebViewController controller = WebViewController();

  @override
  void initState() {
    initController();
    super.initState();
  }

  void initController() {
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {},
          onPageStarted: (String url) {},
          onWebResourceError: (WebResourceError error) {},
          onNavigationRequest: (NavigationRequest navigation) async {
            debugPrint("--->2 ${navigation.url}");
            if (navigation.url.contains("${widget.callBackUrl}/success")) {
              Get.back(result: true);
            }
            if (navigation.url.contains("${widget.callBackUrl}/failure") || navigation.url.contains("${widget.callBackUrl}/pending")) {
              Get.back(result: false);
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.initialURl));
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _showMyDialog();
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
            title: const Text("Marcado Pago Payment"),
            centerTitle: false,
            leading: GestureDetector(
              onTap: () {
                _showMyDialog();
              },
              child: const Icon(
                Icons.arrow_back,
                color: Colors.white,
              ),
            )),
        body: WebViewWidget(controller: controller),
      ),
    );
  }

  Future<void> _showMyDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Cancel Payment'.tr),
          content: SingleChildScrollView(
            child: Text("Are you want to cancel the payment?".tr),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'No'.tr,
                style: const TextStyle(color: Colors.red),
              ),
              onPressed: () {
                Navigator.of(context).pop();

              },
            ),
            TextButton(
              child: Text(
                'Yes'.tr,
                style: const TextStyle(color: Colors.green),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                Get.back(result: false);
              },
            ),
          ],
        );
      },
    );
  }
}
