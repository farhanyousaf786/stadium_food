import 'package:cloud_firestore/cloud_firestore.dart' hide Order;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:stadium_food/src/bloc/order/order_bloc.dart';
import 'package:stadium_food/src/core/translations/translate.dart';
import 'package:stadium_food/src/data/models/order.dart';
import 'package:stadium_food/src/services/store_url_service.dart';
import 'package:stadium_food/src/data/models/order_status.dart';
import 'package:stadium_food/src/presentation/screens/tip/tip_screen.dart';
import 'package:stadium_food/src/data/models/shopuser.dart';
import 'package:stadium_food/src/presentation/screens/chat/chat_details_screen.dart';
import 'package:stadium_food/src/presentation/screens/order/track_delivery_screen.dart';
import 'package:stadium_food/src/presentation/widgets/buttons/back_button.dart';
import 'package:stadium_food/src/presentation/widgets/image_placeholder.dart';
import 'package:stadium_food/src/presentation/utils/app_colors.dart';
import 'package:stadium_food/src/presentation/utils/app_styles.dart';
import 'package:stadium_food/src/presentation/utils/custom_text_style.dart';
import 'package:stadium_food/src/presentation/widgets/order_status_stepper.dart';

import '../../../data/services/currency_service.dart';
import '../../../services/location_service.dart';
import '../../widgets/buttons/primary_button.dart';

class OrderDetailsScreen extends StatefulWidget {
  final Order order;

  const OrderDetailsScreen({super.key, required this.order});

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  final LocationService _locationService = LocationService();
  Position? _currentPosition;

  @override
  void initState() {
    super.initState();
    if (widget.order.id != null) {
      context.read<OrderBloc>().add(FetchOrderById(widget.order.id!));
    }
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      final position = await _locationService.getCurrentLocation();
      setState(() {
        _currentPosition = position;
      });
    } catch (e) {
      debugPrint('Error getting location: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentCurrency = CurrencyService.getCurrentCurrency();
    final symbol = CurrencyService.getCurrencySymbol(currentCurrency);
    
    return BlocBuilder<OrderBloc, OrderState>(
      builder: (context, state) {
        if (state is SingleOrderFetching) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is SingleOrderError) {
          return Center(child: Text(state.message));
        }
        
        final order = state is SingleOrderFetched ? state.order : widget.order;
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const CustomBackButton(),
                  order.status.index != 3
                      ? InkWell(
                          onTap: () async {
                            final querySnapshot = await FirebaseFirestore
                                .instance
                                .collection('users')
                                .where('shopsId', arrayContains: order.shopId)
                                .limit(1)
                                .get();

                            if (querySnapshot.docs.isEmpty) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text(
                                          Translate.get('shopOwnerNotFound'))),
                                );
                              }
                              return;
                            }

                            final shopUser = ShopUser.fromMap(
                                querySnapshot.docs.first.data());
                            if (context.mounted) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ChatDetailsScreen(
                                    otherUser: shopUser,
                                  ),
                                ),
                              );
                            }
                          },
                          borderRadius: AppStyles.defaultBorderRadius,
                          child: Container(
                            width: 45,
                            height: 45,
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: AppColors.primaryColor.withOpacity(0.1),
                              borderRadius: AppStyles.defaultBorderRadius,
                            ),
                            child: SvgPicture.asset(
                              "assets/svg/chat.svg",
                            ),
                          ),
                        )
                      : SizedBox(),
                ],
              ),
              const SizedBox(height: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${Translate.get('order')} #${order.id}",
                    style: CustomTextStyle.size22Weight600Text(),
                  ),
                  if (order.location != null && _currentPosition != null) ...[  
                    const SizedBox(height: 8),
                    Text(
                      "${Translate.get('distance')}: ${_locationService.calculateDistance(
                        _currentPosition!.latitude,
                        _currentPosition!.longitude,
                        order.location!.latitude,
                        order.location!.longitude,
                      ).toStringAsFixed(0)} ${Translate.get('meters')}",
                      style: CustomTextStyle.size16Weight400Text(),
                    ),
                  ],
                ],
              ),
              // --- QR Code Section ---
              order.status.index != 3 ? const SizedBox(height: 20) : SizedBox(),

              order.status.index != 3
                  ? Center(
                      child: QrImageView(
                        data: order.orderCode ??
                            '',
                        version: QrVersions.auto,
                        size: 160,
                        backgroundColor: Colors.white,
                        eyeStyle: const QrEyeStyle(
                          color: Colors.black,
                          eyeShape: QrEyeShape.square,
                        ),
                        dataModuleStyle: const QrDataModuleStyle(
                          color: Colors.black,
                          dataModuleShape: QrDataModuleShape.square,
                        ),
                      ),
                    )
                  : SizedBox(),
              // --- End QR Code Section ---

              const SizedBox(height: 20),

              OrderStatusStepper(
                status: order.status,
                orderTime: order.createdAt?.toDate(),
                deliveryTime: order.deliveryTime?.toDate(),
              ),

              const SizedBox(height: 20),
              if (order.status == OrderStatus.delivered) ...[
                Row(
                  children: [
                    if (!order.isTipAdded)
                      Expanded(
                        child: PrimaryButton(
                          onTap: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    TipScreen(orderId: order.id),
                              ),
                            );
                          },
                          text: Translate.get('addTip'),
                        ),
                      ),
                    SizedBox(
                      width: 5,
                    ),
                    Expanded(
                      child: PrimaryButton(
                        onTap: () {
                          StoreUrlService.openStoreReview();
                        },
                        text: Translate.get('feedbackUs'),
                      ),
                    ),
                  ],
                )
              ],

              const SizedBox(height: 20),

              Text(
                Translate.get('items'),
                style: CustomTextStyle.size18Weight600Text(),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: ListView.builder(
                  itemCount: order.cart.length,
                  itemBuilder: (context, index) {
                    var item = order.cart[index];

                    return Container(
                      margin: EdgeInsets.only(top: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(15),
                              bottomLeft: Radius.circular(15),
                            ),
                            child: item.images.isNotEmpty
                                ? Image.network(
                                    item.images[0],
                                    width: 120,
                                    height: 120,
                                    fit: BoxFit.cover,
                                  )
                                : Container(
                                    width: 120,
                                    height: 120,
                                    color: Colors.grey[200],
                                    child: Icon(Icons.fastfood,
                                        color: Colors.grey[400], size: 40),
                                  ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        item.name,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Spacer(),
                                      Text(
                                        "${Translate.get('quantity')} ${item.quantity}",
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    item.description,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[600],
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        '$symbol${item.price.toStringAsFixed(2)}',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.primaryColor,
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.primaryColor
                                              .withOpacity(0.1),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.watch_later_rounded,
                                              color: AppColors.primaryColor,
                                            ),
                                            Text(
                                              '${item.preparationTime} ${Translate.get('minutes')}',
                                              style: TextStyle(
                                                fontSize: 13,
                                                color: AppColors.primaryColor,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
      },
    );
  }
}
