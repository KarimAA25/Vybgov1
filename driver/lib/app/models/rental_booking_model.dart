// ignore_for_file: depend_on_referenced_packages
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:driver/app/models/location_lat_lng.dart';
import 'package:driver/app/models/positions.dart';
import 'package:driver/app/models/rental_package_model.dart';
import 'package:driver/app/models/vehicle_type_model.dart';
import 'admin_commission.dart';
import 'coupon_model.dart';
import 'tax_model.dart';

class RentalBookingModel {
  String? id;
  Timestamp? createAt;
  Timestamp? updateAt;
  String? driverId;
  LocationLatLng? pickUpLocation;
  RentalPackageModel? rentalPackage;
  String? pickUpLocationAddress;
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
  String? otp;
  Positions? position;
  CouponModel? coupon;
  List<TaxModel>? taxList;
  AdminCommission? adminCommission;
  String? cancelledReason;
  String? currentKM;
  String? completedKM;
  String? extraKmCharge;
  String? extraHourCharge;
  bool? isOnlyForFemale;

  RentalBookingModel({
    this.createAt,
    this.updateAt,
    this.driverId,
    this.bookingStatus,
    this.rentalPackage,
    this.id,
    this.pickUpLocation,
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
    this.otp,
    this.position,
    this.adminCommission,
    this.coupon,
    this.taxList,
    this.cancelledReason,
    this.currentKM,
    this.completedKM,
    this.extraKmCharge,
    this.extraHourCharge,
    this.isOnlyForFemale,
  });

  @override
  String toString() {
    return 'RentalBookingModel{id: $id, rentalPackage: $rentalPackage,createAt: $createAt, updateAt: $updateAt,cancelledReason:$cancelledReason, driverId: $driverId, pickUpLocation: $pickUpLocation, pickUpLocationAddress: $pickUpLocationAddress, bookingStatus: $bookingStatus, customerId: $customerId, paymentType: $paymentType, paymentStatus: $paymentStatus, cancelledBy: $cancelledBy, discount: $discount, subTotal: $subTotal, bookingTime: $bookingTime, pickupTime: $pickupTime, dropTime: $dropTime, vehicleType: $vehicleType, rejectedDriverId: $rejectedDriverId, otp: $otp, position: $position, coupon: $coupon, taxList: $taxList, adminCommission: $adminCommission, currentKM: $currentKM, completedKM: $completedKM, extraKmCharge: $extraKmCharge, extraHourCharge: $extraHourCharge,isOnlyForFemale:$isOnlyForFemale}';
  }

  factory RentalBookingModel.fromRawJson(String str) => RentalBookingModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory RentalBookingModel.fromJson(Map<String, dynamic> json) => RentalBookingModel(
        createAt: json["createAt"],
        updateAt: json["updateAt"],
        driverId: json["driverId"],
        bookingStatus: json["bookingStatus"],
        pickUpLocation: json['pickUpLocation'] != null ? LocationLatLng.fromJson(json['pickUpLocation']) : null,
        rentalPackage: json['rentalPackage'] != null ? RentalPackageModel.fromJson(json['rentalPackage']) : null,
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
        vehicleType: json["vehicleType"] == null ? null : VehicleTypeModel.fromJson(json["vehicleType"]),
        rejectedDriverId: json["rejectedDriverId"] == null ? [] : List<dynamic>.from(json["rejectedDriverId"]!.map((x) => x)),
        taxList: json["taxList"] == null ? [] : List<TaxModel>.from(json["taxList"]!.map((x) => TaxModel.fromJson(x))),
        position: json["position"] == null ? null : Positions.fromJson(json["position"]),
        coupon: json["coupon"] == null ? null : CouponModel.fromJson(json["coupon"]),
        adminCommission: json["adminCommission"] == null ? null : AdminCommission.fromJson(json["adminCommission"]),
        completedKM: json["completedKM"],
        currentKM: json["currentKM"],
        extraKmCharge: json["extraKmCharge"],
        extraHourCharge: json["extraHourCharge"],
        isOnlyForFemale: json["isOnlyForFemale"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "createAt": createAt,
        "updateAt": updateAt,
        "driverId": driverId,
        "bookingStatus": bookingStatus,
        "pickUpLocation": pickUpLocation?.toJson(),
        "rentalPackage": rentalPackage?.toJson(),
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
        "vehicleType": vehicleType?.toJson(),
        "rejectedDriverId": rejectedDriverId == null ? [] : List<dynamic>.from(rejectedDriverId!.map((x) => x)),
        "taxList": taxList == null ? [] : (taxList!.map((x) => x.toJson()).toList()),
        "position": position?.toJson(),
        "coupon": coupon?.toJson(),
        "adminCommission": adminCommission?.toJson(),
        "otp": otp,
        "currentKM": currentKM,
        "completedKM": completedKM,
        "extraKmCharge": extraKmCharge,
        "extraHourCharge": extraHourCharge,
        "isOnlyForFemale": isOnlyForFemale,
      };
}
