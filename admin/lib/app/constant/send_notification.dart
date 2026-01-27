// ignore_for_file: depend_on_referenced_packages

import 'dart:convert';
import 'dart:developer';
import 'package:admin/app/constant/constants.dart';
import 'package:admin/app/models/notification_model.dart';
import 'package:admin/app/utils/fire_store_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';

class SendNotification {
  static final _scopes = ['https://www.googleapis.com/auth/firebase.messaging'];

  // Load service account JSON
  static Future getServiceAccountJson() async {
    final response = await http.get(Uri.parse(Constant.jsonFileURL.toString()));
    return json.decode(response.body);
  }

  // Get Access Token for FCM REST API
  static Future<String> getAccessToken() async {
    final jsonData = await getServiceAccountJson();
    final serviceAccountCredentials = ServiceAccountCredentials.fromJson(jsonData);
    final client = await clientViaServiceAccount(serviceAccountCredentials, _scopes);
    return client.credentials.accessToken.data;
  }

  static Future<void> sendOneNotification({
    required String token,
    required String title,
    required String body,
    required String type,
    required Map<String, dynamic> payload,
    String? bookingId,
    String? driverId,
    String? customerId,
    String? senderId,
    bool isBooking = false,
  }) async {
    NotificationModel notificationModel = NotificationModel();
    notificationModel.id = Constant.getUuid();
    notificationModel.type = type;
    notificationModel.title = title;
    notificationModel.description = body;
    notificationModel.bookingId = bookingId;
    notificationModel.customerId = customerId;
    notificationModel.driverId = driverId;
    notificationModel.senderId = senderId;
    notificationModel.createdAt = Timestamp.now();
    await FireStoreUtils.setNotification(notificationModel).then((value) {});

    final String accessToken = await getAccessToken();

    log("token--->$token");
    log("AccessToken--->$accessToken");

    Map<String, dynamic> mergedPayload = {
      ...bookingId != null ? notificationModel.toNotificationJson() : payload,
      'isBooking': isBooking == true ? 'true' : 'false',
    };

    Map<String, dynamic> message = {
      'token': token,
      'notification': {
        'title': title,
        'body': body,
      },
      'data': mergedPayload,
    };

    if (isBooking == true) {
      message['android'] = {
        'notification': {
          'sound': 'booking_notification',
          'channel_id': '0',
        },
      };
      message['apns'] = {
        'payload': {
          'aps': {
            'sound': 'booking_notification.caf',
          },
        },
      };
    }

    await http.post(
      Uri.parse('https://fcm.googleapis.com/v1/projects/${Constant.notificationServerKey}/messages:send'),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
      body: jsonEncode(
        <String, dynamic>{'message': message},
      ),
    );
  }

  // Send Notification to a specific Topic
  static Future<void> sendTopicNotification({
    required String topic,
    required String title,
    required String body,
  }) async {
    final accessToken = await getAccessToken();

    final url = Uri.parse(
      'https://fcm.googleapis.com/v1/projects/${Constant.notificationServerKey}/messages:send',
    );

    final message = {
      'message': {
        'topic': topic, // Example: "drivers" or "customers"
        'notification': {
          'title': title,
          'body': body,
        }
      }
    };

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
      body: jsonEncode(message),
    );

    if (response.statusCode == 200) {
      if (kDebugMode) {
        print('✅ Notification sent successfully to topic: $topic');
      }
    } else {
      if (kDebugMode) {
        print('❌ Failed to send notification: ${response.body}');
      }
    }
  }
}
