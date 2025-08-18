import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:stadium_food/src/data/models/payment_method.dart';
import 'package:hive/hive.dart';

// ignore: must_be_immutable
class ShopUser extends Equatable {
  final String email;
  final String name;

  final String? image;
  final String fcmToken;
  String userId;
  final List<String> shopsId;
  final List<dynamic>? location;

  ShopUser({
    required this.email,
    required this.name,
    required this.userId,
    required this.shopsId,
    this.image,
    required this.fcmToken,
    this.location,
  });

  factory ShopUser.fromMap(Map<String, dynamic> map) {
    return ShopUser(
      email: map['email'],
      name: map['name'],
      userId: map['userId'],
      image: map['image'],
      fcmToken: map['fcmToken'],
      shopsId: (map['shopsId'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      location: map['location'] as List<dynamic>?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'email': email,
      'name': name,
      'image': image,
      'shopsId': shopsId,
      'fcmToken': fcmToken,
      'location': location,
    };
  }



  @override
  List<Object?> get props => [
        email,
        name,
        image,
        userId,
        fcmToken,
        shopsId,
        location,
      ];
}
