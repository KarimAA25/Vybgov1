class EmergencyContactModel {
  String? id;
  String? name;
  String? phoneNumber;
  String? countryCode;

  EmergencyContactModel({this.id, this.name, this.phoneNumber, this.countryCode});

  EmergencyContactModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    phoneNumber = json['phoneNumber'];
    countryCode = json['countryCode'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['phoneNumber'] = phoneNumber;
    data['countryCode'] = countryCode;
    return data;
  }
}
