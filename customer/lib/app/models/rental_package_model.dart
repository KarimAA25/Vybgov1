class RentalPackageModel {
  String? id;
  String? title;
  String? baseFare;
  String? includedHours;
  String? includedDistance;
  String? extraKmFare;
  String? extraHourFare;
  String? vehicleId;

  RentalPackageModel({this.id, this.title, this.baseFare, this.includedHours, this.includedDistance, this.extraKmFare, this.extraHourFare, this.vehicleId});

  RentalPackageModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    baseFare = json['baseFare'];
    includedHours = json['includedHours'];
    includedDistance = json['includedDistance'];
    extraKmFare = json['extraKmFare'];
    extraHourFare = json['extraHourFare'];
    vehicleId = json['vehicleId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['title'] = title;
    data['baseFare'] = baseFare;
    data['includedHours'] = includedHours;
    data['includedDistance'] = includedDistance;
    data['extraKmFare'] = extraKmFare;
    data['extraHourFare'] = extraHourFare;
    data['vehicleId'] = vehicleId;
    return data;
  }
}
