import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hive/hive.dart';
import 'package:stadium_food/src/bloc/order/order_bloc.dart';
import 'package:stadium_food/src/core/translations/translate.dart';
import 'package:stadium_food/src/data/services/guest_auth_service.dart';
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

  bool get _hasUserId {
    final id = Hive.box('myBox').get('id');
    return id != null && id.toString().isNotEmpty;
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    if (_hasUserId) {
      BlocProvider.of<OrderBloc>(context).add(FetchOrders());
    }
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
        return orders
            .where((o) =>
                o.status == OrderStatus.delivered ||
                o.status == OrderStatus.canceled)
            .toList();
      default:
        return [];
    }
  }

  bool _isLoginError(String message) {
    final m = message.toLowerCase();
    return m.contains('user id') ||
        m.contains('login') ||
        m.contains('not found') ||
        m.contains('sign in');
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final primary = AppColors.primaryColor;
    final dark = AppColors.primaryDarkColor;
    final light = AppColors.primaryLightColor;

    return Scaffold(
      backgroundColor: AppColors.bgColor,
      body: Stack(
        children: [
          // Themed header (venue colors)
          Container(
            width: double.infinity,
            height: size.height * 0.28,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [light, primary, dark],
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context),
                  const SizedBox(height: 28),
                  Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.22),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withOpacity(0.45)),
                      boxShadow: [AppStyles.boxShadow7],
                    ),
                    child: TabBar(
                      controller: _tabController,
                      indicatorSize: TabBarIndicatorSize.tab,
                      dividerColor: Colors.transparent,
                      indicator: BoxDecoration(
                        color: dark,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      labelColor: Colors.white,
                      unselectedLabelColor: Colors.white,
                      labelStyle:
                          const TextStyle(fontWeight: FontWeight.w600),
                      tabs: [
                        Tab(text: Translate.get('active')),
                        Tab(text: Translate.get('completed')),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),
                  Expanded(
                    child: !_hasUserId
                        ? _buildLoginPrompt()
                        : BlocBuilder<OrderBloc, OrderState>(
                            builder: (context, state) {
                              if (state is OrdersFetching) {
                                return _buildShimmer();
                              } else if (state is OrdersFetched) {
                                return TabBarView(
                                  controller: _tabController,
                                  children: [
                                    _buildOrderList(
                                        filterOrders(state.orders, 'active')),
                                    _buildOrderList(filterOrders(
                                        state.orders, 'completed')),
                                  ],
                                );
                              } else if (state is OrderFetchingError) {
                                if (_isLoginError(state.message)) {
                                  return _buildLoginPrompt();
                                }
                                return _buildGenericError(state.message);
                              }
                              return const SizedBox.shrink();
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
      child: Text(
        Translate.get('orders'),
        textAlign: TextAlign.center,
        style: CustomTextStyle.size25Weight600Text(Colors.white),
      ),
    );
  }

  Widget _buildLoginPrompt() {
    final primary = AppColors.primaryColor;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
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
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: primary.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.receipt_long_rounded,
                    size: 36, color: primary),
              ),
              const SizedBox(height: 18),
              Text(
                'Sign in to see your orders',
                textAlign: TextAlign.center,
                style: CustomTextStyle.size20Weight600Text(),
              ),
              const SizedBox(height: 8),
              Text(
                'Log in or continue as guest to track active and past orders.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () async {
                    await Navigator.pushNamed(context, '/login');
                    if (!mounted) return;
                    if (_hasUserId) {
                      context.read<OrderBloc>().add(FetchOrders());
                      setState(() {});
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primary,
                    foregroundColor: Colors.white,
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
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton(
                  onPressed: () async {
                    try {
                      await GuestAuthService.ensureGuestUser();
                      if (!mounted) return;
                      context.read<OrderBloc>().add(FetchOrders());
                      setState(() {});
                    } catch (e) {
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Guest login failed: $e'),
                          backgroundColor: AppColors.errorColor,
                        ),
                      );
                    }
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: primary,
                    side: BorderSide(color: primary, width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    Translate.get('loginAsGuest'),
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () =>
                    Navigator.pushNamedAndRemoveUntil(context, '/home', (_) => false),
                child: Text(
                  Translate.get('continueShopping'),
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGenericError(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: AppColors.errorColor),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: CustomTextStyle.size16Weight400Text(AppColors.errorColor),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () =>
                  context.read<OrderBloc>().add(FetchOrders()),
              child: Text(
                'Retry',
                style: TextStyle(
                  color: AppColors.primaryColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
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
              'assets/svg/order.svg',
              colorFilter: ColorFilter.mode(
                AppColors.primaryColor.withOpacity(0.35),
                BlendMode.srcIn,
              ),
              height: 100,
              width: 100,
            ),
            const SizedBox(height: 16),
            Text(
              Translate.get('noOrdersFound'),
              style: CustomTextStyle.size22Weight600Text(),
            ),
            const SizedBox(height: 20),
            PrimaryButton(
              iconData: Icons.shopping_bag,
              text: Translate.get('continueShopping'),
              onTap: () =>
                  Navigator.pushNamedAndRemoveUntil(context, '/home', (_) => false),
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
