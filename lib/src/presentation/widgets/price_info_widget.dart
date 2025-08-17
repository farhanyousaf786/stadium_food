import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:stadium_food/src/core/translations/translate.dart';
import 'package:stadium_food/src/data/repositories/order_repository.dart';
import 'package:stadium_food/src/presentation/widgets/buttons/secondary_button.dart';
import 'package:stadium_food/src/presentation/widgets/formatted_price_text.dart';
import 'package:stadium_food/src/presentation/utils/app_colors.dart';
import 'package:stadium_food/src/presentation/utils/app_styles.dart';
import 'package:stadium_food/src/presentation/utils/custom_text_style.dart';

class PriceInfoWidget extends StatelessWidget {
  final VoidCallback onTap;
  const PriceInfoWidget({
    super.key,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Container(
        margin: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: AppColors.primaryGradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: AppStyles.largeBorderRadius,
          boxShadow: [AppStyles.boxShadow7],
        ),
        child: Stack(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: SvgPicture.asset(
                'assets/svg/pattern-card.svg',
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        Translate.get('subtotal'),
                        style: CustomTextStyle.size16Weight400Text(
                          Colors.white,
                        ),
                      ),
                      FormattedPriceText(
                        amount: OrderRepository.subtotal,
                        style: CustomTextStyle.size16Weight400Text(
                          Colors.white,
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
                          Colors.white,
                        ),
                      ),
                      FormattedPriceText(
                        amount: OrderRepository.deliveryFee,
                        style: CustomTextStyle.size16Weight400Text(
                          Colors.white,
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
                          Colors.white,
                        ),
                      ),
                      FormattedPriceText(
                        amount: OrderRepository.tip,
                        style: CustomTextStyle.size16Weight400Text(
                          Colors.white,
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
                          Colors.white,
                        ),
                      ),
                      FormattedPriceText(
                        amount: OrderRepository.discount,
                        style: CustomTextStyle.size16Weight400Text(
                          Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        Translate.get('total'),
                        style: CustomTextStyle.size22Weight600Text(
                          Colors.white,
                        ),
                      ),
                      FormattedPriceText(
                        amount: OrderRepository.total,
                        style: CustomTextStyle.size22Weight600Text(
                          Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: SecondaryButton(
                          text: Translate.get('placeOrder'),
                          onTap: onTap,
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
