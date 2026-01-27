import 'package:customer/app/models/vehicle_type_model.dart';

class TimeSlotsChargesModel {
  String id;
  bool isAvailable;
  bool isBidEnable;
  List<ZoneChargesModel> zoneCharges;

  TimeSlotsChargesModel({
    required this.id,
    required this.isAvailable,
    required this.zoneCharges,
    required this.isBidEnable,
  });

  factory TimeSlotsChargesModel.fromJson(String id, Map<String, dynamic> json) {
    return TimeSlotsChargesModel(
      id: id,
      isBidEnable: json["isBidEnable"] ?? false,
      isAvailable: json["isAvailable"] ?? false,
      zoneCharges: json['zoneCharges'] != null
          ? List<ZoneChargesModel>.from(
              (json['zoneCharges'] as List).map(
                (x) => ZoneChargesModel.fromJson(x),
              ),
            )
          : [],
    );
  }
}
