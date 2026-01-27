// ignore_for_file: depend_on_referenced_packages
import 'package:cloud_firestore/cloud_firestore.dart';

class ReviewModel {
  String? id;
  String? rating;
  Timestamp? date;
  String? customerId;
  String? comment;
  String? driverId;
  String? bookingId;
  String? type;

  ReviewModel({this.id, this.date, this.rating, this.customerId, this.comment, this.driverId, this.bookingId, this.type});

  @override
  String toString() {
    return 'ReviewModel{id: $id, rating: $rating, date: $date, customerId: $customerId, comment: $comment, driverId: $driverId,  type: $type,bookingId: $bookingId,}';
  }

  ReviewModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    date = json['date'];
    rating = json['rating'];
    customerId = json['customerId'];
    comment = json['comment'];
    driverId = json['driverId'];
    bookingId = json['bookingId'];
    type = json['type'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['date'] = date;
    data['customerId'] = customerId;
    data['rating'] = rating;
    data['comment'] = comment;
    data['driverId'] = driverId;
    data['bookingId'] = bookingId;
    data['type'] = type;
    return data;
  }
}
