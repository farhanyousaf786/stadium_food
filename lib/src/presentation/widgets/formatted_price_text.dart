import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stadium_food/src/bloc/settings/settings_bloc.dart';
import 'package:stadium_food/src/data/services/currency_service.dart';

class FormattedPriceText extends StatelessWidget {
  final double amount;
  final TextStyle? style;
  final String? currencyCode; // optional override

  const FormattedPriceText({
    super.key,
    required this.amount,
    this.style,
    this.currencyCode,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsBloc, SettingsState>(
      builder: (context, state) {
        final formatted = CurrencyService.formatPrice(amount, firebaseCurrency: currencyCode ?? 'ILS');
        return Text(
          formatted,
          style: style,
        );
      },
    );
  }
}
