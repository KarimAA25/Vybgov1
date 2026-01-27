import 'dart:developer';

import 'package:admin/app/constant/collection_name.dart';
import 'package:admin/app/models/email_template_model.dart';
import 'package:admin/app/utils/fire_store_utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:html_editor_enhanced/html_editor.dart';

class EmailTemplateController extends GetxController {
  RxBool isLoading = false.obs;
  RxString title = "Email Templates".tr.obs;

  RxString initialBody = ''.obs;
  Rx<HtmlEditorController> htmlEditorController = HtmlEditorController().obs;
  Rx<TextEditingController> subjectController = TextEditingController().obs;

  RxList<EmailTemplateModel> emailTemplatesList = <EmailTemplateModel>[].obs;

  @override
  void onInit() {
    getData();
    super.onInit();
  }

  Future<void> getData() async {
    isLoading.value = true;
    emailTemplatesList.clear();
    try {
      List<EmailTemplateModel> data = await FireStoreUtils.getEmailTemplate();

      if (data.isNotEmpty) {
        emailTemplatesList.addAll(data);
        log("✅ Loaded ${data.length} email templates from Firestore.");
      } else {
        log("⚠️ No email templates found in Firestore. Saving default templates...");
        await addDefaultTemplate();
        emailTemplatesList.addAll(_defaultTemplates);
      }
    } catch (e) {
      log("❌ Error in get Email template : $e");
      // If Firestore fails, still show default list
      emailTemplatesList.addAll(_defaultTemplates);
    } finally {
      isLoading.value = false;
    }
  }

  List<EmailTemplateModel> get _defaultTemplates => [
        EmailTemplateModel(
          id: 'signup',
          type: 'signup',
          subject: 'Welcome to My Taxi, {{name}}!',
          status: true,
          body: '''
            <h1>Hello {{name}}</h1>
            <p>Thank you for signing up. We are excited to have you onboard.</p>
            <p>Login here: <a href="{{login_link}}">Click Here</a></p>
          ''',
        ),
        EmailTemplateModel(
          id: 'wallet_topup',
          type: 'wallet_topup',
          subject: 'Wallet Top-Up Successful!',
          status: true,
          body: '''
            <h1>Hi {{name}}</h1>
            <p>Your wallet has been topped up with {{amount}}.</p>
            <p>Current Balance: {{balance}}</p>
          ''',
        ),
        EmailTemplateModel(
          id: 'booking_completed',
          type: 'booking_completed',
          subject: 'Booking Completed - {{booking_id}}',
          status: true,
          body: '''
            <h1>Hi {{name}}</h1>
            <p>Your booking with ID {{booking_id}} has been confirmed.</p>
            <p>Pickup: {{pickup_location}}</p>
            <p>Drop: {{drop_location}}</p>
            <p>Date & Time: {{booking_time}}</p>
          ''',
        ),
        EmailTemplateModel(
          id: 'withdraw_request',
          type: 'withdraw_request',
          subject: 'Withdrawal Request Received',
          status: true,
          body: '''
            <h1>Hi {{name}}</h1>
            <p>Your withdrawal request of {{amount}} has been received.</p>
          ''',
        ),
        EmailTemplateModel(
          id: 'withdraw_complete',
          type: 'withdraw_complete',
          subject: 'Withdrawal Completed',
          status: true,
          body: '''
            <h1>Hi {{name}}</h1>
            <p>Your withdrawal of {{amount}} has been successfully processed.</p>
          ''',
        ),
        EmailTemplateModel(
          id: 'refer_and_earn',
          type: 'refer_and_earn',
          subject: 'You Earned Rewards!',
          status: true,
          body: '''
            <h1>Hi {{name}}</h1>
            <p>You referred {{referral_name}} and earned {{amount}} rewards.</p>
          ''',
        ),
      ];

  Future<void> addDefaultTemplate() async {
    try {
      for (var template in _defaultTemplates) {
        await FirebaseFirestore.instance.collection(CollectionName.emailTemplate).doc(template.id).set(template.toJson());
      }
      if (kDebugMode) {
        print('✅ Default email templates saved to Firestore.');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error saving default templates: $e');
      }
    }
  }
}
