import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hive/hive.dart';

import 'package:stadium_food/src/bloc/theme/theme_bloc.dart';

import 'package:stadium_food/src/presentation/utils/app_router.dart';
import 'package:stadium_food/src/presentation/utils/app_theme.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
    builder: (context, state) {
      ThemeData themeData =
          Hive.box('myBox').get('isDarkMode', defaultValue: false)
              ? AppTheme().lightThemeData
              : AppTheme().lightThemeData;
      if (state is ThemeChanged) {
        themeData = state.themeData;
      }

      return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: "Fans Food",
        theme: themeData,
        onGenerateRoute: AppRouter.onGenerateRoute,
        localizationsDelegates: [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('he', 'IL'), // Hebrew
          Locale('en', 'US'), // English
        ],
        locale: const Locale('he', 'IL'),
      );
    },
        );
  }
}
