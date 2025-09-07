import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stadium_food/src/bloc/menu/menu_bloc.dart';
import 'package:stadium_food/src/bloc/category/category_bloc.dart';
import 'package:stadium_food/src/data/models/category.dart';
import 'package:stadium_food/src/data/services/language_service.dart';
import 'package:stadium_food/src/core/translations/translate.dart';
import 'package:stadium_food/src/presentation/utils/app_colors.dart';

class CategoryList extends StatefulWidget {
  const CategoryList({super.key});

  @override
  State<CategoryList> createState() => _CategoryListState();
}

class _CategoryListState extends State<CategoryList> {
  int _selectedIndex = 0;


  @override
  void initState() {
    super.initState();
    // Initial filter with 'All' category
    _filterByCategory('All');
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
          child: Text(
            Translate.get('allCategories'),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.grayColor,
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 56,
          child: BlocBuilder<CategoryBloc, CategoryState>(
            builder: (context, state) {
              if (state is CategoryLoading || state is CategoryInitial) {
                return const Center(child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2)));
              }
              if (state is CategoryError) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(state.message, style: const TextStyle(color: Colors.red)),
                );
              }
              if (state is CategoryLoaded) {
                final String lang = LanguageService.getCurrentLanguage();
                // Build a combined list with an 'All' pseudo-category at the front
                final List<_DisplayCategory> display = [
                  _DisplayCategory(icon: '🔥', label: Translate.get('all'), filterValue: 'All'),
                  ...state.categories.map((FoodCategory c) => _DisplayCategory(
                        icon: c.icon,
                        label: c.localizedName(lang),
                        // Use category document id for filtering
                        filterValue: c.docId,
                      )),
                ];

                return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: display.length,
                  itemBuilder: (context, index) {
                    final item = display[index];
                    final isSelected = index == _selectedIndex;
                    return Container(
                      margin: const EdgeInsets.only(right: 12, bottom: 4),
                      child: Material(
                        color: isSelected ? AppColors.primaryColor : Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        elevation: 2,
                        child: InkWell(
                          onTap: () {
                            if (_selectedIndex != index) {
                              setState(() {
                                _selectedIndex = index;
                              });
                              _filterByCategory(item.filterValue);
                            }
                          },
                          borderRadius: BorderRadius.circular(15),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
                            child: Row(
                              children: [
                                Text(
                                  item.icon,
                                  style: const TextStyle(fontSize: 20),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  item.label,
                                  style: TextStyle(
                                    fontSize: 15,
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
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      ],
    );
  }
}

class _DisplayCategory {
  final String icon;
  final String label;
  final String filterValue; // 'All' or categoryId

  _DisplayCategory({required this.icon, required this.label, required this.filterValue});
}
