import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stadium_food/src/bloc/profile/profile_bloc.dart';
import 'package:stadium_food/src/bloc/settings/settings_bloc.dart';
import 'package:stadium_food/src/core/constants/colors.dart';
import 'package:stadium_food/src/data/models/user.dart';
import 'package:stadium_food/src/presentation/widgets/items/food_item.dart';
import 'package:stadium_food/src/presentation/utils/custom_text_style.dart';
import 'package:stadium_food/src/presentation/widgets/loading_indicator.dart';

import '../../../../bloc/order/order_bloc.dart';
import '../../../../data/models/order.dart';
import '../../../../data/models/order_status.dart';
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

  Widget _buildStatsItem(String value, String label) {
    return Container(
      width: 100,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).primaryColor.withOpacity(0.1),
            Theme.of(context).cardColor.withOpacity(0.5),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).primaryColor.withOpacity(0.15),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).primaryColor.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: CustomTextStyle.size24Weight600Text(
              Theme.of(context).primaryColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: CustomTextStyle.size14Weight400Text(
              Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection(BuildContext context) {
    // If user is not logged in, show login button instead of settings
    if (_user == null) {
      return Container(
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
            const Text(
              "You are currently browsing as a guest",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/login');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text("Login"),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/register');
              },
              child: const Text("Create Account"),
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
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Log Out"),
            content: const Text("Are you sure you want to log out?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  BlocProvider.of<SettingsBloc>(context).add(Logout());
                },
                child: const Text(
                  "Log Out",
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
        );
      },
      onDeleteAccount: () {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Delete Account"),
            content: const Text(
              "Are you sure you want to delete your account? This action cannot be undone. Your account and all associated data will be permanently deleted.",
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  // Show loading dialog
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) => const AlertDialog(
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 16),
                          Text("Deleting account..."),
                        ],
                      ),
                    ),
                  );
                  
                  // Add the delete account event
                  BlocProvider.of<SettingsBloc>(context).add(DeleteAccount());
                },
                child: const Text(
                  "Delete Account",
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SettingsBloc, SettingsState>(
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
            const SnackBar(content: Text('Account deleted successfully')),
          );
          await Navigator.pushNamedAndRemoveUntil(
            context,
            "/register",
            (route) => false,
          );
        } else if (state is AccountDeletionFailure) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to delete account: ${state.message}')),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.bgColor,
        body: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Profile Card
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Theme.of(context)
                                  .shadowColor
                                  .withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color:
                                Theme.of(context).primaryColor.withOpacity(0.1),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 40,
                                  backgroundColor: Theme.of(context).primaryColor.withOpacity(0.2),
                                  child: _user?.photoUrl != null
                                    ? null // Let backgroundImage handle the display
                                    : Icon(
                                        Icons.person,
                                        size: 40,
                                        color: Theme.of(context).primaryColor,
                                      ),
                                  backgroundImage: _user?.photoUrl != null
                                    ? NetworkImage(_user!.photoUrl)
                                    : null,
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _user != null ? _user!.fullName : 'Guest User',
                                        style:
                                            CustomTextStyle.size18Weight600Text(
                                          Theme.of(context)
                                              .textTheme
                                              .titleLarge
                                              ?.color,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        _user != null ? _user!.email : 'Sign in to access your profile',
                                        style:
                                            CustomTextStyle.size14Weight400Text(
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
                              ],
                            ),
                            const SizedBox(height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                BlocBuilder<OrderBloc, OrderState>(
                                  builder: (context, stateOrder) {
                                    if (stateOrder is OrdersFetching) {
                                      return Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          _buildStatsItem('...', 'Active'),
                                          _buildStatsItem('...', 'Cancelled'),
                                          _buildStatsItem('...', 'Complete'),
                                        ],
                                      );
                                    } else if (stateOrder is OrdersFetched) {
                                      return Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          _buildStatsItem(
                                              filterOrders(
                                                  stateOrder.orders, 'active'),
                                              'Active'),
                                          _buildStatsItem(
                                              filterOrders(stateOrder.orders,
                                                  'completed'),
                                              'Cancelled'),
                                          _buildStatsItem(
                                              filterOrders(stateOrder.orders,
                                                  'cancelled'),
                                              'Complete'),
                                        ],
                                      );
                                    }
                                    return Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        _buildStatsItem('...', 'Active'),
                                        _buildStatsItem('...', 'Cancelled'),
                                        _buildStatsItem('...', 'Complete'),
                                      ],
                                    );
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Settings Section
                      Text(
                        'Settings',
                        style: CustomTextStyle.size18Weight600Text(
                          Theme.of(context).primaryColor,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildSettingsSection(context),
                      const SizedBox(height: 24),

                      // Favorite Foods Section
                      Text(
                        'Favorite Foods',
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
                                color: Theme.of(context).cardColor,
                              ),
                              child: const Center(child: LoadingIndicator()),
                            );
                          } else if (state is FavoritesFetched) {
                            if (state.favoriteFoods.isEmpty) {
                              return Container(
                                height: 220,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  color: Theme.of(context).cardColor,
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
                                        'No favorite foods yet',
                                        style:
                                            CustomTextStyle.size16Weight400Text(
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
              ),
            ],
          ),
        ),
      ),
    );
  }

  String filterOrders(List<Order> orders, String tabKey) {
    switch (tabKey) {
      case 'active':
        return orders
            .where((o) =>
                o.status == OrderStatus.pending ||
                o.status == OrderStatus.preparing ||
                o.status == OrderStatus.delivering)
            .length
            .toString();
      case 'completed':
        return orders
            .where((o) => o.status == OrderStatus.delivered)
            .length
            .toString();
      case 'cancelled':
        return orders
            .where((o) => o.status == OrderStatus.canceled)
            .length
            .toString();
      default:
        return '0';
    }
  }
}
