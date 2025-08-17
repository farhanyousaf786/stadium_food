import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:stadium_food/src/data/models/order.dart' as model;
import 'package:stadium_food/src/data/models/order_status.dart';
import 'package:stadium_food/src/data/models/user.dart';
import 'package:stadium_food/src/data/repositories/shop_repository.dart';
import 'package:stadium_food/src/data/services/firestore_db.dart';
import 'package:hive/hive.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stadium_food/src/services/notification_class.dart';

import '../models/food.dart';

class OrderRepository {
  static String? selectedShopId;
  final FirestoreDatabase _db = FirestoreDatabase();
  static final List<Food> cart = [];

  static final Box<dynamic> box = Hive.box('myBox');
  static double _tip = 0;

  static double get tip => _tip;
  static set tip(double value) => _tip = value;

  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Future<double> getOrderTotal(String orderId) async {
    final doc = await _firestore.collection('orders').doc(orderId).get();
    if (doc.exists) {
      final data = doc.data();
      return (data?['total'] as num?)?.toDouble() ?? 0.0;
    }
    return 0.0;
  }

  // load cart from hive
  static void loadCart() {
    if (box.containsKey('cart')) {
      final List<Food> cartList = List<Food>.from(box.get('cart'));
      cart.clear();
      for (Food item in cartList) {
        cart.add(item);
      }
    }
  }

  // update cart in hive
  void updateHive() {
    box.put('cart', cart);
  }

  void addToCart(Food food) {
    // If cart is not empty, check if new item is from same shop
    if (cart.isNotEmpty) {
      String currentShopId = cart[0].shopIds.first;
      String newShopId = food.shopIds.first;

      // If from different shop, clear cart and reset quantities
      if (currentShopId != newShopId) {
        // Reset quantities of old items
        for (var item in cart) {
          item.quantity = 0;
        }
        // Clear cart
        cart.clear();
      }
    }

    // Add new item
    if (cart.contains(food)) {
      cart[cart.indexOf(food)].quantity++;
    } else {
      cart.add(food);
      food.quantity++;
    }
    updateHive();
  }

  void removeFromCart(Food food) {
    if (cart.contains(food)) {
      if (food.quantity > 1) {
        food.quantity--;
      }
    }
    updateHive();
  }

  void removeCompletelyFromCart(Food food) {
    if (cart.contains(food)) {
      cart.remove(food);
      food.quantity = 0;
    }
    updateHive();
  }

  // subtotal
  static double get subtotal {
    double total = 0;
    for (var food in cart) {
      total += food.price * food.quantity;
    }
    return total;
  }

  // delivery fee
  static double get deliveryFee {
    return 2;
  }

  // discount
  static double get discount {
    return 0;
  }

  // total
  static double get total {
    return subtotal + deliveryFee + tip - discount;
  }

  Future<model.Order> createOrder(Map<String, dynamic> seatInfo) async {
    final model.Order order = model.Order(
      cart: [...cart],
      subtotal: subtotal,
      deliveryFee: deliveryFee,
      discount: discount,
      total: total + tip,
      tipAmount: tip,
      isTipAdded: tip > 0,
      createdAt: Timestamp.now(),
      status: OrderStatus.pending,
      stadiumId: cart[0].stadiumId,
      shopId: selectedShopId ?? cart[0].shopIds.first,
      orderId: DateTime.now().millisecondsSinceEpoch.toString(),
      orderCode: getRandomSixDigitNumber().toString(),
      deliveryUserId: null,
      userInfo: {
        'userEmail': box.get('email') ?? '',
        'userName': box.get('firstName') ?? '',
        'userPhoneNo': box.get('phone') ?? '',
        'userId': box.get('id') ?? '',
      },
      seatInfo: {
        'ticketImage': seatInfo['ticketImage'] ?? '',
        'row': seatInfo['row'] ?? '',
        'seatNo': seatInfo['seatNo'] ?? '',
        'area': seatInfo['area'] ?? '',
        'entrance': seatInfo['entrance'] ?? '',
        'stand': seatInfo['stand'] ?? '',
        'seatDetails': seatInfo['seatDetails'] ?? '',
      },
    );

    // firestore
    await _db.addDocument(
      'orders',
      order.toMap(),
    );

    // try{
    //   final User user = User.fromHive();
    //   var shopInfo =
    //   await ShopRepository().findNearestShop(cart[0].stadiumId, cart[0].shopIds);
    //   NotificationServiceClass().sendNotification(shopInfo.shopUserFcmToken,
    //       'Order Received', 'You received a new order from ${user.fullName}');
    //
    // }catch (e) {
    //   if (kDebugMode) {
    //     print("Error occurred: $e");
    //   }
    // }

    cart.clear();
    updateHive();

    return order;
  }

  int getRandomSixDigitNumber() {
    final random = Random();
    return 100000 + random.nextInt(900000); // ensures it's always 6 digits
  }

  Future<List<model.Order>> fetchOrders() async {
    try {
      final userID = box.get('id');
      if (userID == null) {
        throw Exception('User ID not found. Please login again.');
      }

      final snapshot = await _db.firestore
          .collection('orders')
          .where('userId', isEqualTo: userID)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => model.Order.fromMap(doc.id, doc.data()))
          .toList();
    } catch (e) {
      debugPrint('Error fetching orders: ${e.toString()}');
      rethrow;
    }
  }

  Stream<List<model.Order>> streamOrders() {
    final userID = box.get('id');
    debugPrint('Current userID: $userID');
    if (userID == null) {
      return Stream.error('User ID not found. Please login again.');
    }

    return _db.firestore
        .collection('orders')
        .where('userInfo.userId', isEqualTo: userID)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => model.Order.fromMap(doc.id, doc.data()))
            .toList())
        .handleError((error) {
      debugPrint('Error streaming orders: ${error.toString()}');
      throw error;
    });
  }
}
