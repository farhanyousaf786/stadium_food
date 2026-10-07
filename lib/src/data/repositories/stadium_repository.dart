import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/stadium.dart';
import '../models/section.dart';

class StadiumRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Stadium>> fetchStadiums() async {
    final querySnapshot = await _firestore.collection('stadiums').get();
    return querySnapshot.docs
        .map((doc) => Stadium.fromMap(doc.id, doc.data()))
        .toList();
  }

  Future<Stadium?> getStadiumById(String id) async {
    if (id.isEmpty) return null;
    final doc = await _firestore.collection('stadiums').doc(id).get();
    if (!doc.exists || doc.data() == null) return null;
    return Stadium.fromMap(doc.id, doc.data()!);
  }

  Future<List<Stadium>> searchStadiums(String query) async {
    query = query.toLowerCase();
    final querySnapshot = await _firestore.collection('stadiums').get();
    return querySnapshot.docs
        .map((doc) => Stadium.fromMap(doc.id, doc.data()))
        .where((stadium) =>
            stadium.name.toLowerCase().contains(query) ||
            stadium.location.toLowerCase().contains(query))
        .toList();
  }

  Future<List<Section>> fetchSections(String stadiumId) async {
    final querySnapshot = await _firestore
        .collection('stadiums')
        .doc(stadiumId)
        .collection('sections')
        .get();
    return querySnapshot.docs
        .map((doc) => Section.fromMap(doc.id, doc.data()))
        .toList();
  }
}
