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
      if (_isLoggedIn) {
        BlocProvider.of<OrderBloc>(context).add(FetchOrders());
        bloc.add(FetchFavorites());
      }
    } catch (e) {
      print('User data not available: $e');
      _user = null;
    }
  }

  bool get _isLoggedIn => _user != null && _user!.id.isNotEmpty;

  Widget _buildGuestAuthCard(BuildContext context) {
    final primary = Theme.of(context).primaryColor;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: primary.withOpacity(0.12),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  primary.withOpacity(0.15),
                  primary.withOpacity(0.35),
                ],
              ),
              border: Border.all(color: Colors.white, width: 3),
              boxShadow: [
                BoxShadow(
                  color: primary.withOpacity(0.2),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(Icons.person_outline_rounded, size: 36, color: primary),
          ),
          const SizedBox(height: 14),
          Text(
            Translate.get('guestUser'),
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            Translate.get('signInPrompt'),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              height: 1.35,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () async {
                await Navigator.pushNamed(context, '/login');
                if (!mounted) return;
                try {
                  setState(() => _user = User.fromHive());
                } catch (_) {}
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(
                Translate.get('login'),
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: OutlinedButton(
              onPressed: () => Navigator.pushNamed(context, '/register'),
              style: OutlinedButton.styleFrom(
                foregroundColor: primary,
                side: BorderSide(color: primary, width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(
                Translate.get('register'),
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection(BuildContext context) {
    return SettingsSection(
      user: _isLoggedIn ? _user : null,
      settingsBloc: BlocProvider.of<SettingsBloc>(context),
      isDarkMode: Theme.of(context).brightness == Brightness.dark,
      onLogout: _isLoggedIn
          ? () {
              BlocProvider.of<SettingsBloc>(context).add(Logout());
            }
          : null,
      onDeleteAccount: _isLoggedIn
          ? () {
              BlocProvider.of<SettingsBloc>(context).add(DeleteAccount());
            }
          : null,
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
              setState(() {});
            }
          },
        ),
      ],
      child: Scaffold(
        backgroundColor: AppColors.bgColor,
        body: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Builder(
                builder: (context) {
                  final size = MediaQuery.of(context).size;
                  final headerHeight = size.height * 0.28;
                  return Stack(
                    children: [
                      // Venue-themed header
                      Container(
                        height: headerHeight,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Theme.of(context).colorScheme.primary,
                              Theme.of(context).primaryColor,
                              Theme.of(context).colorScheme.secondary,
                            ],
                          ),
                        ),
                      ),

                      // Content card
                      Container(
                        margin: EdgeInsets.only(
                          top: _isLoggedIn ? headerHeight - 40 : headerHeight - 28,
                        ),
                        padding: EdgeInsets.fromLTRB(
                          16,
                          _isLoggedIn ? 56 : 24,
                          16,
                          16,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.bgColor,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(24),
                            topRight: Radius.circular(24),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (_isLoggedIn) ...[
                              // Name + email + Logout button row
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const SizedBox(width: 88),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          _user!.fullName,
                                          style: CustomTextStyle
                                              .size18Weight600Text(
                                            Colors.black87,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          _user!.email,
                                          style: CustomTextStyle
                                              .size14Weight400Text(
                                            Colors.blueGrey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  ElevatedButton.icon(
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title: Text(Translate.get('logout')),
                                          content:
                                              Text(Translate.get('confirmLogout')),
                                          actions: [
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(context),
                                              child:
                                                  Text(Translate.get('cancel')),
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                Navigator.pop(context);
                                                BlocProvider.of<SettingsBloc>(
                                                        context)
                                                    .add(Logout());
                                              },
                                              child: Text(
                                                Translate.get('logout'),
                                                style: const TextStyle(
                                                    color: Colors.red),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 10),
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
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16),
                                  child: BlocBuilder<OrderBloc, OrderState>(
                                    builder: (context, stateOrder) {
                                      String active = '...';
                                      String completed = '...';
                                      if (stateOrder is OrdersFetched) {
                                        active = filterOrders(
                                            stateOrder.orders, 'activeOrders');
                                        completed = filterOrders(
                                            stateOrder.orders,
                                            'completedOrders');
                                      }
                                      return Row(
                                        children: [
                                          Expanded(
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  active.padLeft(2, '0'),
                                                  style: CustomTextStyle
                                                      .size27Weight600Text(
                                                    Colors.black87,
                                                  ),
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  Translate.get('activeOrders'),
                                                  style: CustomTextStyle
                                                      .size16Weight400Text(
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
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  completed.padLeft(2, '0'),
                                                  style: CustomTextStyle
                                                      .size27Weight600Text(
                                                    Colors.green,
                                                  ),
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  Translate.get(
                                                      'completedOrders'),
                                                  style: CustomTextStyle
                                                      .size16Weight400Text(
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
                            ] else ...[
                              // Guest: polished auth card (no awkward avatar gap)
                              const SizedBox(height: 8),
                              _buildGuestAuthCard(context),
                              const SizedBox(height: 24),
                            ],

                            // Settings Section
                            Text(
                              Translate.get('settings'),
                              style: CustomTextStyle.size16Weight600Text(
                                Colors.blueGrey,
                              ),
                            ),
                            const SizedBox(height: 12),
                            _buildSettingsSection(context),

                            if (_isLoggedIn) ...[
                              const SizedBox(height: 24),
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
                                    return const SizedBox(
                                      height: 220,
                                      child: Center(child: LoadingIndicator()),
                                    );
                                  } else if (state is FavoritesFetched) {
                                    if (state.favoriteFoods.isEmpty) {
                                      return SizedBox(
                                        height: 160,
                                        child: Center(
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
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
                                                style: CustomTextStyle
                                                    .size16Weight400Text(
                                                  Colors.blueGrey,
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
                                                arguments:
                                                    state.favoriteFoods[index],
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
                            ],
                            const SizedBox(height: 24),
                          ],
                        ),
                      ),

                      // Avatar overlapping — logged-in only
                      if (_isLoggedIn)
                        Positioned(
                          top: headerHeight - 80,
                          left: 24,
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 4),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.12),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: CircleAvatar(
                              radius: 40,
                              backgroundColor: Theme.of(context)
                                  .primaryColor
                                  .withOpacity(0.2),
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
                        ),
                    ],
                  );
                },
              ),
            ),
          ],
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
