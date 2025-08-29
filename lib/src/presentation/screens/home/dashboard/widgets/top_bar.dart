import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stadium_food/src/bloc/menu/menu_bloc.dart';
import 'package:stadium_food/src/bloc/shop/shop_bloc.dart';
import 'package:stadium_food/src/bloc/stadium/stadium_bloc.dart';
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
  User? _user; // Make user nullable

  @override
  void initState() {
    super.initState();
    _loadUserAndStadium();
    _updateGreeting();
  }

  Future<void> _loadUserAndStadium() async {
    try {
      // Try to load user from Hive, but don't crash if it fails
      _user = User.fromHive();
    } catch (e) {
      // User is not logged in or data is invalid
      _user = null;
      print('User data not available: $e');
    }

    final prefs = await SharedPreferences.getInstance();
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

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding:  EdgeInsets.fromLTRB(16, MediaQuery.of(context).padding.top+16, 16, 36),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(16),bottomRight:Radius.circular(16) ),
        image: DecorationImage(
          image: AssetImage("assets/png/dashboard_bg.png"),
          fit: BoxFit.fill, // or BoxFit.contain / BoxFit.fill etc.
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row: profile icon, stadium selector, cart icon
          Row(
            children: [
              _circleIconButton(onTap: () {}),
              const SizedBox(width: 12),
              Expanded(
                child: InkWell(
                  borderRadius: BorderRadius.circular(24),
                  onTap: () async {
                    final result =
                        await Navigator.pushNamed(context, '/select-stadium');
                    if (result != null && mounted) {
                      final stadium = result as Stadium;
                      context.read<StadiumBloc>().add(SelectStadium(stadium));
                      context.read<MenuBloc>().add(LoadStadiumMenu(
                            stadiumId: stadium.id,
                          ));
                      context.read<ShopBloc>().add(LoadShops(stadium.id));
                    }
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        Translate.get('selectedStadium'),
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      Row(
                        children: [
                          BlocBuilder<StadiumBloc, StadiumState>(
                            builder: (context, state) {
                              String displayName = _selectedStadiumName ??
                                  Translate.get('chooseStadium');
                              if (state is StadiumSelected) {
                                displayName = state.stadium.name;
                              }
                              return Text(
                                displayName,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              );
                            },
                          ),
                          const SizedBox(width: 4),
                          const Icon(Icons.keyboard_arrow_right,
                              color: Colors.white70),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              InkWell(
                onTap: () => Navigator.pushNamed(context, "/cart"),
                borderRadius: BorderRadius.circular(22.5),
                child: Container(
                  width: 45,
                  height: 45,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(22.5),
                    border: Border.all(color: Colors.white.withOpacity(0.25)),
                    boxShadow: [AppStyles.boxShadow7],
                  ),
                  padding: const EdgeInsets.all(10),
                  child: Badge(
                    backgroundColor: AppColors.errorColor,
                    isLabelVisible: OrderRepository.cart.isNotEmpty,
                    label: Text(
                      OrderRepository.cart.length.toString(),
                      style: CustomTextStyle.size14Weight400Text(Colors.white),
                    ),
                    offset: const Offset(10, -10),
                    child: SvgPicture.asset(
                      "assets/svg/cart.svg",
                      colorFilter: const ColorFilter.mode(
                        Colors.white,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Greeting
          Text(
            _user != null
                ? '$_greeting, ${_user!.firstName}!'
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
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: Colors.white70,
            ),
          ),

          const SizedBox(height: 30),

          // Glass search
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
              child: Container(
                height: 52,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.20),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withOpacity(0.35)),
                ),
                child: Row(
                  children: [
                    SvgPicture.asset(
                      "assets/svg/ic_search.svg",
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: widget.searchController,
                        onChanged: widget.onSearch,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          isCollapsed: true,
                          hintText: Translate.get('searchForFood'),
                          hintStyle: const TextStyle(color: Colors.white70),
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
  }
}

Widget _circleIconButton({VoidCallback? onTap}) {
  return InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(22.5),
    child: Container(
      width: 45,
      height: 45,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(22.5),
        border: Border.all(color: Colors.white.withOpacity(0.25)),
      ),
      child: SvgPicture.asset(
        "assets/svg/ic_loc.svg",
        colorFilter: const ColorFilter.mode(
          Colors.white,
          BlendMode.srcIn,
        ),
      ),
    ),
  );
}
