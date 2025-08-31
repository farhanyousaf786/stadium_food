import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:stadium_food/src/bloc/order/order_bloc.dart';
import 'package:stadium_food/src/core/translations/translate.dart';
import 'package:stadium_food/src/data/repositories/order_repository.dart';
import 'package:stadium_food/src/presentation/widgets/buttons/primary_button.dart';
import 'package:stadium_food/src/presentation/widgets/items/order_item.dart';
import 'package:stadium_food/src/presentation/utils/app_colors.dart';
import 'package:stadium_food/src/presentation/utils/app_styles.dart';
import 'package:stadium_food/src/presentation/utils/custom_text_style.dart';

import '../../../data/models/order.dart';
import '../../../data/models/order_status.dart';

class OrderListScreen extends StatefulWidget {
  const OrderListScreen({super.key});

  @override
  State<OrderListScreen> createState() => _OrderListScreenState();
}

class _OrderListScreenState extends State<OrderListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();

    BlocProvider.of<OrderBloc>(context).add(FetchOrders());

    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<Order> filterOrders(List<Order> orders, String tabKey) {
    switch (tabKey) {
      case 'active':
        return orders
            .where((o) =>
                o.status == OrderStatus.pending ||
                o.status == OrderStatus.preparing ||
                o.status == OrderStatus.delivering)
            .toList();
      case 'completed':
        return orders.where((o) => o.status == OrderStatus.delivered || o.status == OrderStatus.canceled).toList();
      // case 'cancelled':
      //   return orders.where((o) => o.status == OrderStatus.canceled).toList();
      default:
        return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      body: Stack(
        children: [
          Image.asset(
            'assets/png/order_bg.png',
            width: double.infinity,
            height: size.height * 0.25,
            fit: BoxFit.fill,
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 30, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context),
                  const SizedBox(height: 36),
                  Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.5),
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      border: Border.all(
                          color: Colors.white.withOpacity(0.6)),
                      boxShadow: [AppStyles.boxShadow7],
                    ),
                    child: TabBar(
                      controller: _tabController,
                      indicatorSize: TabBarIndicatorSize.tab,
                      dividerColor: Colors.transparent,
                      indicator: BoxDecoration(
                        color: AppColors.primaryDarkColor, // your primaryColor
                        borderRadius: BorderRadius.circular(10),
                      ),
                      labelColor: Colors.white,
                      unselectedLabelColor: Colors.white,
                      labelStyle: const TextStyle(fontWeight: FontWeight.w600),
                      tabs:  [
                            Tab(text: Translate.get('active')),
                            Tab(text: Translate.get('completed')),
                        //     // Tab(text: Translate.get('cancelled')),
                      ],
                    ),
                  ),

                  const SizedBox(height: 60),
                  Expanded(
                    child: BlocBuilder<OrderBloc, OrderState>(
                      builder: (context, state) {
                        if (state is OrdersFetching) {
                          return _buildShimmer();
                        } else if (state is OrdersFetched) {
                          return TabBarView(
                            controller: _tabController,
                            children: [
                              _buildOrderList(filterOrders(state.orders, 'active')),
                              _buildOrderList(
                                  filterOrders(state.orders, 'completed')),
                            //   _buildOrderList(
                            //       filterOrders(state.orders, 'cancelled')),
                            ],
                          );
                        } else if (state is OrderFetchingError) {
                          return Center(
                            child: Text(
                              state.message,
                              style: CustomTextStyle.size16Weight400Text(
                                AppColors.errorColor,
                              ),
                            ),
                          );
                        } else {
                          return const SizedBox.shrink();
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Center(
      child: Text(Translate.get('orders'),
          textAlign: TextAlign.center,
          style: CustomTextStyle.size25Weight600Text(Colors.white)),
    );
  }

  Widget _buildShimmer() {
    return Column(
      children: List.generate(
        3,
        (index) => const Column(
          children: [
            OrderItemShimmer(),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderList(List<Order> orders) {
    if (orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              "assets/svg/order.svg",
              color: AppColors.starEmptyColor,
              height: 100,
              width: 100,
            ),
            const SizedBox(
              height: 16,
            ),
            Text(Translate.get('noOrdersFound'),
                style: CustomTextStyle.size22Weight600Text()),
            const SizedBox(height: 20),
            PrimaryButton(
              iconData: Icons.shopping_bag,
              text: Translate.get('continueShopping'),
              onTap: () => Navigator.pushNamed(context, "/home"),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(top: 10),
      itemCount: orders.length,
      itemBuilder: (context, index) => Column(
        children: [
          OrderItem(order: orders[index]),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
