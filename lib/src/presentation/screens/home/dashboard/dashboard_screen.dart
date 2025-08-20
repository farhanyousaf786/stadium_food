import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stadium_food/src/bloc/menu/menu_bloc.dart';
import 'package:stadium_food/src/bloc/offer/offer_bloc.dart';
import 'package:stadium_food/src/data/repositories/offer_repository.dart';
import 'package:stadium_food/src/presentation/utils/app_colors.dart';
import 'package:stadium_food/src/presentation/widgets/search_filter_widget.dart';
import 'widgets/category_list.dart';
import 'widgets/menu_list.dart';
import 'widgets/offers_list.dart';
import 'widgets/top_bar.dart';
import 'widgets/shop_list.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final TextEditingController _searchController = TextEditingController();

  void _handleSearch(String value) {
    context.read<MenuBloc>().add(FilterMenuBySearch(query: value));
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (context) => OfferBloc(
              offerRepository: OfferRepository(),
            ),
        child: Scaffold(
          backgroundColor: AppColors.bgColor,
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const TopBar(),
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SearchFilterWidget(
                            searchController: _searchController,
                            onChanged: _handleSearch,
                            onFilterTap: () {},
                          ),
                          const SizedBox(height: 24),
                          OffersList(),
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
                ),
              ],
            ),
          ),
        ));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
