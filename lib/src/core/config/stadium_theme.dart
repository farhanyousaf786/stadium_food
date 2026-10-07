import 'package:flutter/material.dart';
import 'package:stadium_food/src/data/models/stadium.dart';
import 'package:stadium_food/src/presentation/utils/app_colors.dart';
import 'package:stadium_food/src/presentation/utils/app_theme.dart';

/// Venue branding derived from stadium Firestore fields (matches web stadiumTheme.js).
class StadiumTheme {
  final Color primary;
  final Color secondary;
  final Color light;
  final String appName;
  final String logoUrl;
  final String bannerUrl;

  const StadiumTheme({
    required this.primary,
    required this.secondary,
    required this.light,
    required this.appName,
    required this.logoUrl,
    required this.bannerUrl,
  });

  static StadiumTheme fromStadium(Stadium? stadium) {
    final primary = _parseHex(stadium?.color) ?? AppColors.defaultPrimaryColor;
    final secondary = _parseHex(stadium?.secondaryColor) ??
        _shade(primary, -18) ??
        AppColors.defaultPrimaryDarkColor;
    final light = _shade(primary, 12) ?? AppColors.defaultPrimaryLightColor;

    return StadiumTheme(
      primary: primary,
      secondary: secondary,
      light: light,
      appName: (stadium?.brandName.isNotEmpty == true)
          ? stadium!.brandName
          : (stadium?.name.isNotEmpty == true ? stadium!.name : 'Fans Food'),
      logoUrl: stadium?.logoUrl ?? '',
      bannerUrl: stadium?.bannerUrl ?? '',
    );
  }

  /// Apply venue colors into [AppColors] and return a ThemeData for ThemeBloc.
  ThemeData apply() {
    AppColors.applyVenueColors(
      primary: primary,
      dark: secondary,
      light: light,
    );
    return AppTheme.buildLightTheme();
  }

  static Color? _parseHex(String? hex) {
    if (hex == null) return null;
    var value = hex.trim();
    if (value.isEmpty) return null;
    if (RegExp(r'^#[0-9A-Fa-f]{3}$').hasMatch(value)) {
      value =
          '#${value[1]}${value[1]}${value[2]}${value[2]}${value[3]}${value[3]}';
    }
    if (!RegExp(r'^#[0-9A-Fa-f]{6}$').hasMatch(value)) return null;
    final intColor = int.tryParse(value.substring(1), radix: 16);
    if (intColor == null) return null;
    return Color(0xFF000000 | intColor);
  }

  static Color? _shade(Color color, double amount) {
    final factor = 1 + amount / 100;
    int clampChannel(double c) => c.clamp(0, 255).round();
    return Color.fromARGB(
      255,
      clampChannel(color.red * factor),
      clampChannel(color.green * factor),
      clampChannel(color.blue * factor),
    );
  }
}
