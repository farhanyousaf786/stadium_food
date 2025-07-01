import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stadium_food/src/bloc/menu/menu_bloc.dart';
import 'package:stadium_food/src/bloc/shop/shop_bloc.dart';
import 'package:stadium_food/src/presentation/utils/app_colors.dart';
import 'package:stadium_food/src/presentation/widgets/search_filter_widget.dart';
import 'widgets/category_list.dart';
import 'widgets/menu_list.dart';
import 'widgets/shop_list.dart';
import 'widgets/top_bar.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => MenuBloc()),
        BlocProvider(create: (context) => ShopBloc()),
      ],
      child: Scaffold(
        backgroundColor: AppColors.bgColor,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const TopBar(),
              SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SearchFilterWidget(
                        searchController: _searchController,
                        onChanged: (value) {},
                        onTap: () {},
                      ),
                      const SizedBox(height: 24),
                      const CategoryList(),
                      const SizedBox(height: 24),
                      const MenuList(),
                      const SizedBox(height: 24),
                      const ShopList(),
                    ],
                  ),
                    ),
                    const SizedBox(height: 24),
                    const CategoryList(),
                    const SizedBox(height: 24),
                    const MenuList(),
                    const SizedBox(height: 24),
                    const ShopList(),
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
    _searchController.dispose();
    super.dispose();
  }
}
