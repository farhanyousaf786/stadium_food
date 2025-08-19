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
  StreamSubscription? _ordersSubscription;

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
      await _ordersSubscription?.cancel();
      _ordersSubscription = orderRepository.streamOrders().listen(
            (orders) => add(_UpdateOrders(orders)),
            onError: (error) => add(_OrderError(error.toString())),
          );
    });

    on<_UpdateOrders>((event, emit) {
      emit(OrdersFetched(event.orders));
    });

    on<_OrderError>((event, emit) {
      emit(OrderFetchingError(event.message));
    });

    on<FetchOrderById>((event, emit) async {
      emit(SingleOrderFetching());
      await emit.forEach<Order>(
        orderRepository.streamOrderById(event.orderId),
        onData: (order) => SingleOrderFetched(order),
        onError: (error, stackTrace) {
          debugPrint(error.toString());
          debugPrint(stackTrace.toString());
          return SingleOrderError(error.toString());
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
    await _ordersSubscription?.cancel();
    return super.close();
  }
}

// Private events for internal bloc usage
class _UpdateOrders extends OrderEvent {
  final List<Order> orders;
  _UpdateOrders(this.orders);
}

class _OrderError extends OrderEvent {
  final String message;
  _OrderError(this.message);
}
