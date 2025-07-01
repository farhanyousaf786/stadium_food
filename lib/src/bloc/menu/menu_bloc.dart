import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:stadium_food/src/data/models/food.dart';
import 'package:stadium_food/src/data/repositories/menu_repository.dart';

part 'menu_event.dart';
part 'menu_state.dart';

class MenuBloc extends Bloc<MenuEvent, MenuState> {
  final MenuRepository menuRepository = MenuRepository();

  MenuBloc() : super(MenuInitial()) {
    on<LoadStadiumMenu>((event, emit) async {
      emit(MenuLoading());
      try {
        Map<String, dynamic> map = await menuRepository.fetchStadiumMenu(
          event.stadiumId,
          event.limit,
          event.lastDocument,
        );
        emit(MenuLoaded(
          foods: map["menuItems"] as List<Food>,
          lastDocument: map["lastDocument"] as DocumentSnapshot?,
        ));
      } catch (e) {
        debugPrint(e.toString());
        emit(MenuError(message: e.toString()));
      }
    });
  }
}
