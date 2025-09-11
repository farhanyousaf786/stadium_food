import 'package:cloud_firestore/cloud_firestore.dart';

class Shop {
  final String id;
  final String name;
  final String description;
  final String location;
  final double latitude;
  final double longitude;
  final String floor;
  final String gate;
  final String shopUserFcmToken;
  final String stadiumId;
  final String stadiumName;
  final List<String> admins;
  final bool shopAvailability;
  final DateTime createdAt;
  final DateTime updatedAt;

  Shop({
    required this.id,
    required this.name,
    required this.description,
    required this.location,
    required this.latitude,
    required this.longitude,
    required this.floor,
    required this.gate,
    required this.stadiumId,
    required this.stadiumName,
    required this.shopUserFcmToken,
    required this.admins,
    required this.shopAvailability,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Shop.fromMap(String id, Map<String, dynamic> map) {
    return Shop(
      id: id,
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      location: map['location'] ?? '',
      latitude: (map['latitude'] ?? 0.0).toDouble(),
      longitude: (map['longitude'] ?? 0.0).toDouble(),
      floor: map['floor'] ?? '',
      gate: map['gate'] ?? '',
      stadiumId: map['stadiumId'] ?? '',
      stadiumName: map['stadiumName'] ?? '',
      shopUserFcmToken: map['shopUserFcmToken'] ?? '',
      admins: List<String>.from(map['admins'] ?? []),
      shopAvailability: map['shopAvailability'] ?? true,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
    );
  }
}
