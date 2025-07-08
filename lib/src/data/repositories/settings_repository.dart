import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:stadium_food/src/data/services/firebase_auth.dart';
import 'package:hive/hive.dart';

class SettingsRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  // Toggle theme between light and dark mode
  Future<void> toggleTheme() async {
    final box = Hive.box('myBox');
    bool currentMode = box.get('isDarkMode', defaultValue: false);
    await box.put('isDarkMode', !currentMode);
  }

  // Log out the user
  Future<void> logout() async {
    await _auth.signOut();
    FirebaseAuthService(_auth).signOut();
    bool isDarkMode = await Hive.box('myBox').get('isDarkMode');
    await Hive.box('myBox').clear();
    await Hive.box('myBox').put('isDarkMode', isDarkMode);
  }
  
  // Deactivate user account (set isActive to false)
  Future<void> deactivateAccount() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        // Update user document in Firestore
        await _firestore.collection('customers').doc(user.uid).update({
          'isActive': false,
          'deactivatedAt': FieldValue.serverTimestamp(),
        });
        
        // Log out the user
        await logout();
      } else {
        throw Exception('No user is currently signed in');
      }
    } catch (e) {
      throw Exception('Failed to deactivate account: ${e.toString()}');
    }
  }
}
