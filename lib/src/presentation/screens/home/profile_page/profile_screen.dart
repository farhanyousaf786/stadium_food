import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stadium_food/src/bloc/profile/profile_bloc.dart';
import 'package:stadium_food/src/bloc/settings/settings_bloc.dart';
import 'package:stadium_food/src/core/constants/colors.dart';
import 'package:stadium_food/src/core/translations/translate.dart';
import 'package:stadium_food/src/data/models/user.dart';
import 'package:stadium_food/src/presentation/widgets/loading_indicator.dart';

import '../../../../bloc/order/order_bloc.dart';
import '../../../../data/models/order.dart';
import '../../../../data/models/order_status.dart';
import 'package:stadium_food/src/presentation/utils/custom_text_style.dart';
import 'package:stadium_food/src/presentation/widgets/items/food_item.dart';
import 'widgets/settings_section.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  User? _user; // Make user nullable to handle guest users

  @override
  void initState() {
    super.initState();
    final bloc = BlocProvider.of<ProfileBloc>(context);

    // Try to load user data, but don't crash if it fails
    try {
      _user = User.fromHive();
      // Only fetch user-specific data if user is logged in
      if (_user != null) {
        BlocProvider.of<OrderBloc>(context).add(FetchOrders());
        bloc.add(FetchFavorites());
        // bloc.add(FetchOrderStats());
      }
    } catch (e) {
      print('User data not available: $e');
      _user = null;
    }
  }

  Widget _buildSettingsSection(BuildContext context) {
    // If user is not logged in, show login button instead of settings
    if (_user == null) {
      return Container(
        width: double.maxFinite,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).shadowColor.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(
              Translate.get('guestUser'),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/login');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              child: Text(Translate.get('login')),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/register');
              },
              child: Text(Translate.get('register')),
            ),
          ],
        ),
      );
    }

    // Regular settings section for logged in users
    return SettingsSection(
      user: _user!,
      settingsBloc: BlocProvider.of<SettingsBloc>(context),
      isDarkMode: Theme.of(context).brightness == Brightness.dark,
      onLogout: () {
        BlocProvider.of<SettingsBloc>(context).add(Logout());
      },
      onDeleteAccount: () {
        BlocProvider.of<SettingsBloc>(context).add(DeleteAccount());
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<SettingsBloc, SettingsState>(
          listenWhen: (previous, current) => 
            current is LogoutInProgress || 
            current is AccountDeletionInProgress || 
            current is LogoutSuccess || 
            current is AccountDeletionSuccess,
          listener: (context, state) async {
            if (state is LogoutInProgress || state is AccountDeletionInProgress) {
              showDialog(
                context: context,
                builder: (context) => const LoadingIndicator(),
              );
            } else if (state is LogoutSuccess) {
              Navigator.pop(context);
              await Navigator.pushNamedAndRemoveUntil(
                context,
                "/register",
                (route) => false,
              );
            } else if (state is AccountDeletionSuccess) {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(Translate.get('accountDeletedSuccess'))),
              );
              await Navigator.pushNamedAndRemoveUntil(
                context,
                "/register",
                (route) => false,
              );
            }
          },
        ),
        BlocListener<SettingsBloc, SettingsState>(
          listenWhen: (previous, current) => current is LanguageChanged,
          listener: (context, state) {
            if (state is LanguageChanged) {
              setState(() {}); // Rebuild screen to update translations
            }
          },
        ),
      ],
      child: Scaffold(
        backgroundColor: AppColors.bgColor,
        body: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Builder(
                  builder: (context) {
                    final size = MediaQuery.of(context).size;
                    final headerHeight = size.height * 0.28;
                    return Stack(
                      children: [
                        // Header background image
                        SizedBox(
                          height: headerHeight,
                          width: double.infinity,
                          child: Image.asset(
                            'assets/png/profile_bg.png',
                            fit: BoxFit.cover,
                          ),
                        ),

                        // Content card
                        Container(
                          margin: EdgeInsets.only(top: headerHeight - 40),
                          padding: const EdgeInsets.fromLTRB(16, 56, 16, 16),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(24),
                              topRight: Radius.circular(24),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Name + email + Logout button row
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  // Spacing for avatar overlap
                                  const SizedBox(width: 88),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          _user != null
                                              ? _user!.fullName
                                              : Translate.get('guestUser'),
                                          style: CustomTextStyle.size18Weight600Text(
                                            Colors.black87,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          _user != null
                                              ? _user!.email
                                              : Translate.get('signInPrompt'),
                                          style: CustomTextStyle.size14Weight400Text(
                                            Colors.blueGrey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  if (_user != null)
                                    ElevatedButton.icon(
                                      onPressed: () {
                                        BlocProvider.of<SettingsBloc>(context).add(Logout());
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                      ),
                                      icon: const Icon(Icons.logout, size: 18),
                                      label: Text(Translate.get('logout')),
                                    ),
                                ],
                              ),

                              const SizedBox(height: 16),

                              // Stats
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.06),
                                      blurRadius: 12,
                                      offset: const Offset(0, 6),
                                    ),
                                  ],
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  child: BlocBuilder<OrderBloc, OrderState>(
                                    builder: (context, stateOrder) {
                                      String active = '...';
                                      String completed = '...';
                                      if (stateOrder is OrdersFetched) {
                                        active = filterOrders(stateOrder.orders, 'activeOrders');
                                        completed = filterOrders(stateOrder.orders, 'completedOrders');
                                      }
                                      return Row(
                                        children: [
                                          Expanded(
                                            child: Column(
                                              children: [
                                                Text(
                                                  active.padLeft(2, '0'),
                                                  style: CustomTextStyle.size27Weight600Text(
                                                    Colors.black87,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  Translate.get('activeOrders'),
                                                  style: CustomTextStyle.size14Weight400Text(
                                                    Colors.blueGrey,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Container(
                                            width: 1,
                                            height: 36,
                                            color: Colors.grey.shade300,
                                          ),
                                          Expanded(
                                            child: Column(
                                              children: [
                                                Text(
                                                  completed.padLeft(2, '0'),
                                                  style: CustomTextStyle.size27Weight600Text(
                                                    Colors.green,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  Translate.get('completedOrders'),
                                                  style: CustomTextStyle.size14Weight400Text(
                                                    Colors.blueGrey,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                ),
                              ),

                              const SizedBox(height: 24),

                              // Settings Section
                              Text(
                                Translate.get('settings'),
                                style: CustomTextStyle.size16Weight600Text(
                                  Colors.blueGrey,
                                ),
                              ),
                              const SizedBox(height: 12),
                              _buildSettingsSection(context),

                              const SizedBox(height: 24),

                              // Favorite Foods Section
                              Text(
                                Translate.get('favoritesFoods'),
                                style: CustomTextStyle.size18Weight600Text(
                                  Theme.of(context).primaryColor,
                                ),
                              ),
                              const SizedBox(height: 16),
                              BlocBuilder<ProfileBloc, ProfileState>(
                                builder: (context, state) {
                                  if (state is FetchingFavorites) {
                                    return Container(
                                      height: 220,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: const Center(child: LoadingIndicator()),
                                    );
                                  } else if (state is FavoritesFetched) {
                                    if (state.favoriteFoods.isEmpty) {
                                      return Container(
                                        height: 220,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(16),
                                        ),
                                        child: Center(
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.favorite_border,
                                                size: 48,
                                                color: Theme.of(context)
                                                    .primaryColor
                                                    .withOpacity(0.5),
                                              ),
                                              const SizedBox(height: 12),
                                              Text(
                                                Translate.get('noFavorites'),
                                                style: CustomTextStyle.size16Weight400Text(
                                                  Theme.of(context)
                                                      .textTheme
                                                      .bodyMedium
                                                      ?.color
                                                      ?.withOpacity(0.7),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    }

                                    return SizedBox(
                                      height: 280,
                                      child: ListView.builder(
                                        scrollDirection: Axis.horizontal,
                                        itemCount: state.favoriteFoods.length,
                                        itemBuilder: (context, index) {
                                          return FoodItem(
                                            food: state.favoriteFoods[index],
                                            onTap: () {
                                              Navigator.pushNamed(
                                                context,
                                                '/foods/detail',
                                                arguments: state.favoriteFoods[index],
                                              );
                                            },
                                          );
                                        },
                                      ),
                                    );
                                  }
                                  return const SizedBox();
                                },
                              ),
                              const SizedBox(height: 24),
                            ],
                          ),
                        ),

                        // Avatar overlapping
                        Positioned(
                          top: headerHeight - 80,
                          left: 24,
                          child: CircleAvatar(
                            radius: 40,
                            backgroundColor: Theme.of(context).primaryColor.withOpacity(0.2),
                            backgroundImage: _user?.photoUrl != null
                                ? NetworkImage(_user!.photoUrl)
                                : null,
                            child: _user?.photoUrl != null
                                ? null
                                : Icon(
                                    Icons.person,
                                    size: 40,
                                    color: Theme.of(context).primaryColor,
                                  ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String filterOrders(List<Order> orders, String tabKey) {
    switch (tabKey) {
      case 'activeOrders':
        return orders
            .where((o) =>
                o.status == OrderStatus.pending ||
                o.status == OrderStatus.preparing ||
                o.status == OrderStatus.delivering)
            .length
            .toString();
      case 'completedOrders':
        return orders
            .where((o) => o.status == OrderStatus.delivered)
            .length
            .toString();
      case 'cancelledOrders':
        return orders
            .where((o) => o.status == OrderStatus.canceled)
            .length
            .toString();
      default:
        return '0';
    }
  }
}
