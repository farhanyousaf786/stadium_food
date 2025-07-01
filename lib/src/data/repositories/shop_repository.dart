import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/shop.dart';

class ShopRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Shop>> fetchShopsByStadium(String stadiumId) async {
    final querySnapshot = await _firestore

        .collection('shops')
        .where('stadiumId', isEqualTo: stadiumId)
        .get();
    return querySnapshot.docs
        .map((doc) => Shop.fromMap(doc.id, doc.data()))
        .toList();
  }

  Future<Shop> fetchShop(String stadiumId,String shopId) async {
    final doc = await _firestore
        .collection('shops')
        .doc(shopId)
        .get();
    return Shop.fromMap(doc.id,
      doc.data() as Map<String, dynamic>,
    );
  }
}
