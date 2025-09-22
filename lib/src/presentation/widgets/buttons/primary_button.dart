import 'package:flutter/material.dart';
import 'package:stadium_food/src/presentation/utils/app_colors.dart';
import 'package:stadium_food/src/presentation/utils/custom_text_style.dart';

class PrimaryButton extends StatelessWidget {
  final String text;
  final IconData? iconData;
  final VoidCallback onTap;
  final double? horizontalPadding;
  final double? verticalPadding;
  final Color? bgColor;
  final Color? textColor;

  const PrimaryButton({
    super.key,
    required this.text,
    required this.onTap,
    this.iconData,
    this.bgColor,
    this.textColor,
    this.horizontalPadding,
    this.verticalPadding,
  });

  @override
  Widget build(BuildContext context) {
    return Ink(
      decoration:  BoxDecoration(
        color: bgColor?? AppColors.primaryDarkColor,
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      child: InkWell(
        borderRadius: const BorderRadius.all(Radius.circular(10)),
        onTap: onTap,
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(10))
          ),
          padding:  EdgeInsets.symmetric(
            horizontal: horizontalPadding ?? 60,
            vertical: verticalPadding ?? 20,
          ),
          child: iconData == null
              ? Text(
                  text,
                  textAlign: TextAlign.center,
                  style: CustomTextStyle.size16Weight600Text(
                    textColor??  Colors.white,
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      iconData,
                      color: Colors.white,
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Text(
                      text,
                      textAlign: TextAlign.center,
                      style: CustomTextStyle.size16Weight600Text(
                        textColor??   Colors.white,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
