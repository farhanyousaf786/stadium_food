import 'package:cloud_firestore/cloud_firestore.dart';

class Section {
  final String id; // Firestore document ID
  final String sectionId; // Redundant field stored in doc, from your schema
  final String sectionName;
  final int sectionNo;
  final int rows;
  final int column;
  final bool isActive;
  final List<String> shops; // List of Shop document IDs
  final DateTime createdAt;
  final DateTime updatedAt;

  Section({
    required this.id,
    required this.sectionId,
    required this.sectionName,
    required this.sectionNo,
    required this.rows,
    required this.column,
    required this.isActive,
    required this.shops,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Section.fromMap(String id, Map<String, dynamic> map) {
    return Section(
      id: id,
      sectionId: map['sectionId'] ?? id,
      sectionName: map['sectionName'] ?? '',
      sectionNo: (map['sectionNo'] ?? 0) is int
          ? map['sectionNo']
          : int.tryParse(map['sectionNo'].toString()) ?? 0,
      rows: (map['rows'] ?? 0) is int
          ? map['rows']
          : int.tryParse(map['rows'].toString()) ?? 0,
      column: (map['column'] ?? 0) is int
          ? map['column']
          : int.tryParse(map['column'].toString()) ?? 0,
      isActive: map['isActive'] ?? true,
      shops: List<String>.from(map['shops'] ?? const []),
      createdAt: (map['createdAt'] is Timestamp)
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.tryParse(map['createdAt']?.toString() ?? '') ?? DateTime.fromMillisecondsSinceEpoch(0),
      updatedAt: (map['updatedAt'] is Timestamp)
          ? (map['updatedAt'] as Timestamp).toDate()
          : DateTime.tryParse(map['updatedAt']?.toString() ?? '') ?? DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'sectionId': sectionId,
      'sectionName': sectionName,
      'sectionNo': sectionNo,
      'rows': rows,
      'column': column,
      'isActive': isActive,
      'shops': shops,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }
}
