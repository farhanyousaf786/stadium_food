import 'package:cloud_firestore/cloud_firestore.dart';

class Stadium {
  final String id;
  final String name;
  final String about;
  final String location;
  final int capacity;
  final String imageUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  Stadium({
    required this.id,
    required this.name,
    required this.about,
    required this.location,
    required this.capacity,
    required this.imageUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Stadium.fromMap(String id, Map<String, dynamic> map) {
    return Stadium(
      id: id,
      name: map['name'] ?? '',
      about: map['about'] ?? '',
      location: map['location'] ?? '',
      capacity: map['capacity'] ?? 0,
      imageUrl: map['imageUrl'] ?? '',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
    );
  }
}
