import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

import 'package:hive/hive.dart';

// ignore: must_be_immutable
class Offer extends Equatable {
  final String id;
  final List<String> allergens;
  final String category;
  final DateTime createdAt;
  final Map<String, dynamic> customization;
  final String description;
  final List<Map<String, dynamic>> extras;
  final List<String> images;
  final bool isAvailable;
  final bool active;
  final String name;
  final Map<String, dynamic> nutritionalInfo;
  final int preparationTime;
  final double price;
  final double discountPercentage;
  final List<Map<String, dynamic>> sauces;
  final String shopId;
  final String stadiumId;
  final List<Map<String, dynamic>> sizes;
  final List<Map<String, dynamic>> toppings;
  final DateTime updatedAt;
  final Map<String, bool> foodType; // Non-Halal, Non-Kosher, Non-Vegan

  // for cart
  int quantity = 1;

  Offer({
    required this.id,
    required this.allergens,
    required this.category,
    required this.createdAt,
    required this.customization,
    required this.description,
    required this.extras,
    required this.images,
    required this.isAvailable,
    required this.active,
    required this.name,
    required this.nutritionalInfo,
    required this.preparationTime,
    required this.price,
    required this.discountPercentage,
    required this.sauces,
    required this.shopId,
    required this.stadiumId,
    required this.sizes,
    required this.toppings,
    required this.updatedAt,
    required this.foodType,
    this.quantity = 1,
  });

  factory Offer.fromMap(String id, Map<String, dynamic> map) {
    return Offer(
      id: id,
      allergens: (map['allergens'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      category: map['category'] ?? '',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      customization: (map['customization'] as Map<String, dynamic>?) ?? {},
      description: map['description'] ?? '',
      extras: (map['extras'] as List<dynamic>?)?.map((x) => Map<String, dynamic>.from(x)).toList() ?? [],
      images: (map['images'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      isAvailable: map['isAvailable'] ?? true,
      active: map['active'] ?? true,
      name: map['name'] ?? '',
      nutritionalInfo: (map['nutritionalInfo'] as Map<String, dynamic>?) ?? {},
      preparationTime: map['preparationTime'] ?? 15,
      price: (map['price'] ?? 0).toDouble(),
      discountPercentage: (map['discountPercentage'] ?? 0).toDouble(),
      sauces: (map['sauces'] as List<dynamic>?)?.map((x) => Map<String, dynamic>.from(x)).toList() ?? [],
      shopId: map['shopId'] ?? '',
      stadiumId: map['stadiumId'] ?? '',
      sizes: (map['sizes'] as List<dynamic>?)?.map((x) => Map<String, dynamic>.from(x)).toList() ?? [],
      toppings: (map['toppings'] as List<dynamic>?)?.map((x) => Map<String, dynamic>.from(x)).toList() ?? [],
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
      foodType: (map['foodType'] as Map<String, dynamic>?)?.map(
        (key, value) => MapEntry(key, value as bool),
      ) ?? {
        'halal': false,
        'kosher': false,
        'vegan': false,
      },
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
      'active': active,
      'name': name,
      'nutritionalInfo': nutritionalInfo,
      'preparationTime': preparationTime,
      'price': price,
      'discountPercentage': discountPercentage,
      'sauces': sauces,
      'shopId': shopId,
      'stadiumId': stadiumId,
      'sizes': sizes,
      'toppings': toppings,
      'updatedAt': updatedAt,
      'foodType': foodType,
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
