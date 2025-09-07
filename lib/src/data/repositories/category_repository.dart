import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stadium_food/src/data/models/category.dart';
import 'package:stadium_food/src/data/services/firestore_db.dart';

class CategoryRepository {
  final FirestoreDatabase _db = FirestoreDatabase();

  Future<List<FoodCategory>> fetchCategories() async {
    final QuerySnapshot<Object?> snapshot = await _db.getCollection('categories');
    final List<FoodCategory> categories = [];

    for (final doc in snapshot.docs) {
      try {
        final data = doc.data() as Map<String, dynamic>;
        categories.add(FoodCategory.fromMap(data, docId: doc.id));
      } catch (e, s) {
        // Log and continue to allow others to load
        // ignore: avoid_print
        print('Error parsing category ${doc.id}: $e');
        // ignore: avoid_print
        print(s);
      }
    }

    return categories;
  }
}
