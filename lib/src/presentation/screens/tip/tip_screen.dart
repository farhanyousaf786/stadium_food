import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stadium_food/src/bloc/order/order_bloc.dart';
import 'package:stadium_food/src/core/constants/colors.dart';
import 'package:stadium_food/src/presentation/widgets/buttons/primary_button.dart';
import 'package:stadium_food/src/services/tip_service.dart';
import 'package:stadium_food/src/data/repositories/order_repository.dart';
import 'package:stadium_food/src/data/services/currency_service.dart';
import 'package:stadium_food/src/presentation/widgets/buttons/back_button.dart';
import 'package:stadium_food/src/presentation/widgets/formatted_price_text.dart';

import '../../utils/custom_text_style.dart';

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
  double _orderTotal = 0.0;
  final TextEditingController _customTipController = TextEditingController();
  final String tipSymbol = '\$';

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
    _tipAmount = (_orderTotal * _selectedTipPercentage / 100).roundToDouble();

  }

  void _updateTip(double percentage) {
    setState(() {
      _selectedTipPercentage = percentage;
      _calculateTip();
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.bgColor,
      body: SingleChildScrollView(
        child: Stack(
          children: [
            // Background image
            Image.asset(
              'assets/png/tip_bg.png',
              width: double.infinity,
              height: size.height * 0.6,
              fit: BoxFit.fill,
            ),
        
            // Main content
            SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Back button
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: CustomBackButton(color: Colors.white),
                  ),
        
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    margin: EdgeInsets.only(top: (size.height * 0.21)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          '100% of your tip goes to your courier.',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textColor,
                          ),
                        ),
                        SizedBox(
                          height: 8,
                        ),
                        Text(
                          'Tips are based on your order total of ₪$_orderTotal before any discounts or promotions',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: AppColors.textColor,
                          ),
                        ),
                      ],
                    ),
                  ),
        
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24.0, vertical: 16.0),
                    margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(
                          top: Radius.circular(30), bottom: Radius.circular(30)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 10,
                          offset: Offset(0, -5),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Your order total is',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                        FormattedPriceText(
                          amount: _orderTotal,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Select a tip amount',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[800],
                          ),
                        ),
                        const SizedBox(height: 16),
        
                        // Tip percentage buttons
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildTipButton(6, _selectedTipPercentage == 6),
                            _buildTipButton(10, _selectedTipPercentage == 10),
                            _buildTipButton(20, _selectedTipPercentage == 20),
                            _buildTipButton(25, _selectedTipPercentage == 25),
                          ],
                        ),
        
                        const SizedBox(height: 24),
        
                        // Custom tip input
                        GestureDetector(
                          onTap: _showCustomTipDialog,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 16, horizontal: 16),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey[300]!),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.edit_outlined,
                                    color: Colors.grey[600], size: 20),
                                const SizedBox(width: 12),
                                Text(
                                  'Custom amount',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 16,
                                  ),
                                ),
                                const Spacer(),
                                FormattedPriceText(
                                  amount: _tipAmount,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
        
                        // Action buttons
                      ],
                    ),
                  ),
        
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40,vertical: 16),
                    child: PrimaryButton(
                      onTap: () async {
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
                      text: 'Add Tip',
                    ),
                  ),
        
        
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40,vertical: 8),
                    child: Ink(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                      child: InkWell(
                        borderRadius: const BorderRadius.all(Radius.circular(10)),
                        onTap: () {
                          if (widget.orderId != null) {
                            Navigator.pop(context);
                          } else {
                            // Skip tip for new order
                            context.read<OrderBloc>().add(UpdateTipEvent(0));
                            Navigator.pushNamed(
                              context,
                              '/order/confirm',
                            );
                          }
                        },
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.all(Radius.circular(10))),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 60,
                            vertical: 20,
                          ),
                          child: Text(
                            'Skip',
                            textAlign: TextAlign.center,
                            style: CustomTextStyle.size16Weight600Text(
                              AppColors.textColor,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
        
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildTipButton(int percentage, bool isSelected) {
    return GestureDetector(
      onTap: () => _updateTip(percentage.toDouble()),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryColor : Colors.grey[100],
          borderRadius: BorderRadius.circular(50),
          border: Border.all(
            color: isSelected ? AppColors.primaryColor : Colors.grey[300]!,
            width: 1.5,
          ),
        ),
        child: Center(
          child: Text(
            '$tipSymbol$percentage%',
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black87,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  void _showCustomTipDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const Text(
              'Custom Tip',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Enter your custom tip amount',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _customTipController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                prefixText: '₪',
                hintText: '0.00',
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
              ),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: BorderSide(color: Colors.grey[300]!),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      final customAmount =
                          double.tryParse(_customTipController.text) ?? 0;
                      if (customAmount >= 0) {
                        setState(() {
                          _tipAmount = customAmount;
                          if (_orderTotal > 0) {
                            _selectedTipPercentage =
                                (customAmount / _orderTotal * 100)
                                    .roundToDouble();
                          }
                        });
                        Navigator.pop(context);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please enter a valid tip amount'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Apply',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
