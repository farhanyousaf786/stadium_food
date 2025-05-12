import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import '../../data/models/shop.dart';
import '../../data/repositories/shop_repository.dart';

part 'shop_event.dart';
part 'shop_state.dart';

class ShopBloc extends Bloc<ShopEvent, ShopState> {
  final ShopRepository _repository = ShopRepository();

  ShopBloc() : super(ShopInitial()) {
    on<LoadShops>((event, emit) async {
      emit(ShopsLoading());
      try {
        final shops = await _repository.fetchShopsByStadium(event.stadiumId);
        emit(ShopsLoaded(shops));
      } catch (e) {
        emit(ShopError(e.toString()));
      }
    });
  }
}
