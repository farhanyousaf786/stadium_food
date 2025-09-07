import 'package:equatable/equatable.dart';

// ignore: must_be_immutable
class FoodCategory extends Equatable {
  /// Firestore document id (can be stored in the document or passed separately)
  final String docId;

  /// Emoji or icon string representation, e.g. "🍔"
  final String icon;

  /// Localized names map, e.g. { 'en': 'Food', 'he': 'אוכל' }
  final Map<String, String> nameMap;

  FoodCategory({
    required this.docId,
    required this.icon,
    required this.nameMap,
  });

  /// Prefer this when reading from Firestore documents that may or may not
  /// contain the `docId` field inside the document.
  factory FoodCategory.fromMap(Map<String, dynamic> json, {String? docId}) {
    final dynamic rawNameMap = json['nameMap'];
    final Map<String, String> parsedNameMap = rawNameMap is Map
        ? rawNameMap.map((key, value) => MapEntry(key.toString(), value?.toString() ?? ''))
        : <String, String>{};

    return FoodCategory(
      docId: (json['docId'] ??'').toString(),
      icon: (json['icon'] ?? '').toString(),
      nameMap: parsedNameMap,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'docId': docId,
      'icon': icon,
      'nameMap': nameMap,
    };
  }

  /// Returns the localized name for [localeCode] if available, otherwise
  /// falls back to English ('en'), and finally to any available value.
  String localizedName(String localeCode) {
    if (nameMap.containsKey(localeCode)) return nameMap[localeCode] ?? '';
    if (nameMap.containsKey('en')) return nameMap['en'] ?? '';
    return nameMap.values.isNotEmpty ? nameMap.values.first : '';
  }

  @override
  List<Object?> get props => [docId, icon, nameMap];
}
