import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:stadium_food/src/data/models/food.dart';
import 'package:stadium_food/src/data/models/order_status.dart';

// ignore: must_be_immutable
class Order extends Equatable {
  final List<Food> cart;
  final double subtotal;
  final double deliveryFee;
  final double discount;
  final double total;
  final double tipAmount;
  final Map<String, dynamic> userInfo;
  final String stadiumId;
  final String shopId;
  final String orderId;
  final OrderStatus status;
  final Timestamp? createdAt;
  final Timestamp? deliveryTime;
  final Map<String, dynamic> seatInfo;

  String? id;

  Order({
    required this.cart,
    required this.subtotal,
    required this.deliveryFee,
    required this.discount,
    required this.total,
    required this.tipAmount,
    required this.userInfo,
    required this.stadiumId,
    required this.shopId,
    required this.orderId,
    required this.status,
    required this.createdAt,
    this.deliveryTime,
    required this.seatInfo,
  });

  factory Order.fromMap(String id, Map<String, dynamic> map) {
    var order = Order(
      cart: List<Food>.from(
        map['cart']?.map(
              (x) => Food.fromMap(x['id'] as String, x as Map<String, dynamic>),
        ) ??
            [],
      ),
      subtotal: (map['subtotal'] ?? 0) * 1.0,
      deliveryFee: (map['deliveryFee'] ?? 0) * 1.0,
      discount: (map['discount'] ?? 0) * 1.0,
      total: (map['total'] ?? 0) * 1.0,
      tipAmount: (map['tipAmount'] ?? 0) * 1.0,
      userInfo: map['userInfo'] ?? {},
      stadiumId: map['stadiumId'] ?? '',
      shopId: map['shopId'] ?? '',
      orderId: map['orderId'] ?? '',
      status: OrderStatus.values[map['status'] ?? 0],
      createdAt: map['createdAt'] as Timestamp?,
      deliveryTime: map['deliveryTime'] as Timestamp?,
      seatInfo: map['seatInfo'] ?? {},
    );
    order.id = id;
    return order;
  }

  Map<String, dynamic> toMap() {
    return {
      'cart': cart.map((x) {
        var food = x.toMap();
        food['quantity'] = x.quantity;
        return food;
      }).toList(),
      'subtotal': subtotal,
      'deliveryFee': deliveryFee,
      'discount': discount,
      'total': total,
      'tipAmount': tipAmount,
      'userInfo': userInfo,

      'stadiumId': stadiumId,
      'shopId': shopId,
      'orderId': orderId,
      'status': status.index,
      'createdAt': createdAt,
      'deliveryTime': deliveryTime,
      'seatInfo': seatInfo,
    };
  }

  @override
  List<Object?> get props => [
    id,
    cart,
    subtotal,
    deliveryFee,
    discount,
    total,
    tipAmount,
    userInfo,
    stadiumId,
    shopId,
    orderId,
    status,
    createdAt,
    seatInfo,
  ];
}
