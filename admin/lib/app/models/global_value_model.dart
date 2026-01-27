import 'package:admin/app/models/night_timing_model.dart';

class GlobalValueModel {
  String? distanceType;
  String? driverLocationUpdate;
  String? radius;
  String? minimumAmountAcceptRide;
  NightTimingModel? nightTime;

  GlobalValueModel({
    this.distanceType,
    this.driverLocationUpdate,
    this.radius,
    this.minimumAmountAcceptRide,
    this.nightTime,
  });

  GlobalValueModel.fromJson(Map<String, dynamic> json) {
    distanceType = json['distanceType'];
    driverLocationUpdate = json['driverLocationUpdate'];
    radius = json['radius'];
    minimumAmountAcceptRide = json['minimum_amount_accept_ride'];
    nightTime = json["nightTime"] == null ? null : NightTimingModel.fromJson(json["nightTime"]);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['distanceType'] = distanceType;
    data['driverLocationUpdate'] = driverLocationUpdate;
    data['radius'] = radius;
    data['minimum_amount_accept_ride'] = minimumAmountAcceptRide ?? "";
    if (nightTime != null) {
      data['nightTime'] = nightTime!.toJson();
    }

    return data;
  }
}
