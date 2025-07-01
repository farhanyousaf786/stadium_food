part of 'shop_bloc.dart';

@immutable
abstract class ShopEvent {}

class LoadShops extends ShopEvent {
  final String stadiumId;
  LoadShops(this.stadiumId);


}

