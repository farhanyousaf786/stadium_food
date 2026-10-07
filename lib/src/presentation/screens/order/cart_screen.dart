import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stadium_food/src/presentation/widgets/buttons/primary_button.dart';
import 'package:stadium_food/src/data/models/food.dart';
import 'package:stadium_food/src/data/repositories/food_repository.dart';
import 'package:stadium_food/src/presentation/widgets/food_card.dart';
import '../../../data/services/language_service.dart';
import '../../../data/services/guest_auth_service.dart';
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

import '../../widgets/loading_indicator.dart';
import '../../widgets/dialogs/auth_required_dialog.dart';

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

    CurrencyService.initializeRates();
  }

  Future<bool> _checkShopAvailability() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final stadiumId = prefs.getString('selected_stadium_id') ?? '';
      Query query = FirebaseFirestore.instance
          .collection('shops')
          .where('shopAvailability', isEqualTo: true);
      if (stadiumId.isNotEmpty) {
        query = query.where('stadiumId', isEqualTo: stadiumId);
      }
      var snap = await query.get();
      if (snap.docs.isEmpty && stadiumId.isNotEmpty) {
        snap = await FirebaseFirestore.instance
            .collection('shops')
            .where('shopAvailability', isEqualTo: true)
            .get();
      }
      if (snap.docs.isEmpty) {
        if (!mounted) return false;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(Translate.get('noShopAvailable')),
            backgroundColor: AppColors.errorColor,
          ),
        );
        return false;
      }
      return true;
    } catch (_) {
      if (!mounted) return false;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to check shop availability. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }
  }

  Future<void> _proceedToCheckout() async {
    if (OrderRepository.cart.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(Translate.get('cartEmpty')),
          backgroundColor: AppColors.errorColor,
        ),
      );
      return;
    }
    if (!GuestAuthService.isLoggedIn) {
      await AuthRequiredDialog.show(
        context,
        onSignIn: () {
          Navigator.pushNamed(context, '/login', arguments: '/tip');
        },
        onRegister: () {
          Navigator.pushNamed(context, '/register');
        },
        onContinueAsGuest: () => _continueAsGuestAndCheckout(),
      );
      return;
    }
    final open = await _checkShopAvailability();
    if (!open || !mounted) return;
    Navigator.pushNamed(context, '/tip');
  }

  Future<void> _continueAsGuestAndCheckout() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const LoadingIndicator(),
    );
    try {
      await GuestAuthService.ensureGuestUser();
      if (!mounted) return;
      Navigator.pop(context); // loading
      final prefs = await SharedPreferences.getInstance();
      final hasStadium = prefs.getString('selected_stadium_id') != null;
      if (!hasStadium) {
        if (!mounted) return;
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/select-stadium',
          (route) => false,
        );
        return;
      }
      final open = await _checkShopAvailability();
      if (!open || !mounted) return;
      Navigator.pushNamed(context, '/tip');
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context); // loading
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Guest login failed: $e'),
          backgroundColor: AppColors.errorColor,
        ),
      );
    }
  }

  Future<void> _confirmClearCart() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear cart?'),
        content: const Text('Remove all items from your cart?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    OrderRepository().clearCart();
    context.read<OrderBloc>().add(UpdateUI());
    setState(() {});
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
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) =>
      const LoadingIndicator(),
    );
    await LocationService.checkLocationPermission();
    final position = await _locationService.getCurrentLocation();
    // final nearestDeliveryUserId = await _loadNearbyData();
    final nearestShop = await ShopRepository().findNearestShop(
        OrderRepository.cart[0].stadiumId, OrderRepository.cart[0].shopIds);

    // If no nearest shop found or the id is empty, show an error and do not navigate
    if (nearestShop == null || (nearestShop.id).toString().isEmpty) {
      if (context.mounted) {
        Navigator.of(context).pop();
        _showErrorSnackBar(context, 'noShopAvailable');
      }
      return;
    }

    OrderRepository.selectedDeliveryUerId = '';
    OrderRepository.selectedShopId = nearestShop.id;
    OrderRepository.customerLocation =
        GeoPoint(position.latitude, position.longitude);

    if (context.mounted) {
      Navigator.of(context).pop();
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
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppColors.primaryLightColor,
                            AppColors.primaryColor,
                            AppColors.primaryDarkColor,
                          ],
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
                    if (OrderRepository.cart.isNotEmpty)
                      Positioned(
                        right: 12,
                        top: MediaQuery.of(context).padding.top + 16,
                        child: TextButton(
                          onPressed: _confirmClearCart,
                          child: const Text(
                            'Clear',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),

                // Empty state — themed card + CTA
                if (OrderRepository.cart.isEmpty)
                  Builder(
                    builder: (context) {
                      final primary = AppColors.primaryColor;
                      final dark = AppColors.primaryDarkColor;
                      return Padding(
                        padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
                        child: Container(
                          width: double.infinity,
                          constraints: BoxConstraints(
                            minHeight:
                                MediaQuery.of(context).size.height * 0.5,
                          ),
                          padding: const EdgeInsets.fromLTRB(24, 40, 24, 32),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                primary.withOpacity(0.08),
                                primary.withOpacity(0.02),
                                Colors.white,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: primary.withOpacity(0.12),
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 104,
                                height: 104,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      primary.withOpacity(0.14),
                                      dark.withOpacity(0.28),
                                    ],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: primary.withOpacity(0.18),
                                      blurRadius: 20,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  Icons.shopping_bag_outlined,
                                  size: 46,
                                  color: primary,
                                ),
                              ),
                              const SizedBox(height: 24),
                              Text(
                                'Your cart is empty',
                                textAlign: TextAlign.center,
                                style: CustomTextStyle.size22Weight600Text(
                                  Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'Browse the menu and add something tasty to get started.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14,
                                  height: 1.45,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 28),
                              SizedBox(
                                width: double.infinity,
                                height: 52,
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    Navigator.pushNamedAndRemoveUntil(
                                      context,
                                      '/home',
                                      (route) => false,
                                    );
                                  },
                                  icon: const Icon(Icons.restaurant_menu),
                                  label: Text(
                                    Translate.get('continueShopping'),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 16,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: primary,
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
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
                        //                               style: TextStyle(
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
                          child:  PrimaryButton(

                              text: Translate.get('continueShopping'),
                              onTap: ()  {
                                Navigator.pushNamedAndRemoveUntil(
                                  context,
                                  "/home",
                                      (route) => false,
                                );
                              })

                        ),
                        SizedBox(height: 20,),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 30),
                          child: OrderRepository.cart.isNotEmpty
                              ? PrimaryButton(
                            bgColor: Colors.white,
                              textColor: AppColors().textColor,
                              text: Translate.get('goToCheckout'),
                              onTap: _proceedToCheckout)
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
