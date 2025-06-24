part of 'order_bloc.dart';

@immutable
abstract class OrderEvent {}

class UpdateUI extends OrderEvent {}

class AddToCart extends OrderEvent {
  final Food food;

  AddToCart(this.food);
}

class RemoveFromCart extends OrderEvent {
  final Food food;

  RemoveFromCart(this.food);
}

class RemoveCompletelyFromCart extends OrderEvent {
  final Food food;

  RemoveCompletelyFromCart(this.food);
}

class CreateOrder extends OrderEvent {
  final Map<String, dynamic> seatInfo;
  final double tipAmount;

  CreateOrder({required this.seatInfo, required this.tipAmount});
}

class FetchOrders extends OrderEvent {
  FetchOrders();
}
