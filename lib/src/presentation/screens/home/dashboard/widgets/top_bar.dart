import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stadium_food/src/bloc/menu/menu_bloc.dart';
import 'package:stadium_food/src/bloc/shop/shop_bloc.dart';
import 'package:stadium_food/src/bloc/stadium/stadium_bloc.dart';
import 'package:stadium_food/src/bloc/theme/theme_bloc.dart';
import 'package:stadium_food/src/core/translations/translate.dart';
import 'package:stadium_food/src/data/models/stadium.dart';
import 'package:stadium_food/src/data/models/user.dart';
import 'package:stadium_food/src/presentation/utils/app_colors.dart';
import '../../../../../data/repositories/order_repository.dart';
import '../../../../utils/app_styles.dart';
import '../../../../utils/custom_text_style.dart';

class TopBar extends StatefulWidget {
  const TopBar({super.key, this.onSearch, this.searchController});

  final ValueChanged<String>? onSearch;
  final TextEditingController? searchController;

  @override
  State<TopBar> createState() => _TopBarState();
}

class _TopBarState extends State<TopBar> {
  String? _selectedStadiumName;
  String _greeting = '';
  User? _user;

  bool get _isBranded =>
      AppColors.logoUrl.isNotEmpty ||
      AppColors.primaryColor != AppColors.defaultPrimaryColor ||
      AppColors.brandName.isNotEmpty && AppColors.brandName != 'Fans Food';

  @override
  void initState() {
    super.initState();
    _loadUserAndStadium();
    _updateGreeting();
  }

  Future<void> _loadUserAndStadium() async {
    try {
      _user = User.fromHive();
    } catch (_) {
      _user = null;
    }

    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _selectedStadiumName = prefs.getString('selected_stadium_name') ??
          Translate.get('chooseStadium');
    });
  }

  void _updateGreeting() {
    final hour = DateTime.now().hour;
    setState(() {
      if (hour < 12) {
        _greeting = Translate.get('goodMorning');
      } else if (hour < 17) {
        _greeting = Translate.get('goodAfternoon');
      } else {
        _greeting = Translate.get('goodEvening');
      }
    });
  }

  Future<void> _openStadiumPicker() async {
    final result = await Navigator.pushNamed(context, '/select-stadium');
    if (result != null && mounted) {
      final stadium = result as Stadium;
      context.read<StadiumBloc>().add(SelectStadium(stadium));
      context.read<MenuBloc>().add(LoadStadiumMenu(stadiumId: stadium.id));
      context.read<ShopBloc>().add(LoadShops(stadium.id));
      setState(() {
        _selectedStadiumName =
            stadium.brandName.isNotEmpty ? stadium.brandName : stadium.name;
      });
    }
  }

  DecorationImage? _backgroundImage() {
    // Branded venues use solid theme gradient (web home-top-section--branded)
    if (_isBranded) return null;
    return const DecorationImage(
      image: AssetImage('assets/png/dashboard_bg.png'),
      fit: BoxFit.cover,
      colorFilter: ColorFilter.mode(
        Color(0x66000000),
        BlendMode.darken,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Rebuild when venue theme changes
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, _) {
        final primary = AppColors.primaryColor;
        final dark = AppColors.primaryDarkColor;
        final light = AppColors.primaryLightColor;

        return Container(
          width: double.infinity,
          padding: EdgeInsets.fromLTRB(
            16,
            MediaQuery.of(context).padding.top + 16,
            16,
            28,
          ),
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [light, primary, dark],
            ),
            image: _backgroundImage(),
            boxShadow: [
              BoxShadow(
                color: primary.withOpacity(0.28),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Stadium selector + cart (no location icon — matches branded web)
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      borderRadius: BorderRadius.circular(24),
                      onTap: _openStadiumPicker,
                      child: Row(
                        children: [
                          if (AppColors.logoUrl.isNotEmpty) ...[
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.12),
                                    blurRadius: 8,
                                  ),
                                ],
                              ),
                              padding: const EdgeInsets.all(3),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(9),
                                child: Image.network(
                                  AppColors.logoUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Icon(
                                    Icons.stadium,
                                    color: primary,
                                    size: 22,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                          ],
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  Translate.get('selectedStadium'),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.8),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      ConstrainedBox(
                                        constraints: BoxConstraints(
                                          maxWidth: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.52,
                                        ),
                                        child: BlocBuilder<StadiumBloc,
                                            StadiumState>(
                                          builder: (context, state) {
                                            String displayName =
                                                AppColors.brandName.isNotEmpty
                                                    ? AppColors.brandName
                                                    : (_selectedStadiumName ??
                                                        Translate.get(
                                                            'chooseStadium'));
                                            if (state is StadiumSelected) {
                                              final s = state.stadium;
                                              displayName =
                                                  s.brandName.isNotEmpty
                                                      ? s.brandName
                                                      : s.name;
                                            }
                                            return Text(
                                              displayName,
                                              maxLines: 1,
                                              softWrap: false,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 15,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                      const SizedBox(width: 2),
                                      Icon(
                                        Icons.keyboard_arrow_right,
                                        color: Colors.white.withOpacity(0.85),
                                        size: 20,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Padding(
                    padding: const EdgeInsets.only(right: 2, top: 2),
                    child: InkWell(
                      onTap: () => Navigator.pushNamed(context, '/cart'),
                      borderRadius: BorderRadius.circular(22.5),
                      child: SizedBox(
                        width: 45,
                        height: 45,
                        child: Badge(
                          backgroundColor: AppColors.errorColor,
                          isLabelVisible: OrderRepository.cart.isNotEmpty,
                          label: Text(
                            OrderRepository.cart.length.toString(),
                            style: CustomTextStyle.size14Weight400Text(
                                Colors.white),
                          ),
                          offset: const Offset(2, -2),
                          child: Container(
                            width: 45,
                            height: 45,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.18),
                              borderRadius: BorderRadius.circular(22.5),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.35),
                              ),
                              boxShadow: [AppStyles.boxShadow7],
                            ),
                            padding: const EdgeInsets.all(10),
                            child: SvgPicture.asset(
                              'assets/svg/cart.svg',
                              colorFilter: const ColorFilter.mode(
                                Colors.white,
                                BlendMode.srcIn,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 22),

              Text(
                (_user != null && _user!.id.isNotEmpty)
                    ? '$_greeting, ${_user!.firstName.isNotEmpty ? _user!.firstName : Translate.get('user')}!'
                    : '$_greeting, ${Translate.get('guest')}!',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                Translate.get('whatToEat'),
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  color: Colors.white.withOpacity(0.85),
                ),
              ),

              const SizedBox(height: 22),

              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                  child: Container(
                    height: 52,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.22),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.4),
                      ),
                    ),
                    child: Row(
                      children: [
                        SvgPicture.asset('assets/svg/ic_search.svg'),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: widget.searchController,
                            onChanged: widget.onSearch,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              isCollapsed: true,
                              hintText: Translate.get('searchForFood'),
                              hintStyle: TextStyle(
                                color: Colors.white.withOpacity(0.75),
                              ),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
