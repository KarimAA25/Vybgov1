// ignore_for_file: depend_on_referenced_packages
import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  String? fullName;
  String? id;
  String? email;
  String? loginType;
  String? profilePic;
  String? fcmToken;
  String? countryCode;
  String? phoneNumber;
  String? walletAmount;
  String? gender;
  bool? isActive;
  String? reviewsCount;
  String? reviewsSum;
  Timestamp? createdAt;
  String? loyaltyCredits;
  List<dynamic>? searchNameKeywords;
  List<dynamic>? searchEmailKeywords;
  String? activeRideId;

  UserModel({
    this.fullName,
    this.id,
    this.isActive,
    this.email,
    this.loginType,
    this.profilePic,
    this.fcmToken,
    this.countryCode,
    this.phoneNumber,
    this.walletAmount,
    this.reviewsSum,
    this.reviewsCount,
    this.loyaltyCredits,
    this.createdAt,
    this.gender,
    this.searchNameKeywords,
    this.searchEmailKeywords,
    this.activeRideId,
  });

  UserModel.fromJson(Map<String, dynamic> json) {
    fullName = json['fullName'];
    id = json['id'];
    email = json['email'];
    loginType = json['loginType'];
    profilePic = json['profilePic'];
    fcmToken = json['fcmToken'];
    countryCode = json['countryCode'];
    phoneNumber = json['phoneNumber'];
    walletAmount = json['walletAmount'] ?? "0";
    createdAt = json['createdAt'];
    gender = json['gender'];
    isActive = json['isActive'];
    reviewsCount = json['reviewsCount'];
    reviewsSum = json['reviewsSum'];
    loyaltyCredits = json['loyaltyCredits'] ?? "0";
    searchNameKeywords = json['searchNameKeywords'] ?? [];
    searchEmailKeywords = json['searchEmailKeywords'] ?? [];
    activeRideId = json['activeRideId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['fullName'] = fullName;
    data['id'] = id;
    data['email'] = email;
    data['loginType'] = loginType;
    data['profilePic'] = profilePic;
    data['fcmToken'] = fcmToken;
    data['countryCode'] = countryCode;
    data['phoneNumber'] = phoneNumber;
    data['walletAmount'] = walletAmount;
    data['createdAt'] = createdAt;
    data['gender'] = gender;
    data['isActive'] = isActive;
    data['reviewsCount'] = reviewsCount ?? '0';
    data['reviewsSum'] = reviewsSum ?? "0.0";
    data['loyaltyCredits'] = loyaltyCredits ?? "0";
    data['searchNameKeywords'] = searchNameKeywords;
    data['searchEmailKeywords'] = searchEmailKeywords;
    data['activeRideId'] = activeRideId;
    return data;
  }
}
