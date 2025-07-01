import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stadium_food/src/data/models/food.dart';
import 'package:stadium_food/src/data/services/firestore_db.dart';

class MenuRepository {
  final FirestoreDatabase _db = FirestoreDatabase();

  Future<Map<String, Object?>> fetchStadiumMenu(
      String stadiumId, int limit, DocumentSnapshot? lastDocument) async {
    QuerySnapshot menuCollection =
        await _db.getRootMenuItems(stadiumId, limit, lastDocument);

    List<Food> foods = [];
    for (var snapshot in menuCollection.docs) {
      try {
        var data = snapshot.data() as Map<String, dynamic>;
        foods.add(Food.fromMap(snapshot.id, data));
      } catch (e) {
        print('Error processing menu item ${snapshot.id}: $e');
        rethrow;
      }
    }

    return {
      "menuItems": foods,
      "lastDocument": menuCollection.docs.isEmpty ? null : menuCollection.docs.last
    };
  }
}
