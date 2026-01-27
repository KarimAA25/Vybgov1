// ignore_for_file: depend_on_referenced_packages

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:customer/app/models/email_template_model.dart';
import 'package:customer/app/models/smtp_setting_model.dart';
import 'package:customer/constant/collection_name.dart';
import 'package:flutter/foundation.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

class EmailTemplateService {
  static Future<void> sendEmail({
    required String type,
    required Map<String, String> variables,
    required String toEmail,
  }) async {
    try {
      // 1. Load SMTP settings from Firestore
      DocumentSnapshot smtpSnapshot = await FirebaseFirestore.instance.collection(CollectionName.settings).doc('smtp_settings').get();

      SMTPSettingModel smtp = SMTPSettingModel.fromJson(smtpSnapshot.data() as Map<String, dynamic>);

      // 2. Load the email template
      QuerySnapshot templateSnapshot = await FirebaseFirestore.instance.collection(CollectionName.emailTemplate).where('type', isEqualTo: type).get();

      if (templateSnapshot.docs.isEmpty) {
        if (kDebugMode) {
          print('No email template found for type: $type');
        }
        return;
      }

      EmailTemplateModel template = EmailTemplateModel.fromJson(templateSnapshot.docs.first.data() as Map<String, dynamic>);

      if (template.status != true) {
        if (kDebugMode) {
          print('Email template for "$type" is inactive. Skipping send.');
        }
        return;
      }

      // 3. Replace placeholders with dynamic values
      String subject = _replacePlaceholders(template.subject ?? '', variables);
      String body = _replacePlaceholders(template.body ?? '', variables);

      // 4. Setup mailer using Gmail helper
      final smtpServer = gmail(
        smtp.username!, // your Gmail address
        smtp.password!, // **App Password**, not normal Gmail password
      );

      final message = Message()
        ..from = Address(smtp.username!, 'MyTaxi')
        ..recipients.add(toEmail)
        ..subject = subject
        ..html = body;

      // 5. Send email
      final sendReport = await send(message, smtpServer);
      if (kDebugMode) {
        print('Email sent: ${sendReport.toString()}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Email sending error: $e');
      }
    }
  }

  static String _replacePlaceholders(String text, Map<String, String> variables) {
    String updated = text;
    variables.forEach((key, value) {
      updated = updated.replaceAll('{{$key}}', value);
    });
    return updated;
  }
}
