class LoyaltyPointModel {
  String? points;
  String? conversionRate;
  String? minRedeemPoint;

  LoyaltyPointModel({this.points, this.conversionRate, this.minRedeemPoint});

  LoyaltyPointModel.fromJson(Map<String, dynamic> json) {
    points = json['points'];
    conversionRate = json['conversionRate'];
    minRedeemPoint = json['minRedeemPoint'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['points'] = points;
    data['conversionRate'] = conversionRate;
    data['minRedeemPoint'] = minRedeemPoint;
    return data;
  }
}
