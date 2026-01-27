// ignore_for_file: non_constant_identifier_names

import 'package:admin/app/models/loyalty_point_model.dart';

class ConstantModel {
  String? googleMapKey;
  String? jsonFileURL;
  String? minimumAmountDeposit;
  String? referralAmount;
  String? minimumAmountWithdraw;
  String? notificationServerKey;
  String? aboutApp;
  String? appColor;
  String? appName;
  String? interCityRadius;
  bool? isSubscriptionEnable;
  bool? isDocumentVerificationEnable;
  bool? isDriverAutoApproved;
  String? secondsForRideCancel;
  bool? isOTPEnable;
  LoyaltyPointModel? loyaltyProgram;
  bool? isHomeFeatureEnable;
  String? countryCode;
  String? selectedMap;
  String? sosNumber;
  MapSettingModel? mapSettings;

  ConstantModel({
    this.googleMapKey,
    this.jsonFileURL,
    this.minimumAmountDeposit,
    this.referralAmount,
    this.minimumAmountWithdraw,
    this.notificationServerKey,
    this.aboutApp,
    this.appColor,
    this.appName,
    this.interCityRadius,
    this.isSubscriptionEnable,
    this.isDocumentVerificationEnable,
    this.isDriverAutoApproved,
    this.secondsForRideCancel,
    this.isOTPEnable,
    this.loyaltyProgram,
    this.isHomeFeatureEnable,
    this.countryCode,
    this.selectedMap,
    this.sosNumber,
    this.mapSettings,
  });

  ConstantModel.fromJson(Map<String, dynamic> json) {
    googleMapKey = json['googleMapKey'];
    jsonFileURL = json['jsonFileURL'];
    minimumAmountDeposit = json['minimum_amount_deposit'];
    referralAmount = json['referral_Amount'];
    minimumAmountWithdraw = json['minimum_amount_withdraw'];
    notificationServerKey = json['notification_senderId'];
    aboutApp = json['aboutApp'];
    appColor = json['appColor'];
    appName = json['appName'];
    interCityRadius = json['interCityRadius'];
    isSubscriptionEnable = json['isSubscriptionEnable'];
    isDocumentVerificationEnable = json['isDocumentVerificationEnable'];
    isDriverAutoApproved = json['isDriverAutoApproved'];
    secondsForRideCancel = json['secondsForRideCancel'];
    isOTPEnable = json['isOTPEnable'];
    isHomeFeatureEnable = json['isHomeFeatureEnable'];
    countryCode = json['countryCode'];
    loyaltyProgram = json["loyaltyProgram"] == null ? null : LoyaltyPointModel.fromJson(json["loyaltyProgram"]);
    selectedMap = json['selectedMap'] ?? '';
    sosNumber = json['sosNumber'];
    mapSettings = json["mapSettings"] == null ? null : MapSettingModel.fromJson(json["mapSettings"]);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['googleMapKey'] = googleMapKey ?? "";
    data['jsonFileURL'] = jsonFileURL ?? "";
    data['minimum_amount_deposit'] = minimumAmountDeposit ?? "";
    data['referral_Amount'] = referralAmount ?? "";
    data['minimum_amount_withdraw'] = minimumAmountWithdraw ?? "";
    data['notification_senderId'] = notificationServerKey ?? "";
    data['aboutApp'] = aboutApp ?? "";
    data['appColor'] = appColor ?? "";
    data['appName'] = appName ?? "";
    data['interCityRadius'] = interCityRadius ?? "";
    data['isSubscriptionEnable'] = isSubscriptionEnable ?? false;
    data['isDocumentVerificationEnable'] = isDocumentVerificationEnable ?? true;
    data['isDriverAutoApproved'] = isDriverAutoApproved ?? false;
    data['secondsForRideCancel'] = secondsForRideCancel;
    data['isOTPEnable'] = isOTPEnable ?? false;
    data['isHomeFeatureEnable'] = isHomeFeatureEnable ?? false;
    data['countryCode'] = countryCode;
    data['selectedMap'] = selectedMap ?? "";
    data['sosNumber'] = sosNumber;
    if (loyaltyProgram != null) {
      data['loyaltyProgram'] = loyaltyProgram!.toJson();
    }
    if (mapSettings != null) {
      data['mapSettings'] = mapSettings!.toJson();
    }
    return data;
  }
}

class MapSettingModel {
  String? googleMapKey;
  String? mapType;

  MapSettingModel({this.googleMapKey, this.mapType});

  MapSettingModel.fromJson(Map<String, dynamic> json) {
    googleMapKey = json['googleMapKey'];
    mapType = json['mapType'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['googleMapKey'] = googleMapKey;
    data['mapType'] = mapType;
    return data;
  }
}
