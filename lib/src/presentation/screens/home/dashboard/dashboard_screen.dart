import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stadium_food/src/bloc/menu/menu_bloc.dart';
import 'package:stadium_food/src/bloc/category/category_bloc.dart';
import 'package:stadium_food/src/bloc/theme/theme_bloc.dart';
import 'package:stadium_food/src/core/config/stadium_sync.dart';
import 'package:stadium_food/src/core/config/stadium_theme.dart';
import 'package:stadium_food/src/core/translations/translate.dart';
import 'package:stadium_food/src/presentation/utils/app_colors.dart';
import 'widgets/category_list.dart';
import 'widgets/menu_list.dart';
import 'widgets/top_bar.dart';
import 'widgets/shop_list.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final TextEditingController _searchController = TextEditingController();
  String? _selectedStadiumId;
  bool _checkingStadium = true;

  @override
  void initState() {
    super.initState();
    _checkStadiumSelection();
  }

  Future<void> _checkStadiumSelection() async {
    final prefs = await SharedPreferences.getInstance();
    var stadiumId = prefs.getString('selected_stadium_id');

    // Pull latest branding from admin dashboard (color/logo/banner/brandName)
    if (stadiumId != null && stadiumId.isNotEmpty) {
      final stadium = await StadiumSync.refreshSelectedStadiumFromFirestore();
      if (mounted && stadium != null) {
        final theme = StadiumTheme.fromStadium(stadium).apply();
        context.read<ThemeBloc>().add(ChangeTheme(themeData: theme));
        stadiumId = stadium.id;
      }
    }

    if (!mounted) return;
    setState(() {
      _selectedStadiumId = stadiumId;
      _checkingStadium = false;
    });

    // If no stadium, open auto-select flow (web nearest-venue)
    if ((stadiumId == null || stadiumId.isEmpty) && mounted) {
      Future.delayed(const Duration(milliseconds: 400), () {
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/select-stadium');
        }
      });
    }
  }

  void _handleSearch(String value) {
    context.read<MenuBloc>().add(FilterMenuBySearch(query: value));
  }

  Widget _buildNoStadiumPlaceholder() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.location_on, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              Translate.get('pleaseSelectVenue'),
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              Translate.get('chooseVenueToBrowse'),
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/select-stadium'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              ),
              child: Text(Translate.get('selectStadium')),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => CategoryBloc()..add(LoadCategories()),
        ),
      ],
      child: Scaffold(
        backgroundColor: AppColors.bgColor,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TopBar(
              onSearch: _handleSearch,
              searchController: _searchController,
            ),
            Expanded(
              child: _checkingStadium
                  ? const Center(child: CircularProgressIndicator())
                  : _selectedStadiumId == null
                      ? _buildNoStadiumPlaceholder()
                      : SingleChildScrollView(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 24),
                                const CategoryList(),
                                const SizedBox(height: 24),
                                const ShopList(),
                                const SizedBox(height: 24),
                                const MenuList(),
                                const SizedBox(height: 50),
                              ],
                            ),
                          ),
                        ),
            ),
          ],
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
