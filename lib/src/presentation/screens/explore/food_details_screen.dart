import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_swipe_button/flutter_swipe_button.dart';
import 'package:stadium_food/src/bloc/food/food_bloc.dart';
import 'package:stadium_food/src/core/translations/translate.dart';
import 'package:stadium_food/src/bloc/order/order_bloc.dart';
import 'package:stadium_food/src/bloc/profile/profile_bloc.dart';
import 'package:stadium_food/src/bloc/testimonial/testimonial_bloc.dart';
import 'package:stadium_food/src/data/models/food.dart';
import 'package:stadium_food/src/data/models/testimonial.dart';
import 'package:stadium_food/src/data/services/language_service.dart';
import 'package:stadium_food/src/presentation/widgets/bullet_point.dart';
import 'package:stadium_food/src/presentation/widgets/formatted_price_text.dart';
import 'package:stadium_food/src/presentation/widgets/image_placeholder.dart';
import 'package:stadium_food/src/presentation/widgets/buttons/like_button.dart';
import 'package:stadium_food/src/presentation/widgets/items/testimonial_item.dart';
import 'package:stadium_food/src/presentation/utils/app_colors.dart';
import 'package:stadium_food/src/presentation/utils/custom_text_style.dart';
import '../../../data/repositories/order_repository.dart';
import '../../widgets/buttons/back_button.dart';
import '../../widgets/items/cart_item.dart';

class FoodDetailsScreen extends StatefulWidget {
  final Food food;

  const FoodDetailsScreen({super.key, required this.food});

  @override
  State<FoodDetailsScreen> createState() => _FoodDetailsScreenState();
}

class _FoodDetailsScreenState extends State<FoodDetailsScreen> {
  List<Testimonial> testimonials = [];
  double rating = 0;
  int qty=1;

  Widget _dot(bool active) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: active
            ? AppColors.primaryColor
            : AppColors.primaryColor.withOpacity(0.2),
        shape: BoxShape.circle,
      ),
    );
  }

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
    final lang = LanguageService.getCurrentLanguage();
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
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
            child: SwipeButton.expand(
              duration: const Duration(milliseconds: 200),
              thumbPadding: EdgeInsets.all(3),
              height: 60,
              activeThumbColor: AppColors.primaryDarkColor,
              inactiveThumbColor: Colors.white,
              activeTrackColor: Colors.white,
              inactiveTrackColor: AppColors.primaryDarkColor,
              elevationThumb: 1,
              child: Text(
                Translate.get('addToCart'),
                style: TextStyle(
                  fontSize: 18,
                  color: Color(0xFF969696),
                ),
              ),
              onSwipe: () {
                BlocProvider.of<OrderBloc>(context).add(
                  AddToCartQty(widget.food,qty),
                );

                Navigator.pushReplacementNamed(context, '/cart');
              },
            ),
          ),
        ),
        body: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                backgroundColor: AppColors.bgColor,
                leading: SizedBox.shrink(),
                expandedHeight: MediaQuery.of(context).size.height * 0.45,
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      widget.food.images.isNotEmpty
                          ? Container(
                              color: AppColors.bgColor,
                              padding: const EdgeInsets.symmetric(vertical: 10),
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
                      // bottom gradient fade
                      // Align(
                      //   alignment: Alignment.bottomCenter,
                      //   child:
                      //
                      //   Container(
                      //     height: 120,
                      //     decoration:  BoxDecoration(
                      //       gradient: LinearGradient(
                      //         begin: Alignment.topCenter,
                      //         end: Alignment.bottomCenter,
                      //         colors: [
                      //           Colors.transparent,
                      //           Colors.black12.withOpacity(0.1),
                      //           Colors.black26.withOpacity(0.1),
                      //         ],
                      //       ),
                      //     ),
                      //   ),
                      // ),
                      // top-right like button
                      Positioned(
                        left: 16,
                        top: 16,
                        child: CustomBackButton(
                          color: AppColors.primaryDarkColor,
                        ),
                      ),
                      Positioned(
                        right: 16,
                        top: 16,
                        child: BlocBuilder<ProfileBloc, ProfileState>(
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
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Container(
                  color: AppColors.bgColor,
                  padding: const EdgeInsets.fromLTRB(
                    20,
                    8,
                    20,
                    40,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      // orders centered
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SvgPicture.asset(
                            "assets/svg/orders.svg",
                            height: 24,
                            width: 24,
                          ),
                          const SizedBox(width: 8),
                          BlocBuilder<FoodBloc, FoodState>(
                            builder: (context, state) {
                              String text;
                              if (state is OrderCountFetched) {
                                text =
                                    "${state.count} ${Translate.get('orderCount')}";
                              } else if (state is OrderCountFetching) {
                                text = Translate.get('loading');
                              } else {
                                text = "0 ${Translate.get('orderCount')}";
                              }
                              return Text(
                                text,
                                style: CustomTextStyle.size16Weight400Text(
                                    AppColors().secondaryTextColor),
                              );
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // title centered
                      Center(
                        child: Text(
                          widget.food.nameFor(lang),
                          style: CustomTextStyle.size27Weight600Text(),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Center(
                        child: Text(
                          Translate.get('description'),
                          style: CustomTextStyle.size20Weight600Text(),
                        ),
                      ),
                      const SizedBox(height: 8),

                      Center(
                        child: Text(
                          widget.food.descriptionFor(lang).isNotEmpty
                              ? widget.food.descriptionFor(lang)
                              : Translate.get('noDescriptionAvailable'),
                          style: CustomTextStyle.size14Weight400Text(
                            widget.food.descriptionFor(lang).isNotEmpty
                                ? null
                                : AppColors().secondaryTextColor,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Price big and blue
                      Center(
                        child: FormattedPriceText(
                          amount: widget.food.price,
                          style: CustomTextStyle.size22Weight600Text(
                                  AppColors.primaryColor)
                              .copyWith(fontSize: 26),
                        ),
                      ),
                      const SizedBox(height: 20),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          UpdateQuantityButton(
                            backgroundColor: AppColors.primaryDarkColor,
                            iconColor: Colors.white,
                            icon: Icons.remove,
                            onTap: () {
                              setState(() {
                                if (qty > 1) {
                                  qty--;
                                }
                              });
                            },
                          ),
                          const SizedBox(width: 10),
                          // Live quantity text

                          Text(qty.toString(),
                              style: CustomTextStyle.size16Weight600Text(
                                AppColors().secondaryTextColor,
                              )),
                          const SizedBox(width: 10),
                          UpdateQuantityButton(
                            backgroundColor: AppColors.primaryDarkColor,
                            iconColor: Colors.white,
                            icon: Icons.add,
                            onTap: () {
                              setState(() {
                                qty++;
                              });
                            },
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),
                      // allergens
                      widget.food.allergens.isNotEmpty
                          ? Text(
                              Translate.get('allergens'),
                              style: CustomTextStyle.size18Weight600Text(),
                            )
                          : SizedBox(),
                      widget.food.allergens.isNotEmpty
                          ? const SizedBox(height: 10)
                          : SizedBox(),
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
                            return SizedBox.shrink();
                            // return Center(
                            //   child: Text(
                            //     Translate.get('noTestimonialsAvailable'),
                            //     style: CustomTextStyle.size14Weight400Text(
                            //       AppColors().secondaryTextColor,
                            //     ),
                            //   ),
                            // );
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
