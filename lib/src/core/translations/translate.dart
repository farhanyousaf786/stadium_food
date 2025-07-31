import 'package:stadium_food/src/core/translations/app_translations.dart';
import 'package:stadium_food/src/data/services/language_service.dart';

class Translate {
  static String get(String key) {
    final languageCode = LanguageService.getCurrentLanguage();
    return AppTranslations.getText(key, languageCode);
  }

  static String withLanguage(String key, String languageCode) {
    return AppTranslations.getText(key, languageCode);
  }
}
