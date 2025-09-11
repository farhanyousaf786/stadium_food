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

  Future<List<FoodCategory>> fetchCategoriesForStadium(String stadiumId) async {
    // Try stadium-specific subcollection first: stadiums/{stadiumId}/categories
    try {
      final snapshot = await _db.firestore
          .collection('stadiums')
          .doc(stadiumId)
          .collection('categories')
          .get();
      if (snapshot.docs.isNotEmpty) {
        return snapshot.docs.map((doc) {
          final data = doc.data();
          return FoodCategory.fromMap(data, docId: doc.id);
        }).toList();
      }
    } catch (_) {
      // ignore and fallback to root
    }

    // Fallback to root collection
    return await fetchCategories();
  }

  Future<List<FoodCategory>> fetchCategoriesScoped({required String stadiumId, required String shopId}) async {
    // 1) Try stadiums/{stadiumId}/shops/{shopId}/categories
    try {
      final snapshot = await _db.firestore
          .collection('stadiums')
          .doc(stadiumId)
          .collection('shops')
          .doc(shopId)
          .collection('categories')
          .get();
      if (snapshot.docs.isNotEmpty) {
        return snapshot.docs.map((doc) {
          final data = doc.data();
          return FoodCategory.fromMap(data, docId: doc.id);
        }).toList();
      }
    } catch (_) {}

    // 2) Try shops/{shopId}/categories
    try {
      final snapshot = await _db.firestore
          .collection('shops')
          .doc(shopId)
          .collection('categories')
          .get();
      if (snapshot.docs.isNotEmpty) {
        return snapshot.docs.map((doc) {
          final data = doc.data();
          return FoodCategory.fromMap(data, docId: doc.id);
        }).toList();
      }
    } catch (_) {}

    // 3) Try stadium-level
    final stadiumLevel = await fetchCategoriesForStadium(stadiumId);
    if (stadiumLevel.isNotEmpty) return stadiumLevel;

    // 4) Fallback to root
    return await fetchCategories();
  }
}
