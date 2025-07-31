import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stadium_food/src/bloc/order/order_bloc.dart';
import 'package:stadium_food/src/data/models/food.dart';
import 'package:stadium_food/src/data/services/firestore_db.dart';
import 'package:stadium_food/src/presentation/widgets/image_placeholder.dart';
import 'package:stadium_food/src/presentation/widgets/formatted_price_text.dart';
import 'package:stadium_food/src/presentation/utils/app_colors.dart';
import 'package:stadium_food/src/presentation/utils/app_styles.dart';
import 'package:stadium_food/src/presentation/utils/custom_text_style.dart';
import 'package:shimmer/shimmer.dart';

class CartItem extends StatefulWidget {
  final Food food;
  const CartItem({super.key, required this.food});

  @override
  State<CartItem> createState() => _CartItemState();
}

class _CartItemState extends State<CartItem> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.food.name,
                    style: CustomTextStyle.size18Weight600Text(),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: FormattedPriceText(
                          amount: widget.food.price,
                          style: CustomTextStyle.size18Weight600Text(
                            AppColors.primaryColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Row(
                        children: [
                          UpdateQuantityButton(
                            backgroundColor:
                                AppColors.primaryColor.withOpacity(0.1),
                            iconColor: AppColors.primaryColor,
                            icon: Icons.remove,
                            onTap: () {
                              if (widget.food.quantity == 1) {
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Remove Item'),
                                    content: Text(
                                        'Remove ${widget.food.name} from cart?'),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text('Cancel'),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          BlocProvider.of<OrderBloc>(context)
                                              .add(
                                            RemoveFromCart(widget.food),
                                          );
                                          Navigator.pop(context);
                                        },
                                        child: const Text(
                                          'Remove',
                                          style: TextStyle(color: Colors.red),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              } else {
                                BlocProvider.of<OrderBloc>(context).add(
                                  RemoveFromCart(widget.food),
                                );
                              }
                            },
                          ),
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 8),
                            child: BlocBuilder<OrderBloc, OrderState>(
                              builder: (context, state) {
                                return Text(
                                  widget.food.quantity.toString(),
                                  style: CustomTextStyle.size16Weight600Text(),
                                );
                              },
                            ),
                          ),
                          UpdateQuantityButton(
                            backgroundColor: AppColors.primaryColor,
                            iconColor: Colors.white,
                            icon: Icons.add,
                            onTap: () {
                              BlocProvider.of<OrderBloc>(context).add(
                                AddToCart(widget.food),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(16),
              bottomRight: Radius.circular(16),
            ),
            child: SizedBox(
              height: 120,
              width: 120,
              child: widget.food.images.isEmpty
                  ? ImagePlaceholder(
                      iconData: Icons.fastfood,
                      iconSize: 40,
                    )
                  : Image.network(
                      widget.food.images.first,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return ImagePlaceholder(
                          iconData: Icons.fastfood,
                          iconSize: 40,
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class UpdateQuantityButton extends StatelessWidget {
  const UpdateQuantityButton({
    super.key,
    required this.onTap,
    required this.icon,
    required this.backgroundColor,
    required this.iconColor,
  });

  final VoidCallback onTap;
  final IconData icon;
  final Color backgroundColor;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 26,
        width: 26,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          boxShadow: [AppStyles().largeBoxShadow],
          color: backgroundColor,
        ),
        child: Icon(
          icon,
          color: iconColor,
          size: 16,
        ),
      ),
    );
  }
}

class CartItemShimmer extends StatelessWidget {
  const CartItemShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: AppStyles.largeBorderRadius,
        boxShadow: [AppStyles.boxShadow7],
        color: AppColors().cardColor,
      ),
      padding: const EdgeInsets.fromLTRB(10, 10, 20, 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Shimmer.fromColors(
            baseColor: AppColors.shimmerBaseColor,
            highlightColor: AppColors.shimmerHighlightColor,
            child: Container(
              height: 64,
              width: 64,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                boxShadow: [AppStyles().largeBoxShadow],
                color: AppColors.shimmerBaseColor,
              ),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Shimmer.fromColors(
                  baseColor: AppColors.shimmerBaseColor,
                  highlightColor: AppColors.shimmerHighlightColor,
                  child: Container(
                    height: 16,
                    width: 100,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [AppStyles().largeBoxShadow],
                      color: AppColors.shimmerBaseColor,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Shimmer.fromColors(
                  baseColor: AppColors.shimmerBaseColor,
                  highlightColor: AppColors.shimmerHighlightColor,
                  child: Container(
                    height: 16,
                    width: 100,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [AppStyles().largeBoxShadow],
                      color: AppColors.shimmerBaseColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Shimmer.fromColors(
            baseColor: AppColors.shimmerBaseColor,
            highlightColor: AppColors.shimmerHighlightColor,
            child: Container(
              height: 32,
              width: 32,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                boxShadow: [AppStyles().largeBoxShadow],
                color: AppColors.shimmerBaseColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
