// ignore_for_file: depend_on_referenced_packages

import 'package:cloud_firestore/cloud_firestore.dart';

class LoyaltyPointTransactionModel {
  String? id;
  String? note;
  String? customerId;
  String? transactionId;
  String? points;
  bool? isCredit;
  Timestamp? createdAt;

  LoyaltyPointTransactionModel({this.id, this.note, this.isCredit, this.customerId, this.transactionId, this.points, this.createdAt});

  LoyaltyPointTransactionModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    note = json['note'];
    customerId = json['customerId'];
    transactionId = json['transactionId'];
    points = json['points'];
    isCredit = json['isCredit'];
    createdAt = json['createdAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['note'] = note;
    data['customerId'] = customerId;
    data['transactionId'] = transactionId;
    data['points'] = points;
    data['isCredit'] = isCredit;
    data['createdAt'] = createdAt;
    return data;
  }
}
