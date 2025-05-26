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
    final fields = reader.read();
    return Food(
      name: fields[0] as String,
      price: fields[1] as double,
      description: fields[2] as String? ?? '',
      category: fields[3] as String,
      createdAt: DateTime.now(),
      images: fields[4] as List<String>,
      id: fields[5] as String,
      allergens: fields[6] as List<String>,
      customization: Map<String, dynamic>.from(fields[7]),
      extras: (fields[8] as List).map((e) => Map<String, dynamic>.from(e)).toList(),
      isAvailable: fields[9] as bool,
      nutritionalInfo: Map<String, dynamic>.from(fields[10]),
      preparationTime: fields[11] as int,
      sauces: (fields[12] as List).map((e) => Map<String, dynamic>.from(e)).toList(),
      shopId: fields[13] as String,
      stadiumId: fields[14] as String,
      sizes: (fields[15] as List).map((e) => Map<String, dynamic>.from(e)).toList(),
      toppings: (fields[16] as List).map((e) => Map<String, dynamic>.from(e)).toList(),
      updatedAt: fields[17] as DateTime,
      foodType: (fields[18] as Map).cast<String, bool>(),
    );
  }

  @override
  void write(BinaryWriter writer, Food obj) {
    writer.write([
      obj.name,
      obj.price,
      obj.description,
      obj.category,
      obj.images,
      obj.id,
      obj.allergens,
      obj.customization,
      obj.extras,
      obj.isAvailable,
      obj.nutritionalInfo,
      obj.preparationTime,
      obj.sauces,
      obj.shopId,
      obj.stadiumId,
      obj.sizes,
      obj.toppings,
      obj.updatedAt,
      obj.foodType,
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
