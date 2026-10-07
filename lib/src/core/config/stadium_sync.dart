import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stadium_food/src/core/config/stadium_theme.dart';
import 'package:stadium_food/src/data/models/stadium.dart';
import 'package:stadium_food/src/data/repositories/stadium_repository.dart';
import 'package:stadium_food/src/presentation/utils/app_colors.dart';

/// Merge latest stadium branding from Firestore (matches web stadiumSync.js).
/// Keeps logo/banner/colors in sync after admin dashboard edits.
class StadiumSync {
  static const _brandingKeys = [
    'logoUrl',
    'bannerUrl',
    'color',
    'secondaryColor',
    'brandName',
    'name',
    'imageUrl',
  ];

  /// Returns fresh stadium (or cached), applies venue theme colors.
  static Future<Stadium?> refreshSelectedStadiumFromFirestore({
    StadiumRepository? repository,
  }) async {
    final box = Hive.box('myBox');
    final cachedRaw = box.get('selectedStadium');
    if (cachedRaw is! Map || cachedRaw['id'] == null) return null;

    final cached = Stadium.fromHiveMap(Map<String, dynamic>.from(cachedRaw));
    try {
      final repo = repository ?? StadiumRepository();
      final fresh = await repo.getStadiumById(cached.id);
      if (fresh == null) {
        _applyTheme(cached);
        return cached;
      }

      final cachedMap = cached.toHiveMap();
      final freshMap = fresh.toHiveMap();
      final changed = _brandingKeys.any((k) => cachedMap[k] != freshMap[k]);
      if (changed) {
        box.put('selectedStadium', freshMap);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('selected_stadium_id', fresh.id);
        await prefs.setString('selected_stadium_name', fresh.name);
        if (kDebugMode) {
          print('[StadiumSync] Branding updated from dashboard for ${fresh.id}');
        }
      }
      _applyTheme(fresh);
      return fresh;
    } catch (e) {
      if (kDebugMode) {
        print('[StadiumSync] Failed to refresh stadium branding: $e');
      }
      _applyTheme(cached);
      return cached;
    }
  }

  static void _applyTheme(Stadium stadium) {
    final venue = StadiumTheme.fromStadium(stadium);
    AppColors.brandName = venue.appName;
    AppColors.logoUrl = venue.logoUrl;
    AppColors.bannerUrl = venue.bannerUrl;
    venue.apply();
  }
}
