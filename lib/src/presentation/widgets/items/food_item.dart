import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:stadium_food/src/data/models/food.dart';
import 'package:stadium_food/src/presentation/utils/app_colors.dart';
import 'package:stadium_food/src/presentation/utils/custom_text_style.dart';


class FoodItem extends StatelessWidget {
  final Food food;
  final VoidCallback? onTap;

  const FoodItem({super.key, required this.food, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 1,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Image section
            Expanded(
              flex: 5,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: AspectRatio(
                  aspectRatio: 1.5,
                  child: food.images.isEmpty
                      ? _placeholder()
                      : Image.network(
                          food.images.first,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _placeholder(),
                        ),
                ),
              ),
            ),

            // Content section
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name
                    Text(
                      food.name,
                      style: CustomTextStyle.size16Weight600Text(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),

                    // Prep time and Rating
                    Row(
                      children: [
                        Icon(
                          Icons.schedule,
                          size: 16,
                          color: AppColors().secondaryTextColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${food.preparationTime} min',
                          style: CustomTextStyle.size14Weight400Text(
                            AppColors().secondaryTextColor,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Icon(
                          Icons.star,
                          size: 16,
                          color: Colors.amber,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '4.8',
                          style: CustomTextStyle.size14Weight400Text(
                            AppColors().secondaryTextColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Price
                    Text(
                      '${food.price.toStringAsFixed(2)} \$',
                      style: CustomTextStyle.size18Weight600Text(
                        AppColors.primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      color: Colors.grey[200],
      child: const Center(
        child: Icon(Icons.fastfood, size: 32, color: Colors.grey),
      ),
    );
  }
}



class FoodItemShimmer extends StatelessWidget {
  const FoodItemShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image shimmer
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: AspectRatio(
              aspectRatio: 1.2,
              child: Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: Container(color: Colors.white),
              ),
            ),
          ),

          // Content shimmer
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _shimmerLine(height: 18, width: 120),
                const SizedBox(height: 6),
                _shimmerLine(height: 14, width: double.infinity),
                const SizedBox(height: 6),
                _shimmerLine(height: 14, width: 100),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _shimmerLine(height: 18, width: 50),
                    _shimmerLine(height: 24, width: 40),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _shimmerLine({required double height, required double width}) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(6),
        ),
      ),
    );
  }
}