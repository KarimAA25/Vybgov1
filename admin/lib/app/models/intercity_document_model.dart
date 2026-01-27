import 'package:admin/app/models/vehicle_type_model.dart';

class IntercityDocumentModel {
  String id;
  bool isAvailable;
  bool isBidEnable;
  List<ZoneChargesModel> zoneCharges;

  IntercityDocumentModel({
    required this.id,
    required this.isAvailable,
    required this.zoneCharges,
    required this.isBidEnable,
  });

  factory IntercityDocumentModel.fromJson(String id, Map<String, dynamic> json) {
    return IntercityDocumentModel(
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
