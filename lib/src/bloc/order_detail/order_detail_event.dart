part of 'order_detail_bloc.dart';

abstract class OrderDetailEvent {}

class FetchOrderDetail extends OrderDetailEvent {
  final String orderId;
  FetchOrderDetail(this.orderId);
}
