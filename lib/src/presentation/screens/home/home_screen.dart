import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:stadium_food/src/bloc/food/food_bloc.dart';
import 'package:stadium_food/src/bloc/order/order_bloc.dart';

import 'package:stadium_food/src/data/models/order_status.dart';
import 'package:stadium_food/src/bloc/theme/theme_bloc.dart';
import 'package:stadium_food/src/data/models/food.dart';
import 'package:stadium_food/src/data/models/restaurant.dart';
import 'package:stadium_food/src/data/repositories/order_repository.dart';

import 'package:stadium_food/src/presentation/screens/home/profile_page/profile_screen.dart';
import 'package:stadium_food/src/presentation/screens/order/cart_screen.dart';
import 'package:stadium_food/src/presentation/screens/order/order_list_screen.dart';
import 'package:stadium_food/src/presentation/widgets/items/food_item.dart';
import 'package:stadium_food/src/presentation/widgets/items/restaurant_item.dart';
import 'package:stadium_food/src/presentation/widgets/search_filter_widget.dart';
import 'package:stadium_food/src/presentation/utils/app_colors.dart';
import 'package:stadium_food/src/presentation/utils/app_styles.dart';
import 'package:stadium_food/src/presentation/utils/custom_text_style.dart';

import '../stadium/stadium_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final TextEditingController _searchController = TextEditingController();

  final List<Restaurant> _restaurants = [];
  final int _restaurantLimit = 2;

  final List<Food> _foods = [];
  final int _foodLimit = 5;

  @override
  void initState() {
    super.initState();
    // Fetch orders to get active order count
    BlocProvider.of<OrderBloc>(context).add(FetchOrders());
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Hide keyboard when user taps outside an input field
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        bottomNavigationBar: BlocBuilder<ThemeBloc, ThemeState>(
          builder: (context, state) {
            return Container(
              margin: const EdgeInsets.fromLTRB(10, 0, 10, 0),
              decoration: BoxDecoration(
                color: AppColors().cardColor,
                borderRadius: AppStyles.largeBorderRadius,
                boxShadow: [AppStyles().largeBoxShadow],
              ),
              child: NavigationBar(
                backgroundColor: Colors.transparent,
                labelBehavior:
                    NavigationDestinationLabelBehavior.alwaysShow,
                onDestinationSelected: (int index) {
                  setState(() {
                    _selectedIndex = index;
                  });
                },
                selectedIndex: _selectedIndex,
                destinations: [
                  NavigationDestination(
                    icon: Opacity(
                      opacity: 0.5,
                      child: SvgPicture.asset(
                        "assets/svg/home_new.svg",
                      ),
                    ),
                    selectedIcon: SvgPicture.asset(
                      "assets/svg/home_new.svg",
                    ),
                    label: "Home",
                  ),
                  NavigationDestination(
                    icon: BlocBuilder<OrderBloc, OrderState>(
                      builder: (context, state) {
                        int activeOrderCount = 0;
                        if (state is OrdersFetched) {
                          activeOrderCount = state.orders.where((o) =>
                            o.status == OrderStatus.pending ||
                            o.status == OrderStatus.preparing ||
                            o.status == OrderStatus.delivering).length;
                        }
                        return Badge(
                          backgroundColor: AppColors.errorColor,
                          isLabelVisible: activeOrderCount > 0,
                          label: Text(
                            activeOrderCount.toString(),
                            style: CustomTextStyle.size14Weight400Text(
                              Colors.white,
                            ),
                          ),
                          offset: const Offset(10, -10),
                          child: Opacity(
                            opacity: 0.5,
                            child: SvgPicture.asset(
                              "assets/svg/order.svg",
                            ),
                          ),
                        );
                      },
                    ),
                    selectedIcon: BlocBuilder<OrderBloc, OrderState>(
                      builder: (context, state) {
                        int activeOrderCount = 0;
                        if (state is OrdersFetched) {
                          activeOrderCount = state.orders.where((o) =>
                            o.status == OrderStatus.pending ||
                            o.status == OrderStatus.preparing ||
                            o.status == OrderStatus.delivering).length;
                        }
                        return Badge(
                          backgroundColor: AppColors.errorColor,
                          isLabelVisible: activeOrderCount > 0,
                          label: Text(
                            activeOrderCount.toString(),
                            style: CustomTextStyle.size14Weight400Text(
                              Colors.white,
                            ),
                          ),
                          offset: const Offset(10, -10),
                          child: SvgPicture.asset(
                            "assets/svg/order.svg",
                          ),
                        );
                      },
                    ),
                    label: "Orders",
                  ),
                  NavigationDestination(
                    icon: BlocBuilder<OrderBloc, OrderState>(
                      builder: (context, state) {
                        return Badge(
                          backgroundColor: AppColors.errorColor,
                          isLabelVisible: OrderRepository.cart.isNotEmpty,
                          label: Text(
                            OrderRepository.cart.length.toString(),
                            style: CustomTextStyle.size14Weight400Text(
                              Colors.white,
                            ),
                          ),
                          offset: const Offset(10, -10),
                          child: Opacity(
                            opacity: 0.5,
                            child: SvgPicture.asset(
                              "assets/svg/cart.svg",
                            ),
                          ),
                        );
                      },
                    ),
                    selectedIcon: BlocBuilder<OrderBloc, OrderState>(
                      builder: (context, state) {
                        return Badge(
                          backgroundColor: AppColors.errorColor,
                          isLabelVisible: OrderRepository.cart.isNotEmpty,
                          label: Text(
                            OrderRepository.cart.length.toString(),
                            style: CustomTextStyle.size14Weight400Text(
                              Colors.white,
                            ),
                          ),
                          offset: const Offset(10, -10),
                          child: SvgPicture.asset(
                            "assets/svg/cart.svg",
                          ),
                        );
                      },
                    ),
                    label: "Cart",
                  ),
                  NavigationDestination(
                    icon: Opacity(
                      opacity: 0.5,
                      child: SvgPicture.asset(
                        "assets/svg/profile.svg",
                      ),
                    ),
                    selectedIcon: SvgPicture.asset(
                      "assets/svg/profile.svg",
                    ),
                    label: "Profile",
                  ),
                ],
              ),
            );
          },
        ),
        body: _selectedIndex == 0
            ? const StadiumScreen()
            : _selectedIndex == 1
                ? const  OrderListScreen()
                : _selectedIndex == 2
                    ?  CartScreen(isFromHome: true)
                    : const ProfileScreen(),
      ),
    );
  }


}
