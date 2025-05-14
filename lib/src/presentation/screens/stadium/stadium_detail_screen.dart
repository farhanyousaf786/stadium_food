import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stadium_food/src/presentation/screens/explore/food_details_screen.dart';
import 'package:stadium_food/src/presentation/screens/explore/food_list_screen.dart';
import '../../../bloc/shop/shop_bloc.dart';
import '../../../data/models/stadium.dart';
import '../../../data/models/shop.dart';
import '../../utils/app_colors.dart';

class StadiumDetailScreen extends StatefulWidget {
  final Stadium stadium;

  const StadiumDetailScreen({super.key, required this.stadium});

  @override
  State<StadiumDetailScreen> createState() => _StadiumDetailScreenState();
}

class _StadiumDetailScreenState extends State<StadiumDetailScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ShopBloc>().add(LoadShops(widget.stadium.id));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          _buildStadiumInfo(),
          _buildShopsList(),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          widget.stadium.name,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        background: Hero(
          tag: 'stadium_${widget.stadium.id}',
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.network(
                widget.stadium.imageUrl,
                fit: BoxFit.cover,
              ),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.7),
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

  Widget _buildStadiumInfo() {
    return SliverToBoxAdapter(
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.location_on, color: AppColors.primaryColor),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.stadium.location,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.people, color: AppColors.primaryColor, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        '${widget.stadium.capacity}',
                        style: const TextStyle(
                          color: AppColors.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              widget.stadium.about,
              style: const TextStyle(fontSize: 14, height: 1.5),
            ),
            const SizedBox(height: 24),
            const Text(
              'Available Shops',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShopsList() {
    return BlocBuilder<ShopBloc, ShopState>(
      builder: (context, state) {
        if (state is ShopsLoading) {
          return const SliverFillRemaining(
            child: Center(
              child: CircularProgressIndicator(color: AppColors.primaryColor),
            ),
          );
        } else if (state is ShopsLoaded) {
          return state.shops.isEmpty
              ? const SliverFillRemaining(
                  child: Center(
                    child: Text('No shops available'),
                  ),
                )
              : SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => _ShopCard(shop: state.shops[index],stadium: widget.stadium,),
                      childCount: state.shops.length,
                    ),
                  ),
                );
        } else if (state is ShopError) {
          return SliverFillRemaining(
            child: Center(
              child: Text(state.message),
            ),
          );
        }
        return const SliverFillRemaining();
      },
    );
  }
}

class _ShopCard extends StatelessWidget {
  final Shop shop;
  final Stadium stadium;

  const _ShopCard({required this.shop, required this.stadium});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => FoodListScreen(stadium: stadium, shop: shop,),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      shop.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Floor ${shop.floor}',
                      style: const TextStyle(
                        color: AppColors.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                shop.description,
                style: TextStyle(color: Colors.grey[600]),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.location_on, size: 16, color: AppColors.primaryColor),
                  const SizedBox(width: 4),
                  Text(
                    'Gate ${shop.gate} - ${shop.location}',
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
