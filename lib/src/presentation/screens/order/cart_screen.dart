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
   const CartScreen(  {super.key, required this.isFromHome});



  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: AppColors.bgColor,
      bottomNavigationBar: BlocBuilder<OrderBloc, OrderState>(
        builder: (context, state) {
          return OrderRepository.cart.isNotEmpty? PriceInfoWidget(
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
              


                              Navigator.pushNamed(context, "/tip");

            },
          ):SizedBox();
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
