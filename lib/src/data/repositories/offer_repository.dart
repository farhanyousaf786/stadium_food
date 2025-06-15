import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/offer.dart';

class OfferRepository {
  final FirebaseFirestore _firestore;

  OfferRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Stream<List<Offer>> getOffers() {
    return _firestore
        .collectionGroup('offers')
        .where('active', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Offer.fromMap(doc.id, doc.data()))
          .toList();
    });
  }

  Future<List<Offer>> getOffersForStadium(String stadiumId) {
    return _firestore
        .collection('stadiums')
        .doc(stadiumId)
        .collection('offers')
        .where('active', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .get()
        .then((snapshot) {
      return snapshot.docs
          .map((doc) => Offer.fromMap(doc.id, doc.data()))
          .toList();
    });
  }
}
