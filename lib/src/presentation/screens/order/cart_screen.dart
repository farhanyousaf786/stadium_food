import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:stadium_food/src/bloc/order/order_bloc.dart';
import 'package:stadium_food/src/data/repositories/order_repository.dart';
import 'package:stadium_food/src/presentation/widgets/buttons/back_button.dart';
import 'package:stadium_food/src/presentation/widgets/buttons/primary_button.dart';
import 'package:stadium_food/src/presentation/widgets/items/cart_item.dart';
import 'package:stadium_food/src/presentation/widgets/price_info_widget.dart';
import 'package:stadium_food/src/presentation/utils/app_colors.dart';
import 'package:stadium_food/src/presentation/utils/app_styles.dart';
import 'package:stadium_food/src/presentation/utils/custom_text_style.dart';

class CartScreen extends StatelessWidget {

  final bool isFromHome;
   CartScreen(  {super.key, required this.isFromHome});

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
                  style: CustomTextStyle.size18Weight600Text(),
                ),
                const SizedBox(height: 16),
                Text(
                  'You need to be logged in to place an order. Please login or create an account to continue.',
                  textAlign: TextAlign.center,
                  style: CustomTextStyle.size14Weight400Text(
                    AppColors().secondaryTextColor,
                  ),
                ),
                const SizedBox(height: 24),
                PrimaryButton(
                  text: 'Login',
                  onTap: () {
                    Navigator.pop(context); // Close dialog
                    // Navigate to login without removing previous screens
                    Navigator.pushNamed(context, '/login');
                  },
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
                    style: CustomTextStyle.size14Weight600Text(AppColors.primaryColor),
                  ),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context); // Close dialog
                  },
                  child: Text(
                    'Cancel',
                    style: CustomTextStyle.size14Weight400Text(Colors.grey),
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
      bottomNavigationBar: BlocBuilder<OrderBloc, OrderState>(
        builder: (context, state) {
          return PriceInfoWidget(
            onTap: () {
              if (OrderRepository.cart.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Cart is empty"),
                    backgroundColor: AppColors.errorColor,
                  ),
                );
                return;
              }
              
              // // Check if user is logged in
              // final currentUser = FirebaseAuth.instance.currentUser;
              // if (currentUser == null) {
              //   // Show login/signup dialog
              //   _showAuthDialog(context);
              // } else {
              //   // User is logged in, proceed to checkout
              //   Navigator.pushNamed(context, "/tip");
              // }

                              Navigator.pushNamed(context, "/tip");

            },
          );
        },
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
            isFromHome==false?    const CustomBackButton():SizedBox(),
                const SizedBox(height: 20),
                Text(
                  "Cart",
                  style: CustomTextStyle.size25Weight600Text(),
                ),
                const SizedBox(height: 20),
                if (OrderRepository.cart.isEmpty)
                  Container(
                    alignment: Alignment.center,
                    height: MediaQuery.of(context).size.height * 0.4,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SvgPicture.asset(
                          "assets/svg/cart.svg",
                           color: AppColors.starEmptyColor,
                          height: 100,
                          width: 100,
                        ),
                        const SizedBox(
                          height: 16,
                        ),
                        Text(
                          "Cart is empty",

                          style: CustomTextStyle.size22Weight600Text(),
                        ),
                      ],
                    ),
                  ),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: OrderRepository.cart.length,
                  itemBuilder: (context, index) {
                    return Column(
                      children: [
                        Dismissible(
                          key: Key(OrderRepository.cart[index].name),
                          onDismissed: (direction) {
                            BlocProvider.of<OrderBloc>(context).add(
                              RemoveCompletelyFromCart(
                                OrderRepository.cart[index],
                              ),
                            );
                          },
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: AppStyles.largeBorderRadius,
                              color: AppColors.secondaryColor,
                            ),
                            child: SvgPicture.asset(
                              "assets/svg/trash.svg",
                            ),
                          ),
                          child: CartItem(
                            food: OrderRepository.cart[index],
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
