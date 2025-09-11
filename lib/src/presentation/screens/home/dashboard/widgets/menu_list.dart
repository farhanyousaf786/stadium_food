import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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

  @override
  void initState() {
    super.initState();
    _loadStadiumIdAndFetchMenu();
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

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            Translate.get('popularMenu'),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.grayColor,
            ),
          ),
        ),
        const SizedBox(height: 16),
        BlocBuilder<MenuBloc, MenuState>(
            builder: (context, state) {
              if (state is MenuLoading) {
                return const MenuShimmer();
              }

              if (state is MenuLoaded) {
                _menuItems = state.foods;

                if (_menuItems.isEmpty) {
                  return Center(
                    child: Text(Translate.get('noMenuItems')),
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
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 0.9,
                      ),
                      itemCount: _menuItems.length,
                      itemBuilder: (context, index) {
                        final food = _menuItems[index];
                        final lang = LanguageService.getCurrentLanguage();
                        final localizedName = food.nameFor(lang);

                        return Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
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
                                Navigator.pushNamed(
                                  context,
                                  '/foods/detail',
                                  arguments: food,
                                );
                              },
                              borderRadius: BorderRadius.circular(8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  // Food Image
                                  Expanded(
                                    child: ClipRRect(
                                      borderRadius: const BorderRadius.vertical(
                                        top: Radius.circular(8),
                                      ),
                                      child: Image.network(
                                        food.images.first,
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 10,),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        localizedName,
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),

                                      const SizedBox(height: 4),
                                      FormattedPriceText(
                                        amount: food.price,
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.primaryColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 10,),
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
