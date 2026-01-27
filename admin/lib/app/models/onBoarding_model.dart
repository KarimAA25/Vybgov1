import 'package:cloud_firestore/cloud_firestore.dart';

class OnboardingModel {
  String? id;
  String? title;
  String? description;
  String? type;
  String? image;
  bool? status;
  Timestamp? createdAt;

  OnboardingModel(
      {this.id,
        this.title,
        this.description,
        this.type,
        this.image,
        this.status,
        this.createdAt});

  OnboardingModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    description = json['description'];
    type = json['type'];
    image = json['image'];
    status = json['status'];
    createdAt = json['createdAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['title'] = title;
    data['description'] = description;
    data['type'] = type;
    data['image'] = image;
    data['status'] = status;
    data['createdAt'] = createdAt;
    return data;
  }
}
