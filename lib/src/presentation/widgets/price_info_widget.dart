import 'package:flutter/material.dart';
import 'package:stadium_food/src/core/translations/translate.dart';
import 'package:stadium_food/src/data/repositories/order_repository.dart';
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
                    currencyCode: 'NIS',
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
                    currencyCode: 'NIS',
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
                    currencyCode: 'NIS',
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
                    currencyCode: 'NIS',
                    style: CustomTextStyle.size16Weight400Text(
                      AppColors().secondaryTextColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const Divider(thickness: 1),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    Translate.get('total'),
                    style: CustomTextStyle.size18Weight600Text(
                      AppColors().textColor,
                    ),
                  ),
                  FormattedPriceText(
                    amount: OrderRepository.total,
                    style: CustomTextStyle.size18Weight600Text(
                      AppColors.primaryColor,
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
