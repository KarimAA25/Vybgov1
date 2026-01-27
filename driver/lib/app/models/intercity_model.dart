import 'dart:convert';

// ignore_for_file: depend_on_referenced_packages
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:driver/app/models/admin_commission.dart';
import 'package:driver/app/models/booking_model.dart';
import 'package:driver/app/models/coupon_model.dart';
import 'package:driver/app/models/distance_model.dart';
import 'package:driver/app/models/driver_user_model.dart';
import 'package:driver/app/models/location_lat_lng.dart';
import 'package:driver/app/models/person_model.dart';
import 'package:driver/app/models/positions_model.dart';
import 'package:driver/app/models/vehicle_type_model.dart';
import 'package:driver/app/models/zone_model.dart';

import 'tax_model.dart';

class IntercityModel {
  String? id;
  Timestamp? createAt;
  Timestamp? updateAt;
  String? driverId;
  List<dynamic>? driverBidIdList;
  LocationLatLng? pickUpLocation;
  LocationLatLng? dropLocation;
  String? pickUpLocationAddress;
  String? dropLocationAddress;
  String? bookingStatus;
  String? customerId;
  String? paymentType;
  bool? paymentStatus;
  String? cancelledBy;
  String? discount;
  String? subTotal;
  Timestamp? bookingTime;
  Timestamp? pickupTime;
  Timestamp? dropTime;
  VehicleTypeModel? vehicleType;
  List<dynamic>? rejectedDriverId;
  DriverVehicleDetails? driverVehicleDetails;
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
  String? persons;
  String? rideStartTime;
  String? vehicleTypeID;
  List<StopModel>? stops;
  List<HoldTimingModel>? holdTiming;
  ZoneModel? zoneModel;
  String? holdCharges;
  bool? isOnlyForFemale;

  IntercityModel({
    this.createAt,
    this.updateAt,
    this.driverId,
    this.bookingStatus,
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
    this.vehicleType,
    this.rejectedDriverId,
    this.driverBidIdList,
    this.otp,
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
    this.bidList,
    this.persons,
    this.distance,
    this.driverVehicleDetails,
    this.rideStartTime,
    this.vehicleTypeID,
    this.cancelledReason,
    this.stops,
    this.holdTiming,
    this.zoneModel,
    this.holdCharges,
    this.isOnlyForFemale,
  });

  @override
  String toString() {
    return 'BookingModel{id: $id,stops: $stops,createAt: $createAt, updateAt: $updateAt,cancelledReason:$cancelledReason, driverId: $driverId, pickUpLocation: $pickUpLocation, dropLocation: $dropLocation, pickUpLocationAddress: $pickUpLocationAddress, dropLocationAddress: $dropLocationAddress, bookingStatus: $bookingStatus, customerId: $customerId, paymentType: $paymentType, paymentStatus: $paymentStatus, cancelledBy: $cancelledBy, discount: $discount, subTotal: $subTotal, bookingTime: $bookingTime, pickupTime: $pickupTime, dropTime: $dropTime, vehicleType: $vehicleType, rejectedDriverId: $rejectedDriverId, otp: $otp, pickupPosition: $pickupPosition, dropPosition: $dropPosition, coupon: $coupon, taxList: $taxList, adminCommission: $adminCommission, distance: $distance,recommendedPrice: $recommendedPrice, isOnlyForFemale:$isOnlyForFemale}';
  }

  factory IntercityModel.fromRawJson(String str) => IntercityModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory IntercityModel.fromJson(Map<String, dynamic> json) => IntercityModel(
        createAt: json["createAt"],
        updateAt: json["updateAt"],
        driverId: json["driverId"],
        bookingStatus: json["bookingStatus"],
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
        vehicleTypeID: json["vehicleTypeID"],
        dropTime: json["dropTime"],
        otp: json["otp"],
        startDate: json["startDate"],
        setPrice: json["setPrice"],
        recommendedPrice: json["recommendedPrice"] ?? '0.0',
        isPersonalRide: json["isPersonalRide"],
        persons: json["persons"],
        rideStartTime: json["rideStartTime"],
        vehicleType: json["vehicleType"] == null ? null : VehicleTypeModel.fromJson(json["vehicleType"]),
        rejectedDriverId: json["rejectedDriverId"] == null ? [] : List<dynamic>.from(json["rejectedDriverId"]!.map((x) => x)),
        driverBidIdList: json["driverBidIdList"] == null ? [] : List<dynamic>.from(json["driverBidIdList"]!.map((x) => x)),
        taxList: json["taxList"] == null ? [] : List<TaxModel>.from(json["taxList"]!.map((x) => TaxModel.fromJson(x))),
        sharingPersonList: json["sharingPersonList"] == null ? [] : List<PersonModel>.from(json["sharingPersonList"]!.map((x) => PersonModel.fromJson(x))),
        bidList: json["bidList"] == null ? [] : List<BidModel>.from(json["bidList"]!.map((x) => BidModel.fromJson(x))),
        pickupPosition: json["pickupPosition"] == null ? null : Positions.fromJson(json["pickupPosition"]),
        dropPosition: json["dropPosition"] == null ? null : Positions.fromJson(json["dropPosition"]),
        coupon: json["coupon"] == null ? null : CouponModel.fromJson(json["coupon"]),
        adminCommission: json["adminCommission"] == null ? null : AdminCommission.fromJson(json["adminCommission"]),
        distance: json["distance"] == null ? null : DistanceModel.fromJson(json["distance"]),
        driverVehicleDetails: json["driverVehicleDetails"] == null ? null : DriverVehicleDetails.fromJson(json["driverVehicleDetails"]),
        stops: json["stops"] == null ? [] : List<StopModel>.from(json["stops"]!.map((x) => StopModel.fromJson(x))),
        zoneModel: json["zoneModel"] == null ? null : ZoneModel.fromJson(json["zoneModel"]),
        holdTiming: json["holdTiming"] == null ? [] : List<HoldTimingModel>.from(json["holdTiming"]!.map((x) => HoldTimingModel.fromJson(x))),
        holdCharges: json["holdCharges"],
        isOnlyForFemale: json["isOnlyForFemale"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "createAt": createAt,
        "updateAt": updateAt,
        "driverId": driverId,
        "bookingStatus": bookingStatus,
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
        "vehicleTypeID": vehicleTypeID,
        "bookingTime": bookingTime,
        "pickupTime": pickupTime,
        "dropTime": dropTime,
        "persons": persons,
        "isPersonalRide": isPersonalRide,
        "setPrice": setPrice,
        "recommendedPrice": recommendedPrice,
        "startDate": startDate,
        "rideStartTime": rideStartTime,
        "vehicleType": vehicleType?.toJson(),
        "driverVehicleDetails": driverVehicleDetails?.toJson(),
        "rejectedDriverId": rejectedDriverId == null ? [] : List<dynamic>.from(rejectedDriverId!.map((x) => x)),
        "driverBidIdList": driverBidIdList == null ? [] : List<dynamic>.from(driverBidIdList!.map((x) => x)),
        "taxList": taxList == null ? [] : (taxList!.map((x) => x.toJson()).toList()),
        "sharingPersonList": sharingPersonList == null ? [] : (sharingPersonList!.map((x) => x.toJson()).toList()),
        "bidList": bidList == null ? [] : (bidList!.map((x) => x.toJson()).toList()),
        "pickupPosition": pickupPosition?.toJson(),
        "dropPosition": dropPosition?.toJson(),
        "coupon": coupon?.toJson(),
        "adminCommission": adminCommission?.toJson(),
        "distance": distance?.toJson(),
        "otp": otp,
        "stops": stops == null ? [] : (stops!.map((x) => x.toJson()).toList()),
        "zoneModel": zoneModel?.toJson(),
        "holdCharges": holdCharges,
        "isOnlyForFemale": isOnlyForFemale,
        "holdTiming": holdTiming == null ? [] : holdTiming!.map((x) => x.toJson()).toList(),
      };
}

class BidModel {
  String? id;
  String? driverID;
  String? bidStatus;
  String? amount;
  Timestamp? createAt;

  BidModel({
    this.id,
    this.amount,
    this.bidStatus,
    this.driverID,
    this.createAt,
  });

  BidModel.fromJson(Map<String, dynamic> json) {
    id = json["id"];
    createAt = json["createAt"];
    amount = json["amount"];
    bidStatus = json["bidStatus"];
    driverID = json["driverID"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};

    data["id"] = id;
    data["createAt"] = createAt;
    data["amount"] = amount;
    data["bidStatus"] = bidStatus;
    data["driverID"] = driverID;

    return data;
  }
}
