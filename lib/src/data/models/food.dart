import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

import 'package:hive/hive.dart';

// ignore: must_be_immutable
class Food extends Equatable {
  final String id;
  final List<String> allergens;
  final String category;
  final DateTime createdAt;
  final Map<String, dynamic> customization;
  final String description;
  final List<Map<String, dynamic>> extras;
  final List<String> images;
  final bool isAvailable;
  final String name;
  final Map<String, dynamic> nutritionalInfo;
  final int preparationTime;
  final double price;
  final List<Map<String, dynamic>> sauces;
  final String shopId;
  final String stadiumId;
  final List<Map<String, dynamic>> sizes;
  final List<Map<String, dynamic>> toppings;
  final DateTime updatedAt;

  // for cart
  int quantity = 1;

  Food({
    required this.id,
    required this.allergens,
    required this.category,
    required this.createdAt,
    required this.customization,
    required this.description,
    required this.extras,
    required this.images,
    required this.isAvailable,
    required this.name,
    required this.nutritionalInfo,
    required this.preparationTime,
    required this.price,
    required this.sauces,
    required this.shopId,
    required this.stadiumId,
    required this.sizes,
    required this.toppings,
    required this.updatedAt,
    this.quantity = 1,
  });

  factory Food.fromMap(String id, Map<String, dynamic> map) {
    return Food(
      id: id,
      allergens: List<String>.from(map['allergens'] ?? []),
      category: map['category'] ?? '',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      customization: Map<String, dynamic>.from(map['customization'] ?? {}),
      description: map['description'] ?? '',
      extras: List<Map<String, dynamic>>.from(map['extras']?.map(
            (x) => Map<String, dynamic>.from(x),
          ) ??
          []),
      images: List<String>.from(map['images'] ?? []),
      isAvailable: map['isAvailable'] ?? true,
      name: map['name'] ?? '',
      nutritionalInfo: Map<String, dynamic>.from(map['nutritionalInfo'] ?? {}),
      preparationTime: map['preparationTime'] ?? 15,
      price: (map['price'] ?? 0).toDouble(),
      sauces: List<Map<String, dynamic>>.from(map['sauces']?.map(
            (x) => Map<String, dynamic>.from(x),
          ) ??
          []),
      shopId: map['shopId'] ?? '',
      stadiumId: map['stadiumId'] ?? '',
      sizes: List<Map<String, dynamic>>.from(map['sizes']?.map(
            (x) => Map<String, dynamic>.from(x),
          ) ??
          []),
      toppings: List<Map<String, dynamic>>.from(map['toppings']?.map(
            (x) => Map<String, dynamic>.from(x),
          ) ??
          []),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),

      quantity: map['quantity'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'allergens': allergens,
      'category': category,
      'createdAt': createdAt,
      'customization': customization,
      'description': description,
      'extras': extras,
      'images': images,
      'isAvailable': isAvailable,
      'name': name,
      'nutritionalInfo': nutritionalInfo,
      'preparationTime': preparationTime,
      'price': price,
      'sauces': sauces,
      'shopId': shopId,
      'stadiumId': stadiumId,
      'sizes': sizes,
      'toppings': toppings,
      'updatedAt': updatedAt,
    };
  }

  // food is favorite
  bool get isFavorite {
    final box = Hive.box('myBox');
    final favorites = box.get('favoriteFoods') as List<dynamic>?;
    if (favorites == null || favorites.isEmpty) return false;
    DocumentReference ref = FirebaseFirestore.instance.doc('/stadiums/$stadiumId/shops/$shopId/menuItems/$id');
    return favorites.contains(ref);
  }

  @override
  List<Object> get props => [name, createdAt];
}
