import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:stadium_food/src/core/config/app_config.dart';

class StripeConfig {
  /// Prefer server `/api/config` (admin toggle). Fall back to .env only if
  /// AppConfig has not loaded a publishable key yet.
  static bool get isLiveMode {
    if (AppConfig.loaded) {
      return !AppConfig.useTestApis;
    }
    final value = dotenv.env['STRIPE_USE_LIVE_MODE'];
    return value?.toLowerCase() != 'false';
  }

  static String get publishableKey {
    final fromApi = AppConfig.stripePublishableKey;
    if (fromApi != null && fromApi.isNotEmpty) {
      return fromApi;
    }

    final key = isLiveMode
        ? dotenv.env['STRIPE_LIVE_PUBLISHABLE_KEY']
        : dotenv.env['STRIPE_TEST_PUBLISHABLE_KEY'];
    if (key == null || key.isEmpty || key.contains('YOUR_')) {
      throw Exception(
        'Stripe publishable key is missing. '
        'Ensure /api/config returns a key or add it to .env.',
      );
    }
    return key;
  }

  static String get baseUrl => '${AppConfig.apiBase}/api/stripe';

  static String get mode => isLiveMode ? 'LIVE' : 'TEST';
}
