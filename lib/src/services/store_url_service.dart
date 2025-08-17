import 'dart:io';
import 'package:url_launcher/url_launcher.dart';

class StoreUrlService {
  static Future<void> openStoreReview() async {
    final appId = Platform.isAndroid 
        ? 'com.fanmunch.stadium_food'  // Android package name
        : '6443935819';  // iOS App Store ID
        
    try {
      if (Platform.isAndroid) {
        final url = Uri.parse('market://details?id=$appId');
        if (await canLaunchUrl(url)) {
          await launchUrl(url);
        } else {
          // Fallback to Play Store website
          await launchUrl(
            Uri.parse('https://play.google.com/store/apps/details?id=$appId'),
          );
        }
      } else if (Platform.isIOS) {
        final url = Uri.parse('itms-apps://itunes.apple.com/app/id$appId?action=write-review');
        if (await canLaunchUrl(url)) {
          await launchUrl(url);
        }
      }
    } catch (e) {
      print('Error opening store review: $e');
    }
  }
}
