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
   // FirebaseAuthService(_auth).signOut();
   // bool isDarkMode = await Hive.box('myBox').get('isDarkMode');
   String lang= Hive.box('myBox').get('language', defaultValue: 'he');
    await Hive.box('myBox').clear();
    await Hive.box('myBox').put('language', lang);

   // await Hive.box('myBox').put('isDarkMode', isDarkMode);
  }
  
  // Delete user account completely (both Firestore document and Firebase Auth account)
  Future<void> deactivateAccount() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        // 1. Update user document in Firestore to mark as deleted
        await _firestore.collection('customers').doc(user.uid).update({
          'isActive': false,
        });
        
        // 2. Delete the actual Firebase Authentication account
        // This requires recent authentication, so we might need to re-authenticate
        try {
          // Delete the user account from Firebase Authentication
          await user.delete();
        } catch (authError) {
          // If error is due to requiring recent login, we'll need to handle that separately
          // For now, we'll just throw the error
          throw Exception('Authentication error: ${authError.toString()}. You may need to log out and log back in before deleting your account.');
        }
        
        // 3. Clear local data
      //  bool isDarkMode = await Hive.box('myBox').get('isDarkMode');
        String lang= Hive.box('myBox').get('language', defaultValue: 'he');
        await Hive.box('myBox').clear();
        await Hive.box('myBox').put('language', lang);
      //  await Hive.box('myBox').put('isDarkMode', isDarkMode);
        logout();
      } else {
        throw Exception('No user is currently signed in');
      }
    } catch (e) {
      throw Exception('Failed to delete account: ${e.toString()}');
    }
  }
}
