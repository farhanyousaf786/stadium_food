import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stadium_food/src/bloc/shop/shop_bloc.dart';
import 'package:stadium_food/src/core/translations/translate.dart';
import 'package:stadium_food/src/data/models/shop.dart';
import 'package:stadium_food/src/data/models/stadium.dart';
import 'package:stadium_food/src/presentation/screens/explore/food_list_screen.dart';
import 'package:stadium_food/src/presentation/utils/app_colors.dart';
import 'package:stadium_food/src/presentation/widgets/shimmer_widgets.dart';

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
                Translate.get('openRestaurants'),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              // TextButton(
              //   onPressed: () {},
              //   child: Text(
              //     Translate.get('viewAll'),
              //     style: const TextStyle(
              //       color: AppColors.primaryColor,
              //       fontWeight: FontWeight.w600,
              //     ),
              //   ),
              // )
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 360,
          child: BlocBuilder<ShopBloc, ShopState>(
            builder: (context, state) {
              if (state is ShopsLoading) {
                return const ShopShimmer();
              }

              if (state is ShopsLoaded) {
                _shops = state.shops;

                if (_shops.isEmpty) {
                  return Center(
                    child: Text(Translate.get('noShopsAvailable')),
                  );
                }

                return ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _shops.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final shop = _shops[index];
                    final cardWidth = MediaQuery.of(context).size.width - 48; // full-bleed card look
                    return SizedBox(
                      width: cardWidth,
                      child: _ShopCard(shop: shop),
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

class _ShopCard extends StatelessWidget {
  const _ShopCard({required this.shop});

  final Shop shop;

  Future<void> _openShop(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final stadiumId = prefs.getString('selected_stadium_id');
    final stadiumName = prefs.getString('selected_stadium_name');

    if (stadiumId != null && stadiumName != null && context.mounted) {
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
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => _openShop(context),
      child: Container(
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: Image.asset(
                'assets/png/shop_img.png',
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    shop.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  _DescriptionWithSeeMore(text: shop.description),
                  const SizedBox(height: 10),
                  _InfoRow(
                    icon: 'ic_loc',

                    text: shop.location,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: _InfoRow(
                          icon: 'ic_stadium',

                          text: shop.stadiumName,
                        ),
                      ),

                      const SizedBox(width: 8),
                      Expanded(
                        child: _InfoRow(
                          icon: 'ic_floor',

                          text: '${Translate.get('floor')} ${shop.floor}',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  _InfoRow(
                    icon: 'ic_stadium',

                    text: '${Translate.get('gate')} ${shop.gate}',
                  ),



                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon,  required this.text});

  final String icon;

  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SvgPicture.asset(
          "assets/svg/$icon.svg",

        ),

        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade700,
            ),
          ),
        ),
      ],
    );
  }
}

class _DescriptionWithSeeMore extends StatelessWidget {
  const _DescriptionWithSeeMore({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(fontSize: 13, color: Colors.grey.shade700);
    final span = TextSpan(text: text, style: style);
    return RichText(
      text: TextSpan(
        children: [
          span,

        ],
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }
}
