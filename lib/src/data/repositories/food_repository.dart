import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stadium_food/src/data/models/food.dart';

import '../services/firestore_db.dart';

class FoodRepository {
  final FirestoreDatabase _db = FirestoreDatabase();

  Future<List<Food>> fetchFoods(String stadiumId, String shopId) async {
    QuerySnapshot<Object?> foodsCollection =
        await _db.getStadiumMenuWithPagination(
      stadiumId,
      shopId,
      "menuItems",
    );

    // id is the document id
    List<Food> foods = [];
    for (var snapshot in foodsCollection.docs) {
      try {
        print('Processing document: ${snapshot.id}');
        var data = snapshot.data() as Map<String, dynamic>;
        print('Document data: $data');
        foods.add(Food.fromMap(snapshot.id, data));
      } catch (e, stackTrace) {
        print('Error processing document ${snapshot.id}: $e');
        print('Stack trace: $stackTrace');
        rethrow;
      }
    }

    // sort by date
    foods.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return foods;
  }

  // get number of orders for a food
  Future<int> getFoodOrderCount(String foodId) async {
    int count = 0;
    QuerySnapshot<Object?> ordersCollection = await _db.getCollection("orders");

    var data = ordersCollection.docs
        .map((snapshot) => snapshot.data() as Map<String, dynamic>)
        .toList();

    for (var order in data) {
      for (var food in order["cart"]) {
        if (food["id"] == foodId) {
          count += food["quantity"] as int;
        }
      }
    }

    return count;
  }
}
