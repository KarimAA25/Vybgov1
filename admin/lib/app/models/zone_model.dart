import 'package:admin/app/models/vehicle_type_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ZoneModel {
  String? id;
  String? name;
  bool? status;
  List<dynamic>? area;
  Timestamp? createdAt;
  Charges? charges;

  TextEditingController? minDistanceController;
  TextEditingController? minFareController;
  TextEditingController? perKmController;
  TextEditingController? holdChargeController;
  TextEditingController? minuteChargeController;
  TextEditingController? nightChargeController;

  ZoneModel({
    this.id,
    this.name,
    this.status,
    this.area,
    this.createdAt,
    this.charges,
  });

  ZoneModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    status = json['status'];
    area = json['area'] ?? [];
    createdAt = json['createdAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['status'] = status;
    data['area'] = area;
    data['createdAt'] = createdAt;
    return data;
  }
}
