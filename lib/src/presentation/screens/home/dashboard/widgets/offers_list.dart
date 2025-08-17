import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stadium_food/src/bloc/offer/offer_bloc.dart';
import 'package:stadium_food/src/bloc/offer/offer_event.dart';
import 'package:stadium_food/src/bloc/offer/offer_state.dart';
import 'package:stadium_food/src/data/models/food.dart';
import 'package:stadium_food/src/presentation/utils/app_colors.dart';
import 'package:stadium_food/src/presentation/widgets/formatted_price_text.dart';
import 'package:stadium_food/src/presentation/screens/explore/food_details_screen.dart';

class OffersList extends StatefulWidget {
  const OffersList({Key? key}) : super(key: key);

  @override
  State<OffersList> createState() => _OffersListState();
}

class _OffersListState extends State<OffersList> {
  @override
  void initState() {
    super.initState();
    context.read<OfferBloc>().add(LoadOffers());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OfferBloc, OfferState>(
      builder: (context, state) {
        if (state is OfferInitial) {
          context.read<OfferBloc>().add(LoadOffers());
          return const SizedBox.shrink();
        }

        if (state is OfferLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is OfferError) {
          return Text('Error: ${state.message}');
        }

        if (state is OfferLoaded) {
          final offers = state.offers
              .where((offer) => offer.discountPercentage > 0)
              .toList();

          if (offers.isEmpty) {
            return const SizedBox.shrink();
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(bottom: 12),
                child: Text(
                  'Special Offers',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(
                height: 120,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: offers.length,
                  itemBuilder: (context, index) {
                    final offer = offers[index];
                    return GestureDetector(
                      onTap: () {
                        // Calculate discounted price
                        final discountedPrice = offer.price -
                            (offer.price * (offer.discountPercentage / 100));

                        // Convert Offer to Food model
                        final food = Food(
                          id: offer.id,
                          allergens: offer.allergens,
                          category: offer.category,
                          createdAt: offer.createdAt,
                          customization: offer.customization,
                          description: offer.description,
                          extras: offer.extras,
                          images: offer.images,
                          isAvailable: offer.isAvailable,
                          name: offer.name,
                          nutritionalInfo: offer.nutritionalInfo,
                          preparationTime: offer.preparationTime,
                          price:
                              discountedPrice, // Use the calculated discounted price
                          sauces: offer.sauces,
                          shopIds: [offer.shopId],
                          stadiumId: offer.stadiumId,
                          sizes: offer.sizes,
                          toppings: offer.toppings,
                          updatedAt: offer.updatedAt,
                          foodType: offer.foodType,
                        );

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => FoodDetailsScreen(food: food),
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: Column(
                          children: [
                            SizedBox(
                              width: 90,
                              height: 90,
                              child: Stack(
                                children: [
                                  // Image
                                  Container(
                                    width: 90,
                                    height: 90,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(45),
                                      border: Border.all(
                                        color: AppColors.primaryColor,
                                        width: 2,
                                      ),
                                      image: offer.images.isNotEmpty
                                          ? DecorationImage(
                                              image:
                                                  NetworkImage(offer.images[0]),
                                              fit: BoxFit.cover,
                                            )
                                          : null,
                                    ),
                                  ),
                                  // Gradient Overlay
                                  Container(
                                    width: 90,
                                    height: 90,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(45),
                                      gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          AppColors.primaryColor
                                              .withOpacity(0.3),
                                          AppColors.primaryColor
                                              .withOpacity(0.5),
                                        ],
                                      ),
                                    ),
                                  ),
                                  // Price Text
                                  Center(
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 4, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: AppColors.primaryColor
                                            .withOpacity(0.5),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          FormattedPriceText(
                                            amount: offer.price,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 10,
                                              fontWeight: FontWeight.w600,
                                              decoration:
                                                  TextDecoration.lineThrough,
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                          FormattedPriceText(
                                            amount: offer.price *
                                                (1 -
                                                    offer.discountPercentage /
                                                        100),
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 10,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              offer.name,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}
