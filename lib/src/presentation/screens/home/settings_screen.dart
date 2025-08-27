import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stadium_food/src/bloc/settings/settings_bloc.dart';
import 'package:stadium_food/src/data/services/currency_service.dart';
import 'package:stadium_food/src/data/services/language_service.dart';
import 'package:stadium_food/src/presentation/widgets/buttons/back_button.dart';
import 'package:stadium_food/src/presentation/utils/custom_text_style.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CustomBackButton(),
              const SizedBox(height: 20),
              Text(
                "Settings",
                style: CustomTextStyle.size25Weight600Text(),
              ),
              const SizedBox(height: 20),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  "Language",
                  style: CustomTextStyle.size16Weight400Text(),
                ),
                trailing: BlocBuilder<SettingsBloc, SettingsState>(
                  builder: (context, state) {
                    return DropdownButton<String>(
                      value: LanguageService.getCurrentLanguage(),
                      items: const [
                        DropdownMenuItem(
                          value: 'en',
                          child: Text('English'),
                        ),
                        DropdownMenuItem(
                          value: 'he',
                          child: Text('Hebrew'),
                        ),
                      ],
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          context.read<SettingsBloc>().add(
                                ChangeLanguage(newValue),
                              );
                        }
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
              // ListTile(
              //   contentPadding: EdgeInsets.zero,
              //   title: Text(
              //     "Currency",
              //     style: CustomTextStyle.size16Weight400Text(),
              //   ),
              //   trailing: BlocBuilder<SettingsBloc, SettingsState>(
              //     builder: (context, state) {
              //       return DropdownButton<String>(
              //         value: CurrencyService.getCurrentCurrency(),
              //         items: const [
              //           DropdownMenuItem(
              //             value: 'USD',
              //             child: Text('USD'),
              //           ),
              //           DropdownMenuItem(
              //             value: 'NIS',
              //             child: Text('NIS'),
              //           ),
              //         ],
              //         onChanged: (String? newValue) {
              //           if (newValue != null) {
              //             context.read<SettingsBloc>().add(
              //                   ChangeCurrency(newValue),
              //                 );
              //           }
              //         },
              //       );
              //     },
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
