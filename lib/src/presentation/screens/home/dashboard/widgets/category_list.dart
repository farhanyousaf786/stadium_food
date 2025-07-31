import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stadium_food/src/bloc/menu/menu_bloc.dart';
import 'package:stadium_food/src/core/translations/translate.dart';
import 'package:stadium_food/src/presentation/utils/app_colors.dart';

class CategoryList extends StatefulWidget {
  const CategoryList({super.key});

  @override
  State<CategoryList> createState() => _CategoryListState();
}

class _CategoryListState extends State<CategoryList> {
  int _selectedIndex = 0;

  final List<Map<String, dynamic>> categories = [
    {'name': 'all', 'icon': '🔥'},
    {'name': 'snacksStreetFood', 'icon': '🥨'},
    {'name': 'saladsSoups', 'icon': '🥗'},
    {'name': 'pizzaPastaBurgers', 'icon': '🍕'},
    {'name': 'grillBbq', 'icon': '🍖'},
    {'name': 'seafood', 'icon': '🦐'},
    {'name': 'vegetarianVegan', 'icon': '🥬'},
    {'name': 'dessertsSweets', 'icon': '🍰'},
    {'name': 'drinksBeverages', 'icon': '🥤'},
    {'name': 'kidsMenu', 'icon': '🧸'},
    {'name': 'combosDeals', 'icon': '🎯'},
    {'name': 'traditionalLocal', 'icon': '🏆'},
    {'name': 'trendingChef', 'icon': '⭐'},
    {'name': 'appetizers', 'icon': '🍱'},
  ];

  @override
  void initState() {
    super.initState();
    // Initial filter with 'All' category
    _filterByCategory('all');
  }

  void _filterByCategory(String category) {
    if (!mounted) return;
    context.read<MenuBloc>().add(FilterMenuByCategory(category: category));
  }
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                Translate.get('allCategories'),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.grayColor,
                ),
              ),
              TextButton(
                onPressed: () {},
                child: Row(
                  children: [
                    Text(
                      Translate.get('seeAll'),
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.primaryColor,
                      ),
                    ),
                    Icon(
                      Icons.chevron_right,
                      size: 20,
                      color: AppColors.primaryColor,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 56,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              final isSelected = index == _selectedIndex;

              return Container(
                margin: const EdgeInsets.only(right: 12, bottom: 4),
                child: Material(
                  color: isSelected ? AppColors.primaryColor : Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  elevation: 2,
                  child: InkWell(
                    onTap: () {
                      if (_selectedIndex != index) {
                        setState(() {
                          _selectedIndex = index;
                        });
                        _filterByCategory(category['name'] as String);
                      }
                    },
                    borderRadius: BorderRadius.circular(25),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Row(
                        children: [
                          Text(
                            category['icon'] as String,
                            style: const TextStyle(fontSize: 24),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            Translate.get(category['name'] as String),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: isSelected ? Colors.white : Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
