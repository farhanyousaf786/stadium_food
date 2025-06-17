import 'package:cloud_firestore/cloud_firestore.dart' hide Order;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:stadium_food/src/data/models/order.dart';
import 'package:stadium_food/src/data/models/shopuser.dart';
import 'package:stadium_food/src/presentation/screens/chat/chat_details_screen.dart';
import 'package:stadium_food/src/presentation/widgets/buttons/back_button.dart';
import 'package:stadium_food/src/presentation/widgets/image_placeholder.dart';
import 'package:stadium_food/src/presentation/utils/app_colors.dart';
import 'package:stadium_food/src/presentation/utils/app_styles.dart';
import 'package:stadium_food/src/presentation/utils/custom_text_style.dart';

class OrderDetailsScreen extends StatelessWidget {
  final Order order;
  const OrderDetailsScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColor,

      bottomNavigationBar: Container(
        height: 163,
        margin: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: AppColors.primaryGradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: AppStyles.largeBorderRadius,
          boxShadow: [AppStyles.boxShadow7],
        ),
        child: Stack(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: SvgPicture.asset(
                'assets/svg/pattern-card.svg',
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Subtotal',
                        style: CustomTextStyle.size16Weight400Text(
                          Colors.white,
                        ),
                      ),
                      Text(
                        '\$${order.subtotal}',
                        style: CustomTextStyle.size16Weight400Text(
                          Colors.white,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Delivery fee',
                        style: CustomTextStyle.size16Weight400Text(
                          Colors.white,
                        ),
                      ),
                      Text(
                        '\$${order.deliveryFee}',
                        style: CustomTextStyle.size16Weight400Text(
                          Colors.white,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Discount',
                        style: CustomTextStyle.size16Weight400Text(
                          Colors.white,
                        ),
                      ),
                      Text(
                        '\$${order.discount}',
                        style: CustomTextStyle.size16Weight400Text(
                          Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total',
                        style: CustomTextStyle.size22Weight600Text(
                          Colors.white,
                        ),
                      ),
                      Text(
                        '\$${order.total.toStringAsFixed(2)}',
                        style: CustomTextStyle.size22Weight600Text(
                          Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const CustomBackButton(),
                  InkWell(
                    onTap: () async {

                        final querySnapshot = await FirebaseFirestore.instance
                            .collection('users')
                            .where('shopsId', arrayContains: order.shopId)
                            .limit(1)
                            .get();

                        if (querySnapshot.docs.isEmpty) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Shop owner not found')),
                            );
                          }
                          return;
                        }

                        final shopUser = ShopUser.fromMap(querySnapshot.docs.first.data());
                        if (context.mounted) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChatDetailsScreen(
                                otherUser: shopUser,
                              ),
                            ),
                          );
                        }

                    },
                    borderRadius: AppStyles.defaultBorderRadius,
                    child: Container(
                      width: 45,
                      height: 45,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor.withOpacity(0.1),
                        borderRadius: AppStyles.defaultBorderRadius,
                      ),
                      child:  SvgPicture.asset(
                        "assets/svg/chat.svg",
                      ),
                    ),
                  )

                ],
              ),
              const SizedBox(height: 20),
              Text(
                "Order #${order.id}",
                style: CustomTextStyle.size22Weight600Text(),
              ),
              const SizedBox(height: 20),
              Text(
                "Items",
                style: CustomTextStyle.size18Weight600Text(),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: ListView.builder(
                  itemCount: order.cart.length,
                  itemBuilder: (context, index) {
                    var item = order.cart[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 20),
                      padding: const EdgeInsets.fromLTRB(10, 10, 20, 10),
                      decoration: BoxDecoration(
                        borderRadius: AppStyles.defaultBorderRadius,
                        boxShadow: [AppStyles.boxShadow7],
                        color: AppColors().cardColor,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: AppStyles.defaultBorderRadius,
                            child: item.images.isNotEmpty
                                ? Image.network(
                                    item.images.first,
                                    fit: BoxFit.cover,
                                    width: 64,
                                    height: 64,
                                    errorBuilder: (context, error, stackTrace) {
                                      return ImagePlaceholder(
                                        iconData: Icons.fastfood,
                                        iconSize: 30,
                                        width: 64,
                                        height: 64,
                                      );
                                    },
                                  ): const SizedBox(
                                    width: 64,
                                    )
                          ),
                          const SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.name,
                                style: CustomTextStyle.size16Weight500Text(),
                              ),
                              const SizedBox(height: 5),

                              ShaderMask(
                                shaderCallback: (rect) {
                                  return LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: AppColors.primaryGradient,
                                  ).createShader(rect);
                                },
                                child: Text(
                                  "\$${item.price.toStringAsFixed(2)}",
                                  style:
                                      CustomTextStyle.size18Weight600Text(
                                    Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          Text(
                            "x${item.quantity}",
                            style: CustomTextStyle.size16Weight500Text(),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
