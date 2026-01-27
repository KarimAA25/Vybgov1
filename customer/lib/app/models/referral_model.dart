class ReferralModel {
  String? userId;
  String? referralCode;
  String? referralBy;
  String? role;
  String? referralRole;

  ReferralModel({this.userId, this.referralCode, this.referralBy, this.role, this.referralRole});

  ReferralModel.fromJson(Map<String, dynamic> json) {
    userId = json['userId'];
    referralCode = json['referralCode'];
    referralBy = json['referralBy'];
    role = json['role'];
    referralRole = json['referralRole'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['userId'] = userId;
    data['referralCode'] = referralCode;
    data['referralBy'] = referralBy;
    data['role'] = role;
    data['referralRole'] = referralRole;
    return data;
  }
}
