import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/shop.dart';
import '../../services/location_service.dart';

class ShopRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final LocationService _locationService = LocationService();

  Future<List<Shop>> fetchShopsByStadium(String stadiumId) async {
    final querySnapshot = await _firestore
        .collection('shops')
        .where('stadiumId', isEqualTo: stadiumId)
        .where('shopAvailability',isEqualTo: true)
        .get();
    return querySnapshot.docs
        .map((doc) => Shop.fromMap(doc.id, doc.data()))
        .toList();
  }

  Future<Shop> fetchShop(String stadiumId, String shopId) async {
    final doc = await _firestore.collection('shops').doc(shopId).get();
    return Shop.fromMap(
      doc.id,
      doc.data() as Map<String, dynamic>,
    );
  }

  Future<Shop> findNearestShop(String stadiumId, List<String> shopIds) async {
    try {
      final userLocation = await _locationService.getCurrentLocation();
      
      // Get all shops that have any of the shopIds
      final querySnapshot = await _firestore
          .collection('shops')
          .where('stadiumId', isEqualTo: stadiumId)
          .where('shopAvailability', isEqualTo: true)
          .get();

      if (querySnapshot.docs.isEmpty) {
        throw Exception('No shops found');
      }

      // Convert to Shop objects and find nearest
      Shop? nearestShop;
      double? shortestDistance;

      for (var doc in querySnapshot.docs) {
        final shop = Shop.fromMap(doc.id, doc.data());
        final distance = _locationService.calculateDistance(
          userLocation.latitude,
          userLocation.longitude,
          shop.latitude,
          shop.longitude
        );

        if (shortestDistance == null || distance < shortestDistance) {
          shortestDistance = distance;
          nearestShop = shop;
        }
      }

      return nearestShop!;
    } catch (e) {
      // Fallback to first shop if location fails
      return fetchShop(stadiumId, shopIds.first);
    }
  }
}
