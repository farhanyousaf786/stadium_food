import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import 'package:stadium_food/src/data/models/restaurant.dart';
import 'package:stadium_food/src/data/services/firestore_db.dart';
import 'package:hive/hive.dart';

import '../models/food.dart';
import '../models/user.dart';

class ProfileRepository {
  final FirestoreDatabase _db = FirestoreDatabase();
  var box = Hive.box('myBox');

  // fetch favorite foods
  Future<List<Food>> fetchFavoriteFoods() async {
    List<DocumentReference> favoriteFoodsReferences =
        User.fromHive().favoriteFoods ?? [];
    List<Food> favoriteFoods = [];
    for (var foodReference in favoriteFoodsReferences) {
      try {
        DocumentSnapshot foodSnapshot = await foodReference.get();
        final data = foodSnapshot.data();
        if (data != null) {
          favoriteFoods.add(
            Food.fromMap(
              foodSnapshot.id,
              data as Map<String, dynamic>,
            ),
          );
        }
      } catch (e) {
        debugPrint('Error fetching favorite food: ${e.toString()}');
        // Continue to the next item if there's an error with this one
        continue;
      }
    }
    return favoriteFoods;
  }

  // fetch favorite restaurants
  // Future<List<Restaurant>> fetchFavoriteRestaurants() async {
  //   List<DocumentReference> favoriteRestaurantsReferences =
  //       User.fromHive().favoriteRestaurants ?? [];
  //   List<Restaurant> favoriteRestaurants = [];
  //   for (var restaurantReference in favoriteRestaurantsReferences) {
  //     DocumentSnapshot restaurantSnapshot = await restaurantReference.get();
  //     favoriteRestaurants.add(
  //       Restaurant.fromMap(
  //         restaurantSnapshot.data() as Map<String, dynamic>,
  //       )..id = restaurantSnapshot.id,
  //     );
  //   }
  //   return favoriteRestaurants;
  // }

  // add/remove favorite food
  Future<void> toggleFavoriteFood(String foodId,String shopId,String stadiumId) async {
    // get favorite foods from hive
    List<dynamic> favoriteFoods = box.get('favoriteFoods') as List<dynamic>? ?? [];


    DocumentReference foodReference =
        FirebaseFirestore.instance.doc('/stadiums/$stadiumId/shops/$shopId/menuItems/$foodId');
    // add/remove food id
    if (!favoriteFoods.contains(foodReference)) {
      favoriteFoods.add(foodReference);
    } else {
      favoriteFoods.remove(foodReference);
    }

    // update firestore
    await _db.updateDocument(
      'customers',
      box.get("id"),
      {
        'favoriteFoods': favoriteFoods,
      },
    );

    // update hive
    box.put('favoriteFoods', favoriteFoods);
  }

  // add/remove favorite restaurant
  // Future<void> toggleFavoriteRestaurant(String restaurantId) async {
  //   // get favorite restaurants from hive
  //   List favoriteRestaurants = box.get('favoriteRestaurants', defaultValue: []);
  //   DocumentReference restaurantReference =
  //       FirebaseFirestore.instance.doc('/restaurants/$restaurantId');
  //   // add/remove restaurant id
  //   if (!favoriteRestaurants.contains(restaurantReference)) {
  //     favoriteRestaurants.add(restaurantReference);
  //   } else {
  //     favoriteRestaurants.remove(restaurantReference);
  //   }
  //
  //   // update firestore
  //   await _db.updateDocument(
  //     'users',
  //     box.get("id"),
  //     {
  //       'favoriteRestaurants': favoriteRestaurants,
  //     },
  //   );
  //
  //   // update hive
  //   box.put('favoriteRestaurants', favoriteRestaurants);
  // }
}
