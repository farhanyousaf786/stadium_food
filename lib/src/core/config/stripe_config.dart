import 'package:flutter_dotenv/flutter_dotenv.dart';

class StripeConfig {
  /// Control mode from .env (default true since server is live).
  /// Set STRIPE_USE_LIVE_MODE=false only when testing against a test server.
  static bool get isLiveMode {
    final value = dotenv.env['STRIPE_USE_LIVE_MODE'];
    return value?.toLowerCase() != 'false';
  }

  static String get publishableKey {
    final key = isLiveMode
        ? dotenv.env['STRIPE_LIVE_PUBLISHABLE_KEY']
        : dotenv.env['STRIPE_TEST_PUBLISHABLE_KEY'];
    if (key == null || key.isEmpty || key.contains('YOUR_')) {
      throw Exception(
        'Stripe publishable key is missing. Add it to the .env file.',
      );
    }
    return key;
  }

  static String get baseUrl {
    return 'https://fans-munch-app-2-22c94417114b.herokuapp.com/api/stripe';
  }

  static String get mode => isLiveMode ? 'LIVE' : 'TEST';
}
