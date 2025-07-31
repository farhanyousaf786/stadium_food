import 'package:hive/hive.dart';

class CurrencyService {
  static const String _boxName = 'myBox';
  static const String _currencyKey = 'currency';
  static const Map<String, double> _rates = {
    'USD': 1.0, // Base currency
    'NIS':
        3.75, // NIS to USD rate (approximate, you may want to use an API for live rates)
  };

  static String getCurrentCurrency() {
    return Hive.box(_boxName).get(_currencyKey, defaultValue: 'USD');
  }

  static void setCurrency(String currency) {
    if (!_rates.containsKey(currency)) {
      throw Exception('Unsupported currency: $currency');
    }
    Hive.box(_boxName).put(_currencyKey, currency);
  }

  static double convertFromUSD(double amount, String targetCurrency) {
    if (!_rates.containsKey(targetCurrency)) {
      throw Exception('Unsupported currency: $targetCurrency');
    }
    return amount * _rates[targetCurrency]!;
  }

  static double convertToUSD(double amount, String fromCurrency) {
    if (!_rates.containsKey(fromCurrency)) {
      throw Exception('Unsupported currency: $fromCurrency');
    }
    return amount / _rates[fromCurrency]!;
  }

  static String getCurrencySymbol(String currency) {
    switch (currency) {
      case 'USD':
        return '\$';
      case 'NIS':
        return '₪';
      default:
        return currency;
    }
  }
}
