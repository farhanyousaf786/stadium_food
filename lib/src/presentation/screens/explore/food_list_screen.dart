import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stadium_food/src/core/translations/translate.dart';
import 'package:stadium_food/src/presentation/widgets/shimmer_widgets.dart';
import '../../../bloc/food/food_bloc.dart';
import '../../../data/models/food.dart';
import '../../../data/models/shop.dart';
import '../../../data/models/stadium.dart';
import '../../../data/services/language_service.dart';
import '../../../data/models/category.dart';
import '../../../data/repositories/category_repository.dart';
import '../../widgets/buttons/back_button.dart';
import '../../utils/custom_text_style.dart';
import '../../utils/app_colors.dart';
import '../../widgets/formatted_price_text.dart';

class FoodListScreen extends StatefulWidget {
  final Stadium stadium;
  final Shop shop;

  const FoodListScreen({super.key, required this.stadium, required this.shop});

  @override
  State<FoodListScreen> createState() => _FoodListScreenState();
}

class _FoodListScreenState extends State<FoodListScreen> {
  final List<Food> _foods = [];
  List<Food> _filteredFoods = [];
  final TextEditingController _searchController = TextEditingController();
  // Holds category ids (from Food.category). We display localized labels for these.
  List<String> _categories = ['All'];
  // Map of category id -> localized label
  final Map<String, String> _categoryLabels = {};
  String _selectedCategory = 'All';

  // Food type filter
  final List<String> _foodTypes = ['halal', 'kosher', 'vegan'];
  final Map<String, bool> _selectedFilters = {
    'halal': false,
    'kosher': false,
    'vegan': false,
  };

  final CategoryRepository _categoryRepository = CategoryRepository();

  @override
  void initState() {
    super.initState();
    context.read<FoodBloc>().add(LoadFoods(
          shopId: widget.shop.id,
          stadiumId: widget.stadium.id,
        ));
    _loadCategoryLabels();
  }

  void _filterFoods(String query) {
    setState(() {
      // First filter by category if not 'All'
      var categoryFiltered = _foods;
      if (_selectedCategory != 'All') {
        categoryFiltered = _foods
            .where((food) =>
                food.category.toLowerCase() == _selectedCategory.toLowerCase())
            .toList();
      }

      // Then filter by search query
      var queryFiltered = categoryFiltered.where((food) =>
          food.name.toLowerCase().contains(query.toLowerCase()) ||
          food.description.toLowerCase().contains(query.toLowerCase()));

      // Then apply food type filters if any are selected
      bool hasSelectedFilters =
          _selectedFilters.values.any((isSelected) => isSelected);
      if (hasSelectedFilters) {
        queryFiltered = queryFiltered.where((food) {
          // Check if any selected filter matches the food's type
          for (var type in _selectedFilters.keys) {
            if (_selectedFilters[type]! && !food.foodType[type]!) {
              return false;
            }
          }
          return true;
        });
      }

      _filteredFoods = queryFiltered.toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final lang = LanguageService.getCurrentLanguage();
    return BlocListener<FoodBloc, FoodState>(
      listener: (context, state) {
        if (state is FoodError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
        if (state is FoodFetched) {
          setState(() {
            _foods.clear();
            _foods.addAll(state.foods);
            _filteredFoods = _foods;
            _updateCategories(_foods);
          });
          // Refresh category labels when foods update (handles language change too)
          _loadCategoryLabels();
        }
      },
      child: GestureDetector(
        onTap: () {
          // close keyboard
          FocusScope.of(context).unfocus();
        },
        child: Scaffold(
          backgroundColor: AppColors.bgColor,
          body: SafeArea(
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CustomBackButton(color: AppColors.primaryDarkColor,),
                  const SizedBox(height: 20),
                  Text(
                    widget.shop.name,
                    style: CustomTextStyle.size25Weight600Text(),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Gate ${widget.shop.gate} - ${widget.shop.location}',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 20),
                  // Filter chips for food types
                  SizedBox(
                    height: 50,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _foodTypes.length,
                      itemBuilder: (context, index) {
                        final type = _foodTypes[index];
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: FilterChip(
                            selected: _selectedFilters[type] ?? false,
                            label: Text(Translate.get(type).toUpperCase()),
                            onSelected: (bool selected) {
                              setState(() {
                                _selectedFilters[type] = selected;
                                _filterFoods(_searchController.text);
                              });
                            },
                            selectedColor:
                                AppColors.primaryColor.withOpacity(0.2),
                            checkmarkColor: AppColors.primaryColor,
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: _filterFoods,
                      decoration: InputDecoration(
                        hintText: Translate.get('searchFood'),
                        prefixIcon: const Icon(Icons.search,
                            color: AppColors.primaryColor),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 50,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _categories.length,
                      itemBuilder: (context, index) {
                        final category = _categories[index];
                        final isSelected = category == _selectedCategory;
                        return Padding(
                          padding: EdgeInsets.only(
                              right: 8.0, left: index == 0 ? 8.0 : 0),
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedCategory = category;
                                _filterFoods(_searchController.text);
                              });
                            },
                            child: IntrinsicWidth(
                              child: Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8.0),
                                    child: Text(
                                      category == 'All'
                                          ? Translate.get('all')
                                          : (_categoryLabels[category] ?? category),
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey[600],
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Container(
                                    height: 3,
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? AppColors.primaryColor
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),

                  Expanded(
                    child: BlocBuilder<FoodBloc, FoodState>(
                      builder: (context, state) {
                        if (state is FoodFetching) {
                          return const Center(
                            child: FoodListShimmer(),
                          );
                        }

                        if (_filteredFoods.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.fastfood_outlined,
                                    size: 64, color: Colors.grey[400]),
                                const SizedBox(height: 16),
                                Text(
                                  Translate.get('noFoodItemsFound'),
                                  style: TextStyle(
                                      color: Colors.grey[600], fontSize: 16),
                                ),
                              ],
                            ),
                          );
                        }

                        return ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          itemCount: _filteredFoods.length,
                          itemBuilder: (context, index) {
                            final food = _filteredFoods[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: InkWell(
                                onTap: () {
                                  Navigator.pushNamed(
                                    context,
                                    '/foods/detail',
                                    arguments: food,
                                  );
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(15),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.05),
                                        blurRadius: 10,
                                        offset: const Offset(0, 5),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    children: [
                                      ClipRRect(
                                        borderRadius: const BorderRadius.only(
                                          topLeft: Radius.circular(15),
                                          bottomLeft: Radius.circular(15),
                                        ),
                                        child: food.images.isNotEmpty
                                            ? Image.network(
                                                food.images[0],
                                                width: 120,
                                                height: 120,
                                                fit: BoxFit.cover,
                                              )
                                            : Container(
                                                width: 120,
                                                height: 120,
                                                color: Colors.grey[200],
                                                child: Icon(Icons.fastfood,
                                                    color: Colors.grey[400],
                                                    size: 40),
                                              ),
                                      ),
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.all(12),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                              food.nameFor(lang),
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                food.descriptionFor(lang),
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.grey[600],
                                                ),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(height: 8),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  FormattedPriceText(
                                                    amount: food.price,
                                                    style: TextStyle(
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: AppColors
                                                          .primaryColor,
                                                    ),
                                                  ),
                                                  Container(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                      horizontal: 8,
                                                      vertical: 4,
                                                    ),
                                                    decoration: BoxDecoration(
                                                      color: AppColors
                                                          .primaryColor
                                                          .withOpacity(0.1),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              12),
                                                    ),
                                                    child: Row(
                                                      children: [
                                                        Icon(
                                                          Icons
                                                              .watch_later_rounded,
                                                          color: AppColors
                                                              .primaryColor,
                                                        ),
                                                        Text(
                                                          '${food.preparationTime} ${Translate.get('preparationTime')}',
                                                          style: TextStyle(
                                                            fontSize: 13,
                                                            color: AppColors
                                                                .primaryColor,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
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
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _updateCategories(List<Food> foods) {
    final String lang = LanguageService.getCurrentLanguage();
    // Unique category ids
    final List<String> categories = foods
        .map((food) => food.category)
        .where((id) => id.trim().isNotEmpty)
        .toSet()
        .toList()
      ..sort();

    // Build id -> localized label map using the first food that matches each id
    final Map<String, String> labels = {};
    for (final id in categories) {
      final Food sample = foods.firstWhere((f) => f.category == id, orElse: () => foods.first);
      final String localized = sample.categoryFor(lang).isNotEmpty
          ? sample.categoryFor(lang)
          : id; // fallback to id if no localized value
      labels[id] = localized;
    }

    setState(() {
      _categoryLabels
        ..clear()
        ..addAll(labels);
      _categories = ['All', ...categories];
    });
  }

  Future<void> _loadCategoryLabels() async {
    try {
      final String lang = LanguageService.getCurrentLanguage();
      final List<FoodCategory> categories = await _categoryRepository
          .fetchCategoriesScoped(stadiumId: widget.stadium.id, shopId: widget.shop.id);
      if (!mounted) return;
      setState(() {
        _categoryLabels.addAll({for (final c in categories) c.docId: c.localizedName(lang)});
      });
    } catch (_) {
      // Silently ignore; fallback to showing IDs
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
