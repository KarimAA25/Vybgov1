class CancellationChargeModel {
  String? charge;
  bool? active;
  bool? isFix;

  CancellationChargeModel({this.charge, this.active, this.isFix});

  CancellationChargeModel.fromJson(Map<String, dynamic> json) {
    charge = json['charge'];
    active = json['active'];
    isFix = json['isFix'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['charge'] = charge;
    data['active'] = active;
    data['isFix'] = isFix;
    return data;
  }
}