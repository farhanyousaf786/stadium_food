import 'package:flutter/material.dart';
import 'package:stadium_food/src/presentation/utils/app_colors.dart';
import '../../utils/app_styles.dart';

class LikeButton extends StatelessWidget {
  final bool isLiked;
  final VoidCallback onTap;
  /// Solid chip behind the icon (e.g. white on a colored hero).
  final Color? backgroundColor;

  const LikeButton({
    super.key,
    required this.isLiked,
    required this.onTap,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final accent = AppColors.likeColor;
    final bg = backgroundColor ?? accent.withOpacity(0.1);
    final isSolid = backgroundColor != null;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(50),
        onTap: onTap,
        child: Container(
          height: 44,
          width: 44,
          decoration: BoxDecoration(
            color: bg,
            shape: BoxShape.circle,
            border: isSolid
                ? null
                : Border.all(color: accent.withOpacity(0.25)),
            boxShadow: isSolid
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.18),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [AppStyles.boxShadow7],
          ),
          child: Icon(
            isLiked ? Icons.favorite : Icons.favorite_border,
            color: accent,
            size: 22,
          ),
        ),
      ),
    );
  }
}
