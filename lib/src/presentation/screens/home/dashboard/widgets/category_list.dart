import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stadium_food/src/bloc/menu/menu_bloc.dart';
import 'package:stadium_food/src/presentation/utils/app_colors.dart';

class CategoryList extends StatefulWidget {
  const CategoryList({super.key});

  @override
  State<CategoryList> createState() => _CategoryListState();
}

class _CategoryListState extends State<CategoryList> {
  int _selectedIndex = 0;

  final List<Map<String, dynamic>> categories = [
    {'name': 'All', 'icon': '🔥'},
    {'name': 'Snacks & Street Food', 'icon': '🥨'},
    {'name': 'Salads & Soups', 'icon': '🥗'},
    {'name': 'Pizza, Pasta & Burgers', 'icon': '🍕'},
    {'name': 'Grill & BBQ', 'icon': '🍖'},
    {'name': 'Seafood', 'icon': '🦐'},
    {'name': 'Vegetarian / Vegan', 'icon': '🥬'},
    {'name': 'Desserts & Sweets', 'icon': '🍰'},
    {'name': 'Drinks & Beverages', 'icon': '🥤'},
    {'name': 'Kids Menu', 'icon': '🧸'},
    {'name': 'Combos & Deals', 'icon': '🎯'},
    {'name': 'Traditional / Local Specials', 'icon': '🏆'},
    {'name': 'Trending / Chef\'s Specials', 'icon': '⭐'},
    {'name': 'Appetizers', 'icon': '🍱'},
  ];

  @override
  void initState() {
    super.initState();
    // Initial filter with 'All' category
    _filterByCategory('All');
  }

  Future<void> _filterByCategory(String category) async {
    if (!mounted) return;
    
    final prefs = await SharedPreferences.getInstance();
    final stadiumId = prefs.getString('selected_stadium_id');
    
    if (stadiumId != null && mounted) {
      context.read<MenuBloc>().add(FilterMenuByCategory(
        category: category,
        stadiumId: stadiumId,
      ));
    }
  }
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'All Categories',
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
                      'See All',
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
                            category['name'] as String,
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
