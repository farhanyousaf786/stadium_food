import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
  int qty = 1;
  final List<Map<String, dynamic>> _selectedExtras = [];
  List<Food> _comboItems = [];
  bool _comboLoading = false;

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

    if (widget.food.isCombo && widget.food.comboItemIds.isNotEmpty) {
      _fetchComboItems();
    }
  }

  Future<void> _fetchComboItems() async {
    setState(() => _comboLoading = true);
    try {
      final items = <Food>[];
      for (final itemId in widget.food.comboItemIds) {
        final doc = await FirebaseFirestore.instance
            .collection('menuItems')
            .doc(itemId)
            .get();
        if (doc.exists && doc.data() != null) {
          items.add(Food.fromMap(doc.id, doc.data()!));
        }
      }
      if (mounted) setState(() => _comboItems = items);
    } catch (_) {}
    if (mounted) setState(() => _comboLoading = false);
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
          child: SizedBox(
            height: 54,
            child: ElevatedButton(
              onPressed: () {
                BlocProvider.of<OrderBloc>(context).add(
                  AddToCartQty(widget.food, qty),
                );
                Navigator.pushReplacementNamed(context, '/cart');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                textStyle: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
              child: Text(Translate.get('addToCart')),
            ),
          ),
        ),
        body: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                backgroundColor: AppColors.bgColor,
                leading: SizedBox.shrink(),
                expandedHeight: MediaQuery.of(context).size.height * 0.30,
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      widget.food.images.isNotEmpty
                          ? Container(
                              color: AppColors.bgColor,
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child:
                              (widget.food.isCombo &&
                                  widget. food.images.length >= 2)
                                  ? Row(
                                children: [
                                  Expanded(
                                    child: Image.network(
                                      widget.food.images[0],
                                      width: double.infinity,
                                      height: double.infinity,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error,
                                          stackTrace) =>
                                          ImagePlaceholder(
                                            iconData: Icons.fastfood,
                                            iconSize: 100,
                                          ),
                                    ),
                                  ),
                                  Container(
                                    margin: EdgeInsets.symmetric(
                                        horizontal: 5),
                                    height: double.infinity,
                                    width: 3,
                                    color: AppColors.primaryColor,
                                  ),
                                  Expanded(
                                    child: Image.network(
                                      widget.food.images[1],
                                      width: double.infinity,
                                      height: double.infinity,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error,
                                          stackTrace) =>
                                          ImagePlaceholder(
                                            iconData: Icons.fastfood,
                                            iconSize: 100,
                                          ),
                                    ),
                                  ),
                                ],
                              )
                                  :Image.network(
                                widget.food.images.first,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error,
                                    stackTrace) =>
                                    ImagePlaceholder(
                                      iconData: Icons.fastfood,
                                      iconSize: 100,
                                    ),
                              )

                              // Image.network(
                              //   widget.food.images.first,
                              //   fit: BoxFit.cover,
                              //   errorBuilder: (context, error, stackTrace) =>
                              //       ImagePlaceholder(
                              //     iconData: Icons.fastfood,
                              //     iconSize: 100,
                              //   ),
                              // ),
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
                      // Name
                      Center(
                        child: Text(
                          widget.food.nameFor(lang),
                          style: CustomTextStyle.size27Weight600Text(),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Price + time + orders row (matching web)
                      Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            FormattedPriceText(
                              amount: widget.food.price,
                              style: CustomTextStyle.size22Weight600Text(
                                AppColors.primaryColor,
                              ).copyWith(fontSize: 22),
                            ),
                            const SizedBox(width: 12),
                            Icon(Icons.access_time, size: 14, color: Colors.grey.shade500),
                            const SizedBox(width: 4),
                            Text(
                              '${widget.food.preparationTime} min',
                              style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
                            ),
                            const SizedBox(width: 12),
                            Icon(Icons.shopping_bag_outlined, size: 14, color: Colors.grey.shade500),
                            const SizedBox(width: 4),
                            BlocBuilder<FoodBloc, FoodState>(
                              builder: (context, state) {
                                String countText;
                                if (state is OrderCountFetched) {
                                  countText = '${state.count} orders';
                                } else if (state is OrderCountFetching) {
                                  countText = '...';
                                } else {
                                  countText = '0 orders';
                                }
                                return Text(
                                  countText,
                                  style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Description section
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

                      // Extras / Customization options from backend
                      _buildExtrasSection(),

                      const SizedBox(height: 8),

                      // Combo items section (matching web)
                      _buildComboSection(),

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

  /// Build extras/options section from backend customization data
  Widget _buildExtrasSection() {
    final options = widget.food.customization['options'];
    if (options == null || options is! List || options.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Options',
          style: CustomTextStyle.size18Weight600Text(),
        ),
        const SizedBox(height: 10),
        ...options.map((opt) {
          final name = opt['name']?.toString() ?? '';
          final priceVal = (opt['price'] ?? 0).toDouble();
          final isSelected = _selectedExtras.any(
            (s) => s['name'] == name && s['price'] == priceVal,
          );
          return InkWell(
            onTap: () {
              setState(() {
                if (isSelected) {
                  _selectedExtras.removeWhere(
                    (s) => s['name'] == name && s['price'] == priceVal,
                  );
                } else {
                  _selectedExtras.add({
                    'name': name,
                    'price': priceVal,
                  });
                }
              });
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  Checkbox(
                    value: isSelected,
                    onChanged: (_) {
                      setState(() {
                        if (isSelected) {
                          _selectedExtras.removeWhere(
                            (s) => s['name'] == name && s['price'] == priceVal,
                          );
                        } else {
                          _selectedExtras.add({
                            'name': name,
                            'price': priceVal,
                          });
                        }
                      });
                    },
                    activeColor: AppColors.primaryColor,
                    visualDensity: VisualDensity.compact,
                  ),
                  Expanded(
                    child: Text(
                      name,
                      style: CustomTextStyle.size14Weight400Text(),
                    ),
                  ),
                  if (priceVal > 0)
                    FormattedPriceText(
                      amount: priceVal,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryColor,
                      ),
                    )
                  else
                    Text(
                      'Free',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Colors.green.shade600,
                      ),
                    ),
                ],
              ),
            ),
          );
        }).toList(),
        const SizedBox(height: 10),
      ],
    );
  }

  /// Build combo items section matching web UI
  Widget _buildComboSection() {
    if (!widget.food.isCombo) return const SizedBox.shrink();
    if (_comboLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 20),
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }
    if (_comboItems.isEmpty) return const SizedBox.shrink();

    final totalIndividual = _comboItems.fold<double>(
      0,
      (sum, item) => sum + item.price,
    );
    final savings = totalIndividual - widget.food.price;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Text(
            'This combo includes:',
            style: CustomTextStyle.size20Weight600Text(),
          ),
        ),
        const SizedBox(height: 16),
        // Price comparison card
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            children: [
              _priceRow('Individual items total:', totalIndividual, Colors.grey.shade700, true),
              const SizedBox(height: 6),
              _priceRow('Combo price:', widget.food.price, AppColors.primaryColor, false),
              if (savings > 0) ...[
                const Divider(height: 16),
                _priceRow('You save:', savings, Colors.green.shade700, false),
              ],
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Combo item cards
        ..._comboItems.asMap().entries.map((entry) {
          final item = entry.value;
          return InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => FoodDetailsScreen(food: item),
                ),
              );
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: item.images.isNotEmpty
                      ? Image.network(
                          item.images.first,
                          width: 56,
                          height: 56,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            width: 56,
                            height: 56,
                            color: Colors.grey.shade200,
                            child: Icon(Icons.fastfood, color: Colors.grey.shade400, size: 24),
                          ),
                        )
                      : Container(
                          width: 56,
                          height: 56,
                          color: Colors.grey.shade200,
                          child: Icon(Icons.fastfood, color: Colors.grey.shade400, size: 24),
                        ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.description.isNotEmpty ? item.description : item.name,
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          FormattedPriceText(
                            amount: item.price,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primaryColor,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Icon(Icons.access_time, size: 11, color: Colors.grey.shade400),
                          const SizedBox(width: 3),
                          Text(
                            '${item.preparationTime} min',
                            style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward, size: 16, color: AppColors.primaryColor),
              ],
            ),
          ),
        );
        }).toList(),
        const SizedBox(height: 12),
        // Combo note banner
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF8E1),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFFFE082)),
          ),
          child: const Row(
            children: [
              Icon(Icons.info_outline, size: 18, color: Color(0xFFF9A825)),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Click on any item to view its details. Items are prepared together and served as a combo at the combo price above.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF8D6E63),
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _priceRow(String label, double amount, Color valueColor, bool strike) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
        ),
        FormattedPriceText(
          amount: amount,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: valueColor,
            decoration: strike ? TextDecoration.lineThrough : TextDecoration.none,
            decorationColor: Colors.grey.shade500,
          ),
        ),
      ],
    );
  }
}
