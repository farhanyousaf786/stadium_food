import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stadium_food/src/data/models/food.dart';
import 'package:stadium_food/src/data/models/restaurant.dart';
import 'package:hive_flutter/adapters.dart';

class FirestoreDocumentReferenceAdapter extends TypeAdapter<DocumentReference> {
  @override
  final int typeId = 0;

  @override
  DocumentReference read(BinaryReader reader) {
    return FirebaseFirestore.instance.doc(reader.read());
  }

  @override
  void write(BinaryWriter writer, DocumentReference obj) {
    writer.write(obj.path);
  }
}

class FoodAdapter extends TypeAdapter<Food> {
  @override
  final int typeId = 1;

  @override
  Food read(BinaryReader reader) {
    final data = reader.read() as List<dynamic>;

    T getOr<T>(int index, T fallback) {
      if (index < data.length && data[index] is T) return data[index] as T;
      return fallback;
    }

    Map<String, String> mapStringStringOr(int index) {
      if (index < data.length && data[index] is Map) {
        return Map<String, dynamic>.from(data[index] as Map)
            .map((k, v) => MapEntry(k.toString(), v?.toString() ?? ''));
      }
      return <String, String>{};
    }

    List<Map<String, dynamic>> listOfMapOr(int index) {
      if (index < data.length && data[index] is List) {
        return (data[index] as List)
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList();
      }
      return <Map<String, dynamic>>[];
    }

    return Food(
      name: getOr<String>(0, ''),
      price: getOr<double>(1, 0.0),
      description: getOr<String>(2, ''),
      category: getOr<String>(3, ''),
      images: (getOr<List<dynamic>>(4, const [])).map((e) => e.toString()).toList(),
      id: getOr<String>(5, ''),
      allergens: (getOr<List<dynamic>>(6, const [])).map((e) => e.toString()).toList(),
      customization: Map<String, dynamic>.from(getOr<Map>(7, {})),
      extras: listOfMapOr(8),
      isAvailable: getOr<bool>(9, true),
      nutritionalInfo: Map<String, dynamic>.from(getOr<Map>(10, {})),
      preparationTime: getOr<int>(11, 15),
      sauces: listOfMapOr(12),
      shopIds: (getOr<List<dynamic>>(13, const [])).map((e) => e.toString()).toList(),
      stadiumId: getOr<String>(14, ''),
      sizes: listOfMapOr(15),
      toppings: listOfMapOr(16),
      updatedAt: getOr<DateTime>(17, DateTime.now()),
      foodType: (getOr<Map>(18, {'halal': false, 'kosher': false, 'vegan': false}))
          .map((k, v) => MapEntry(k.toString(), v as bool)),
      // Newly added fields (appended at the end in write())
      categoryMap: mapStringStringOr(19),
      descriptionMap: mapStringStringOr(20),
      nameMap: mapStringStringOr(21),
      createdAt: getOr<DateTime>(22, DateTime.now()),
      quantity: getOr<int>(23, 1),
    );
  }

  @override
  void write(BinaryWriter writer, Food obj) {
    writer.write([
      // Keep existing indices stable (0..18)
      obj.name, // 0
      obj.price, // 1
      obj.description, // 2
      obj.category, // 3
      obj.images, // 4
      obj.id, // 5
      obj.allergens, // 6
      obj.customization, // 7
      obj.extras, // 8
      obj.isAvailable, // 9
      obj.nutritionalInfo, // 10
      obj.preparationTime, // 11
      obj.sauces, // 12
      obj.shopIds, // 13
      obj.stadiumId, // 14
      obj.sizes, // 15
      obj.toppings, // 16
      obj.updatedAt, // 17
      obj.foodType, // 18
      // Append new fields to avoid breaking older data
      obj.categoryMap, // 19
      obj.descriptionMap, // 20
      obj.nameMap, // 21
      obj.createdAt, // 22
      obj.quantity, // 23
    ]);
  }
}

class RestaurantAdapter extends TypeAdapter<Restaurant> {
  @override
  final int typeId = 3;

  @override
  Restaurant read(BinaryReader reader) {
    return Restaurant(
      name: reader.read(),
      location: reader.read(),
      createdAt: reader.read(),
      image: reader.read(),
      description: reader.read(),
    );
  }

  @override
  void write(BinaryWriter writer, Restaurant obj) {
    writer.write(obj.name);
    writer.write(obj.location);
    writer.write(obj.createdAt);
    writer.write(obj.image);
    writer.write(obj.description);
  }
}
