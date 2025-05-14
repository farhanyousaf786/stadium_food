import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../bloc/food/food_bloc.dart';
import '../../../data/models/food.dart';
import '../../../data/models/shop.dart';
import '../../../data/models/stadium.dart';
import '../../widgets/buttons/back_button.dart';
import '../../widgets/items/food_item.dart';
import '../../widgets/search_filter_widget.dart';
import '../../utils/custom_text_style.dart';
import '../../utils/app_colors.dart';

class FoodListScreen extends StatefulWidget {

  final Stadium stadium;
  final Shop shop;

  const FoodListScreen({super.key, required this.stadium, required this.shop});

  @override
  State<FoodListScreen> createState() => _FoodListScreenState();
}

class _FoodListScreenState extends State<FoodListScreen> {
  final ScrollController _scrollController = ScrollController();
  final List<Food> _foods = [];
  List<Food> _filteredFoods = [];
  final TextEditingController _searchController = TextEditingController();
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    context.read<FoodBloc>().add(LoadFoods(
      shopId: widget.shop.id,
      stadiumId: widget.stadium.id,
      limit: 20,
      lastDocument: null,
    ));

    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      // Load more foods if needed
      context.read<FoodBloc>().add(FetchMoreFoods(
        shopId: widget.shop.id,
        stadiumId: widget.stadium.id,
        limit: 10,
        lastDocument: null,
      ));
    }
  }

  Widget _buildCategoryChips() {
    final categories = _foods.map((food) => food.category).toSet().toList();
    categories.sort();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: const Text('All'),
              selected: _selectedCategory == null,
              onSelected: (selected) {
                if (selected) {
                  setState(() => _selectedCategory = null);
                }
              },
            ),
          ),
          ...categories.map((category) => Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(category),
              selected: category == _selectedCategory,
              onSelected: (selected) {
                setState(() {
                  _selectedCategory = selected ? category : null;
                });
              },
            ),
          )).toList(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
          });
        } else if (state is FoodMoreFetched) {
          setState(() {
            for (var food in state.foods) {
              if (!_foods.contains(food)) {
                _foods.add(food);
              }
            }
            _filteredFoods = _foods;
          });
        }
      },
      child: GestureDetector(
        onTap: () {
          // close keyboard
          FocusScope.of(context).unfocus();
        },
        child: Scaffold(
          body: Stack(
            children: [
              Align(
                alignment: Alignment.topRight,
                child: SvgPicture.asset(
                  "assets/svg/pattern-small.svg",
                ),
              ),
              SafeArea(
                child: Container(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const CustomBackButton(),
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
                      SearchFilterWidget(
                        searchController: _searchController,
                        onChanged: (value) {
                          setState(() {
                            _filteredFoods = _foods.where((food) =>
                                food.name.toLowerCase().contains(value.toLowerCase()) ||
                                food.description.toLowerCase().contains(value.toLowerCase())
                            ).toList();
                          });
                        },
                        onTap: () {},
                      ),
                      const SizedBox(height: 20),
                      _buildCategoryChips(),
                      const SizedBox(height: 16),
                      Expanded(
                        child: BlocBuilder<FoodBloc, FoodState>(
                          builder: (context, state) {
                            if (state is FoodFetching || state is FoodMoreFetching) {
                              return const Center(
                                child: CircularProgressIndicator(color: AppColors.primaryColor),
                              );
                            }
                            
                            final displayedFoods = _selectedCategory != null
                                ? _filteredFoods.where((food) => food.category == _selectedCategory).toList()
                                : _filteredFoods;

                            if (displayedFoods.isEmpty) {
                              return Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.fastfood_outlined, size: 64, color: Colors.grey[400]),
                                    const SizedBox(height: 16),
                                    Text(
                                      'No food items found',
                                      style: TextStyle(color: Colors.grey[600], fontSize: 16),
                                    ),
                                  ],
                                ),
                              );
                            }

                            return ListView.builder(
                              controller: _scrollController,
                              padding: EdgeInsets.zero,
                              itemCount: displayedFoods.length,
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 16),
                                  child: FoodItem(food: displayedFoods[index]),
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
              
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }
}
