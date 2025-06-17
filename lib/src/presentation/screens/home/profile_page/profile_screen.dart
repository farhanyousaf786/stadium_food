import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stadium_food/src/bloc/profile/profile_bloc.dart';
import 'package:stadium_food/src/bloc/settings/settings_bloc.dart';
import 'package:stadium_food/src/bloc/theme/theme_bloc.dart';
import 'package:stadium_food/src/data/models/user.dart';
import 'package:stadium_food/src/presentation/widgets/items/food_item.dart';
import 'package:stadium_food/src/presentation/utils/custom_text_style.dart';
import 'package:stadium_food/src/presentation/widgets/loading_indicator.dart';

import 'widgets/settings_section.dart';

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

  Widget _buildStatsItem(String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).primaryColor.withOpacity(0.1),
            Theme.of(context).cardColor.withOpacity(0.5),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).primaryColor.withOpacity(0.15),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).primaryColor.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: CustomTextStyle.size24Weight600Text(
              Theme.of(context).textTheme.titleLarge?.color,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: CustomTextStyle.size14Weight400Text(
              Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
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
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Theme.of(context)
                                      .primaryColor
                                      .withOpacity(0.05),
                                  Theme.of(context).cardColor,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Theme.of(context)
                                    .primaryColor
                                    .withOpacity(0.1),
                                width: 1,
                              ),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 40,
                                      backgroundImage:
                                          NetworkImage(_user.photoUrl),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            _user.fullName,
                                            style: CustomTextStyle
                                                .size18Weight600Text(
                                              Theme.of(context)
                                                  .textTheme
                                                  .titleLarge
                                                  ?.color,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            _user.email,
                                            style: CustomTextStyle
                                                .size14Weight400Text(
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
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    _buildStatsItem('12', 'Active'),
                                    _buildStatsItem('3', 'Pending'),
                                    _buildStatsItem('25', 'Complete'),
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
                                return const SizedBox(
                                  height: 300,
                                  child: LoadingIndicator(),
                                );
                              } else if (state is FavoritesFetched) {
                                if (state.favoriteFoods.isEmpty) {
                                  return Center(
                                    child: Text(
                                      'No favorite foods',
                                      style:
                                          CustomTextStyle.size16Weight400Text(
                                        Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.color
                                            ?.withOpacity(0.7),
                                      ),
                                    ),
                                  );
                                }

                                return SizedBox(
                                  height: 300,
                                  child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    shrinkWrap: true,
                                    itemCount: state.favoriteFoods.length,
                                    itemBuilder: (context, index) {
                                      return Padding(
                                        padding:
                                            const EdgeInsets.only(right: 16),
                                        child: SizedBox(
                                          width: 200,
                                          child: FoodItem(
                                            food: state.favoriteFoods[index],
                                            onTap: () {
                                              Navigator.pushNamed(
                                                context,
                                                '/foods/detail',
                                                arguments:
                                                    state.favoriteFoods[index],
                                              );
                                            },
                                          ),
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
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
