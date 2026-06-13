import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hive/hive.dart';
import 'firestore_db.dart';

class GuestAuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final Box<dynamic> _box = Hive.box('myBox');

  /// Checks if there's any user logged in (real or anonymous)
  static bool get isLoggedIn {
    final user = _auth.currentUser;
    return user != null;
  }

  /// Checks if current user is anonymous
  static bool get isAnonymous {
    return _auth.currentUser?.isAnonymous ?? false;
  }

  /// Get current user ID (null if not logged in)
  static String? get currentUserId => _auth.currentUser?.uid;

  /// Automatically sign in anonymously if no user is logged in.
  /// Creates Firestore record and saves to Hive.
  static Future<void> ensureGuestUser() async {
    // If already signed in (real or anonymous), nothing to do
    if (_auth.currentUser != null) {
      // Just make sure Hive has the ID
      _box.put('id', _auth.currentUser!.uid);
      return;
    }

    try {
      final credential = await _auth.signInAnonymously();
      final uid = credential.user!.uid;

      final randomNum = Random().nextInt(9000) + 1000;
      final displayName = 'FanMunch User $randomNum';

      final userData = {
        'id': uid,
        'firstName': 'FanMunch',
        'lastName': 'User $randomNum',
        'displayName': displayName,
        'email': null,
        'phone': null,
        'image': null,
        'isAnonymous': true,
        'createdAt': DateTime.now(),
        'fcmToken': null,
        'isActive': true,
        'type': 'anonymous',
      };

      // Save to Firestore
      await FirestoreDatabase().addUserDocument('anonymous_users', uid, userData);

      // Save minimal info to Hive so app treats them as logged in
      _box.put('id', uid);
      _box.put('firstName', 'FanMunch');
      _box.put('lastName', 'User $randomNum');
      _box.put('email', '');
      _box.put('phone', '');
      _box.put('image', null);
      _box.put('isAnonymous', true);
    } catch (e) {
      // Silently fail — app will still show guest UI
      print('Guest auth failed: $e');
    }
  }

  /// Convert anonymous user to real account (link credentials).
  /// Should be called after email/password registration succeeds.
  static Future<void> linkAnonymousToRealAccount(String email, String password) async {
    final user = _auth.currentUser;
    if (user == null || !user.isAnonymous) return;

    final credential = EmailAuthProvider.credential(email: email, password: password);
    await user.linkWithCredential(credential);
  }

  /// Sign out and clear guest data
  static Future<void> signOut() async {
    await _auth.signOut();
    _box.delete('id');
    _box.delete('isAnonymous');
  }
}
