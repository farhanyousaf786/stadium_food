part of 'food_bloc.dart';

@immutable
abstract class FoodEvent {}

class LoadFoods extends FoodEvent {
  // limit, lastDocument
  final String stadiumId;
  final String shopId;
  final int limit;
  final DocumentSnapshot? lastDocument;

  LoadFoods( {
    required this.stadiumId,
    required this.shopId,
    required this.limit,
    required this.lastDocument,
  });
}

class FetchMoreFoods extends FoodEvent {
  // limit, lastDocument
  final String stadiumId;
  final String shopId;
  final int limit;
  final DocumentSnapshot? lastDocument;

  FetchMoreFoods({
    required this.stadiumId,
    required this.shopId,
    required this.limit,
    required this.lastDocument,
  });
}

class QueryFoods extends FoodEvent {}

class FetchOrderCount extends FoodEvent {
  final String foodId;

  FetchOrderCount({required this.foodId});
}
