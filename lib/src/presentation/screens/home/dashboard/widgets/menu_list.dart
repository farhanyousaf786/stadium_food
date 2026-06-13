import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stadium_food/src/bloc/menu/menu_bloc.dart';
import 'package:stadium_food/src/core/translations/translate.dart';
import 'package:stadium_food/src/data/services/language_service.dart';
import 'package:stadium_food/src/data/models/food.dart';
import 'package:stadium_food/src/presentation/utils/app_colors.dart';

import 'package:stadium_food/src/presentation/widgets/shimmer_widgets.dart';
import 'package:stadium_food/src/presentation/widgets/formatted_price_text.dart';

class MenuList extends StatefulWidget {
  const MenuList({super.key});

  @override
  State<MenuList> createState() => _MenuListState();
}

class _MenuListState extends State<MenuList> {
  List<Food> _menuItems = [];
  final Map<String, bool> _shopAvailability = {};
  final Map<String, String> _shopNames = {};

  @override
  void initState() {
    super.initState();
    _loadStadiumIdAndFetchMenu();
    _loadShopsForAvailability();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadStadiumIdAndFetchMenu();
  }

  Future<void> _loadStadiumIdAndFetchMenu() async {
    final prefs = await SharedPreferences.getInstance();
    final stadiumId = prefs.getString('selected_stadium_id');
    if (stadiumId != null && mounted) {
      context.read<MenuBloc>().add(LoadStadiumMenu(
            stadiumId: stadiumId,
          ));
    }
  }

  Future<void> _loadShopsForAvailability() async {
    final prefs = await SharedPreferences.getInstance();
    final stadiumId = prefs.getString('selected_stadium_id');
    if (stadiumId == null) return;

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('shops')
          .where('stadiumId', isEqualTo: stadiumId)
          .get();

      for (final doc in snapshot.docs) {
        final data = doc.data();
        _shopAvailability[doc.id] = data['shopAvailability'] != false;
        _shopNames[doc.id] = data['name'] ?? Translate.get('shop');
      }
      if (mounted) setState(() {});
    } catch (_) {}
  }

  bool _isFoodAvailable(Food food) {
    if (food.shopIds.isEmpty) return true;
    return food.shopIds.any((id) => _shopAvailability[id] == true);
  }

  String _getShopName(Food food) {
    if (food.shopIds.isEmpty) return '';
    return _shopNames[food.shopIds.first] ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  Translate.get('popularMenu'),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.grayColor,
                  ),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pushNamed(context, '/menu'),
                child: Text(
                  Translate.get('seeAll'),
                  style: TextStyle(
                    color: AppColors.primaryColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        BlocBuilder<MenuBloc, MenuState>(
          builder: (context, state) {
            if (state is MenuLoading) {
              return const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: MenuShimmer(),
              );
            }

            if (state is MenuError) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  children: [
                    Icon(Icons.error_outline, size: 48, color: Colors.grey.shade400),
                    const SizedBox(height: 12),
                    Text(
                      state.message,
                      style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            }

            if (state is MenuLoaded) {
              _menuItems = state.foods;

              if (_menuItems.isEmpty) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.restaurant_outlined, size: 48, color: Colors.grey.shade400),
                      const SizedBox(height: 12),
                      Text(
                        Translate.get('noMenuItems'),
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              }

              return LayoutBuilder(
                builder: (context, constraints) {
                  final double width = constraints.maxWidth;
                  final int crossAxisCount = width >= 1000
                      ? 4
                      : width >= 700
                          ? 3
                          : 2;

                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      childAspectRatio: 0.82,
                    ),
                    itemCount: _menuItems.length,
                    itemBuilder: (context, index) {
                      final food = _menuItems[index];
                      final lang = LanguageService.getCurrentLanguage();
                      final localizedName = food.nameFor(lang);
                      final available = _isFoodAvailable(food);
                      final shopName = _getShopName(food);

                      return Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: InkWell(
                            onTap: () {
                              if (!available) {
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: Text('Closed'),
                                    content: Text('This item is currently unavailable.'),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: Text('OK'),
                                      ),
                                    ],
                                  ),
                                );
                                return;
                              }
                              Navigator.pushNamed(
                                context,
                                '/foods/detail',
                                arguments: food,
                              );
                            },
                            borderRadius: BorderRadius.circular(10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
                                    child: Stack(
                                      fit: StackFit.expand,
                                      children: [
                                        (food.isCombo && food.images.length >= 2)
                                            ? Row(
                                                children: [
                                                  Expanded(
                                                    child: Image.network(
                                                      food.images[0],
                                                      fit: BoxFit.cover,
                                                      errorBuilder: (context, error, stackTrace) =>
                                                          _SmallPlaceholder(),
                                                    ),
                                                  ),
                                                  Container(width: 2, color: AppColors.primaryColor),
                                                  Expanded(
                                                    child: Image.network(
                                                      food.images[1],
                                                      fit: BoxFit.cover,
                                                      errorBuilder: (context, error, stackTrace) =>
                                                          _SmallPlaceholder(),
                                                    ),
                                                  ),
                                                ],
                                              )
                                            : food.images.isNotEmpty
                                                ? Image.network(
                                                    food.images.first,
                                                    fit: BoxFit.cover,
                                                    errorBuilder: (context, error, stackTrace) =>
                                                        _SmallPlaceholder(),
                                                  )
                                                : const _SmallPlaceholder(),
                                        if (food.isCombo)
                                          Positioned(
                                            top: 8,
                                            right: 8,
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFFD39A75),
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: const Text(
                                                'COMBO',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 9,
                                                  fontWeight: FontWeight.w800,
                                                ),
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(9, 7, 9, 7),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              localizedName,
                                              style: const TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w700,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          if (!available)
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFFFFF0F0),
                                                borderRadius: BorderRadius.circular(4),
                                                border: Border.all(color: const Color(0xFFE8B6B6)),
                                              ),
                                              child: Text(
                                                Translate.get('closed'),
                                                style: const TextStyle(
                                                  color: Color(0xFFD98A8A),
                                                  fontSize: 8,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                      const SizedBox(height: 3),
                                      FormattedPriceText(
                                        amount: food.price,
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.primaryColor,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Row(
                                        children: [
                                          Icon(Icons.access_time, size: 11, color: Colors.grey.shade400),
                                          const SizedBox(width: 3),
                                          Text(
                                            '${food.preparationTime} min',
                                            style: TextStyle(fontSize: 9, color: Colors.grey.shade500),
                                          ),
                                          const Spacer(),
                                          if (shopName.isNotEmpty)
                                            Text(
                                              shopName,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(fontSize: 9, color: Colors.grey.shade400),
                                            ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ));
                    },
                  );
                },
              );
            }

            if (state is MenuError) {
              return Center(child: Text(state.message));
            }

            return const SizedBox();
          },
        ),
      ],
    );
  }
}

class _SmallPlaceholder extends StatelessWidget {
  const _SmallPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey.shade100,
      child: Center(
        child: Icon(
          Icons.fastfood,
          size: 28,
          color: Colors.grey.shade300,
        ),
      ),
    );
  }
}
