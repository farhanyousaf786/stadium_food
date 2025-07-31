import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:stadium_food/src/presentation/widgets/buttons/primary_button.dart';
import 'package:stadium_food/src/presentation/utils/custom_text_style.dart';
import 'package:hive/hive.dart';
import 'package:stadium_food/src/core/translations/translate.dart';

import '../../utils/app_colors.dart';

class OnboardingSecondScreen extends StatelessWidget {
  const OnboardingSecondScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      body: SingleChildScrollView(
        child: Align(
          child: Column(
            children: [
              const SizedBox(height: 56),
              SvgPicture.asset(
                "assets/svg/onboarding-2.svg",
                width: 400,
              ),
              const SizedBox(height: 40),
              Text(
                Translate.get('onboarding_second_title'),
                textAlign: TextAlign.center,
                style: CustomTextStyle.size22Weight600Text(),
              ),
              const SizedBox(height: 20),
              Text(
                Translate.get('onboarding_second_description'),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 60),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: PrimaryButton(
                  text: Translate.get('onboarding_button_next'),
                  onTap: () {
                    // Mark that the user has seen onboarding
                    Hive.box('myBox').put('hasSeenOnboarding', true);

                    // Navigate to stadium selection instead of register
                    Navigator.pushReplacementNamed(
                      context,
                      "/select-stadium",
                    );
                  },
                ),
              ),
              const SizedBox(height: 60),
            ],
          ),
        ),
      ),
    );
  }
}
