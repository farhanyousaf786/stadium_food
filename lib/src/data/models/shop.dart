import 'package:cloud_firestore/cloud_firestore.dart';

class Shop {
  final String id;
  final String name;
  final String description;
  final String location;
  final String floor;
  final String gate;
  final String shopUserFcmToken;
  final String stadiumId;
  final String stadiumName;
  final List<String> admins;
  final DateTime createdAt;
  final DateTime updatedAt;

  Shop({
    required this.id,
    required this.name,
    required this.description,
    required this.location,
    required this.floor,
    required this.gate,
    required this.stadiumId,
    required this.stadiumName,
    required this.shopUserFcmToken,
    required this.admins,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Shop.fromMap(String id, Map<String, dynamic> map) {
    return Shop(
      id: id,
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      location: map['location'] ?? '',
      floor: map['floor'] ?? '',
      gate: map['gate'] ?? '',
      stadiumId: map['stadiumId'] ?? '',
      stadiumName: map['stadiumName'] ?? '',
      shopUserFcmToken: map['shopUserFcmToken'] ?? '',
      admins: List<String>.from(map['admins'] ?? []),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
    );
  }
}
