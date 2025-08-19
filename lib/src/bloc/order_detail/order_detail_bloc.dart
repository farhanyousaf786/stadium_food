import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:stadium_food/src/data/models/order.dart';
import 'package:stadium_food/src/data/repositories/order_repository.dart';

part 'order_detail_event.dart';
part 'order_detail_state.dart';

class OrderDetailBloc extends Bloc<OrderDetailEvent, OrderDetailState> {
  final OrderRepository orderRepository = OrderRepository();
  StreamSubscription? _orderSubscription;

  OrderDetailBloc() : super(OrderDetailInitial()) {
    on<FetchOrderDetail>((event, emit) async {
      emit(OrderDetailLoading());
      await _orderSubscription?.cancel();
      
      _orderSubscription = orderRepository.streamOrderById(event.orderId).listen(
        (order) => add(_UpdateOrderDetail(order)),
        onError: (error) => add(_OrderDetailError(error.toString())),
      );
    });

    on<_UpdateOrderDetail>((event, emit) {
      emit(OrderDetailLoaded(event.order));
    });

    on<_OrderDetailError>((event, emit) {
      emit(OrderDetailError(event.message));
    });
  }

  @override
  Future<void> close() async {
    await _orderSubscription?.cancel();
    return super.close();
  }
}

// Private events
class _UpdateOrderDetail extends OrderDetailEvent {
  final Order order;
  _UpdateOrderDetail(this.order);
}

class _OrderDetailError extends OrderDetailEvent {
  final String message;
  _OrderDetailError(this.message);
}
