import 'package:translator/translator.dart';

class TranslationService {
  static final _translator = GoogleTranslator();

  // Translate text from English to Hebrew
  static Future<String> translateToHebrew(String text) async {
    if (text.isEmpty) return '';
    try {
      final translation = await _translator.translate(text, from: 'en', to: 'he');
      return translation.text;
    } catch (e) {
      print('Translation error: $e');
      return text;
    }
  }

  // Translate text from Hebrew to English
  static Future<String> translateToEnglish(String text) async {
    if (text.isEmpty) return '';
    try {
      final translation = await _translator.translate(text, from: 'he', to: 'en');
      return translation.text;
    } catch (e) {
      print('Translation error: $e');
      return text;
    }
  }

  // Create translation map for a text
  static Future<Map<String, String>> createTranslations(String text, {bool isHebrew = false}) async {
    try {
      if (isHebrew) {
        final englishText = await translateToEnglish(text);
        return {
          'en': englishText,
          'he': text,
        };
      } else {
        final hebrewText = await translateToHebrew(text);
        return {
          'en': text,
          'he': hebrewText,
        };
      }
    } catch (e) {
      print('Translation error: $e');
      return {
        'en': text,
        'he': text,
      };
    }
  }
}
