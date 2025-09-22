import 'package:flutter/material.dart';
import 'package:stadium_food/src/presentation/utils/app_colors.dart';
class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Stack(
            alignment: Alignment.center,
            children: [
              const SizedBox(
                width: 60,
                height: 60,
                child: CircularProgressIndicator(
                  strokeWidth: 5,
                  color: AppColors.primaryColor,
                ),
              ),
              // Replace with your app icon
              Image.asset(
                'assets/icon/app_icon.png',
                width: 40,
                height: 40,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

