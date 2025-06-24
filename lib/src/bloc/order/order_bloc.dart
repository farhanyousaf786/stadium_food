import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:stadium_food/src/data/models/food.dart';
import 'package:stadium_food/src/data/models/order.dart';
import 'package:stadium_food/src/data/repositories/order_repository.dart';

part 'order_event.dart';
part 'order_state.dart';

class OrderBloc extends Bloc<OrderEvent, OrderState> {
  final OrderRepository orderRepository = OrderRepository();

  OrderBloc() : super(OrderInitial()) {
    on<OrderEvent>((event, emit) {});
    on<UpdateUI>((event, emit) {
      emit(OrderInitial());
      emit(UIUpdated());
    });
    on<AddToCart>((event, emit) {
      emit(OrderInitial());
      orderRepository.addToCart(event.food);
      emit(CartUpdated(OrderRepository.cart));
    });
    on<RemoveFromCart>((event, emit) {
      emit(OrderInitial());
      orderRepository.removeFromCart(event.food);
      emit(CartUpdated(OrderRepository.cart));
    });
    on<RemoveCompletelyFromCart>((event, emit) {
      emit(OrderInitial());
      orderRepository.removeCompletelyFromCart(event.food);
      emit(CartUpdated(OrderRepository.cart));
    });
    on<CreateOrder>((event, emit) async {
      emit(OrderCreating());

      try {
        Order order = await orderRepository.createOrder(
          event.seatInfo,

        );
        emit(OrderCreated(order));
      } catch (e, s) {
        debugPrint(e.toString());
        debugPrint(s.toString());
        emit(OrderCreatingError(e.toString()));
      }
    });
    on<FetchOrders>((event, emit) async {
      emit(OrdersFetching());
      await emit.forEach<List<Order>>(
        orderRepository.streamOrders(),
        onData: (orders) => OrdersFetched(orders),
        onError: (error, stackTrace) {
          debugPrint(error.toString());
          debugPrint(stackTrace.toString());
          return OrderFetchingError(error.toString());
        },
      );
    });
    on<UpdateTipEvent>((event, emit) {
      emit(OrderInitial());
      OrderRepository.tip = event.tipAmount;
      emit(UIUpdated());
    });
  }

  @override
  Future<void> close() async {
    return super.close();
  }
}
