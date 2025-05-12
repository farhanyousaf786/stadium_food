part of 'shop_bloc.dart';

@immutable
abstract class ShopState {}

class ShopInitial extends ShopState {}

class ShopsLoading extends ShopState {}

class ShopsLoaded extends ShopState {
  final List<Shop> shops;

  ShopsLoaded(this.shops);
}

class ShopError extends ShopState {
  final String message;

  ShopError(this.message);
}
