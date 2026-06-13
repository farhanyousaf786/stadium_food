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
  String? _selectedShopId;
  List<String> _availableShopIds = [];

  /// Filter foods exactly like the web: stadium shops → selected shop → category → search → combo sort
  void _filterAndEmitMenuItems(Emitter<MenuState> emit) {
    List<Food> filteredFoods = _allFoods;

    // 1. Filter by shops belonging to the stadium (if available)
    if (_availableShopIds.isNotEmpty) {
      filteredFoods = filteredFoods.where((food) {
        if (food.shopIds.isNotEmpty) {
          return food.shopIds.any((id) => _availableShopIds.contains(id));
        }
        return true;
      }).toList();
    }

    // 2. Filter by selected shop
    if (_selectedShopId != null && _selectedShopId!.isNotEmpty) {
      filteredFoods = filteredFoods.where((food) {
        return food.shopIds.contains(_selectedShopId);
      }).toList();
    }

    // 3. Filter by category
    if (_currentCategoryId != 'All') {
      filteredFoods = filteredFoods.where((food) {
        return food.category == _currentCategoryId;
      }).toList();
    }

    // 4. Search: name, description, category, nameMap, descriptionMap
    if (_searchQuery.isNotEmpty) {
      filteredFoods = filteredFoods.where((food) {
        final lower = _searchQuery;
        final nameMatch = food.name.toLowerCase().contains(lower);
        final descMatch = food.description.toLowerCase().contains(lower);
        final catMatch = food.category.toLowerCase().contains(lower);
        // Check nameMap and descriptionMap
        final nameMapMatch = food.nameMap.values.any(
              (v) => v.toString().toLowerCase().contains(lower),
            );
        final descMapMatch = food.descriptionMap.values.any(
              (v) => v.toString().toLowerCase().contains(lower),
            );
        return nameMatch || descMatch || catMatch || nameMapMatch || descMapMatch;
      }).toList();
    }

    // 5. Sort: combos first, then regular items
    filteredFoods.sort((a, b) {
      if (a.isCombo && !b.isCombo) return -1;
      if (!a.isCombo && b.isCombo) return 1;
      return 0;
    });

    emit(MenuLoaded(foods: filteredFoods));
  }

  MenuBloc() : super(MenuInitial()) {
    on<LoadStadiumMenu>((event, emit) async {
      emit(MenuLoading());
      try {
        // Fetch menu items
        Map<String, dynamic> map = await menuRepository.fetchStadiumMenu(
          event.stadiumId,
        );
        _allFoods = map["menuItems"] as List<Food>;

        // Fetch shop IDs for this stadium (like web's loadAvailableShops)
        try {
          final shopsSnapshot = await FirebaseFirestore.instance
              .collection('shops')
              .where('stadiumId', isEqualTo: event.stadiumId)
              .get();
          _availableShopIds = shopsSnapshot.docs.map((d) => d.id).toList();
        } catch (_) {
          _availableShopIds = [];
        }

        _selectedShopId = null;
        _filterAndEmitMenuItems(emit);
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

    on<FilterMenuByShop>((event, emit) {
      _selectedShopId = event.shopId;
      _filterAndEmitMenuItems(emit);
    });
  }
}
