import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stadium_food/src/bloc/profile/profile_bloc.dart';
import 'package:stadium_food/src/bloc/settings/settings_bloc.dart';
import 'package:stadium_food/src/bloc/theme/theme_bloc.dart';
import 'package:stadium_food/src/data/models/user.dart';
import 'package:stadium_food/src/presentation/widgets/image_placeholder.dart';
import 'package:stadium_food/src/presentation/widgets/items/food_item.dart';
import 'package:stadium_food/src/presentation/widgets/items/restaurant_item.dart';
import 'package:stadium_food/src/presentation/utils/app_colors.dart';
import 'package:stadium_food/src/presentation/utils/app_styles.dart';
import 'package:stadium_food/src/presentation/utils/app_theme.dart';
import 'package:stadium_food/src/presentation/utils/custom_text_style.dart';
import 'package:stadium_food/src/presentation/widgets/loading_indicator.dart';
import 'package:hive_flutter/hive_flutter.dart';

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
    BlocProvider.of<ProfileBloc>(context).add(
      FetchFavorites(),
    );
  }

  Widget _buildSettingsSection(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 20),
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.dark_mode, color: AppColors.primaryColor),
            ),
            title: Text(
              "Dark Mode",
              style: CustomTextStyle.size16Weight400Text(),
            ),
            trailing: Switch(
              value: Theme.of(context).brightness == Brightness.dark,
              onChanged: (value) {
                Hive.box('myBox').put('isDarkMode', value);
                BlocProvider.of<ThemeBloc>(context).add(
                  ChangeTheme(
                    themeData: Theme.of(context).brightness == Brightness.dark
                        ? AppTheme().lightThemeData
                        : AppTheme().darkThemeData,
                  ),
                );
              },
            ),
          ),
          const Divider(height: 1),
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 20),
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.logout, color: Colors.red),
            ),
            title: Text(
              "Log Out",
              style: CustomTextStyle.size16Weight400Text(),
            ),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text("Log Out"),
                  content: const Text(
                    "Are you sure you want to log out?",
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        "Cancel",
                        style: TextStyle(
                          color: AppColors().textColor,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        BlocProvider.of<SettingsBloc>(context).add(
                          Logout(),
                        );
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
          ),
        ],
      ),
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
          return PopScope(
            canPop: true,
            onPopInvoked: ((didPop) {
              if (didPop) {
                Navigator.pushReplacementNamed(context, '/home');
              }
            }),
          child: Scaffold(
            body: CustomScrollView(
              slivers: [
                SliverAppBar(
                  expandedHeight: MediaQuery.of(context).size.height * 0.4,
                  flexibleSpace: Stack(
                    children: [
                      FlexibleSpaceBar(
                        background: _user.image != null
                            ? Image.network(
                                _user.image!,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    ImagePlaceholder(
                                  iconData: Icons.person,
                                  iconSize: 100,
                                ),
                              )
                            : ImagePlaceholder(
                                iconData: Icons.person,
                                iconSize: 100,
                              ),
                      ),
                      //Border radius
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Container(
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppColors().backgroundColor,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(50),
                              topRight: Radius.circular(50),
                            ),
                            border: Border.all(
                              width: 0,
                              color: Theme.of(context).scaffoldBackgroundColor,
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                SliverToBoxAdapter(
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(
                      20,
                      0,
                      20,
                      40,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 15,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: AppStyles.largeBorderRadius,
                                gradient: LinearGradient(
                                  colors: [
                                    AppColors.secondaryColor.withOpacity(0.1),
                                    AppColors.secondaryDarkColor
                                        .withOpacity(0.1),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                              ),
                              child: Text(
                                'Member Gold',
                                style: CustomTextStyle.size14Weight400Text(
                                  AppColors.starColor,
                                ),
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: AppStyles.largeBorderRadius,
                                gradient: LinearGradient(
                                  colors: [
                                    AppColors.secondaryColor.withOpacity(0.1),
                                    AppColors.secondaryDarkColor
                                        .withOpacity(0.1),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                              ),
                              child: IconButton(
                                onPressed: () {
                                  Navigator.pushNamed(
                                    context,
                                    '/settings',
                                  );
                                },
                                icon: const Icon(
                                  Icons.settings,
                                  color: AppColors.starColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Text(
                          _user.fullName,
                          style: CustomTextStyle.size27Weight600Text(),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _user.email,
                          style: CustomTextStyle.size14Weight400Text(
                            AppColors().secondaryTextColor,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Settings',
                          style: CustomTextStyle.size18Weight600Text(),
                        ),
                        const SizedBox(height: 10),
                        _buildSettingsSection(context),
                        const SizedBox(height: 20),
                        Text(
                          'Favorite Foods',
                          style: CustomTextStyle.size18Weight600Text(),
                        ),
                        const SizedBox(height: 20),
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
                                      AppColors().secondaryTextColor,
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
                                  return Column(
                                    children: [
                                      FoodItem(
                                          food: state.favoriteFoods[index]),
                                      const SizedBox(height: 20),
                                    ],
                                  );
                                },
                              );
                            }
                            return const SizedBox();
                          },
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Favorite Restaurants',
                          style: CustomTextStyle.size18Weight600Text(),
                        ),
                        const SizedBox(height: 20),
                        BlocBuilder<ProfileBloc, ProfileState>(
                          builder: (context, state) {
                            if (state is FetchingFavorites) {
                              return const SizedBox(
                                width: 150,
                                height: 200,
                                child: RestaurantItemShimmer(),
                              );
                            } else if (state is FavoritesFetched) {
                              if (state.favoriteRestaurants.isEmpty) {
                                return Center(
                                  child: Text(
                                    'No favorite restaurants',
                                    style: CustomTextStyle.size16Weight400Text(
                                      AppColors().secondaryTextColor,
                                    ),
                                  ),
                                );
                              }

                              return SizedBox(
                                height: 200,
                                child: ListView(
                                  scrollDirection: Axis.horizontal,
                                  padding: EdgeInsets.zero,
                                  shrinkWrap: true,
                                  children: state.favoriteRestaurants
                                      .map((restaurant) {
                                    return Container(
                                      width: 150,
                                      margin: const EdgeInsets.only(right: 20),
                                      child: RestaurantItem(
                                        restaurant: restaurant,
                                      ),
                                    );
                                  }).toList(),
                                ),
                              );
                            }
                            return const SizedBox();
                          },
                        ),
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
