// ignore_for_file: depend_on_referenced_packages

import 'package:cloud_firestore/cloud_firestore.dart';

class ZoneModel {
  String? id;
  String? name;
  bool? status;
  List<GeoPoint>? area;
  Timestamp? createdAt;

  ZoneModel({this.id, this.name, this.status, this.area, this.createdAt});

  ZoneModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    status = json['status'];
    if (json['area'] != null) {
      area = (json['area'] as List)
          .map((e) => e as GeoPoint)
          .toList();
    } else {
      area = [];
    }    createdAt = json['createdAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['status'] = status;
    data['area'] = area ;
    data['createdAt'] = createdAt;
    return data;
  }
}
