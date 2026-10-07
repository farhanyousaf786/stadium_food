import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stadium_food/src/bloc/order/order_bloc.dart';
import 'package:stadium_food/src/core/translations/translate.dart';
import 'package:stadium_food/src/data/services/currency_service.dart';
import 'package:stadium_food/src/services/tip_service.dart';
import 'package:stadium_food/src/data/repositories/order_repository.dart';
import 'package:stadium_food/src/presentation/widgets/buttons/back_button.dart';
import 'package:stadium_food/src/presentation/widgets/formatted_price_text.dart';
import 'package:stadium_food/src/presentation/utils/app_colors.dart';

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
  double _selectedTipAmount = 0;
  double _tipAmount = 0;
  double _orderTotal = 0.0;
  final TextEditingController _customTipController = TextEditingController();
  final FocusNode _customTipFocus = FocusNode();
  // Match web fixed tip amounts (base currency units)
  final List<double> _tipAmounts = [2, 4, 6, 8];

  @override
  void initState() {
    super.initState();
    _initializeTotal();
  }

  @override
  void dispose() {
    _customTipController.dispose();
    _customTipFocus.dispose();
    super.dispose();
  }

  Future<void> _initializeTotal() async {
    _orderTotal = widget.orderId != null
        ? await OrderRepository.getOrderTotal(widget.orderId!)
        : OrderRepository.total;
    if (mounted) setState(() {});
  }

  void _updateTip(double amount) {
    setState(() {
      _selectedTipAmount = amount;
      _tipAmount = amount;
      _customTipController.clear();
    });
  }

  void _onCustomTipChanged(String value) {
    final customAmount = double.tryParse(value) ?? 0;
    if (customAmount >= 0) {
      setState(() {
        _selectedTipAmount = customAmount;
        _tipAmount = customAmount;
      });
    }
  }

  Future<void> _addTip() async {
    if (widget.orderId != null) {
      await TipService().updateTip(widget.orderId!, _tipAmount);
      if (!mounted) return;
      Navigator.pop(context);
    } else {
      context.read<OrderBloc>().add(UpdateTipEvent(_tipAmount));
      Navigator.pushNamed(context, '/order/confirm');
    }
  }

  void _skipTip() {
    if (widget.orderId != null) {
      Navigator.pop(context);
    } else {
      context.read<OrderBloc>().add(UpdateTipEvent(0));
      Navigator.pushNamed(context, '/order/confirm');
    }
  }

  @override
  Widget build(BuildContext context) {
    final primary = AppColors.primaryColor;
    final dark = AppColors.primaryDarkColor;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: CustomBackButton(
                        color: Colors.black87,
                        backgroundColor: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      Translate.get('addTip'),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.4,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text.rich(
                      TextSpan(
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.5,
                          color: Colors.grey[600],
                        ),
                        children: [
                          TextSpan(
                            text: '${Translate.get('tipSupportsRunner')} ',
                          ),
                          TextSpan(text: '${Translate.get('yourOrderTotalIs')} '),
                          WidgetSpan(
                            alignment: PlaceholderAlignment.middle,
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 2),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: FormattedPriceText(
                                amount: _orderTotal,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: primary,
                                ),
                              ),
                            ),
                          ),
                          const TextSpan(text: '.'),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    // Courier tip illustration (venue-tinted)
                    Center(
                      child: Container(
                        width: 96,
                        height: 96,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              primary.withOpacity(0.12),
                              dark.withOpacity(0.22),
                            ],
                          ),
                        ),
                        child: Icon(
                          Icons.delivery_dining_rounded,
                          size: 48,
                          color: primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Tip amount summary card
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                        boxShadow: [
                          BoxShadow(
                            color: primary.withOpacity(0.06),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Text(
                            Translate.get('tipAmount'),
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.grey[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const Spacer(),
                          FormattedPriceText(
                            amount: _tipAmount,
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      Translate.get('selectTipAmount'),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: _tipAmounts.map((amount) {
                        final selected = _selectedTipAmount == amount &&
                            _customTipController.text.isEmpty;
                        return Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(
                              right: amount == _tipAmounts.last ? 0 : 8,
                            ),
                            child: _TipChip(
                              label: CurrencyService.formatPrice(amount),
                              selected: selected,
                              primary: primary,
                              onTap: () => _updateTip(amount),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      Translate.get('customTip'),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _customTipController,
                      focusNode: _customTipFocus,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      onChanged: _onCustomTipChanged,
                      decoration: InputDecoration(
                        hintText: '0.00',
                        prefixIcon: Icon(
                          Icons.edit_outlined,
                          size: 20,
                          color: Colors.grey[500],
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: primary, width: 1.5),
                        ),
                      ),
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Sticky actions (match web TipActions)
            Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 12,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: _addTip,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(
                        '${Translate.get('tipButton')} (${CurrencyService.formatPrice(_tipAmount)})',
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: OutlinedButton(
                      onPressed: _skipTip,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF0F172A),
                        side: const BorderSide(color: Color(0xFFE2E8F0)),
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(
                        Translate.get('skipButton'),
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TipChip extends StatelessWidget {
  final String label;
  final bool selected;
  final Color primary;
  final VoidCallback onTap;

  const _TipChip({
    required this.label,
    required this.selected,
    required this.primary,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: selected ? primary : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected ? primary : const Color(0xFFE2E8F0),
              width: selected ? 1.5 : 1,
            ),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: primary.withOpacity(0.25),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: selected ? Colors.white : const Color(0xFF0F172A),
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
