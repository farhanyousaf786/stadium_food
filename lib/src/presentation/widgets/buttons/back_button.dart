import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:stadium_food/src/presentation/utils/app_styles.dart';

class CustomBackButton extends StatelessWidget {
  const CustomBackButton({
    super.key,
    required this.color,
    this.backgroundColor,
  });

  final Color color;
  /// Solid chip behind the icon (e.g. white on a colored hero).
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final bg = backgroundColor ?? color.withOpacity(0.1);
    final isSolid = backgroundColor != null;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => Navigator.pop(context),
        borderRadius: BorderRadius.circular(50),
        child: Container(
          width: 44,
          height: 44,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: bg,
            shape: BoxShape.circle,
            border: isSolid
                ? null
                : Border.all(color: color.withOpacity(0.25)),
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
          child: SvgPicture.asset(
            "assets/svg/back_arrow.svg",
            colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
          ),
        ),
      ),
    );
  }
}
