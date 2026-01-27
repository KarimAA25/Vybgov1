class VehicleTypeModel {
  String? id;
  String? image;
  bool? isActive;
  String? title;
  String? persons;
  List<ZoneChargesModel>? zoneCharges;

  VehicleTypeModel({
    this.id,
    this.image,
    this.isActive,
    this.title,
    this.persons,
    this.zoneCharges,
  });

  factory VehicleTypeModel.fromJson(Map<String, dynamic> json) => VehicleTypeModel(
    id: json["id"],
    image: json["image"],
    isActive: json["isActive"],
    title: json["title"],
    persons: json["persons"],
    zoneCharges: json["zoneCharges"] != null ? (json["zoneCharges"] as List).map((e) => ZoneChargesModel.fromJson(e)).toList() : [],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "image": image,
    "isActive": isActive,
    "title": title,
    "persons": persons,
    "zoneCharges": zoneCharges?.map((z) => z.toJson()).toList(),
  };
}

class ZoneChargesModel {
  String? zoneId;
  String? zoneName;
  Charges? charges;

  ZoneChargesModel({this.zoneId, this.zoneName, this.charges});

  factory ZoneChargesModel.fromJson(Map<String, dynamic> json) => ZoneChargesModel(
    zoneId: json["zoneId"],
    zoneName: json["zoneName"],
    charges: json["charges"] == null ? null : Charges.fromJson(json["charges"]),
  );

  Map<String, dynamic> toJson() => {
    "zoneId": zoneId,
    "zoneName": zoneName,
    "charges": charges?.toJson(),
  };
}

class Charges {
  String? fareMinimumChargesWithinKm;
  String? farMinimumCharges;
  String? farePerKm;
  String? holdCharge;
  String? minuteCharge;
  String? incrementOfNightCharge;

  Charges({
    this.fareMinimumChargesWithinKm,
    this.farMinimumCharges,
    this.farePerKm,
    this.minuteCharge,
    this.holdCharge,
    this.incrementOfNightCharge,
  });

  factory Charges.fromJson(Map<String, dynamic> json) => Charges(
    fareMinimumChargesWithinKm: json["fareMinimumChargesWithinKm"]?.toString() ?? "0",
    farMinimumCharges: json["farMinimumCharges"]?.toString() ?? "0",
    farePerKm: json["farePerKm"]?.toString() ?? "0",
    minuteCharge: json["minuteCharge"]?.toString() ?? "0",
    holdCharge: json["holdCharge"]?.toString() ?? "0",
    incrementOfNightCharge: json["incrementOfNightCharge"]?.toString() ?? "0",
  );

  Map<String, dynamic> toJson() => {
    "fareMinimumChargesWithinKm": fareMinimumChargesWithinKm,
    "farMinimumCharges": farMinimumCharges,
    "farePerKm": farePerKm,
    "minuteCharge": minuteCharge,
    "holdCharge": holdCharge,
    "incrementOfNightCharge": incrementOfNightCharge,
  };
}
