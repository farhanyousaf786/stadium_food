import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stadium_food/src/bloc/order/order_bloc.dart';
import 'package:stadium_food/src/core/constants/colors.dart';
import 'package:stadium_food/src/services/tip_service.dart';
import 'package:stadium_food/src/core/translations/translate.dart';
import 'package:stadium_food/src/data/repositories/order_repository.dart';
import 'package:stadium_food/src/data/services/currency_service.dart';
import 'package:stadium_food/src/presentation/widgets/buttons/back_button.dart';
import 'package:stadium_food/src/presentation/widgets/formatted_price_text.dart';

class TipScreen extends StatefulWidget {
  final String? orderId;

  const TipScreen({
    super.key,
    this.orderId,
  });

  @override
  State<TipScreen> createState() => _TipScreenState();
}

class _TipScreenState extends State<TipScreen> {
  late double _selectedTipPercentage;
  late double _tipAmount;
  final List<double> _tipPercentages = [6, 10, 14, 18];
   double _orderTotal=0.0;
  final TextEditingController _customTipController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedTipPercentage = 10; // Default to 10%
    _initializeTotal();
  }

  Future<void> _initializeTotal() async {
    _orderTotal = widget.orderId != null
        ? await OrderRepository.getOrderTotal(widget.orderId!)
        : OrderRepository.total;
    _calculateTip();
    if (mounted) setState(() {});
  }

  void _calculateTip() {
    // Convert order total to USD for consistent tip calculation
    final currentCurrency = CurrencyService.getCurrentCurrency();
    double orderTotalInUSD = _orderTotal;
    if (currentCurrency != 'USD') {
      orderTotalInUSD =
          CurrencyService.convertToUSD(_orderTotal, currentCurrency);
    }

    // Calculate tip in USD
    double tipInUSD =
        (orderTotalInUSD * _selectedTipPercentage / 100).roundToDouble();

    // Convert tip back to current currency if needed
    if (currentCurrency != 'USD') {
      _tipAmount = CurrencyService.convertFromUSD(tipInUSD, currentCurrency);
    } else {
      _tipAmount = tipInUSD;
    }
  }

  void _updateTip(double percentage) {
    setState(() {
      _selectedTipPercentage = percentage;
      _calculateTip();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomBackButton(color: AppColors.primaryColor,),
              SizedBox(
                height: 16,
              ),
              Text(
                Translate.get('addTip'),
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(
                height: 10,
              ),
              RichText(
                text: TextSpan(
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                  children: [
                    TextSpan(
                      text: '${Translate.get('tipDescription')} ',
                    ),
                    WidgetSpan(
                      child: FormattedPriceText(
                        amount: _orderTotal,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ),
                    TextSpan(
                      text: ' ${Translate.get('beforeDiscounts')}',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: Image.asset(
                  'assets/png/delivery_illustration.png',
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    Translate.get('tipAmount'),
                    style: TextStyle(
                      color: Colors.grey[800],
                      fontSize: 16,
                    ),
                  ),
                  Row(
                    children: [
                      FormattedPriceText(
                        amount: _tipAmount,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (context) => Container(
                              padding: EdgeInsets.only(
                                bottom: 20,
                                left: 20,
                                right: 20,
                                top: 20,
                              ),
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(20),
                                ),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    Translate.get('customTip'),
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    Translate.get('enterCustomTip').replaceAll(
                                      '{amount}',
                                      _orderTotal.toStringAsFixed(2),
                                    ),
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  TextField(
                                    controller: _customTipController,
                                    keyboardType: TextInputType.number,
                                    decoration: InputDecoration(
                                      hintText: Translate.get('enterCustomTip'),
                                      filled: true,
                                      fillColor: Colors.grey[100],
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide.none,
                                      ),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 12,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: Text(
                                          Translate.get('cancelTip'),
                                          style: TextStyle(
                                            color: Colors.grey,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                      ElevatedButton(
                                        onPressed: () {
                                          final customAmount = double.tryParse(
                                                  _customTipController.text) ??
                                              0;
                                          if (customAmount >= 0 &&
                                              customAmount <= _orderTotal) {
                                            setState(() {
                                              _tipAmount = customAmount;
                                              _selectedTipPercentage =
                                                  (customAmount /
                                                          _orderTotal *
                                                          100)
                                                      .roundToDouble();
                                            });
                                            Navigator.pop(context);
                                          } else {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                content: Text(Translate.get(
                                                    'invalidTipAmount')),
                                              ),
                                            );
                                          }
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              AppColors.primaryColor,
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 24,
                                            vertical: 12,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                        ),
                                        child: Text(
                                          Translate.get('confirmTip'),
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                        child: Text(
                          Translate.get('customTip'),
                          style: TextStyle(
                            color: AppColors.primaryColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 50,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 0),
                  itemCount: _tipPercentages.length,
                  itemBuilder: (context, index) {
                    final percentage = _tipPercentages[index];
                    final isSelected = percentage == _selectedTipPercentage;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: ChoiceChip(
                        checkmarkColor: Colors.white,
                        label: Text(
                          '${percentage.toInt()}%',
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.black,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        selected: isSelected,
                        selectedColor: AppColors.primaryColor,
                        backgroundColor: Colors.grey[200],
                        onSelected: (selected) {
                          if (selected) {
                            _updateTip(percentage);
                          }
                        },
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                      ),
                    );
                  },
                ),
              ),
              const Spacer(),
              Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (widget.orderId != null) {
                          // Update existing order tip
                          final tipService = TipService();
                          await tipService.updateTip(widget.orderId!, _tipAmount);
                          Navigator.pop(context);
                        } else {
                          // New order tip
                          context
                              .read<OrderBloc>()
                              .add(UpdateTipEvent(_tipAmount));
                          Navigator.pushNamed(
                            context,
                            '/order/confirm',
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        Translate.get('tipButton'),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: TextButton(
                      onPressed: () async {
                        if (widget.orderId != null) {

                          Navigator.pop(context);
                        } else {
                          // Skip tip for new order
                          context
                              .read<OrderBloc>()
                              .add(UpdateTipEvent(0));
                          Navigator.pushNamed(
                            context,
                            '/order/confirm',
                          );
                        }
                      },
                      style: TextButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: const BorderSide(color: AppColors.primaryColor),
                        ),
                      ),
                      child: Text(
                        Translate.get('skipButton'),
                        style: TextStyle(
                          color: AppColors.primaryColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
