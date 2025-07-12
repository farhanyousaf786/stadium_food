import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stadium_food/src/bloc/order/order_bloc.dart';
import 'package:stadium_food/src/core/constants/colors.dart';
import 'package:stadium_food/src/data/repositories/order_repository.dart';
import 'package:stadium_food/src/presentation/widgets/buttons/back_button.dart';

class TipScreen extends StatefulWidget {
  const TipScreen({
    super.key,
  });

  @override
  State<TipScreen> createState() => _TipScreenState();
}

class _TipScreenState extends State<TipScreen> {
  late double _selectedTipPercentage;
  late double _tipAmount;
  final List<double> _tipPercentages = [6, 10, 14, 18];
  late double _orderTotal;

  @override
  void initState() {
    super.initState();
    _selectedTipPercentage = 10; // Default to 10%
    _orderTotal = OrderRepository.total;
    _calculateTip();
    
    // Check if user is logged in
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final currentUser = FirebaseAuth.instance.currentUser;
      // if (currentUser == null) {
      //   // Show login/signup dialog
      //   _showAuthDialog(context);
      // }
    });
  }

  void _calculateTip() {
    _tipAmount = (_orderTotal * _selectedTipPercentage / 100)
        .roundToDouble();
  }

  void _updateTip(double percentage) {
    setState(() {
      _selectedTipPercentage = percentage;
      _calculateTip();
    });
  }
  
  // Show dialog to prompt user to login or register
  void _showAuthDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/png/logo-small.jpeg',
                  height: 80,
                  width: 80,
                ),
                const SizedBox(height: 20),
                Text(
                  'Account Required',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'You need to be logged in to place an order. Please login or create an account to continue.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context); // Close dialog
                      // Navigate to login without removing previous screens
                      Navigator.pushNamed(context, '/login');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Login',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context); // Close dialog
                    // Navigate to register without removing previous screens
                    Navigator.pushNamed(context, '/register');
                  },
                  child: Text(
                    'Create Account',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryColor,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context); // Close dialog
                    Navigator.pop(context); // Go back to cart
                  },
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
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
              CustomBackButton(),
              SizedBox(height: 16,),
              Text(
                'Add a tip',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10,),
              Text(
                '100% of your tip goes to your courier. Tips are based on your order total of \$${_orderTotal.toStringAsFixed(2)} before any discounts or promotions.',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
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
                    'Tip amount:',
                    style: TextStyle(
                      color: Colors.grey[800],
                      fontSize: 16,
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        '\$${_tipAmount.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          // TODO: Implement custom tip dialog
                        },
                        child: const Text(
                          'Custom tip',
                          style: TextStyle(
                            color: Colors.green,
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
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
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
                      onPressed: () {
                        // Update tip in repository and bloc
                        context.read<OrderBloc>().add(UpdateTipEvent(_tipAmount));

                        Navigator.pushNamed(
                          context,
                          '/order/confirm',
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Add Tip',
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
                      onPressed: () {

                        Navigator.pushNamed(
                          context,
                          '/order/confirm',
                        );
                      },
                      style: TextButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: const BorderSide(color: AppColors.primaryColor),
                        ),
                      ),
                      child: const Text(
                        'Skip',
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
