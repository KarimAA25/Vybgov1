// ignore_for_file: depend_on_referenced_packages

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:driver/app/models/location_lat_lng.dart';

class SOSAlertsModel {
  String? id;
  String? userId;
  String? driverId;
  String? customerId;
  String? bookingId;
  Timestamp? createdAt;
  LocationLatLng? location;
  List<String>? contactIds;
  String? emergencyType;
  String? type;
  String? status;

  SOSAlertsModel({
    this.id,
    this.userId,
    this.driverId,
    this.customerId,
    this.bookingId,
    this.createdAt,
    this.location,
    this.emergencyType,
    this.contactIds,
    this.type,
    this.status,
  });

  SOSAlertsModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['userId'];
    driverId = json['driverId'];
    customerId = json['customerId'];
    bookingId = json['bookingId'];
    createdAt = json['createdAt'];
    location = json['location'] != null ? LocationLatLng.fromJson(json['location']) : LocationLatLng();
    emergencyType = json['emergencyType'];
    type = json['type'];
    status = json['status'];
    contactIds = json['contactIds'] != null ? List<String>.from(json['contactIds']) : [];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['userId'] = userId;
    data['driverId'] = driverId;
    data['customerId'] = customerId;
    data['bookingId'] = bookingId;
    data['createdAt'] = createdAt;
    if (location != null) {
      data['location'] = location!.toJson();
    }
    data['emergencyType'] = emergencyType;
    data['contactIds'] = contactIds;
    data['type'] = type;
    data['status'] = status;
    return data;
  }
}
