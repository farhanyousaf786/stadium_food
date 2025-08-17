import 'package:flutter/material.dart';
import 'package:stadium_food/src/core/translations/translate.dart';
import 'package:stadium_food/src/presentation/utils/app_colors.dart';
import 'package:stadium_food/src/presentation/utils/custom_text_style.dart';

class LocationPermissionDialog extends StatelessWidget {
  const LocationPermissionDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        Translate.get('locationPermissionRequired'),
        style: CustomTextStyle.size18Weight600Text(),
      ),
      content: Text(
        Translate.get('locationPermissionMessage'),
        style: CustomTextStyle.size16Weight400Text(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(
            Translate.get('cancel'),
            style: CustomTextStyle.size16Weight400Text().copyWith(
              color: AppColors.grayColor.withOpacity(0.5),
            ),
          ),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context, true);
          },
          child: Text(
            Translate.get('openSettings'),
            style: CustomTextStyle.size16Weight600Text().copyWith(
              color: AppColors.primaryColor,
            ),
          ),
        ),
      ],
    );
  }
}
