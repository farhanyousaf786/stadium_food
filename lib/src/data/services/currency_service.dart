import 'package:hive/hive.dart';
import 'package:live_currency_rate/live_currency_rate.dart';

class CurrencyService {
  static const String _boxName = 'myBox';
  static const String _currencyKey = 'currency';
  // Base currency of the app: NIS
  static final Map<String, double> _ratesFromNIS = <String, double>{
    'NIS': 1.0,
    'USD': 0.27, // fallback approx
    'EUR': 0.25, // fallback approx
  };
  static DateTime? _lastFetch;
  static const Duration _cacheDuration = Duration(hours: 3);

  static String getCurrentCurrency() {
    return Hive.box(_boxName).get(_currencyKey, defaultValue: 'NIS');
  }

  static void setCurrency(String currency) {
    if (!_ratesFromNIS.containsKey(currency)) {
      throw Exception('Unsupported currency: $currency');
    }
    Hive.box(_boxName).put(_currencyKey, currency);
  }

  // Convert from base NIS to desired display currency
  static double convertFromNIS(double amount, String targetCurrency) {
    if (!_ratesFromNIS.containsKey(targetCurrency)) {
      throw Exception('Unsupported currency: $targetCurrency');
    }
    return amount * _ratesFromNIS[targetCurrency]!;
  }

  // Convert any currency to NIS (if needed in future)
  static double convertToNIS(double amount, String fromCurrency) {
    if (!_ratesFromNIS.containsKey(fromCurrency)) {
      throw Exception('Unsupported currency: $fromCurrency');
    }
    final rateFromNIS = _ratesFromNIS[fromCurrency]!;
    if (rateFromNIS == 0) return amount; // avoid div by zero
    return amount / rateFromNIS;
  }

  // Fetch latest rates (NIS->USD and NIS->EUR) and cache them
  static Future<void> refreshRates({bool force = false}) async {
    if (!force && _lastFetch != null) {
      final age = DateTime.now().difference(_lastFetch!);
      if (age < _cacheDuration) return;
    }

    try {
      // We request conversion of 1 NIS to target currencies
      final CurrencyRate usdRate =
          await LiveCurrencyRate.convertCurrency('NIS', 'USD', 1);
      final CurrencyRate eurRate =
          await LiveCurrencyRate.convertCurrency('NIS', 'EUR', 1);

      // The API returns the result amount for 1 NIS in target currency
      final double nisToUsd = (usdRate.result as num).toDouble();
      final double nisToEur = (eurRate.result as num).toDouble();

      if (nisToUsd > 0) {
        _ratesFromNIS['USD'] = nisToUsd;
      }
      if (nisToEur > 0) {
        _ratesFromNIS['EUR'] = nisToEur;
      }
      _lastFetch = DateTime.now();
    } catch (_) {
      // Silently keep fallback rates on failure
    }
  }

  static String getCurrencySymbol(String currency) {
    switch (currency) {
      case 'USD':
        return '\$';
      case 'NIS':
        return '₪';
      case 'EUR':
        return '€';
      default:
        return currency;
    }
  }

  // Backward compatibility helpers (legacy callers assumed USD base)
  // amount is in USD, convert to target currency via NIS base
  static double convertFromUSD(double amount, String targetCurrency) {
    // USD -> NIS
    final double inNis = convertToNIS(amount, 'USD');
    // NIS -> target
    return convertFromNIS(inNis, targetCurrency);
  }

  // Convert from any currency to USD
  static double convertToUSD(double amount, String fromCurrency) {
    // from -> NIS
    final double inNis = convertToNIS(amount, fromCurrency);
    // NIS -> USD
    return convertFromNIS(inNis, 'USD');
  }
}
