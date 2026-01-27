class NightTimingModel {
  String? startTime;
  String? endTime;

  NightTimingModel({this.startTime, this.endTime});

  NightTimingModel.fromJson(Map<String, dynamic> json) {
    startTime = json['startTime'];
    endTime = json['endTime'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['startTime'] = startTime;
    data['endTime'] = endTime;
    return data;
  }
}
