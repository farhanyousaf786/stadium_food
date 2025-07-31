import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hive/hive.dart';

import 'package:stadium_food/src/core/translations/translate.dart';
import 'package:stadium_food/src/presentation/widgets/buttons/primary_button.dart';
import 'package:stadium_food/src/presentation/utils/app_colors.dart';
import 'package:stadium_food/src/presentation/utils/custom_text_style.dart';

class RegisterSuccessScreen extends StatelessWidget {
  const RegisterSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      body: Stack(
        children: [

          Align(
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  "assets/svg/success.svg",
                ),
                const SizedBox(height: 33),
                ShaderMask(
                  shaderCallback: (bounds) => LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: AppColors.primaryGradient,
                  ).createShader(bounds),
                  blendMode: BlendMode.srcIn,
                  child: Text(
                    Translate.get('register_success_title'),
                    style: CustomTextStyle.size30Weight600Text(),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  Translate.get('register_success_description'),
                  style: CustomTextStyle.size16Weight400Text(
                    AppColors().textColor.withOpacity(0.5),
                  ),
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding:
              const EdgeInsets.only(bottom: 60, left: 25, right: 25),
              child: PrimaryButton(
                text: Translate.get('register_success_continue'),
                onTap: () async {
                  var box = Hive.box('myBox');
                  box.put('isRegistered', true);

                  if (!context.mounted) return;
                  
                  // Always show stadium selection after registration
                  await Navigator.pushNamed(context, '/select-stadium');
                  
                  if (!context.mounted) return;
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/home',
                    (route) => false,
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
