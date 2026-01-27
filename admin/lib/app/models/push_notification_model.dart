// ignore_for_file: depend_on_referenced_packages
import 'package:cloud_firestore/cloud_firestore.dart';

class PushNotificationModel {
  String? id;
  String? title;
  String? description;
  String? type;
  Timestamp? createdAt;

  PushNotificationModel({this.id, this.title, this.description, this.type, this.createdAt});

  PushNotificationModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    description = json['description'];
    type = json['type'];
    createdAt = json['createdAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['title'] = title;
    data['description'] = description;
    data['type'] = type;
    data['createdAt'] = createdAt;
    return data;
  }
}
