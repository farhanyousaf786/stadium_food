import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class FirebaseStorageService {
  final FirebaseStorage _storage;

  FirebaseStorageService(this._storage);

  Future<String> uploadFile(String path, File file) async {
    try {
      final ref = _storage.ref().child(path);
      final uploadTask = ref.putFile(file);
      final snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      print('Error uploading file: $e');
      rethrow;
    }
  }

  Future<String> uploadTicketImage(String userId, File file) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final path = 'tickets/$userId/$timestamp.jpg';
    return uploadFile(path, file);
  }
}
