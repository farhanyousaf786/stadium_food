import 'package:flutter/material.dart';
import 'package:stadium_food/src/presentation/utils/app_colors.dart';

import '../../utils/app_styles.dart';

class LikeButton extends StatelessWidget {
  final bool isLiked;
  final VoidCallback onTap;
  const LikeButton({super.key, required this.isLiked, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(50),
      onTap: onTap,
      child: Container(
        height: 50,
        width: 50,
        decoration: BoxDecoration(
          color: AppColors.likeColor.withOpacity(0.1),
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.likeColor.withOpacity(0.25)),
          boxShadow: [AppStyles.boxShadow7],
        ),

        child: Icon(
          isLiked ? Icons.favorite : Icons.favorite_border,
          color: AppColors.likeColor,
          size: 25,
        ),
      ),
    );
  }
}
