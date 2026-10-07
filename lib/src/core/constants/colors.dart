import 'package:flutter/material.dart';
import 'package:stadium_food/src/presentation/utils/app_colors.dart' as theme;

/// Tip / misc screens — mirrors venue-aware brand colors.
class AppColors {
  static Color get primaryColor => theme.AppColors.primaryColor;
  static Color get primaryDarkColor => theme.AppColors.primaryDarkColor;
  static Color get bgColor => theme.AppColors.bgColor;
  static const textColor = Color(0xFF333333);
  static const accentColor = Color(0xFFFFA726);
  static const errorColor = Color(0xFFE53935);
  static const successColor = Color(0xFF43A047);
}
