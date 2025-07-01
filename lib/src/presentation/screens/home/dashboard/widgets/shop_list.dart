import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stadium_food/src/bloc/shop/shop_bloc.dart';
import 'package:stadium_food/src/data/models/shop.dart';
import 'package:stadium_food/src/presentation/screens/explore/food_list_screen.dart';
import 'package:stadium_food/src/presentation/utils/app_colors.dart';
import 'package:stadium_food/src/data/models/stadium.dart';

class ShopList extends StatefulWidget {
  const ShopList({super.key});

  @override
  State<ShopList> createState() => _ShopListState();
}

class _ShopListState extends State<ShopList> {
  List<Shop> _shops = [];

  @override
  void initState() {
    super.initState();
    _loadStadiumIdAndFetchShops();
  }

  Future<void> _loadStadiumIdAndFetchShops() async {
    final prefs = await SharedPreferences.getInstance();
    final stadiumId = prefs.getString('selected_stadium_id');
    if (stadiumId != null && mounted) {
      context.read<ShopBloc>().add(LoadShops(stadiumId));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Open Restaurants',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.grayColor,
                ),
              ),
              TextButton(
                onPressed: () {},
                child: Row(
                  children: [
                    Text(
                      'See All',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.primaryColor,
                      ),
                    ),
                    Icon(
                      Icons.chevron_right,
                      size: 20,
                      color: AppColors.primaryColor,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 320,
          child: BlocBuilder<ShopBloc, ShopState>(
            builder: (context, state) {
              if (state is ShopsLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              
              if (state is ShopsLoaded) {
                _shops = state.shops;
                
                if (_shops.isEmpty) {
                  return const Center(
                    child: Text('No shops available in this stadium'),
                  );
                }

                return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _shops.length,
                  itemBuilder: (context, index) {
                    final shop = _shops[index];
                    return Container(
                      width: MediaQuery.of(context).size.width - 32,
                      margin: const EdgeInsets.only(right: 16, bottom: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: InkWell(
                        onTap: () async {
                          final prefs = await SharedPreferences.getInstance();
                          final stadiumId = prefs.getString('selected_stadium_id');
                          final stadiumName = prefs.getString('selected_stadium_name');
                          
                          if (stadiumId != null && stadiumName != null && mounted) {
                            final stadium = Stadium(
                              id: stadiumId,
                              name: stadiumName,
                              location: '',
                              imageUrl: '',
                              about: '',
                              capacity: 0,
                              createdAt: DateTime.now().toIso8601String(),
                              updatedAt: DateTime.now().toIso8601String(),
                            );
                            
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => FoodListScreen(
                                  stadium: stadium,
                                  shop: shop,
                                ),
                              ),
                            );
                          }
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Shop Image
                            ClipRRect(
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(16),
                              ),
                              child: Image.network(
                                'https://images.unsplash.com/photo-1546069901-ba9599a7e63c',
                                height: 160,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    shop.name,
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Burger - Chicken - Rice - Wings',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.star,
                                            size: 20,
                                            color: Colors.orange,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            '4.7',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(width: 16),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.delivery_dining,
                                            size: 20,
                                            color: AppColors.primaryColor,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            'Free',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(width: 16),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.timer,
                                            size: 20,
                                            color: Colors.grey[600],
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            '20 min',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }

              if (state is ShopError) {
                return Center(child: Text(state.message));
              }

              return const SizedBox();
            },
          ),
        ),
      ],
    );
  }
}
