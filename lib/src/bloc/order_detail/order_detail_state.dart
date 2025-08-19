part of 'order_detail_bloc.dart';

abstract class OrderDetailState {}

class OrderDetailInitial extends OrderDetailState {}

class OrderDetailLoading extends OrderDetailState {}

class OrderDetailLoaded extends OrderDetailState {
  final Order order;
  OrderDetailLoaded(this.order);
}

class OrderDetailError extends OrderDetailState {
  final String message;
  OrderDetailError(this.message);
}
