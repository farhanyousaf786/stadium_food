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

    _tabController = TabController(length: 3, vsync: this);
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
        return orders.where((o) => o.status == OrderStatus.delivered).toList();
      case 'cancelled':
        return orders.where((o) => o.status == OrderStatus.canceled).toList();
      default:
        return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 30, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              const SizedBox(height: 20),
              TabBar(
                controller: _tabController,
                indicatorColor: AppColors.primaryColor,
                labelColor: AppColors.primaryColor,
                unselectedLabelColor: Colors.grey,
                tabs: [
                  Tab(text: Translate.get('active')),
                  Tab(text: Translate.get('completed')),
                  Tab(text: Translate.get('cancelled')),
                ],
              ),
              const SizedBox(height: 10),
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
                          _buildOrderList(
                              filterOrders(state.orders, 'cancelled')),
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
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(Translate.get('orders'),
            style: CustomTextStyle.size25Weight600Text()),
        InkWell(
          onTap: () => Navigator.pushNamed(context, "/cart"),
          borderRadius: AppStyles.defaultBorderRadius,
          child: Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withOpacity(0.1),
              borderRadius: AppStyles.defaultBorderRadius,
              boxShadow: [AppStyles.boxShadow7],
            ),
            padding: const EdgeInsets.all(10),
            child: Badge(
              backgroundColor: AppColors.errorColor,
              isLabelVisible: OrderRepository.cart.isNotEmpty,
              label: Text(
                OrderRepository.cart.length.toString(),
                style: CustomTextStyle.size14Weight400Text(Colors.white),
              ),
              offset: const Offset(10, -10),
              child: SvgPicture.asset(
                "assets/svg/cart.svg",
                colorFilter: const ColorFilter.mode(
                  AppColors.primaryColor,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
        ),
      ],
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
