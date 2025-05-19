import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:stadium_food/src/bloc/food/food_bloc.dart';
import 'package:stadium_food/src/bloc/order/order_bloc.dart';
import 'package:stadium_food/src/bloc/profile/profile_bloc.dart';
import 'package:stadium_food/src/bloc/testimonial/testimonial_bloc.dart';
import 'package:stadium_food/src/data/models/food.dart';
import 'package:stadium_food/src/data/models/testimonial.dart';
import 'package:stadium_food/src/presentation/widgets/bullet_point.dart';
import 'package:stadium_food/src/presentation/widgets/buttons/primary_button.dart';
import 'package:stadium_food/src/presentation/widgets/image_placeholder.dart';
import 'package:stadium_food/src/presentation/widgets/buttons/like_button.dart';
import 'package:stadium_food/src/presentation/widgets/items/testimonial_item.dart';
import 'package:stadium_food/src/presentation/utils/app_colors.dart';
import 'package:stadium_food/src/presentation/utils/app_styles.dart';
import 'package:stadium_food/src/presentation/utils/custom_text_style.dart';

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
              rating = testimonials.map((e) => e.rating).reduce((a, b) => a + b) /
                  testimonials.length;
            } catch (e) {
              rating = 0;
            }
          });
        } else if (state is TestimonialFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to load testimonials')),
          );
        }
      },
      child: Scaffold(
        bottomNavigationBar: Container(
          margin: const EdgeInsets.fromLTRB(25, 0, 25, 25),
          child: PrimaryButton(
            text: "Add to cart",
            onTap: () {
              BlocProvider.of<OrderBloc>(context).add(
                AddToCart(widget.food),
              );
              Navigator.pushNamed(context, '/cart');
            },
          ),
        ),
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              leading: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(
                  Icons.arrow_back,
                  color: AppColors.secondaryColor,
                ),
              ),
              expandedHeight: MediaQuery.of(context).size.height * 0.4,
              flexibleSpace: Stack(
                children: [
                  FlexibleSpaceBar(
                    background: widget.food.images.isNotEmpty
                        ? Image.network(
                            widget.food.images.first,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                ImagePlaceholder(
                              iconData: Icons.fastfood,
                              iconSize: 100,
                            ),
                          )
                        : ImagePlaceholder(
                            iconData: Icons.fastfood,
                            iconSize: 100,
                          ),
                  ),
                  //Border radius
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors().backgroundColor,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(50),
                          topRight: Radius.circular(50),
                        ),
                        border: Border.all(
                          width: 0,
                          color: Theme.of(context).scaffoldBackgroundColor,
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.fromLTRB(
                  20,
                  0,
                  20,
                  40,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 34,
                      child: Row(
                        children: [
                          Container(
                            alignment: Alignment.center,
                            height: 34,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 15,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: AppStyles.largeBorderRadius,
                              gradient: LinearGradient(
                                colors: [
                                  AppColors.primaryColor.withOpacity(0.1),
                                  AppColors.primaryDarkColor.withOpacity(0.1),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            child: ShaderMask(
                              shaderCallback: (rect) {
                                return LinearGradient(
                                  colors: AppColors.primaryGradient,
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ).createShader(rect);
                              },
                              child: Text(
                                'Popular',
                                style: CustomTextStyle.size14Weight400Text(
                                  Colors.white,
                                ),
                              ),
                            ),
                          ),
                          const Spacer(),
                          SvgPicture.asset(
                            "assets/svg/location.svg",
                          ),
                          const SizedBox(width: 12),
                          BlocBuilder<ProfileBloc, ProfileState>(
                            builder: (context, state) {
                              return LikeButton(
                                isLiked: widget.food.isFavorite,
                                onTap: () {
                                  BlocProvider.of<ProfileBloc>(context).add(
                                    ToggleFavoriteFood(foodId: widget.food.id, shopId: widget.food.shopId, stadiumId: widget.food.stadiumId,),
                                  );
                                },
                              );
                            },
                          ),
                        ],
                      ),
                    ),

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
                        Text(
                          "\$${widget.food.price}",
                          style: CustomTextStyle.size22Weight600Text(
                            AppColors.secondaryDarkColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SvgPicture.asset(
                          "assets/svg/star.svg",
                        ),
                        const SizedBox(width: 10),
                        BlocBuilder<TestimonialBloc, TestimonialState>(
                          builder: (context, state) {
                            return Text(
                              "${rating.toStringAsFixed(2)} Rating",
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
                                "${state.count} ${state.count == 1 ? 'Order' : 'Orders'}",
                                style: CustomTextStyle.size14Weight400Text(
                                  AppColors().secondaryTextColor,
                                ),
                              );
                            }
                            return Text(
                              "0 Orders",
                              style: CustomTextStyle.size14Weight400Text(
                                AppColors().secondaryTextColor,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // description
                    widget.food.description != null
                        ? Text(
                            widget.food.description,
                            style: CustomTextStyle.size14Weight400Text(),
                          )
                        : Center(
                            child: Text(
                              "No description available",
                              style: CustomTextStyle.size14Weight400Text(
                                AppColors().secondaryTextColor,
                              ),
                            ),
                          ),
                    const SizedBox(height: 20),

                    // allergens
                    Text(
                      "Allergens",
                      style: CustomTextStyle.size18Weight600Text(),
                    ),
                    const SizedBox(height: 10),
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
                        : Center(
                            child: Text(
                              "No ingredients available",
                              style: CustomTextStyle.size14Weight400Text(
                                AppColors().secondaryTextColor,
                              ),
                            ),
                          ),
                    const SizedBox(height: 20),

                    // testimonials
                    Text(
                      "Testimonials",
                      style: CustomTextStyle.size18Weight600Text(),
                    ),
                    const SizedBox(height: 20),
                    BlocBuilder<TestimonialBloc, TestimonialState>(
                      builder: (context, state) {
                        if (state is TestimonialLoading) {
                          return const Center(
                            child: CircularProgressIndicator(color: AppColors.primaryColor),
                          );
                        }
                        
                        if (testimonials.isEmpty) {
                          return Center(
                            child: Text(
                              "No testimonials available",
                              style: CustomTextStyle.size14Weight400Text(
                                AppColors().secondaryTextColor,
                              ),
                            ),
                          );
                        }

                        return ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: testimonials.length,
                          padding: const EdgeInsets.all(0),
                          itemBuilder: (context, index) {
                            return TestimonialItem(
                              testimonial: testimonials[index],
                            );
                          },
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
    );
  }
}
