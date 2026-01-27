// ignore_for_file: depend_on_referenced_packages
import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  String? fullName;
  String? slug;
  String? id;
  String? email;
  String? loginType;
  String? profilePic;
  String? fcmToken;
  String? countryCode;
  String? phoneNumber;
  String? walletAmount;
  String? totalEarning;
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
    this.slug,
    this.id,
    this.isActive,
    this.email,
    this.loginType,
    this.profilePic,
    this.fcmToken,
    this.countryCode,
    this.phoneNumber,
    this.walletAmount,
    this.totalEarning,
    this.reviewsSum,
    this.reviewsCount,
    this.loyaltyCredits,
    this.createdAt,
    this.searchEmailKeywords,
    this.searchNameKeywords,
    this.activeRideId,
  });

  @override
  String toString() {
    return 'UserModel{fullName: $fullName,slug: $slug, id: $id, email: $email, loginType: $loginType, profilePic: $profilePic, fcmToken: $fcmToken, countryCode: $countryCode, phoneNumber: $phoneNumber, walletAmount: $walletAmount,totalEarning: $totalEarning, gender: $gender, isActive: $isActive, createdAt: $createdAt,reviewsCount: $reviewsCount, reviewsSum: $reviewsSum, loyaltyCredits: $loyaltyCredits, searchNameKeywords: $searchNameKeywords, searchEmailKeywords: $searchEmailKeywords, activeRideId:$activeRideId}';
  }

  UserModel.fromJson(Map<String, dynamic> json) {
    fullName = json['fullName'];
    slug = json['slug'];
    id = json['id'];
    email = json['email'];
    loginType = json['loginType'];
    profilePic = json['profilePic'];
    fcmToken = json['fcmToken'];
    countryCode = json['countryCode'];
    phoneNumber = json['phoneNumber'];
    walletAmount = json['walletAmount'] ?? "0";
    totalEarning = json['totalEarning'] ?? "0";
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
    data['slug'] = slug;
    data['id'] = id;
    data['email'] = email;
    data['loginType'] = loginType;
    data['profilePic'] = profilePic;
    data['fcmToken'] = fcmToken;
    data['countryCode'] = countryCode;
    data['phoneNumber'] = phoneNumber;
    data['walletAmount'] = walletAmount;
    data['totalEarning'] = totalEarning;
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
