import 'package:flutter/material.dart';
import 'package:stadium_food/src/presentation/utils/app_colors.dart';

// ignore: must_be_immutable
class ImagePlaceholder extends StatelessWidget {
  final IconData iconData;
  final double iconSize;
  double? width;
  double? height;

  ImagePlaceholder({
    super.key,
    required this.iconData,
    required this.iconSize,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width ?? double.infinity,
      height: height ?? double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryLightColor,
            AppColors.primaryColor,
            AppColors.primaryDarkColor,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Icon(
        iconData,
        color: Colors.white.withOpacity(0.92),
        size: iconSize,
      ),
    );
  }
}
