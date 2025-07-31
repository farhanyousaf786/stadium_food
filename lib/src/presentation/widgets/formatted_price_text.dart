import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stadium_food/src/bloc/settings/settings_bloc.dart';
import 'package:stadium_food/src/data/services/currency_service.dart';

class FormattedPriceText extends StatelessWidget {
  final double amount;
  final TextStyle? style;

  const FormattedPriceText({
    super.key,
    required this.amount,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsBloc, SettingsState>(
      builder: (context, state) {
        final currentCurrency = CurrencyService.getCurrentCurrency();
        final convertedAmount = currentCurrency == 'USD'
            ? amount
            : CurrencyService.convertFromUSD(amount, currentCurrency);
        final symbol = CurrencyService.getCurrencySymbol(currentCurrency);

        return Text(
          '$symbol${convertedAmount.toStringAsFixed(2)}',
          style: style,
        );
      },
    );
  }
}
