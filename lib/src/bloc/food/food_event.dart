part of 'food_bloc.dart';

@immutable
abstract class FoodEvent {}

class LoadFoods extends FoodEvent {
  // limit, lastDocument
  final String stadiumId;
  final String shopId;


  LoadFoods( {
    required this.stadiumId,
    required this.shopId,

  });
}



class QueryFoods extends FoodEvent {}

class FetchOrderCount extends FoodEvent {
  final String foodId;

  FetchOrderCount({required this.foodId});
}
