import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:stadium_food/src/core/translations/translate.dart';
import 'package:stadium_food/src/data/repositories/order_repository.dart';
import 'package:stadium_food/src/presentation/widgets/buttons/primary_button.dart';
import 'package:stadium_food/src/presentation/widgets/buttons/secondary_button.dart';
import 'package:stadium_food/src/presentation/widgets/formatted_price_text.dart';
import 'package:stadium_food/src/presentation/utils/app_colors.dart';
import 'package:stadium_food/src/presentation/utils/app_styles.dart';
import 'package:stadium_food/src/presentation/utils/custom_text_style.dart';

class PriceInfoWidget extends StatelessWidget {

  const PriceInfoWidget({
    super.key,

  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Container(

        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: AppStyles.largeBorderRadius,
          boxShadow: [AppStyles.boxShadow7],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    Translate.get('subtotal'),
                    style: CustomTextStyle.size16Weight400Text(
                      AppColors().secondaryTextColor,
                    ),
                  ),
                  FormattedPriceText(
                    amount: OrderRepository.subtotal,
                    style: CustomTextStyle.size16Weight400Text(
                      AppColors().secondaryTextColor,
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    Translate.get('handlingAndDelivery'),
                    style: CustomTextStyle.size16Weight400Text(
                      AppColors().secondaryTextColor,
                    ),
                  ),
                  FormattedPriceText(
                    amount: OrderRepository.deliveryFee,
                    style: CustomTextStyle.size16Weight400Text(
                      AppColors().secondaryTextColor,
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    Translate.get('tip'),
                    style: CustomTextStyle.size16Weight400Text(
                      AppColors().secondaryTextColor,
                    ),
                  ),
                  FormattedPriceText(
                    amount: OrderRepository.tip,
                    style: CustomTextStyle.size16Weight400Text(
                      AppColors().secondaryTextColor,
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    Translate.get('discount'),
                    style: CustomTextStyle.size16Weight400Text(
                      AppColors().secondaryTextColor,
                    ),
                  ),
                  FormattedPriceText(
                    amount: OrderRepository.discount,
                    style: CustomTextStyle.size16Weight400Text(
                      AppColors().secondaryTextColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Divider(
                color:   AppColors().secondaryTextColor,  // line color
                thickness: 1,          // line thickness
                    // empty space after line
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    Translate.get('total'),
                    style: CustomTextStyle.size22Weight600Text(
                      AppColors().secondaryTextColor,
                    ),
                  ),
                  FormattedPriceText(
                    amount: OrderRepository.total,
                    style: CustomTextStyle.size22Weight600Text(
                      AppColors().secondaryTextColor,
                    ),
                  ),
                ],
              ),

            ],
          ),
        ),
      ),
    );
  }
}
