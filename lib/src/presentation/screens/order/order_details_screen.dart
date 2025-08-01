import 'package:cloud_firestore/cloud_firestore.dart' hide Order;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:stadium_food/src/core/translations/translate.dart';
import 'package:stadium_food/src/data/models/order.dart';
import 'package:stadium_food/src/data/models/order_status.dart';
import 'package:stadium_food/src/data/models/shopuser.dart';
import 'package:stadium_food/src/presentation/screens/chat/chat_details_screen.dart';
import 'package:stadium_food/src/presentation/widgets/buttons/back_button.dart';
import 'package:stadium_food/src/presentation/widgets/image_placeholder.dart';
import 'package:stadium_food/src/presentation/utils/app_colors.dart';
import 'package:stadium_food/src/presentation/utils/app_styles.dart';
import 'package:stadium_food/src/presentation/utils/custom_text_style.dart';
import 'package:stadium_food/src/presentation/widgets/order_status_stepper.dart';

class OrderDetailsScreen extends StatelessWidget {
  final Order order;

  const OrderDetailsScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      // bottomNavigationBar: Container(
      //   height: 163,
      //   margin: const EdgeInsets.all(20),
      //   decoration: BoxDecoration(
      //     gradient: LinearGradient(
      //       colors: AppColors.primaryGradient,
      //       begin: Alignment.topLeft,
      //       end: Alignment.bottomRight,
      //     ),
      //     borderRadius: AppStyles.largeBorderRadius,
      //     boxShadow: [AppStyles.boxShadow7],
      //   ),
      //   child: Stack(
      //     children: [
      //       Align(
      //         alignment: Alignment.topRight,
      //         child: SvgPicture.asset(
      //           'assets/svg/pattern-card.svg',
      //         ),
      //       ),
      //       Padding(
      //         padding: const EdgeInsets.all(20),
      //         child: Column(
      //           children: [
      //             Row(
      //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
      //               children: [
      //                 Text(
      //                   'Subtotal',
      //                   style: CustomTextStyle.size16Weight400Text(
      //                     Colors.white,
      //                   ),
      //                 ),
      //                 Text(
      //                   '\$${order.subtotal}',
      //                   style: CustomTextStyle.size16Weight400Text(
      //                     Colors.white,
      //                   ),
      //                 ),
      //               ],
      //             ),
      //             Row(
      //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
      //               children: [
      //                 Text(
      //                   'Handling & Delivery ',
      //                   style: CustomTextStyle.size16Weight400Text(
      //                     Colors.white,
      //                   ),
      //                 ),
      //                 Text(
      //                   '\$${order.deliveryFee}',
      //                   style: CustomTextStyle.size16Weight400Text(
      //                     Colors.white,
      //                   ),
      //                 ),
      //               ],
      //             ),
      //             Row(
      //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
      //               children: [
      //                 Text(
      //                   'Discount',
      //                   style: CustomTextStyle.size16Weight400Text(
      //                     Colors.white,
      //                   ),
      //                 ),
      //                 Text(
      //                   '\$${order.discount}',
      //                   style: CustomTextStyle.size16Weight400Text(
      //                     Colors.white,
      //                   ),
      //                 ),
      //               ],
      //             ),
      //             const SizedBox(height: 20),
      //             Row(
      //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
      //               children: [
      //                 Text(
      //                   'Total',
      //                   style: CustomTextStyle.size22Weight600Text(
      //                     Colors.white,
      //                   ),
      //                 ),
      //                 Text(
      //                   '\$${order.total.toStringAsFixed(2)}',
      //                   style: CustomTextStyle.size22Weight600Text(
      //                     Colors.white,
      //                   ),
      //                 ),
      //               ],
      //             ),
      //           ],
      //         ),
      //       ),
      //     ],
      //   ),
      // ),
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
                            SnackBar(
                                content:
                                    Text(Translate.get('shopOwnerNotFound'))),
                          );
                        }
                        return;
                      }

                      final shopUser =
                          ShopUser.fromMap(querySnapshot.docs.first.data());
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
                      child: SvgPicture.asset(
                        "assets/svg/chat.svg",
                      ),
                    ),
                  )
                ],
              ),
              const SizedBox(height: 20),
              Text(
                "${Translate.get('order')} #${order.id}",
                style: CustomTextStyle.size22Weight600Text(),
              ),
              const SizedBox(height: 20),
              OrderStatusStepper(
                status: order.status,
                orderTime: order.createdAt?.toDate(),
                deliveryTime: order.deliveryTime?.toDate(),
              ),
              const SizedBox(height: 20),
              Text(
                Translate.get('items'),
                style: CustomTextStyle.size18Weight600Text(),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: ListView.builder(
                  itemCount: order.cart.length,
                  itemBuilder: (context, index) {
                    var item = order.cart[index];

                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(15),
                              bottomLeft: Radius.circular(15),
                            ),
                            child: item.images.isNotEmpty
                                ? Image.network(
                                    item.images[0],
                                    width: 120,
                                    height: 120,
                                    fit: BoxFit.cover,
                                  )
                                : Container(
                                    width: 120,
                                    height: 120,
                                    color: Colors.grey[200],
                                    child: Icon(Icons.fastfood,
                                        color: Colors.grey[400], size: 40),
                                  ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        item.name,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Spacer(),
                                      Text(
                                        "${Translate.get('quantity')} ${item.quantity}",
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    item.description,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[600],
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        '\$${item.price.toStringAsFixed(2)}',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.primaryColor,
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.primaryColor
                                              .withOpacity(0.1),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.watch_later_rounded,
                                              color: AppColors.primaryColor,
                                            ),
                                            Text(
                                              '${item.preparationTime} ${Translate.get('minutes')}',
                                              style: TextStyle(
                                                fontSize: 13,
                                                color: AppColors.primaryColor,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
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
