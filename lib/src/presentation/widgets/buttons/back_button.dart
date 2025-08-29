import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:stadium_food/src/presentation/utils/app_colors.dart';
import 'package:stadium_food/src/presentation/utils/app_styles.dart';

class CustomBackButton extends StatelessWidget {


   const CustomBackButton({
    super.key,
     required this.color
  });
   final Color color;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
      },
      borderRadius: AppStyles.defaultBorderRadius,
      child:


      Container(
        width: 50,
        height: 50,
        padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color:color.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(color: color.withOpacity(0.25)),
              boxShadow: [AppStyles.boxShadow7],
            ),

        child: SvgPicture.asset(
          "assets/svg/back_arrow.svg",
          colorFilter:  ColorFilter.mode(
            color,
            BlendMode.srcIn,
          ),
        ),
      ),
    );
  }
}
