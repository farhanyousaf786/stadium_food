import 'package:cloud_firestore/cloud_firestore.dart';

class TipService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> updateTip(String orderId, double tipAmount) async {
    await _firestore.collection('orders').doc(orderId).update({
      'tipAmount': tipAmount,
      'isTipAdded': true,
      'total': FieldValue.increment(tipAmount),
    });
  }
}
