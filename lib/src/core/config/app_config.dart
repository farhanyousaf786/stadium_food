import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// Public app config from `GET /api/config` (matches web AppConfigContext).
class AppConfig {
  static const String apiBase =
      'https://fans-munch-app-2-22c94417114b.herokuapp.com';

  static bool useTestApis = false;
  static String? stripePublishableKey;
  static bool keysConfigured = false;
  static String? configMessage;
  static bool loaded = false;

  static String get paymentMode => useTestApis ? 'test' : 'live';

  /// Stripe test PaymentMethod that auto-succeeds (web: pm_card_visa / 4242).
  static const String testPaymentMethodId = 'pm_card_visa';

  static Future<void> load() async {
    try {
      final response = await http
          .get(Uri.parse('$apiBase/api/config'))
          .timeout(const Duration(seconds: 12));
      final data = jsonDecode(response.body);
      if (response.statusCode >= 400 || data is! Map) {
        throw Exception(data is Map ? data['error'] : 'Config request failed');
      }

      useTestApis = data['useTestApis'] == true;
      stripePublishableKey = data['stripePublishableKey'] as String?;
      keysConfigured = data['keysConfigured'] == true;
      configMessage = data['message'] as String?;
      loaded = true;

      if (kDebugMode) {
        print(
          '[AppConfig] mode=$paymentMode useTestApis=$useTestApis '
          'keysConfigured=$keysConfigured',
        );
      }
    } catch (e) {
      loaded = false;
      if (kDebugMode) {
        print('[AppConfig] Failed to load /api/config: $e');
      }
      rethrow;
    }
  }
}
