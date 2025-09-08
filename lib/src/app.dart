import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hive/hive.dart';

import 'package:stadium_food/src/bloc/language/language_bloc.dart';
import 'package:stadium_food/src/bloc/theme/theme_bloc.dart';

import 'package:stadium_food/src/presentation/utils/app_router.dart';
import 'package:stadium_food/src/presentation/utils/app_theme.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LanguageBloc, LanguageState>(
      builder: (context, languageState) {
        return BlocBuilder<ThemeBloc, ThemeState>(
          builder: (context, themeState) {
            ThemeData themeData =
                Hive.box('myBox').get('isDarkMode', defaultValue: false)
                    ? AppTheme().lightThemeData
                    : AppTheme().lightThemeData;
            if (themeState is ThemeChanged) {
              themeData = themeState.themeData;
            }

            return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: "Fans Food",
        theme: themeData,
        onGenerateRoute: AppRouter.onGenerateRoute,
        locale: languageState.locale,
        supportedLocales: const [
          Locale('en', ''),
          Locale('he', ''),
        ],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],


        // localizationsDelegates: [
        //   GlobalMaterialLocalizations.delegate,
        //   GlobalWidgetsLocalizations.delegate,
        //   GlobalCupertinoLocalizations.delegate,
        // ],
        // supportedLocales: const [
        //   Locale('he', 'IL'), // Hebrew
        //   Locale('en', 'US'), // English
        // ],
        // // Resolve locale from system settings; default to English if unsupported
        // localeResolutionCallback: (locale, supportedLocales) {
        //   if (locale == null) return const Locale('en', 'US');
        //   for (final supported in supportedLocales) {
        //     if (supported.languageCode == locale.languageCode) {
        //       return supported;
        //     }
        //   }
        //   return const Locale('en', 'US');
        // },
        // // Enforce text direction explicitly based on locale
        // builder: (context, child) {
        //   final currentLocale = Localizations.localeOf(context);
        //   final isHebrew = currentLocale.languageCode.toLowerCase() == 'he';
        //   return Directionality(
        //     textDirection: isHebrew ? TextDirection.rtl : TextDirection.ltr,
        //     child: child ?? const SizedBox.shrink(),
        //   );
        // },
      );
          },
        );
      },
    );
  }
}
