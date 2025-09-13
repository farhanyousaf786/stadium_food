import 'package:cloud_firestore/cloud_firestore.dart' hide Order;
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:stadium_food/src/bloc/order/order_bloc.dart';
import 'package:stadium_food/src/bloc/order_detail/order_detail_bloc.dart';
import 'package:stadium_food/src/core/translations/translate.dart';
import 'package:stadium_food/src/data/models/order.dart';
import 'package:stadium_food/src/services/store_url_service.dart';
import 'package:stadium_food/src/data/models/order_status.dart';
import 'package:stadium_food/src/presentation/screens/tip/tip_screen.dart';
import 'package:stadium_food/src/data/models/shopuser.dart';
import 'package:stadium_food/src/presentation/screens/chat/chat_details_screen.dart';
import 'package:stadium_food/src/presentation/widgets/buttons/back_button.dart';
import 'package:stadium_food/src/presentation/utils/app_colors.dart';
import 'package:stadium_food/src/presentation/utils/app_styles.dart';
import 'package:stadium_food/src/presentation/utils/custom_text_style.dart';
import 'package:stadium_food/src/presentation/widgets/order_status_stepper.dart';
import 'package:stadium_food/src/data/services/language_service.dart';
import 'package:stadium_food/src/presentation/widgets/items/cart_item.dart';
import 'package:stadium_food/src/data/repositories/order_repository.dart';
import '../../../data/services/currency_service.dart';
import '../../../services/location_service.dart';
import '../../widgets/buttons/primary_button.dart';
import '../../widgets/delivery_distance_tracker.dart';
import 'package:url_launcher/url_launcher.dart';

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
    context.read<OrderDetailBloc>().add(FetchOrderDetail(widget.order.id));
    // _getCurrentLocation();
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

    return BlocBuilder<OrderDetailBloc, OrderDetailState>(
      builder: (context, state) {
        if (state is OrderDetailLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (state is OrderDetailError) {
          return Scaffold(
            body: Center(child: Text(state.message)),
          );
        }

        final order = state is OrderDetailLoaded ? state.order : widget.order;
        return Scaffold(
          backgroundColor: AppColors.bgColor,
          body: Stack(
            children: [
              Container(
                height: 300,
                width: double.infinity,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/png/order_detail_bg.png'),
                    fit: BoxFit.fill,
                  ),
                ),
              ),
              SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.only(left: 20, right: 20, top: MediaQuery
                      .of(context)
                      .padding
                      .top + 20, bottom: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const CustomBackButton(
                            color: Colors.white,
                          ),
                          order.status.index != 3
                              ? InkWell(
                            onTap: () async {
                              // Prefer delivery user's phone if available
                              String phone = '';
                              try {
                                final deliveryUserId = order.deliveryUserId;
                                if (deliveryUserId != null && deliveryUserId.isNotEmpty) {
                                  final deliveryDoc = await FirebaseFirestore.instance
                                      .collection('deliveryUsers')
                                      .doc(deliveryUserId)
                                      .get();
                                  final data = deliveryDoc.data();
                                  if (data != null) {
                                    // Try common phone field keys
                                    final candidate = (data['phone'] ?? '').toString();
                                    phone = candidate.trim();
                                  }
                                }
                              } catch (_) {}

                              if (phone.isEmpty) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        Translate.get('phoneNotAvailable'),
                                      ),
                                    ),
                                  );
                                }
                                return;
                              }

                              final uri = Uri(scheme: 'tel', path: phone);
                              try {
                                bool launched = false;

                                // Try tel: first
                                if (await canLaunchUrl(uri)) {
                                  launched = await launchUrl(
                                    uri,
                                    mode: LaunchMode.externalApplication,
                                  );
                                }

                                if (!launched && !kIsWeb) {
                                  // Fallback attempt for iOS using telprompt
                                  final telPrompt = Uri(scheme: 'telprompt', path: phone);
                                  if (await canLaunchUrl(telPrompt)) {
                                    launched = await launchUrl(
                                      telPrompt,
                                      mode: LaunchMode.externalApplication,
                                    );
                                  }
                                }

                                // On web, try opening the tel link directly
                                if (!launched && kIsWeb) {
                                  launched = await launchUrl(
                                    uri,
                                    webOnlyWindowName: '_self',
                                  );
                                }

                                if (!launched) {
                                  // As a final fallback, copy number to clipboard
                                  await Clipboard.setData(ClipboardData(text: phone));
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Cannot open phone dialer on this device. Phone number copied to clipboard.',
                                        ),
                                      ),
                                    );
                                  }
                                }
                              } catch (e) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                          'Failed to start call: ${e.toString()}'),
                                    ),
                                  );
                                }
                              }
                            },
                            borderRadius: AppStyles.defaultBorderRadius,
                            child: Container(
                              width: 50,
                              height: 50,
                              padding: const EdgeInsets.all(9),
                              decoration: BoxDecoration(
                                color:Colors.white.withOpacity(0.1),
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white.withOpacity(0.25)),
                                boxShadow: [AppStyles.boxShadow7],
                              ),

                              child: SvgPicture.asset(
                                "assets/svg/call.svg",

                              ),
                            ),
                          )
                              : SizedBox(),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Center(
                            child: Text(
                              "${Translate.get('order')} #${onlyDigits(order.id)}",
                              style: CustomTextStyle.size22Weight600Text(
                                  Colors.white),
                            ),
                          ),
                          // if (order.location != null &&
                          //     order.customerLocation != null) ...[
                          //   const SizedBox(height: 8),
                          //   DeliveryDistanceTracker(
                          //     distance: _locationService.calculateDistance(
                          //       order.customerLocation!.latitude,
                          //       order.customerLocation!.longitude,
                          //       order.location!.latitude,
                          //       order.location!.longitude,
                          //     ),
                          //     isDelivered: order.status ==
                          //         OrderStatus.delivered,
                          //   ),
                          // ],
                        ],
                      ),
                      // --- QR Code Section ---
                      order.status.index != 3
                          ? const SizedBox(height: 20)
                          : SizedBox(),

                      order.status.index != 3
                          ? Center(
                        child: Container(
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.5),
                            shape: BoxShape.rectangle,
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                            border: Border.all(
                                color: Colors.white.withOpacity(0.6)),
                            boxShadow: [AppStyles.boxShadow7],
                          ),
                          child: QrImageView(
                            data: order.orderCode,
                            version: QrVersions.auto,
                            size: 160,
                            backgroundColor: Colors.transparent,
                            eyeStyle: const QrEyeStyle(
                              color: AppColors.primaryDarkColor,
                              eyeShape: QrEyeShape.square,
                            ),
                            dataModuleStyle: const QrDataModuleStyle(
                              color: AppColors.primaryDarkColor,
                              dataModuleShape: QrDataModuleShape.square,
                            ),
                          ),
                        ),
                      )
                          : SizedBox(),
                      // --- End QR Code Section ---

                      const SizedBox(height: 20),

                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,

                          borderRadius: BorderRadius.all(Radius.circular(16)),

                        ),
                        child: OrderStatusStepper(
                          status: order.status,
                          orderTime: order.createdAt?.toDate(),
                          deliveryTime: order.deliveryTime?.toDate(),
                        ),
                      ),
                      if (order.status == OrderStatus.delivered) ...[
                        const SizedBox(height: 20),
                      ],

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
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: order.cart.length,
                        itemBuilder: (context, index) {
                          var item = order.cart[index];
                          final lang = LanguageService.getCurrentLanguage();
                          final localizedName = item.nameFor(lang);
                          final localizedDescription = item.descriptionFor(lang);

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
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              localizedName,
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            Spacer(),
                                            Text(
                                              "${Translate.get(
                                                  'quantity')} ${item
                                                  .quantity}",
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          localizedDescription,
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
                                              '$symbol${item.price
                                                  .toStringAsFixed(2)}',
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: AppColors.primaryColor,
                                              ),
                                            ),
                                            // Container(
                                            //   padding: const EdgeInsets
                                            //       .symmetric(
                                            //     horizontal: 8,
                                            //     vertical: 4,
                                            //   ),
                                            //   decoration: BoxDecoration(
                                            //     color: AppColors.primaryColor
                                            //         .withOpacity(0.1),
                                            //     borderRadius:
                                            //     BorderRadius.circular(12),
                                            //   ),
                                            //   child: Row(
                                            //     children: [
                                            //       Icon(
                                            //         Icons.watch_later_rounded,
                                            //         color: AppColors
                                            //             .primaryColor,
                                            //       ),
                                            //       Text(
                                            //         '${item
                                            //             .preparationTime} ${Translate
                                            //             .get('minutes')}',
                                            //         style: TextStyle(
                                            //           fontSize: 13,
                                            //           color:
                                            //           AppColors.primaryColor,
                                            //         ),
                                            //       ),
                                            //     ],
                                            //   ),
                                            // ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        // Cart quantity controls

                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 20),

                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String onlyDigits(String input) {
    return input.length > 6 ? input.substring(0, 6) : input;
  }
}
