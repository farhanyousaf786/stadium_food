import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;

/// Currency model matching web
class AppCurrency {
  final String code;
  final String name;
  final String symbol;

  const AppCurrency({required this.code, required this.name, required this.symbol});
}

/// Currency Service — matches the web currency system exactly
/// - Base rates: USD
/// - 20 supported currencies
/// - 12-hour rate cache
/// - Convert from Firebase currency → user preferred currency
class CurrencyService {
  static const String _boxName = 'myBox';
  static const String _currencyKey = 'currency_preference';
  static const String _ratesCacheKey = 'currency_rates_cache';
  static const String _ratesTimestampKey = 'currency_rates_timestamp';
  static const Duration _cacheDuration = Duration(hours: 12);

  static const String defaultCurrency = 'USD';

  /// NIS→ILS alias for normalization
  static const Map<String, String> _aliases = {'NIS': 'ILS'};

  /// All 20 supported currencies — matching web exactly
  static const List<AppCurrency> availableCurrencies = [
    AppCurrency(code: 'ILS', name: 'Israeli Shekel', symbol: '₪'),
    AppCurrency(code: 'USD', name: 'US Dollar', symbol: '\$'),
    AppCurrency(code: 'EUR', name: 'Euro', symbol: '€'),
    AppCurrency(code: 'GBP', name: 'British Pound', symbol: '£'),
    AppCurrency(code: 'JPY', name: 'Japanese Yen', symbol: '¥'),
    AppCurrency(code: 'AUD', name: 'Australian Dollar', symbol: 'A\$'),
    AppCurrency(code: 'CAD', name: 'Canadian Dollar', symbol: 'C\$'),
    AppCurrency(code: 'CHF', name: 'Swiss Franc', symbol: 'CHF'),
    AppCurrency(code: 'CNY', name: 'Chinese Yuan', symbol: '¥'),
    AppCurrency(code: 'INR', name: 'Indian Rupee', symbol: '₹'),
    AppCurrency(code: 'MXN', name: 'Mexican Peso', symbol: '\$'),
    AppCurrency(code: 'BRL', name: 'Brazilian Real', symbol: 'R\$'),
    AppCurrency(code: 'ZAR', name: 'South African Rand', symbol: 'R'),
    AppCurrency(code: 'SGD', name: 'Singapore Dollar', symbol: 'S\$'),
    AppCurrency(code: 'HKD', name: 'Hong Kong Dollar', symbol: 'HK\$'),
    AppCurrency(code: 'NZD', name: 'New Zealand Dollar', symbol: 'NZ\$'),
    AppCurrency(code: 'SEK', name: 'Swedish Krona', symbol: 'kr'),
    AppCurrency(code: 'NOK', name: 'Norwegian Krone', symbol: 'kr'),
    AppCurrency(code: 'DKK', name: 'Danish Krone', symbol: 'kr'),
    AppCurrency(code: 'AED', name: 'UAE Dirham', symbol: 'د.إ'),
  ];

  /// Normalize currency code (handle NIS→ILS alias)
  static String _normalize(String code) => _aliases[code] ?? code;

  /// Get user's preferred currency (default: USD)
  static String getCurrentCurrency() {
    final saved = Hive.box(_boxName).get(_currencyKey, defaultValue: defaultCurrency) as String;
    if (availableCurrencies.any((c) => c.code == saved)) return saved;
    return defaultCurrency;
  }

  /// Set user's preferred currency
  static void setCurrency(String code) {
    if (!availableCurrencies.any((c) => c.code == code)) {
      throw ArgumentError('Invalid currency code: $code');
    }
    Hive.box(_boxName).put(_currencyKey, code);
  }

  /// Get currency info by code
  static AppCurrency? getCurrencyInfo(String code) {
    return availableCurrencies.firstWhere(
      (c) => c.code == code,
      orElse: () => availableCurrencies.firstWhere(
        (c) => c.code == defaultCurrency,
      ),
    );
  }

  /// Get symbol for a currency code
  static String getCurrencySymbol(String code) {
    return getCurrencyInfo(code)?.symbol ?? '\$';
  }

  /// Get cached rates from Hive
  static Map<String, dynamic>? _getCachedRates() {
    final box = Hive.box(_boxName);
    final ratesJson = box.get(_ratesCacheKey);
    final timestamp = box.get(_ratesTimestampKey) as int?;
    if (ratesJson == null || timestamp == null) return null;

    final age = DateTime.now().millisecondsSinceEpoch - timestamp;
    if (age > _cacheDuration.inMilliseconds) {
      debugPrint('💱 Currency cache expired');
      return null;
    }

    try {
      return jsonDecode(ratesJson) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  /// Save rates to Hive cache
  static Future<void> _saveRates(Map<String, dynamic> rates) async {
    final box = Hive.box(_boxName);
    await box.put(_ratesCacheKey, jsonEncode(rates));
    await box.put(_ratesTimestampKey, DateTime.now().millisecondsSinceEpoch);
  }

  /// Fetch fresh rates from API
  static Future<Map<String, dynamic>?> fetchRates() async {
    try {
      // Try server first (like web)
      try {
        final response = await http.get(
          Uri.parse('/api/currency/rates'),
        ).timeout(const Duration(seconds: 5));
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          if (data['success'] == true && data['rates'] != null) {
            final rates = data['rates'] as Map<String, dynamic>;
            await _saveRates(rates);
            return rates;
          }
        }
      } catch (_) {
        // Fall through
      }

      // Fallback: ExchangeRate-API (like web)
      final response = await http.get(
        Uri.parse('https://api.exchangerate-api.com/v4/latest/USD'),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['rates'] != null) {
          final allRates = data['rates'] as Map<String, dynamic>;
          // Extract only currencies we need
          final needed = availableCurrencies.map((c) => c.code).toList();
          final rates = <String, dynamic>{};
          for (final code in needed) {
            if (allRates[code] != null) {
              rates[code] = allRates[code];
            }
          }
          await _saveRates(rates);
          return rates;
        }
      }
    } catch (e) {
      debugPrint('❌ Currency rate fetch failed: $e');
    }
    return null;
  }

  /// Initialize rates on app startup (respects 12h cache)
  static Future<Map<String, dynamic>?> initializeRates({bool force = false}) async {
    if (!force) {
      final cached = _getCachedRates();
      if (cached != null) {
        debugPrint('✅ Using cached currency rates');
        return cached;
      }
    }
    return await fetchRates();
  }

  /// Convert price from Firebase currency to user's preferred currency
  static double convertPrice(double price, {String firebaseCurrency = 'ILS'}) {
    if (price <= 0) return 0;

    final normalizedFirebase = _normalize(firebaseCurrency);
    final userCurrency = getCurrentCurrency();

    // Same currency — no conversion
    if (userCurrency == normalizedFirebase) return price;

    final rates = _getCachedRates();
    if (rates == null) {
      debugPrint('⚠️ No rates available, returning original price');
      return price;
    }

    // All rates are relative to USD base
    // Step 1: Firebase currency → USD
    final firebaseRate = (rates[normalizedFirebase] as num?)?.toDouble() ?? 1.0;
    final priceInUSD = price / firebaseRate;

    // Step 2: USD → user currency
    final userRate = (rates[userCurrency] as num?)?.toDouble() ?? 1.0;
    final converted = priceInUSD * userRate;

    return converted;
  }

  /// Format price with symbol (matches web's formatPriceWithCurrency)
  static String formatPrice(double price, {String firebaseCurrency = 'ILS'}) {
    final converted = convertPrice(price, firebaseCurrency: firebaseCurrency);
    final symbol = getCurrencySymbol(getCurrentCurrency());
    return '$symbol${converted.toStringAsFixed(2)}';
  }

  /// Get conversion info (matches web's getPriceInfo)
  static PriceInfo getPriceInfo(double price, {String firebaseCurrency = 'ILS'}) {
    final converted = convertPrice(price, firebaseCurrency: firebaseCurrency);
    final userCurrency = getCurrentCurrency();
    final symbol = getCurrencySymbol(userCurrency);

    return PriceInfo(
      displayPrice: converted.toStringAsFixed(2),
      symbol: symbol,
      currencyCode: userCurrency,
      originalPrice: price,
      firebaseCurrency: _normalize(firebaseCurrency),
    );
  }
}

/// Price info model (matches web return type)
class PriceInfo {
  final String displayPrice;
  final String symbol;
  final String currencyCode;
  final double originalPrice;
  final String firebaseCurrency;

  PriceInfo({
    required this.displayPrice,
    required this.symbol,
    required this.currencyCode,
    required this.originalPrice,
    required this.firebaseCurrency,
  });
}
