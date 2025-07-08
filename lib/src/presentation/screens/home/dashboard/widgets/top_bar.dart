import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stadium_food/src/bloc/menu/menu_bloc.dart';
import 'package:stadium_food/src/bloc/shop/shop_bloc.dart';
import 'package:stadium_food/src/bloc/stadium/stadium_bloc.dart';
import 'package:stadium_food/src/data/models/stadium.dart';
import 'package:stadium_food/src/data/models/user.dart';
import 'package:stadium_food/src/presentation/utils/app_colors.dart';
import '../../../../../data/repositories/order_repository.dart';
import '../../../../utils/app_styles.dart';
import '../../../../utils/custom_text_style.dart';


class TopBar extends StatefulWidget {
  const TopBar({super.key});

  @override
  State<TopBar> createState() => _TopBarState();
}

class _TopBarState extends State<TopBar> {
  String? _selectedStadiumName;
  String _greeting = '';
  late User _user;

  @override
  void initState() {
    super.initState();
    _loadUserAndStadium();
    _updateGreeting();
  }

  Future<void> _loadUserAndStadium() async {
    _user = User.fromHive();
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedStadiumName =
          prefs.getString('selected_stadium_name') ?? 'Select Stadium';
    });
  }

  void _updateGreeting() {
    final hour = DateTime.now().hour;
    setState(() {
      if (hour < 12) {
        _greeting = 'Good Morning';
      } else if (hour < 17) {
        _greeting = 'Good Afternoon';
      } else {
        _greeting = 'Good Evening';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Stadium Selection Header
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.location_on_outlined,
                      color: AppColors.primaryColor),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: () async {
                      final result = await Navigator.pushNamed(context, '/select-stadium');
                      if (result != null && mounted) {
                        // Refresh menu items with the new stadium
                        final stadium = result as Stadium;
                        
                        // Update stadium using bloc
                        context.read<StadiumBloc>().add(SelectStadium(stadium));
                        
                        // Refresh menu items and shops
                        context.read<MenuBloc>().add(LoadStadiumMenu(
                          stadiumId: stadium.id,
                          limit: 10,
                        ));
                        context.read<ShopBloc>().add(LoadShops(stadium.id));
                      }
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Selected Stadium',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: AppColors.grayColor,
                          ),
                        ),
                        Row(
                          children: [
                            BlocBuilder<StadiumBloc, StadiumState>(
                              builder: (context, state) {
                                String displayName = _selectedStadiumName ?? 'Choose a Stadium';
                                
                                if (state is StadiumSelected) {
                                  displayName = state.stadium.name;
                                }
                                
                                return Text(
                                  displayName,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                );
                              },
                            ),
                            Icon(Icons.keyboard_arrow_right_sharp,
                                color: AppColors.primaryColor),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              InkWell(
                onTap: () => Navigator.pushNamed(context, "/cart"),
                borderRadius: AppStyles.defaultBorderRadius,
                child: Container(
                  width: 45,
                  height: 45,
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor.withOpacity(0.1),
                    borderRadius: AppStyles.defaultBorderRadius,
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
                        AppColors.primaryColor,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ),
              ),

            ],
          ),
        ),

        // Greeting Section
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$_greeting, ${_user.firstName}!',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                'What would you like to eat today?',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
