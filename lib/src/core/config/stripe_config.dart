import 'package:firebase_remote_config/firebase_remote_config.dart';

class StripeConfig {
  static FirebaseRemoteConfig? _remoteConfig;
  
  // Default keys (fallback)
  static const String _defaultTestKey = 'pk_test_51RyfgTKj6LjssenC2Wy0Omeu3bQMa2hsc33riQoi43TU7AyIAQ08zELQWLOBvcRBgCyKMYIQ0rhOOsr0mTqanrse00W2xoKNg7';
  static const String _defaultLiveKey = 'pk_live_51RyfgTKj6LjssenCRD0rqWZWYdUcE2xtwcU2afFVpJsUREwjPeQT2nSzxNp4nz1qJ0hnajJiu1dDZd7IS4mqeNr500L4qiCfaz';
  
  static Future<void> initialize() async {
    _remoteConfig = FirebaseRemoteConfig.instance;
    
    // Set default values
    await _remoteConfig!.setDefaults({
      'stripe_use_live_mode': false,
      'stripe_test_publishable_key': _defaultTestKey,
      'stripe_live_publishable_key': _defaultLiveKey,
      'stripe_test_connected_account_id': 'acct_1S570jKWPD2pzAyo',
      'stripe_live_connected_account_id': 'acct_1S4nuc2zXMaebapc',
    });
    
    // Configure fetch settings
    await _remoteConfig!.setConfigSettings(RemoteConfigSettings(
      fetchTimeout: const Duration(seconds: 10),
      minimumFetchInterval: const Duration(minutes: 1),
    ));
    
    try {
      // Fetch and activate
      await _remoteConfig!.fetchAndActivate();
    } catch (e) {
      print('[STRIPE CONFIG] Remote config fetch failed: $e');
    }
  }
  
  static bool get isLiveMode {
    return _remoteConfig?.getBool('stripe_use_live_mode') ?? false;
  }
  
  static String get publishableKey {
    if (isLiveMode) {
      return _remoteConfig?.getString('stripe_live_publishable_key') ?? _defaultLiveKey;
    } else {
      return _remoteConfig?.getString('stripe_test_publishable_key') ?? _defaultTestKey;
    }
  }
  
  static String get baseUrl {
    return 'https://fans-munch-app-2-22c94417114b.herokuapp.com/api/stripe';
  }
  
  static String get connectedAccountId {
    if (isLiveMode) {
      return _remoteConfig?.getString('stripe_live_connected_account_id') ?? 'acct_1S4nuc2zXMaebapc';
    } else {
      return _remoteConfig?.getString('stripe_test_connected_account_id') ?? 'acct_1S570jKWPD2pzAyo';
    }
  }
  
  static String get mode => isLiveMode ? 'LIVE' : 'TEST';
}
