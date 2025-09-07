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
  String _currentCategoryId = 'All';
  String _searchQuery = '';

  void _filterAndEmitMenuItems(Emitter<MenuState> emit) {
    List<Food> filteredFoods = _allFoods;

    // Apply category filter by category ID stored on Food.category
    if (_currentCategoryId != 'All') {
      filteredFoods = filteredFoods.where((food) {
        return food.category == _currentCategoryId;
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
      _currentCategoryId = event.category;
      _filterAndEmitMenuItems(emit);
    });

    on<FilterMenuBySearch>((event, emit) {
      _searchQuery = event.query.toLowerCase();
      _filterAndEmitMenuItems(emit);
    });
  }
}
