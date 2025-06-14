import 'package:firebase_auth/firebase_auth.dart';
import 'package:stadium_food/src/data/services/firebase_auth.dart';
import 'package:hive/hive.dart';

class SettingsRepository {
  // Toggle theme between light and dark mode
  Future<void> toggleTheme() async {
    final box = Hive.box('myBox');
    bool currentMode = box.get('isDarkMode', defaultValue: false);
    await box.put('isDarkMode', !currentMode);
  }

  // Log out the user
  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
    FirebaseAuthService(FirebaseAuth.instance).signOut();
    bool isDarkMode = await Hive.box('myBox').get('isDarkMode');
    await Hive.box('myBox').clear();
    await Hive.box('myBox').put('isDarkMode', isDarkMode);
  }
}
