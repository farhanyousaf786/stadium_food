import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:stadium_food/src/data/models/food.dart';
import 'package:stadium_food/src/data/models/order_status.dart';
import 'package:stadium_food/src/data/repositories/order_repository.dart';
import 'package:stadium_food/src/data/repositories/profile_repository.dart';

part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final ProfileRepository profileRepository = ProfileRepository();
  // final OrderRepository orderRepository = OrderRepository();
  ProfileBloc() : super(ProfileInitial()) {
    on<ProfileEvent>((event, emit) {});
    // on<FetchOrderStats>((event, emit) async {
    //   emit(FetchingOrderStats());
    //   try {
    //     final orders = await orderRepository.fetchOrders();
    //     final activeOrders = orders.where((o) =>
    //       o.status == OrderStatus.pending ||
    //       o.status == OrderStatus.preparing ||
    //       o.status == OrderStatus.delivering
    //     ).length;
    //     final canceledOrders = orders.where((o) => o.status == OrderStatus.canceled).length;
    //     final completedOrders = orders.where((o) => o.status == OrderStatus.delivered).length;
    //
    //     emit(OrderStatsFetched(
    //       activeOrders: activeOrders,
    //       canceledOrders: canceledOrders,
    //       completedOrders: completedOrders,
    //     ));
    //   } catch (e, s) {
    //     debugPrint(e.toString());
    //     debugPrint(s.toString());
    //     emit(ProfileError(message: e.toString()));
    //   }
    // });
    on<FetchFavorites>((event, emit) async {
      emit(FetchingFavorites());
      try {
        List<Food> favoriteFoods = await profileRepository.fetchFavoriteFoods();
        // List<Restaurant> favoriteRestaurants =
        //     await profileRepository.fetchFavoriteRestaurants();
        emit(
          FavoritesFetched(
            favoriteFoods: favoriteFoods,
            // favoriteRestaurants: favoriteRestaurants,
          ),
        );
      } catch (e, s) {
        debugPrint(e.toString());
        debugPrint(s.toString());
        emit(ProfileError(message: e.toString()));
      }
    });

    on<ToggleFavoriteFood>((event, emit) async {
      try {
        emit(ProfileInitial());
        await profileRepository.toggleFavoriteFood(event.foodId,event.shopId,event.stadiumId);
        emit(FavoriteFoodToggled());
      } catch (e, s) {
        debugPrint(e.toString());
        debugPrint(s.toString());
        emit(ProfileError(message: e.toString()));
      }
    });
    // on<ToggleFavoriteRestaurant>((event, emit) async {
    //   try {
    //     emit(ProfileInitial());
    //     await profileRepository.toggleFavoriteRestaurant(event.restaurantId);
    //     emit(FavoriteRestaurantToggled());
    //   } catch (e, s) {
    //     debugPrint(e.toString());
    //     debugPrint(s.toString());
    //     emit(ProfileError(message: e.toString()));
    //   }
    // });
  }
}
