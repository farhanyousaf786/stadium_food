import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

import 'package:hive/hive.dart';

// ignore: must_be_immutable
class Food extends Equatable {
  final String id;
  final List<String> allergens;
  final String category;
  final Map<String, String> categoryMap;
  final DateTime createdAt;
  final Map<String, dynamic> customization;
  final String description;
  final Map<String, String> descriptionMap;
  final List<Map<String, dynamic>> extras;
  final List<String> images;
  final bool isAvailable;
  final bool isCombo;
  final List<String> comboItemIds;
  final String name;
  final Map<String, String> nameMap;
  final Map<String, dynamic> nutritionalInfo;
  final int preparationTime;
  final double price;
  final double costOfGoods;
  final bool hasCOG;
  final String currency;
  final List<Map<String, dynamic>> sauces;
  final List<String> shopIds;
  final String stadiumId;
  final List<Map<String, dynamic>> sizes;
  final List<Map<String, dynamic>> toppings;
  final DateTime updatedAt;
  final Map<String, bool> foodType;

  int quantity = 1;

  Food({
    required this.id,
    required this.allergens,
    required this.category,
    this.categoryMap = const {},
    required this.createdAt,
    required this.customization,
    required this.description,
    this.descriptionMap = const {},
    required this.extras,
    required this.images,
    required this.isAvailable,
     this.isCombo=false,
    this.comboItemIds = const [],
    required this.name,
    this.nameMap = const {},
    required this.nutritionalInfo,
    required this.preparationTime,
    required this.price,
    this.costOfGoods = 0,
    this.hasCOG = false,
    this.currency = 'ILS',
    required this.sauces,
    required this.shopIds,
    required this.stadiumId,
    required this.sizes,
    required this.toppings,
    required this.updatedAt,
    required this.foodType,
    this.quantity = 1,
  });

  factory Food.fromMap(String id, Map<String, dynamic> map) {
    return Food(
      id: id,
      allergens: (map['allergens'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      category: map['category'] ?? '',
      categoryMap: (map['categoryMap'] as Map<String, dynamic>?)
              ?.map((key, value) => MapEntry(key, value?.toString() ?? '')) ??
          {},
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      customization: (map['customization'] as Map<String, dynamic>?) ?? {},
      description: map['description'] ?? '',
      descriptionMap: (map['descriptionMap'] as Map<String, dynamic>?)
              ?.map((key, value) => MapEntry(key, value?.toString() ?? '')) ??
          {},
      extras: (map['extras'] as List<dynamic>?)
              ?.map((x) => Map<String, dynamic>.from(x))
              .toList() ??
          [],
      images: (map['images'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      isAvailable: map['isAvailable'] ?? true,
      isCombo: map['isCombo'] ?? false,
      comboItemIds: (map['comboItemIds'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      name: map['name'] ?? '',
      nameMap: (map['nameMap'] as Map<String, dynamic>?)
              ?.map((key, value) => MapEntry(key, value?.toString() ?? '')) ??
          {},
      nutritionalInfo: (map['nutritionalInfo'] as Map<String, dynamic>?) ?? {},
      preparationTime: map['preparationTime'] ?? 15,
      price: (map['price'] ?? 0).toDouble(),
      costOfGoods: (map['costOfGoods'] ?? 0).toDouble(),
      hasCOG: map['hasCOG'] ?? false,
      currency: map['currency'] ?? 'ILS',
      sauces: (map['sauces'] as List<dynamic>?)
              ?.map((x) => Map<String, dynamic>.from(x))
              .toList() ??
          [],
      shopIds: map['shopIds'] != null
          ? List<String>.from(map['shopIds'])
          : (map['shopId'] != null && map['shopId'].toString().isNotEmpty
              ? [map['shopId'].toString()]
              : []),
      stadiumId: map['stadiumId'] ?? '',
      sizes: (map['sizes'] as List<dynamic>?)
              ?.map((x) => Map<String, dynamic>.from(x))
              .toList() ??
          [],
      toppings: (map['toppings'] as List<dynamic>?)
              ?.map((x) => Map<String, dynamic>.from(x))
              .toList() ??
          [],
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
      foodType: (map['foodType'] as Map<String, dynamic>?)?.map(
            (key, value) => MapEntry(key, value as bool),
          ) ??
          {
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
      'descriptionMap': descriptionMap,
      'extras': extras,
      'images': images,
      'isAvailable': isAvailable,
      'isCombo': isCombo,
      'name': name,
      'nameMap': nameMap,
      'nutritionalInfo': nutritionalInfo,
      'preparationTime': preparationTime,
      'price': price,
      'costOfGoods': costOfGoods,
      'hasCOG': hasCOG,
      'currency': currency,
      'sauces': sauces,
      'shopIds': shopIds,
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
    DocumentReference ref = FirebaseFirestore.instance
        .doc('/stadiums/$stadiumId/shops/${shopIds.first}/menuItems/$id');
    return favorites.contains(ref);
  }

  // Localization helpers (matches web getLocalizedName / getLocalizedText)
  String nameFor(String languageCode) =>
      _localized(nameMap, languageCode, name);

  String descriptionFor(String languageCode) =>
      _localized(descriptionMap, languageCode, description);

  String categoryFor(String languageCode) =>
      _localized(categoryMap, languageCode, category);

  static String _localized(
    Map<String, String> map,
    String languageCode,
    String fallback,
  ) {
    final primary = map[languageCode];
    if (primary != null && primary.trim().isNotEmpty) return primary.trim();
    final en = map['en'];
    if (en != null && en.trim().isNotEmpty) return en.trim();
    final he = map['he'];
    if (he != null && he.trim().isNotEmpty) return he.trim();
    for (final value in map.values) {
      if (value.trim().isNotEmpty) return value.trim();
    }
    return fallback;
  }

  Food copyWith({
    String? id,
    List<String>? allergens,
    String? category,
    Map<String, String>? categoryMap,
    DateTime? createdAt,
    Map<String, dynamic>? customization,
    String? description,
    Map<String, String>? descriptionMap,
    List<Map<String, dynamic>>? extras,
    List<String>? images,
    bool? isAvailable,
    bool? isCombo,
    List<String>? comboItemIds,
    String? name,
    Map<String, String>? nameMap,
    Map<String, dynamic>? nutritionalInfo,
    int? preparationTime,
    double? price,
    double? costOfGoods,
    bool? hasCOG,
    String? currency,
    List<Map<String, dynamic>>? sauces,
    List<String>? shopIds,
    String? stadiumId,
    List<Map<String, dynamic>>? sizes,
    List<Map<String, dynamic>>? toppings,
    DateTime? updatedAt,
    Map<String, bool>? foodType,
    int? quantity,
  }) {
    return Food(
      id: id ?? this.id,
      allergens: allergens ?? this.allergens,
      category: category ?? this.category,
      categoryMap: categoryMap ?? this.categoryMap,
      createdAt: createdAt ?? this.createdAt,
      customization: customization ?? this.customization,
      description: description ?? this.description,
      descriptionMap: descriptionMap ?? this.descriptionMap,
      extras: extras ?? this.extras,
      images: images ?? this.images,
      isAvailable: isAvailable ?? this.isAvailable,
      isCombo: isCombo ?? this.isCombo,
      comboItemIds: comboItemIds ?? this.comboItemIds,
      name: name ?? this.name,
      nameMap: nameMap ?? this.nameMap,
      nutritionalInfo: nutritionalInfo ?? this.nutritionalInfo,
      preparationTime: preparationTime ?? this.preparationTime,
      price: price ?? this.price,
      costOfGoods: costOfGoods ?? this.costOfGoods,
      hasCOG: hasCOG ?? this.hasCOG,
      currency: currency ?? this.currency,
      sauces: sauces ?? this.sauces,
      shopIds: shopIds ?? this.shopIds,
      stadiumId: stadiumId ?? this.stadiumId,
      sizes: sizes ?? this.sizes,
      toppings: toppings ?? this.toppings,
      updatedAt: updatedAt ?? this.updatedAt,
      foodType: foodType ?? this.foodType,
      quantity: quantity ?? this.quantity,
    );
  }

  @override
  List<Object> get props => [name, createdAt];
}
