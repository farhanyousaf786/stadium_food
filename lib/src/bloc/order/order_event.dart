part of 'order_bloc.dart';

@immutable
abstract class OrderEvent {}

class UpdateUI extends OrderEvent {}

class AddToCart extends OrderEvent {
  final Food food;

  AddToCart(this.food);
}

class AddToCartQty extends OrderEvent {
  final Food food;
  final int qty;

  AddToCartQty(this.food,this.qty);
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
  final String deliveryMethod;
  final String? pickupPointId;
  final String? deliveryType;
  final String? deliveryLocation;
  final String? deliveryNotes;
  final Map<String, dynamic>? insideDelivery;
  final Map<String, dynamic>? outsideDelivery;

  CreateOrder({
    required this.seatInfo,
    this.deliveryMethod = 'delivery',
    this.pickupPointId,
    this.deliveryType,
    this.deliveryLocation,
    this.deliveryNotes,
    this.insideDelivery,
    this.outsideDelivery,
  });
}

class FetchOrders extends OrderEvent {
  FetchOrders();
}

class UpdateTipEvent extends OrderEvent {
  final double tipAmount;

  UpdateTipEvent(this.tipAmount);
}

class FetchOrderById extends OrderEvent {
  final String orderId;

  FetchOrderById(this.orderId);
}
