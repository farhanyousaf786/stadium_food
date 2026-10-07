import 'package:flutter/material.dart';
import 'package:stadium_food/src/presentation/utils/app_colors.dart';

class AppTheme {
  /// Rebuilds ThemeData from current venue [AppColors] (call after stadium select).
  ThemeData get lightThemeData => buildLightTheme();

  ThemeData get darkThemeData => buildLightTheme();

  static ThemeData buildLightTheme() {
    final primary = AppColors.primaryColor;
    final dark = AppColors.primaryDarkColor;
    final light = AppColors.primaryLightColor;

    final scheme = ColorScheme.fromSeed(
      seedColor: primary,
      primary: primary,
      secondary: dark,
      brightness: Brightness.light,
    );

    return ThemeData(
      useMaterial3: true,
      primaryColor: primary,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.bgColor,
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors().backgroundColor,
        indicatorColor: primary.withOpacity(0.14),
        surfaceTintColor: Colors.transparent,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: Colors.white,
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(color: primary),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? primary : null,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected)
              ? primary.withOpacity(0.4)
              : null,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: dark),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? primary : null,
        ),
        checkColor: WidgetStateProperty.all(Colors.white),
      ),
      tabBarTheme: TabBarThemeData(
        indicatorColor: primary,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white70,
      ),
      appBarTheme: AppBarTheme(
        surfaceTintColor: Colors.transparent,
        backgroundColor: primary,
        foregroundColor: Colors.white,
      ),
      textSelectionTheme: TextSelectionThemeData(cursorColor: primary),
      dialogTheme: const DialogThemeData(
        surfaceTintColor: Colors.transparent,
      ),
      chipTheme: ChipThemeData(
        selectedColor: primary.withOpacity(0.15),
        checkmarkColor: primary,
      ),
    );
  }
}
