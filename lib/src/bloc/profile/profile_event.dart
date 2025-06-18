part of 'profile_bloc.dart';

@immutable
abstract class ProfileEvent {}

class FetchFavorites extends ProfileEvent {}

class ToggleFavoriteFood extends ProfileEvent {
  final String shopId;
  final String stadiumId;
  final String foodId;

  ToggleFavoriteFood( {required this.foodId,required this.shopId, required this.stadiumId,});
}

class ToggleFavoriteRestaurant extends ProfileEvent {
  final String restaurantId;

  ToggleFavoriteRestaurant({required this.restaurantId});
}

class FetchOrderStats extends ProfileEvent {}
