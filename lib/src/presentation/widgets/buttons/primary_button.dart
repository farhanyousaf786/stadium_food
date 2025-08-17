import 'package:flutter/material.dart';
import 'package:stadium_food/src/presentation/utils/app_colors.dart';
import 'package:stadium_food/src/presentation/utils/custom_text_style.dart';

class PrimaryButton extends StatelessWidget {
  final String text;
  final IconData? iconData;
  final VoidCallback onTap;

  const PrimaryButton({
    super.key,
    required this.text,
    required this.onTap,
    this.iconData,
  });

  @override
  Widget build(BuildContext context) {
    return Ink(
      decoration: const BoxDecoration(
        color: AppColors.primaryDarkColor,

        borderRadius: BorderRadius.all(Radius.circular(5)),
      ),
      child: InkWell(
        borderRadius: const BorderRadius.all(Radius.circular(5)),
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: 60,
            vertical: 16,
          ),
          child: iconData == null
              ? Text(
                  text,
                  textAlign: TextAlign.center,
                  style: CustomTextStyle.size16Weight600Text(
                    Colors.white,
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      iconData,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 10,),
                    Text(
                      text,
                      textAlign: TextAlign.center,
                      style: CustomTextStyle.size16Weight600Text(
                        Colors.white,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
