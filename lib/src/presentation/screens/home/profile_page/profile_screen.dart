import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stadium_food/src/bloc/profile/profile_bloc.dart';
import 'package:stadium_food/src/bloc/settings/settings_bloc.dart';
import 'package:stadium_food/src/bloc/theme/theme_bloc.dart';
import 'package:stadium_food/src/data/models/user.dart';
import 'package:stadium_food/src/presentation/widgets/items/food_item.dart';
import 'package:stadium_food/src/presentation/widgets/items/restaurant_item.dart';
import 'package:stadium_food/src/presentation/utils/app_colors.dart';
import 'package:stadium_food/src/presentation/utils/custom_text_style.dart';
import 'package:stadium_food/src/presentation/widgets/loading_indicator.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'widgets/profile_header.dart';
import 'widgets/settings_section.dart';
import 'widgets/user_stats_card.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final User _user = User.fromHive();

  @override
  void initState() {
    super.initState();
    BlocProvider.of<ProfileBloc>(context).add(FetchFavorites());
  }

  Widget _buildSettingsSection(BuildContext context) {
    return SettingsSection(
      user: _user,
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SettingsBloc, SettingsState>(
      listener: (context, state) async {
        if (state is LogoutInProgress) {
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
        }
      },
      child: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, state) {
          return Scaffold(
            body: CustomScrollView(
              slivers: [
                SliverAppBar(
                  expandedHeight: MediaQuery.of(context).size.height * 0.4,
                  flexibleSpace: ProfileHeader(user: _user),
                  pinned: true,
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      // User Stats Card
                      const UserStatsCard(),
                      const SizedBox(height: 24),
                      
                      // User Info Section
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _user.fullName,
                            style: CustomTextStyle.size27Weight600Text(
                              Theme.of(context).textTheme.titleLarge?.color,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _user.email,
                            style: CustomTextStyle.size14Weight400Text(
                              Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                      
                      // Settings Section
                      Text(
                        'Settings',
                        style: CustomTextStyle.size18Weight600Text(
                          Theme.of(context).textTheme.titleLarge?.color,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildSettingsSection(context),
                      const SizedBox(height: 24),
                      
                      // Favorite Foods Section
                      Text(
                        'Favorite Foods',
                        style: CustomTextStyle.size18Weight600Text(
                          Theme.of(context).textTheme.titleLarge?.color,
                        ),
                      ),
                      const SizedBox(height: 16),
                      BlocBuilder<ProfileBloc, ProfileState>(
                        builder: (context, state) {
                          if (state is FetchingFavorites) {
                            return const FoodItemShimmer();
                          } else if (state is FavoritesFetched) {
                            if (state.favoriteFoods.isEmpty) {
                              return Center(
                                child: Text(
                                  'No favorite foods',
                                  style: CustomTextStyle.size16Weight400Text(
                                    Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                                  ),
                                ),
                              );
                            }
                            return ListView.builder(
                              padding: EdgeInsets.zero,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: state.favoriteFoods.length,
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 16),
                                  child: FoodItem(food: state.favoriteFoods[index]),
                                );
                              },
                            );
                          }
                          return const SizedBox();
                        },
                      ),
                      const SizedBox(height: 24),
                      
                      // Favorite Restaurants Section
                      Text(
                        'Favorite Restaurants',
                        style: CustomTextStyle.size18Weight600Text(
                          Theme.of(context).textTheme.titleLarge?.color,
                        ),
                      ),
                      const SizedBox(height: 16),
                      BlocBuilder<ProfileBloc, ProfileState>(
                        builder: (context, state) {
                          if (state is FetchingFavorites) {
                            return const SizedBox(
                              height: 200,
                              child: RestaurantItemShimmer(),
                            );
                          } else if (state is FavoritesFetched) {
                            if (state.favoriteRestaurants.isEmpty) {
                              return Center(
                                child: Text(
                                  'No favorite restaurants',
                                  style: CustomTextStyle.size16Weight400Text(
                                    Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                                  ),
                                ),
                              );
                            }
                            return SizedBox(
                              height: 200,
                              child: ListView.separated(
                                scrollDirection: Axis.horizontal,
                                padding: EdgeInsets.zero,
                                shrinkWrap: true,
                                itemCount: state.favoriteRestaurants.length,
                                separatorBuilder: (context, index) => const SizedBox(width: 16),
                                itemBuilder: (context, index) {
                                  return SizedBox(
                                    width: 150,
                                    child: RestaurantItem(
                                      restaurant: state.favoriteRestaurants[index],
                                    ),
                                  );
                                },
                              ),
                            );
                          }
                          return const SizedBox();
                        },
                      ),
                      const SizedBox(height: 24),
                    ]),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}