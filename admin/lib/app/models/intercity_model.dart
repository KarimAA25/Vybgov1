import 'dart:convert';

// ignore_for_file: depend_on_referenced_packages
import 'package:admin/app/models/booking_model.dart';
import 'package:admin/app/models/coupon_model.dart';
import 'package:admin/app/models/driver_user_model.dart';
import 'package:admin/app/models/location_lat_lng.dart';
import 'package:admin/app/models/person_model.dart';
import 'package:admin/app/models/positions.dart';
import 'package:admin/app/models/vehicle_type_model.dart';
import 'package:admin/app/models/zone_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'admin_commission_model.dart';
import 'distance_model.dart';
import 'tax_model.dart';

class IntercityModel {
  String? id;
  Timestamp? createAt;
  Timestamp? updateAt;
  String? driverId;
  LocationLatLng? pickUpLocation;
  LocationLatLng? dropLocation;
  String? pickUpLocationAddress;
  String? dropLocationAddress;
  String? bookingStatus;
  String? vehicleTypeID;
  String? customerId;
  String? paymentType;
  bool? paymentStatus;
  String? cancelledBy;
  String? discount;
  String? subTotal;
  Timestamp? bookingTime;
  Timestamp? pickupTime;
  Timestamp? dropTime;
  DriverVehicleDetails? driverVehicleDetails;
  VehicleTypeModel? vehicleType;
  List<StopModel>? stops;
  List<dynamic>? rejectedDriverId;
  List<dynamic>? driverBidIdList;
  String? otp;
  Positions? pickupPosition;
  Positions? dropPosition;
  CouponModel? coupon;
  List<TaxModel>? taxList;
  List<PersonModel>? sharingPersonList;
  List<BidModel>? bidList;
  AdminCommission? adminCommission;
  DistanceModel? distance;
  String? cancelledReason;
  String? startDate;
  String? setPrice;
  String? recommendedPrice;
  bool? isPersonalRide;
  bool? isAcceptDriver;
  String? persons;
  String? type;
  String? rideStartTime;
  List<HoldTimingModel>? holdTiming;
  ZoneModel? zoneModel;
  String? holdCharges;

  IntercityModel({
    this.createAt,
    this.updateAt,
    this.driverId,
    this.bookingStatus,
    this.vehicleTypeID,
    this.id,
    this.dropLocation,
    this.pickUpLocation,
    this.dropLocationAddress,
    this.pickUpLocationAddress,
    this.customerId,
    this.paymentType,
    this.paymentStatus,
    this.cancelledBy,
    this.discount,
    this.subTotal,
    this.bookingTime,
    this.pickupTime,
    this.dropTime,
    this.driverVehicleDetails,
    this.rejectedDriverId,
    this.driverBidIdList,
    this.otp,
    this.stops,
    this.pickupPosition,
    this.dropPosition,
    this.adminCommission,
    this.coupon,
    this.startDate,
    this.setPrice,
    this.recommendedPrice,
    this.isPersonalRide,
    this.taxList,
    this.sharingPersonList,
    this.vehicleType,
    this.bidList,
    this.persons,
    this.distance,
    this.isAcceptDriver,
    this.type,
    this.rideStartTime,
    this.cancelledReason,
    this.holdTiming,
    this.zoneModel,
    this.holdCharges,
  });

  @override
  String toString() {
    return 'BookingModel{id: $id, createAt: $createAt, updateAt: $updateAt,cancelledReason:$cancelledReason, driverId: $driverId, pickUpLocation: $pickUpLocation, dropLocation: $dropLocation, pickUpLocationAddress: $pickUpLocationAddress, dropLocationAddress: $dropLocationAddress, bookingStatus: $bookingStatus, customerId: $customerId, paymentType: $paymentType, paymentStatus: $paymentStatus, cancelledBy: $cancelledBy, discount: $discount, subTotal: $subTotal, bookingTime: $bookingTime, pickupTime: $pickupTime, dropTime: $dropTime, driverVehicleDetails: $driverVehicleDetails, rejectedDriverId: $rejectedDriverId, otp: $otp, pickupPosition: $pickupPosition, dropPosition: $dropPosition, coupon: $coupon, taxList: $taxList, adminCommission: $adminCommission, distance: $distance,recommendedPrice: $recommendedPrice, stops: $stops}';
  }

  factory IntercityModel.fromRawJson(String str) => IntercityModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory IntercityModel.fromJson(Map<String, dynamic> json) => IntercityModel(
    createAt: json["createAt"],
    updateAt: json["updateAt"],
    driverId: json["driverId"],
    bookingStatus: json["bookingStatus"],
    vehicleTypeID: json["vehicleTypeID"],
    dropLocation: json['dropLocation'] != null ? LocationLatLng.fromJson(json['dropLocation']) : null,
    pickUpLocation: json['pickUpLocation'] != null ? LocationLatLng.fromJson(json['pickUpLocation']) : null,
    dropLocationAddress: json['dropLocationAddress'],
    pickUpLocationAddress: json['pickUpLocationAddress'],
    id: json["id"],
    customerId: json["customerId"],
    paymentType: json["paymentType"],
    paymentStatus: json["paymentStatus"],
    cancelledBy: json["cancelledBy"],
    cancelledReason: json["cancelledReason"],
    discount: json["discount"],
    subTotal: json["subTotal"],
    bookingTime: json["bookingTime"],
    pickupTime: json["pickupTime"],
    dropTime: json["dropTime"],
    otp: json["otp"],
    startDate: json["startDate"],
    setPrice: json["setPrice"],
    recommendedPrice: json["recommendedPrice"],
    isAcceptDriver: json["isAcceptDriver"],
    isPersonalRide: json["isPersonalRide"],
    persons: json["persons"],
    type: json["type"],
    rideStartTime: json["rideStartTime"],
    driverVehicleDetails: json["driverVehicleDetails"] == null ? null : DriverVehicleDetails.fromJson(json["driverVehicleDetails"]),
    vehicleType: json["vehicleType"] == null ? null : VehicleTypeModel.fromJson(json["vehicleType"]),
    rejectedDriverId: json["rejectedDriverId"] == null ? [] : List<dynamic>.from(json["rejectedDriverId"]!.map((x) => x)),
    driverBidIdList: json["driverBidIdList"] == null ? [] : List<dynamic>.from(json["driverBidIdList"]!.map((x) => x)),
    taxList: json["taxList"] == null ? [] : List<TaxModel>.from(json["taxList"]!.map((x) => TaxModel.fromJson(x))),
    sharingPersonList: json["sharingPersonList"] == null ? [] : List<PersonModel>.from(json["sharingPersonList"]!.map((x) => PersonModel.fromJson(x))),
    bidList: json["bidList"] == null ? [] : List<BidModel>.from(json["bidList"]!.map((x) => BidModel.fromJson(x))),
    pickupPosition: json["pickupPosition"] == null ? null : Positions.fromJson(json["pickupPosition"]),
    dropPosition: json["dropPosition"] == null ? null : Positions.fromJson(json["dropPosition"]),
    coupon: json["coupon"] == null ? null : CouponModel.fromJson(json["coupon"]),
    adminCommission: json["adminCommission"] == null ? AdminCommission() : AdminCommission.fromJson(json["adminCommission"]),
    stops: json["stops"] == null ? [] : List<StopModel>.from(json["stops"]!.map((x) => StopModel.fromJson(x))),
    distance: json["distance"] == null ? null : DistanceModel.fromJson(json["distance"]),
    zoneModel: json["zoneModel"] == null ? null : ZoneModel.fromJson(json["zoneModel"]),
    holdTiming: json["holdTiming"] == null ? [] : List<HoldTimingModel>.from(json["holdTiming"]!.map((x) => HoldTimingModel.fromJson(x))),
    holdCharges: json["holdCharges"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "createAt": createAt,
    "updateAt": updateAt,
    "driverId": driverId,
    "bookingStatus": bookingStatus,
    "vehicleTypeID": vehicleTypeID,
    "dropLocation": dropLocation?.toJson(),
    "pickUpLocation": pickUpLocation?.toJson(),
    "dropLocationAddress": dropLocationAddress,
    "pickUpLocationAddress": pickUpLocationAddress,
    "customerId": customerId,
    "paymentType": paymentType,
    "paymentStatus": paymentStatus,
    "cancelledBy": cancelledBy,
    "cancelledReason": cancelledReason,
    "discount": discount,
    "subTotal": subTotal,
    "bookingTime": bookingTime,
    "pickupTime": pickupTime,
    "dropTime": dropTime,
    "isAcceptDriver": isAcceptDriver,
    "persons": persons,
    "isPersonalRide": isPersonalRide,
    "setPrice": setPrice,
    "recommendedPrice": recommendedPrice,
    "type": type,
    "rideStartTime": rideStartTime,
    "startDate": startDate,
    "driverVehicleDetails": driverVehicleDetails?.toJson(),
    "rejectedDriverId": rejectedDriverId == null ? [] : List<dynamic>.from(rejectedDriverId!.map((x) => x)),
    "driverBidIdList": driverBidIdList == null ? [] : List<dynamic>.from(driverBidIdList!.map((x) => x)),
    "taxList": taxList == null ? [] : (taxList!.map((x) => x.toJson()).toList()),
    "sharingPersonList": sharingPersonList == null ? [] : (sharingPersonList!.map((x) => x.toJson()).toList()),
    "bidList": bidList == null ? [] : (bidList!.map((x) => x.toJson()).toList()),
    "stops": stops == null ? [] : (stops!.map((x) => x.toJson()).toList()),
    "pickupPosition": pickupPosition?.toJson(),
    "dropPosition": dropPosition?.toJson(),
    "coupon": coupon?.toJson(),
    "vehicleType": vehicleType?.toJson(),
    "adminCommission": adminCommission?.toJson(),
    "distance": distance?.toJson(),
    "otp": otp,
    "zoneModel": zoneModel?.toJson(),
    "holdCharges": holdCharges,
    "holdTiming": holdTiming == null ? [] : holdTiming!.map((x) => x.toJson()).toList(),
  };
}

class BidModel {
  String? id;
  String? driverID;
  String? bidStatus;
  String? amount;

  BidModel({
    this.id,
    this.amount,
    this.bidStatus,
    this.driverID,
  });

  BidModel.fromJson(Map<String, dynamic> json) {
    id = json["id"];
    amount = json["amount"];
    bidStatus = json["bidStatus"];
    driverID = json["driverID"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data["id"] = id;
    data["amount"] = amount;
    data["bidStatus"] = bidStatus;
    data["driverID"] = driverID;
    return data;
  }
}
