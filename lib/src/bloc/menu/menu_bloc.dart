import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:stadium_food/src/data/models/food.dart';
import 'package:stadium_food/src/data/repositories/menu_repository.dart';

part 'menu_event.dart';
part 'menu_state.dart';

class MenuBloc extends Bloc<MenuEvent, MenuState> {
  final MenuRepository menuRepository = MenuRepository();
  List<Food> _allFoods = [];
  String _currentCategory = 'All';
  String _searchQuery = '';

  void _filterAndEmitMenuItems(Emitter<MenuState> emit) {
    List<Food> filteredFoods = _allFoods;

    // Apply category filter
    if (_currentCategory != 'All') {
      filteredFoods = filteredFoods.where((food) {
        final normalizedFoodCategory = food.category.toLowerCase().trim();
        final normalizedTargetCategory = _currentCategory.toLowerCase().trim();

        // Handle special categories
        switch (normalizedTargetCategory) {
          case 'snacks & street food':
            return normalizedFoodCategory.contains('snack') ||
                normalizedFoodCategory.contains('street');
          case 'salads & soups':
            return normalizedFoodCategory.contains('salad') ||
                normalizedFoodCategory.contains('soup');
          case 'pizza, pasta & burgers':
            return normalizedFoodCategory.contains('pizza') ||
                normalizedFoodCategory.contains('pasta') ||
                normalizedFoodCategory.contains('burger');
          case 'grill & bbq':
            return normalizedFoodCategory.contains('grill') ||
                normalizedFoodCategory.contains('bbq');
          case 'vegetarian / vegan':
            return normalizedFoodCategory.contains('vegetarian') ||
                normalizedFoodCategory.contains('vegan');
          case 'drinks & beverages':
            return normalizedFoodCategory.contains('drink') ||
                normalizedFoodCategory.contains('beverage');
          default:
            return normalizedFoodCategory
                .contains(normalizedTargetCategory.replaceAll('& ', ''));
        }
      }).toList();
    }

    if (_searchQuery.isNotEmpty) {
      filteredFoods = filteredFoods.where((food) {
        return food.name.toLowerCase().contains(_searchQuery) ||
            food.description.toLowerCase().contains(_searchQuery);
      }).toList();
    }

    emit(MenuLoaded(foods: filteredFoods));
  }

  MenuBloc() : super(MenuInitial()) {
    on<LoadStadiumMenu>((event, emit) async {
      emit(MenuLoading());
      try {
        Map<String, dynamic> map = await menuRepository.fetchStadiumMenu(
          event.stadiumId,

        );
        _allFoods = map["menuItems"] as List<Food>;
        emit(MenuLoaded(
          foods: _allFoods,

        ));
      } catch (e) {
        debugPrint(e.toString());
        emit(MenuError(message: e.toString()));
      }
    });

    on<FilterMenuByCategory>((event, emit) async {
      _currentCategory = event.category;
      _filterAndEmitMenuItems(emit);
    });

    on<FilterMenuBySearch>((event, emit) {
      _searchQuery = event.query.toLowerCase();
      _filterAndEmitMenuItems(emit);
    });
  }
}
