import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stadium_food/src/presentation/widgets/buttons/primary_button.dart';
import 'package:stadium_food/src/data/models/food.dart';
import 'package:stadium_food/src/data/repositories/food_repository.dart';
import 'package:stadium_food/src/presentation/widgets/food_card.dart';
import '../../../data/services/language_service.dart';
import '../../../services/location_service.dart';
import 'package:flutter_svg/svg.dart';
import 'package:stadium_food/src/bloc/order/order_bloc.dart';
import 'package:stadium_food/src/core/translations/translate.dart';
import 'package:stadium_food/src/data/repositories/order_repository.dart';
import 'package:stadium_food/src/data/repositories/shop_repository.dart';
import 'package:stadium_food/src/presentation/widgets/buttons/back_button.dart';
import 'package:stadium_food/src/presentation/widgets/items/cart_item.dart';
import 'package:stadium_food/src/presentation/widgets/price_info_widget.dart';
import 'package:stadium_food/src/presentation/widgets/dialogs/location_permission_dialog.dart';
import 'package:stadium_food/src/presentation/utils/app_colors.dart';
import 'package:stadium_food/src/presentation/utils/app_styles.dart';
import 'package:stadium_food/src/presentation/utils/custom_text_style.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../widgets/formatted_price_text.dart';
import 'package:stadium_food/src/data/services/currency_service.dart';

class CartScreen extends StatefulWidget {
  final bool isFromHome;

  const CartScreen({super.key, required this.isFromHome});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final LocationService _locationService = LocationService();

  Future<List<Food>> _fetchRelatedFoods() async {
    if (OrderRepository.cart.isEmpty) return [];

    final firstItem = OrderRepository.cart.first;
    final stadiumId = firstItem.stadiumId;
    final shopId = firstItem.shopIds.isNotEmpty ? firstItem.shopIds.first : '';
    if (stadiumId.isEmpty || shopId.isEmpty) return [];

    final foods = await FoodRepository().fetchFoods(stadiumId, shopId);
    // Exclude items already in cart and prioritize same category
    final cartIds = OrderRepository.cart.map((f) => f.id).toSet();
    final sameCategory = foods
        .where((f) => f.category == firstItem.category && !cartIds.contains(f.id))
        .toList();
    final others = foods
        .where((f) => f.category != firstItem.category && !cartIds.contains(f.id))
        .toList();
    return [
      ...sameCategory,
      ...others,
    ];
  }

  @override
  void initState() {
    super.initState();

    CurrencyService.refreshRates();
  }

  Future<String?> _loadNearbyData() async {
    try {
      final userId = await _locationService.getNearestDeliveryUser();
      return userId;
    } catch (e) {
      debugPrint('Error loading nearby data: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return _buildScreen(context);
  }

  Future<void> _findNearestShopAndNavigate(BuildContext context) async {
    await LocationService.checkLocationPermission();
    final position = await _locationService.getCurrentLocation();
    final nearestDeliveryUserId = await _loadNearbyData();
    final nearestShop = await ShopRepository().findNearestShop(
        OrderRepository.cart[0].stadiumId, OrderRepository.cart[0].shopIds);

    OrderRepository.selectedDeliveryUerId = nearestDeliveryUserId;
    OrderRepository.selectedShopId = nearestShop.id;
    OrderRepository.customerLocation =
        GeoPoint(position.latitude, position.longitude);
    if (context.mounted) {
      Navigator.pushNamed(context, "/tip");
    }
  }

  Future<void> _handleLocationError(BuildContext context, dynamic error) async {
    if (!context.mounted) return;

    if (error.toString().contains('location_service_disabled')) {
      _showErrorSnackBar(context, 'locationServiceDisabled');
      return;
    }

    if (error.toString().contains('location_permission_denied') ||
        error.toString().contains('location_permission_permanent')) {
      final shouldOpenSettings = await showDialog<bool>(
        context: context,
        builder: (context) => const LocationPermissionDialog(),
      );

      if (shouldOpenSettings == true && context.mounted) {
        await LocationService.openLocationSettings();
        await Future.delayed(const Duration(seconds: 1));
        if (context.mounted) {
          await _findNearestShopAndNavigate(context);
        }
      }
      return;
    }

    _showErrorSnackBar(context, 'locationError');
  }

  void _showErrorSnackBar(BuildContext context, String messageKey) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(Translate.get(messageKey)),
        backgroundColor: AppColors.errorColor,
      ),
    );
  }

  Widget _buildScreen(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      body: BlocBuilder<OrderBloc, OrderState>(
        builder: (context, state) {
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with background image and overlay
                Stack(
                  children: [
                    Container(
                      height: 300,
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage('assets/png/cart_bg.png'),
                          fit: BoxFit.fill,
                        ),
                      ),
                    ),
                    // dark gradient overlay for text readability

                    Positioned(
                      left: 16,
                      top: MediaQuery.of(context).padding.top + 16,
                      child: widget.isFromHome == false
                          ? const CustomBackButton(
                              color: Colors.white,
                            )
                          : const SizedBox.shrink(),
                    ),
                    Positioned.fill(
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: Padding(
                          padding: EdgeInsets.only(
                              top: MediaQuery.of(context).padding.top + 24),
                          child: Text(
                            Translate.get('addToCart'),
                            style: CustomTextStyle.size22Weight600Text(
                                Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                // Empty state
                if (OrderRepository.cart.isEmpty)
                  Container(
                    height: MediaQuery.of(context).size.height * 0.7,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          "assets/png/empty_img.png",

                          height: 100,
                          width: 100,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          Translate.get('cartEmpty'),
                          style: CustomTextStyle.size22Weight600Text(AppColors().secondaryTextColor),
                        ),
                      ],
                    ),
                  ),

                // Cart items list
                if (OrderRepository.cart.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: OrderRepository.cart.length,
                          itemBuilder: (context, index) {
                            return Column(
                              children: [
                                Dismissible(
                                  key: Key(OrderRepository.cart[index].id),
                                  onDismissed: (direction) {
                                    BlocProvider.of<OrderBloc>(context).add(
                                      RemoveCompletelyFromCart(
                                        OrderRepository.cart[index],
                                      ),
                                    );
                                  },
                                  background: Container(
                                    alignment: Alignment.centerRight,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                    ),
                                    decoration: BoxDecoration(
                                      borderRadius: AppStyles.largeBorderRadius,
                                      color: AppColors.secondaryColor,
                                    ),
                                    child: SvgPicture.asset(
                                      "assets/svg/trash.svg",
                                    ),
                                  ),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: AppStyles.largeBorderRadius,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.03),
                                          blurRadius: 8,
                                          offset: const Offset(0, 3),
                                        ),
                                      ],
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8.0, horizontal: 8),
                                      child: CartItem(
                                        food: OrderRepository.cart[index],
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                              ],
                            );
                          },
                        ),
                        SizedBox(
                          height: 16,
                        ),
                        OrderRepository.cart.isNotEmpty
                            ? PriceInfoWidget()
                            : SizedBox(),
                        SizedBox(
                          height: 30,
                        ),
                        // Related items section
                        // if (OrderRepository.cart.isNotEmpty) ...[
                        //   Align(
                        //     alignment: Alignment.centerLeft,
                        //     child: Padding(
                        //       padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        //       child: Text(
                        //         Translate.get('otherRelatedItems'),
                        //         style: CustomTextStyle.size16Weight600Text(AppColors().secondaryTextColor),
                        //       ),
                        //     ),
                        //   ),
                        //   const SizedBox(height: 12),
                        //   SizedBox(
                        //     height: 200,
                        //     child: FutureBuilder<List<Food>>(
                        //       future: _fetchRelatedFoods(),
                        //       builder: (context, snapshot) {
                        //         if (snapshot.connectionState == ConnectionState.waiting) {
                        //           return const Center(child: CircularProgressIndicator());
                        //         }
                        //         if (snapshot.hasError) {
                        //           return Padding(
                        //             padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        //             child: Text(
                        //               Translate.get('noFoodFound'),
                        //               style: CustomTextStyle.size14Weight400Text(AppColors().secondaryTextColor),
                        //             ),
                        //           );
                        //         }
                        //         final items = snapshot.data ?? [];
                        //         if (items.isEmpty) {
                        //           return Padding(
                        //             padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        //             child: Text(
                        //               Translate.get('noFoodFound'),
                        //               style: CustomTextStyle.size14Weight400Text(AppColors().secondaryTextColor),
                        //             ),
                        //           );
                        //         }
                        //
                        //        return ListView.builder(
                        //           scrollDirection: Axis.horizontal,
                        //           padding: const EdgeInsets.symmetric(horizontal: 16),
                        //           itemCount: items.length.clamp(0, 10),
                        //           itemBuilder: (context, index) {
                        //             final food = items[index];
                        //             final lang = LanguageService.getCurrentLanguage();
                        //             final localizedName = food.nameFor(lang);
                        //
                        //             return Container(
                        //                 width: 180,
                        //                 margin: const EdgeInsets.only(right: 16),
                        //                 decoration: BoxDecoration(
                        //                   color: Colors.white,
                        //                   borderRadius: BorderRadius.circular(8),
                        //                   boxShadow: [
                        //                     BoxShadow(
                        //                       color: Colors.black.withOpacity(0.05),
                        //                       blurRadius: 10,
                        //                       offset: const Offset(0, 5),
                        //                     ),
                        //                   ],
                        //                 ),
                        //                 child: InkWell(
                        //                   onTap: () {
                        //                     Navigator.pushNamed(
                        //                       context,
                        //                       '/foods/detail',
                        //                       arguments: food,
                        //                     );
                        //                   },
                        //                   borderRadius: BorderRadius.circular(8),
                        //                   child: Column(
                        //                     crossAxisAlignment: CrossAxisAlignment.start,
                        //                     children: [
                        //                       // Food Image
                        //                       ClipRRect(
                        //                         borderRadius: const BorderRadius.vertical(
                        //                           top: Radius.circular(8),
                        //                           bottom: Radius.circular(8),
                        //                         ),
                        //                         child: Image.network(
                        //                           food.images.first,
                        //                           height: 120,
                        //                           width: double.infinity,
                        //                           fit: BoxFit.cover,
                        //                         ),
                        //                       ),
                        //                       Padding(
                        //                         padding: const EdgeInsets.all(12),
                        //                         child: Column(
                        //                           crossAxisAlignment: CrossAxisAlignment.start,
                        //                           children: [
                        //                             Text(
                        //                               localizedName,
                        //                               style: const TextStyle(
                        //                                 fontSize: 16,
                        //                                 fontWeight: FontWeight.w600,
                        //                               ),
                        //                               maxLines: 1,
                        //                               overflow: TextOverflow.ellipsis,
                        //                             ),
                        //
                        //                             const SizedBox(height: 4),
                        //                             FormattedPriceText(
                        //                               amount: food.price,
                        //                               style: TextStyle(
                        //                                 fontSize: 16,
                        //                                 fontWeight: FontWeight.w600,
                        //                                 color: AppColors.primaryColor,
                        //                               ),
                        //                             ),
                        //                           ],
                        //                         ),
                        //                       ),
                        //                     ],
                        //                   ),
                        //                 ));
                        //           },
                        //         );
                        //
                        //       },
                        //     ),
                        //   ),
                        //
                        //   const SizedBox(height: 24),
                        // ],
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 30),
                          child: Ink(
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.all(Radius.circular(10)),
                            ),
                            child: InkWell(
                              borderRadius: const BorderRadius.all(Radius.circular(10)),
                              onTap: () {

                              },
                              child: Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.all(Radius.circular(10))),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 60,
                                  vertical: 20,
                                ),
                                child: Text(
                                  Translate.get('continueShopping'),
                                  textAlign: TextAlign.center,
                                  style: CustomTextStyle.size16Weight600Text(
                                    AppColors().textColor,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 20,),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 30),
                          child: OrderRepository.cart.isNotEmpty
                              ? PrimaryButton(
                              text: Translate.get('goToCheckout'),
                              onTap: () async {
                                if (OrderRepository.cart.isEmpty) {
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(
                                    SnackBar(
                                      content: Text(
                                          Translate.get('cartEmpty')),
                                      backgroundColor:
                                      AppColors.errorColor,
                                    ),
                                  );
                                  return;
                                }

                                // Find nearest shop before proceeding
                                try {
                                  await _findNearestShopAndNavigate(
                                      context);
                                } catch (e) {
                                  await _handleLocationError(context, e);
                                }
                              })
                              : SizedBox(),
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

}
