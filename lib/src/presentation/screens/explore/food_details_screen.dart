import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:stadium_food/src/bloc/food/food_bloc.dart';
import 'package:stadium_food/src/core/translations/translate.dart';
import 'package:stadium_food/src/bloc/order/order_bloc.dart';
import 'package:stadium_food/src/bloc/profile/profile_bloc.dart';
import 'package:stadium_food/src/bloc/testimonial/testimonial_bloc.dart';
import 'package:stadium_food/src/data/models/food.dart';
import 'package:stadium_food/src/data/models/testimonial.dart';
import 'package:stadium_food/src/presentation/widgets/bullet_point.dart';
import 'package:stadium_food/src/presentation/widgets/buttons/primary_button.dart';
import 'package:stadium_food/src/presentation/widgets/formatted_price_text.dart';
import 'package:stadium_food/src/presentation/widgets/image_placeholder.dart';
import 'package:stadium_food/src/presentation/widgets/buttons/like_button.dart';
import 'package:stadium_food/src/presentation/widgets/items/testimonial_item.dart';
import 'package:stadium_food/src/presentation/utils/app_colors.dart';
import 'package:stadium_food/src/presentation/utils/custom_text_style.dart';
import '../../widgets/buttons/back_button.dart';

class FoodDetailsScreen extends StatefulWidget {
  final Food food;
  const FoodDetailsScreen({super.key, required this.food});

  @override
  State<FoodDetailsScreen> createState() => _FoodDetailsScreenState();
}

class _FoodDetailsScreenState extends State<FoodDetailsScreen> {
  List<Testimonial> testimonials = [];
  double rating = 0;
  @override
  void initState() {
    super.initState();
    BlocProvider.of<FoodBloc>(context).add(
      FetchOrderCount(foodId: widget.food.id),
    );

    DocumentReference foodRef =
        FirebaseFirestore.instance.collection('foods').doc(widget.food.id);

    BlocProvider.of<TestimonialBloc>(context).add(
      FetchTestimonials(
        target: foodRef,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<TestimonialBloc, TestimonialState>(
      listener: (context, state) {
        if (state is TestimonialsFetched) {
          setState(() {
            testimonials = state.testimonials;
            try {
              rating =
                  testimonials.map((e) => e.rating).reduce((a, b) => a + b) /
                      testimonials.length;
            } catch (e) {
              rating = 0;
            }
          });
        } else if (state is TestimonialFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(Translate.get('failedToLoadTestimonials'))),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.bgColor,
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 0, 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                children: [
                  const SizedBox(width: 40),
                  BlocBuilder<ProfileBloc, ProfileState>(
                    builder: (context, state) {
                      return LikeButton(
                        isLiked: widget.food.isFavorite,
                        onTap: () {
                          BlocProvider.of<ProfileBloc>(context).add(
                            ToggleFavoriteFood(
                              foodId: widget.food.id,
                              shopId: widget.food.shopIds.first,
                              stadiumId: widget.food.stadiumId,
                            ),
                          );
                        },
                      );
                    },
                  ),
                  const SizedBox(width: 10),
                ],
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(25, 0, 25, 0),
                  child: PrimaryButton(
                    iconData: Icons.add_shopping_cart,
                    text: Translate.get('addToCart'),
                    onTap: () {
                      BlocProvider.of<OrderBloc>(context).add(
                        AddToCart(widget.food),
                      );
                      Navigator.pushNamed(context, '/cart');
                    },
                  ),
                ),
              ),
              const SizedBox(width: 20),
            ],
          ),
        ),
        body: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                backgroundColor: AppColors.bgColor,
                leading: Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: const CustomBackButton(),
                ),

                expandedHeight: MediaQuery.of(context).size.height * 0.4,
                flexibleSpace: FlexibleSpaceBar(

                  background: widget.food.images.isNotEmpty
                      ? Container(
                          color: AppColors.bgColor,
                          padding: EdgeInsets.all(10),
                          child: Image.network(
                            widget.food.images.first,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                ImagePlaceholder(
                              iconData: Icons.fastfood,
                              iconSize: 100,
                            ),
                          ),
                        )
                      : ImagePlaceholder(
                          iconData: Icons.fastfood,
                          iconSize: 100,
                        ),
                ),
              ),
              SliverToBoxAdapter(
                child: Container(
                  color: AppColors().backgroundColor,
                  padding: const EdgeInsets.fromLTRB(
                    20,
                    0,
                    20,
                    40,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              widget.food.name,
                              style: CustomTextStyle.size27Weight600Text(),
                            ),
                          ),
                          FormattedPriceText(
                            amount: widget.food.price,
                            style: CustomTextStyle.size22Weight600Text(
                              AppColors.primaryColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SvgPicture.asset(
                              "assets/svg/star.svg",
                            ),
                            const SizedBox(width: 10),
                            BlocBuilder<TestimonialBloc, TestimonialState>(
                              builder: (context, state) {
                                return Text(
                                  rating > 0
                                      ? "${rating.toStringAsFixed(2)} ${Translate.get('rating')}"
                                      : Translate.get('noRatings'),
                                  style: CustomTextStyle.size14Weight400Text(
                                    AppColors().secondaryTextColor,
                                  ),
                                );
                              },
                            ),
                            const SizedBox(width: 25),
                            SvgPicture.asset(
                              "assets/svg/shopping-bag.svg",
                            ),
                            const SizedBox(width: 10),
                            BlocBuilder<FoodBloc, FoodState>(
                              builder: (context, state) {
                                if (state is OrderCountFetching) {
                                  return const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: AppColors.primaryColor,
                                    ),
                                  );
                                } else if (state is OrderCountFetched) {
                                  return Text(
                                    "${state.count} ${Translate.get('orderCount')}",
                                    style: CustomTextStyle.size14Weight400Text(
                                      AppColors().secondaryTextColor,
                                    ),
                                  );
                                }
                                return Text(
                                  "0 ${Translate.get('orderCount')}",
                                  style: CustomTextStyle.size14Weight400Text(
                                    AppColors().secondaryTextColor,
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Text(
                      //   Translate.get('description'),
                      // ),
                      Text(
                        widget.food.description.isNotEmpty
                            ? widget.food.description
                            : Translate.get('noDescriptionAvailable'),
                        style: CustomTextStyle.size14Weight400Text(
                          widget.food.description.isNotEmpty
                              ? null
                              : AppColors().secondaryTextColor,
                        ),
                        textAlign: widget.food.description.isNotEmpty
                            ? TextAlign.right
                            : TextAlign.center,
                      ),
                      const SizedBox(height: 20),

                      // allergens
                      widget.food.allergens.isNotEmpty?  Text(
                        Translate.get('allergens'),
                        style: CustomTextStyle.size18Weight600Text(),
                      ):SizedBox(),
                      widget.food.allergens.isNotEmpty?  const SizedBox(height: 10):SizedBox(),
                      widget.food.allergens.isNotEmpty
                          ? ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: widget.food.allergens.length,
                              padding: const EdgeInsets.all(0),
                              itemBuilder: (context, index) {
                                return Row(
                                  children: [
                                    const SizedBox(width: 20),
                                    const BulletPoint(),
                                    const SizedBox(width: 10),
                                    Text(
                                      widget.food.allergens[index],
                                      style:
                                          CustomTextStyle.size14Weight400Text(),
                                    ),
                                  ],
                                );
                              },
                            )
                          : SizedBox(),
                      // Center(
                      //         child: Text(
                      //           Translate.get('noIngredientsAvailable'),
                      //           style: CustomTextStyle.size14Weight400Text(
                      //             AppColors().secondaryTextColor,
                      //           ),
                      //         ),
                      //       ),


                      // testimonials

                      BlocBuilder<TestimonialBloc, TestimonialState>(
                        builder: (context, state) {
                          if (state is TestimonialLoading) {
                            return const Center(
                              child: CircularProgressIndicator(
                                  color: AppColors.primaryColor),
                            );
                          }

                          if (testimonials.isEmpty) {

                            return SizedBox();
                              Center(
                              child: Text(
                                Translate.get('noTestimonialsAvailable'),
                                style: CustomTextStyle.size14Weight400Text(
                                  AppColors().secondaryTextColor,
                                ),
                              ),
                            );
                          }

                          return Column(
                            children: [
                              const SizedBox(height: 20),
                              Text(
                                Translate.get('testimonials'),
                                style: CustomTextStyle.size18Weight600Text(),
                              ),
                              const SizedBox(height: 20),
                              ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: testimonials.length,
                                padding: const EdgeInsets.all(0),
                                itemBuilder: (context, index) {
                                  return TestimonialItem(
                                    testimonial: testimonials[index],
                                  );
                                },
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
