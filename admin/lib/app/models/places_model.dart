class PlaceModel {
  final String placeId;
  final String description;

  PlaceModel({required this.placeId, required this.description});

  factory PlaceModel.fromJson(Map<String, dynamic> json) {
    return PlaceModel(
      placeId: json['place_id'],
      description: json['description'],
    );
  }
}
