import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:stadium_food/src/bloc/order/order_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:stadium_food/src/presentation/screens/order/order_details_screen.dart';
import 'package:stadium_food/src/presentation/widgets/buttons/back_button.dart';
import 'package:stadium_food/src/presentation/widgets/loading_indicator.dart';
import 'package:stadium_food/src/presentation/widgets/price_info_widget.dart';
import 'package:stadium_food/src/presentation/utils/app_colors.dart';
import 'package:stadium_food/src/presentation/utils/custom_text_style.dart';
import 'package:stadium_food/src/core/translations/translate.dart';
import 'package:stadium_food/src/core/config/stripe_config.dart';
import 'package:hive/hive.dart';
import 'package:stadium_food/src/bloc/stadium/stadium_bloc.dart';
import 'package:stadium_food/src/data/models/section.dart';

import '../../../../data/repositories/order_repository.dart';
import '../../../../data/services/firebase_storage.dart';
import '../../../utils/app_styles.dart';
import '../../../widgets/buttons/primary_button.dart';
import 'widgets/apple_pay_button.dart';
import 'widgets/google_pay_button.dart';

class OrderConfirmScreen extends StatefulWidget {
  const OrderConfirmScreen({super.key});

  @override
  State<OrderConfirmScreen> createState() => _OrderConfirmScreenState();
}

class _OrderConfirmScreenState extends State<OrderConfirmScreen> {
  final FirebaseStorageService _firebaseStorageService = FirebaseStorageService(
    FirebaseStorage.instance,
  );

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    int? maxLines,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines ?? 1,
        decoration: InputDecoration(
          fillColor: AppColors().cardColor,
          filled: true,
          hintText: hint,
          labelText: label,
          labelStyle: const TextStyle(color: AppColors.primaryColor),
          hintStyle: CustomTextStyle.size14Weight400Text(
            AppColors().secondaryTextColor,
          ),
          enabledBorder: AppStyles().defaultEnabledBorder,
          focusedBorder: AppStyles.defaultFocusedBorder(),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return '${Translate.get('pleaseEnter')} ${label.toLowerCase()}';
          }
          return null;
        },
      ),
    );
  }

  final _formKey = GlobalKey<FormState>();
  final _rowController = TextEditingController();
  final _seatNoController = TextEditingController();
  final _standController = TextEditingController();
  final _entranceController = TextEditingController();
  final _floorController = TextEditingController();
  final _roomController = TextEditingController();
  final _areaController = TextEditingController();
  final _phoneController = TextEditingController();

  Map<String, dynamic>? paymentIntent;
  XFile? _image;
  String imageUrl = '';
  String sectionId = '';

  // Delivery mode & type (matches web)
  String _deliveryMode = 'delivery'; // 'delivery' or 'pickup'
  String? _deliveryType; // null, 'inside', 'outside'
  final _deliveryNotesController = TextEditingController();
  String _deliveryLocation = '';
  String _selectedPickupPoint = '';
  List<Map<String, dynamic>> _pickupPoints = [];
  Map<String, dynamic>? _shopData;
  String? _vendorAccountId;

  // Stadium config flags
  bool _showTicketUpload = true;
  bool _showDeliveryToggle = false;
  bool _showSeats = true;
  bool _showSections = true;
  bool _showFloors = false;
  bool _showRooms = false;
  bool _showStands = true;
  int _floorsCount = 0;

  // pick image from gallery
  Future<void> _pickImageFromGallery() async {
    _image = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 30,
    );

    if (_image != null) {}

    setState(() {});
  }

  // pick image from camera
  Future<void> _pickImageFromCamera() async {
    _image = await ImagePicker().pickImage(
      source: ImageSource.camera,
      imageQuality: 30,
    );

    if (_image != null) {}

    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    // Default Stand selection to Gallery if not set
    if (_standController.text.isEmpty) {
      _standController.text = Translate.get('standOptionGallery');
    }

    _loadStadiumConfig();
    _fetchShopData();
    _fetchPickupPoints();

    // Fetch sections for currently selected stadium
    try {
      final box = Hive.box('myBox');
      final sel = box.get('selectedStadium');
      final String? stadiumId = sel != null ? sel['id'] as String? : null;
      if (stadiumId != null && context.mounted) {
        context.read<StadiumBloc>().add(FetchSections(stadiumId));
      }
    } catch (_) {}

    // Initialize default delivery fee
    OrderRepository.calculateDefaultDeliveryFee();

    // Pre-fill phone from Firestore customers collection (matches web)
    _fetchCustomerPhone();
  }

  Future<void> _loadStadiumConfig() async {
    try {
      final box = Hive.box('myBox');
      final sel = box.get('selectedStadium') as Map<dynamic, dynamic>?;
      if (sel == null) return;
      setState(() {
        _showTicketUpload = sel['availableTickets'] == true;
        _showDeliveryToggle = sel['availablePickupPoints'] == true;
        _showSeats = sel['availableSeats'] == true;
        _showSections = sel['availableSections'] != false;
        _showFloors = sel['availableFloors'] == true;
        _showRooms = sel['availableRooms'] == true;
        _showStands = sel['availableStands'] == true;
        _floorsCount = (sel['floors'] as num?)?.toInt() ?? 0;
      });
    } catch (_) {}
  }

  Future<void> _fetchShopData() async {
    if (OrderRepository.cart.isEmpty) return;
    try {
      final firstItem = OrderRepository.cart[0];
      final shopId = firstItem.shopIds.isNotEmpty ? firstItem.shopIds.first : '';
      if (shopId.isEmpty) return;
      final doc = await FirebaseFirestore.instance.collection('shops').doc(shopId).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        setState(() {
          _shopData = data;
          _vendorAccountId = data['stripeConnectedAccountId'] as String?;
        });
      }
    } catch (_) {}
  }

  Future<void> _fetchPickupPoints() async {
    try {
      final box = Hive.box('myBox');
      final sel = box.get('selectedStadium') as Map<dynamic, dynamic>?;
      final stadiumId = sel?['id'] as String?;
      if (stadiumId == null) return;
      final snapshot = await FirebaseFirestore.instance
          .collection('stadiums')
          .doc(stadiumId)
          .collection('pickUpPoints')
          .get();
      setState(() {
        _pickupPoints = snapshot.docs.map((d) => {
          'id': d.id,
          ...d.data(),
        }).toList();
      });
    } catch (_) {}
  }

  void _updateDeliveryFee() {
    if (_deliveryMode == 'pickup') {
      OrderRepository.deliveryFee = 0;
      return;
    }
    if (_shopData == null) return;
    final int itemQuantity = OrderRepository.cart.fold(0, (sum, f) => sum + f.quantity);
    double fee = 0;
    if (_deliveryType == 'inside') {
      final baseFee = (_shopData!['insideDelivery']?['fee'] as num?)?.toDouble() ?? 0;
      fee = baseFee * itemQuantity;
    } else if (_deliveryType == 'outside') {
      fee = (_shopData!['outsideDelivery']?['fee'] as num?)?.toDouble() ?? 0;
    } else {
      final baseFee = (_shopData!['deliveryFee'] as num?)?.toDouble() ?? 0;
      fee = baseFee * itemQuantity;
    }
    OrderRepository.deliveryFee = fee;
    setState(() {});
  }

  // Parse QR scan result URL and populate fields: row, seat, section/sectionId
  void _handleQrScanResult(String result) {
    Uri? uri;
    try {
      uri = Uri.tryParse(result);
    } catch (_) {
      uri = null;
    }

    if (uri == null) {
      // Not a valid URI; try to parse as query only (fallback)
      try {
        uri = Uri.parse('$result');
      } catch (_) {

      }
    }

    if (uri == null) return;

    final qp = uri.queryParameters;
    final row = qp['row'] ?? qp['Row'] ?? qp['r'];
    final seat = qp['seat'] ?? qp['Seat'] ?? qp['s'];
    final sectionNameParam = qp['section'] ?? qp['Section'];
    final sectionIdParam = qp['sectionId'] ?? qp['SectionId'] ?? qp['sid'];

    setState(() {
      if (row != null && row.toString().isNotEmpty) {
        _rowController.text = row.trim();
      }
      if (seat != null && seat.toString().isNotEmpty) {
        _seatNoController.text = seat.trim();
      }
    });

    // Try to select the section from StadiumBloc state
    final stadiumState = context.read<StadiumBloc>().state;
    if (stadiumState is SectionsLoaded) {
      final List<Section> sections = stadiumState.sections;

      Section? matched;
      if (sectionIdParam != null && sectionIdParam.isNotEmpty) {
        matched = sections.firstWhere(
          (s) => s.sectionId == sectionIdParam,
          orElse: () => Section(
            id: '',
            sectionId: '',
            sectionName: '',
            sectionNo: 0,
            rows: 0,
            column: 0,
            isActive: true,
            shops: const [],
            createdAt: DateTime.fromMillisecondsSinceEpoch(0),
            updatedAt: DateTime.fromMillisecondsSinceEpoch(0),
          ),
        );
        if (matched.sectionId.isEmpty) matched = null;
      }

      // Fallback to match by name (case-insensitive)
      matched ??= (sectionNameParam == null
          ? null
          : sections.firstWhere(
              (s) => s.sectionName.toLowerCase() == sectionNameParam.toLowerCase(),
              orElse: () => Section(
                id: '',
                sectionId: '',
                sectionName: '',
                sectionNo: 0,
                rows: 0,
                column: 0,
                isActive: true,
                shops: const [],
                createdAt: DateTime.fromMillisecondsSinceEpoch(0),
                updatedAt: DateTime.fromMillisecondsSinceEpoch(0),
              ),
            ));
      if (matched != null && matched.sectionName.isNotEmpty) {
        setState(() {
          _entranceController.text = matched!.sectionName;
          sectionId = matched.sectionId;
          // Mirror dropdown onChanged side effects
          OrderRepository.selectedDeliveryUerId = '';
          if (matched.shops.isNotEmpty) {
            OrderRepository.selectedShopId = matched.shops.first;
          }
          OrderRepository.customerLocation = const GeoPoint(0, 0);
        });
        return;
      }
    }

    // If we did not find a matching Section in state but a name was provided, still set the text
    if (sectionNameParam != null && sectionNameParam.isNotEmpty) {
      setState(() {
        _entranceController.text = sectionNameParam;
      });
    }
  }

  Widget _buildDeliveryModeToggle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Delivery Method',
          style: CustomTextStyle.size16Weight600Text(AppColors.primaryColor),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildModeButton('delivery', 'Delivery'),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildModeButton('pickup', 'Pickup'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildModeButton(String mode, String label) {
    final isSelected = _deliveryMode == mode;
    return InkWell(
      onTap: () {
        setState(() {
          _deliveryMode = mode;
          if (mode == 'pickup') _deliveryType = null;
          _updateDeliveryFee();
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryColor.withOpacity(0.1) : Colors.white,
          border: Border.all(
            color: isSelected ? AppColors.primaryColor : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isSelected ? AppColors.primaryColor : Colors.grey[700],
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
            fontSize: 15,
          ),
        ),
      ),
    );
  }

  Widget _buildPickupPointsSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: DropdownButtonFormField<String>(
            value: _selectedPickupPoint.isEmpty ? null : _selectedPickupPoint,
            items: [
              const DropdownMenuItem(value: '', child: Text('-- Choose a pickup point --')),
              ..._pickupPoints.map((p) => DropdownMenuItem<String>(
                    value: p['id'] as String,
                    child: Text('${p['name'] ?? p['id']} ${p['address'] != null ? '(${p['address']})' : ''}'),
                  )),
            ],
            onChanged: (value) {
              setState(() {
                _selectedPickupPoint = value ?? '';
              });
            },
            decoration: InputDecoration(
              fillColor: AppColors().cardColor,
              filled: true,
              labelText: 'Select Pickup Point',
              labelStyle: const TextStyle(color: AppColors.primaryColor),
              enabledBorder: AppStyles().defaultEnabledBorder,
              focusedBorder: AppStyles.defaultFocusedBorder(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDeliveryTypeSelector() {
    final hasInside = _shopData!['insideDelivery']?['enabled'] == true;
    final hasOutside = _shopData!['outsideDelivery']?['enabled'] == true;
    final insideLocations = (_shopData!['insideDelivery']?['locations'] as List<dynamic>?) ?? [];
    final outsideLocations = (_shopData!['outsideDelivery']?['locations'] as List<dynamic>?) ?? [];

    List<dynamic> currentLocations = [];
    if (_deliveryType == 'inside') currentLocations = insideLocations;
    if (_deliveryType == 'outside') currentLocations = outsideLocations;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Text(
          'Delivery Type',
          style: CustomTextStyle.size16Weight600Text(AppColors.primaryColor),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            if (hasInside)
              Expanded(
                child: _buildTypeButton('inside', 'Inside Delivery'),
              ),
            if (hasInside && hasOutside)
              const SizedBox(width: 12),
            if (hasOutside)
              Expanded(
                child: _buildTypeButton('outside', 'Outside Delivery'),
              ),
          ],
        ),
        // Location selector
        if (_deliveryType != null && currentLocations.isNotEmpty) ...[
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: DropdownButtonFormField<String>(
              value: _deliveryLocation.isEmpty ? null : _deliveryLocation,
              items: [
                ...currentLocations.map((loc) {
                  final name = loc is String ? loc : (loc['name'] ?? loc.toString());
                  return DropdownMenuItem<String>(
                    value: name as String,
                    child: Text(name),
                  );
                }),
                // Manual entry option for inside delivery (matches web)
                if (_deliveryType == 'inside')
                  const DropdownMenuItem<String>(
                    value: 'manual_delivery_entry',
                    child: Text('Add specific room/section details'),
                  ),
              ],
              onChanged: (value) {
                setState(() {
                  _deliveryLocation = value ?? '';
                });
              },
              decoration: InputDecoration(
                fillColor: AppColors().cardColor,
                filled: true,
                labelText: 'Select Location',
                labelStyle: const TextStyle(color: AppColors.primaryColor),
                enabledBorder: AppStyles().defaultEnabledBorder,
                focusedBorder: AppStyles.defaultFocusedBorder(),
              ),
            ),
          ),
        ],
        // Delivery notes
        if (_deliveryType != null) ...[
          const SizedBox(height: 12),
          _buildTextField(
            controller: _deliveryNotesController,
            label: 'Delivery Notes',
            hint: 'Add any special instructions...',
            icon: Icons.note_outlined,
          ),
        ],
        // Manual entry seat details for inside delivery (matches web)
        if (_deliveryType == 'inside' && _deliveryLocation == 'manual_delivery_entry') ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Delivery Details',
                  style: CustomTextStyle.size14Weight600Text(AppColors.primaryColor),
                ),
                const SizedBox(height: 12),
                if (_showSections)
                  _buildTextField(
                    controller: _entranceController,
                    label: Translate.get('sectionLabel'),
                    hint: Translate.get('sectionHint'),
                    icon: Icons.meeting_room_outlined,
                  ),
                if (_showSections) const SizedBox(height: 12),
                if (_showFloors)
                  _buildTextField(
                    controller: _floorController,
                    label: Translate.get('floorLabel'),
                    hint: Translate.get('floorHint'),
                    icon: Icons.layers_outlined,
                    keyboardType: TextInputType.number,
                  ),
                if (_showFloors) const SizedBox(height: 12),
                if (_showRooms)
                  _buildTextField(
                    controller: _roomController,
                    label: Translate.get('roomLabel'),
                    hint: Translate.get('roomHint'),
                    icon: Icons.meeting_room_outlined,
                  ),
                if (_showRooms) const SizedBox(height: 12),
                _buildTextField(
                  controller: _areaController,
                  label: Translate.get('areaLabel'),
                  hint: Translate.get('areaHint'),
                  icon: Icons.map_outlined,
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  bool _isDeliveryOpen(String type) {
    final delivery = type == 'inside'
        ? _shopData!['insideDelivery'] as Map<String, dynamic>?
        : _shopData!['outsideDelivery'] as Map<String, dynamic>?;
    if (delivery == null || delivery['enabled'] != true) return false;
    final openTime = delivery['openTime'] as String? ?? '00:00';
    final closeTime = delivery['closeTime'] as String? ?? '23:59';
    if (openTime == closeTime) return true;
    final now = DateTime.now();
    final currentTime = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    if (openTime.compareTo(closeTime) < 0) {
      return currentTime.compareTo(openTime) >= 0 && currentTime.compareTo(closeTime) <= 0;
    } else {
      return currentTime.compareTo(openTime) >= 0 || currentTime.compareTo(closeTime) <= 0;
    }
  }

  Widget _buildTypeButton(String type, String label) {
    final isSelected = _deliveryType == type;
    final isOpen = _shopData != null ? _isDeliveryOpen(type) : true;
    return InkWell(
      onTap: () {
        // Check $50 minimum for outside delivery (matches web)
        if (type == 'outside') {
          final subtotal = OrderRepository.subtotal;
          final cartCurrency = OrderRepository.cart.isNotEmpty
              ? OrderRepository.cart[0].currency.toUpperCase()
              : 'ILS';
          // Approximate conversion: ILS->USD divide by ~3.7 (simplified)
          final rate = cartCurrency == 'ILS' ? 3.7 : 1.0;
          final subtotalInUSD = subtotal / rate;
          if (subtotalInUSD < 50) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Outside delivery requires a minimum order of \$50.'),
                backgroundColor: Colors.orange,
              ),
            );
            return;
          }
        }
        // Show closed warning but still allow selection (matches web)
        if (!isOpen) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$label is currently closed.'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        setState(() {
          _deliveryType = isSelected ? null : type;
          _deliveryLocation = '';
          _updateDeliveryFee();
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryColor.withOpacity(0.1)
              : (!isOpen ? Colors.grey[100] : Colors.white),
          border: Border.all(
            color: isSelected ? AppColors.primaryColor : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isSelected
                    ? AppColors.primaryColor
                    : (!isOpen ? Colors.grey[500] : Colors.grey[700]),
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                fontSize: 14,
              ),
            ),
            if (!isOpen)
              Text(
                'Offline',
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
          ],
        ),
      ),
    );
  }

  // Mirrors fee split math in server/controllers/stripeController.js
  Map<String, dynamic> _computeStripeSplit(
    double amountMajor,
    double deliveryFeeMajor,
    double tipAmountMajor,
  ) {
    // Convert to smallest currency unit (agorot/cents)
    final int amountInCents = (amountMajor * 100).round();
    final int deliveryFeeInCents = (deliveryFeeMajor * 100).round();
    final int tipAmountInCents = (tipAmountMajor * 100).round();

    final int basePlatformFees = deliveryFeeInCents + tipAmountInCents;

    int vendorAmount = amountInCents - basePlatformFees;
    if (vendorAmount < 0) vendorAmount = 0;

    // Estimated Stripe fees (approximation like server: 2.9% + 30¢ converted to agorot)
    final int stripePercentageFee = (amountInCents * 0.029).round();
    final int stripeFixedFee = (30 * 3.7).round(); // ~30¢ to agorot (approx.)
    final int totalStripeFees = stripePercentageFee + stripeFixedFee;

    final double platformShare =
        amountInCents == 0 ? 0 : basePlatformFees / amountInCents;
    final double vendorShare =
        amountInCents == 0 ? 0 : vendorAmount / amountInCents;

    final int platformStripeFee = (totalStripeFees * platformShare).round();
    final int vendorStripeFee = (totalStripeFees * vendorShare).round();

    final int finalPlatformFee = basePlatformFees + vendorStripeFee;
    final int finalVendorAmount = vendorAmount - vendorStripeFee;

    // Return both cents and major values for convenience
    double toMajor(int cents) => cents / 100.0;

    return {
      'amountInCents': amountInCents,
      'deliveryFeeInCents': deliveryFeeInCents,
      'tipAmountInCents': tipAmountInCents,
      'basePlatformFeesInCents': basePlatformFees,
      'vendorAmountInCents': vendorAmount,
      'stripePercentageFeeInCents': stripePercentageFee,
      'stripeFixedFeeInCents': stripeFixedFee,
      'totalStripeFeesInCents': totalStripeFees,
      'platformShare': platformShare,
      'vendorShare': vendorShare,
      'platformStripeFeeInCents': platformStripeFee,
      'vendorStripeFeeInCents': vendorStripeFee,
      'finalPlatformFeeInCents': finalPlatformFee,
      'finalVendorAmountInCents': finalVendorAmount,
      'amountMajor': amountMajor,
      'deliveryFeeMajor': deliveryFeeMajor,
      'tipAmountMajor': tipAmountMajor,
      'basePlatformFeeMajor': toMajor(basePlatformFees),
      'estimatedStripeFeesMajor': toMajor(totalStripeFees),
      'platformStripeFeeMajor': toMajor(platformStripeFee),
      'vendorStripeFeeMajor': toMajor(vendorStripeFee),
      'finalPlatformFeeMajor': toMajor(finalPlatformFee),
      'finalVendorReceivesMajor': toMajor(finalVendorAmount),
    };
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<OrderBloc, OrderState>(
      listener: (context, state) {
        if (state is OrderCreated) {
          // remove loading
          Navigator.of(context).pop();
          // Save phone to customer profile if missing (matches web)
          _saveCustomerPhoneIfMissing();
          // Clear tip (matches web localStorage.removeItem('selectedTip'))
          OrderRepository.tip = 0;
          // show success message
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 100.0,
                  ),
                  const SizedBox(height: 10.0),
                  Text(
                    Translate.get('paymentSuccess'),
                    style: CustomTextStyle.size18Weight600Text(),
                  ),
                  const SizedBox(height: 10.0),
                  Text(
                    "${Translate.get('amount')}: ₪${state.order.total.toStringAsFixed(2)}",
                    style: CustomTextStyle.size16Weight400Text(),
                  ),
                ],
              ),
            ),
          );
          // Navigate to order list screen
          Future.delayed(const Duration(seconds: 1), () {
            if (context.mounted) {
              Navigator.of(context, rootNavigator: true).pop(); // Close dialog
              Navigator.pushNamedAndRemoveUntil(
                context,
                "/home",
                (route) => false,
              );

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => OrderDetailsScreen(
                    order: state.order,
                  ),
                ),
              );
            }
          });
        } else if (state is OrderCreatingError) {
          // remove loading
          Navigator.of(context).pop();
          // show error message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.errorColor,
            ),
          );
        } else if (state is OrderCreating) {
          // show loading
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) {
              return const LoadingIndicator();
            },
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.bgColor,
        body: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/png/order_confirm_bg.png'),
                    fit: BoxFit.fill,
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const CustomBackButton(
                              color: Colors.white,
                            ),
                            Expanded(
                              child: Text(
                                Translate.get('selectYourSeat'),
                                textAlign: TextAlign.center,
                                style: CustomTextStyle.size18Weight600Text(
                                  Colors.white,
                                ),
                              ),
                            ),
                            // Stripe Mode Status Dot
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: StripeConfig.isLiveMode
                                    ? Colors.green
                                    : Colors.red,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: (StripeConfig.isLiveMode
                                            ? Colors.green
                                            : Colors.red)
                                        .withOpacity(0.5),
                                    blurRadius: 4,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Text(
                          textAlign: TextAlign.center,
                          Translate.get('provideSeatInfo'),
                          style: CustomTextStyle.size16Weight400Text(
                            Colors.white,
                          ),
                        ),
                        const SizedBox(height: 24),
                        _showTicketUpload ? Column(
                          children: [
                            Text(
                              Translate.get('uploadTicketTitle'),
                              style: CustomTextStyle.size16Weight600Text(
                                Colors.white,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              Translate.get('uploadTicketDesc'),
                              textAlign: TextAlign.center,
                              style: CustomTextStyle.size14Weight400Text(
                                Colors.white,
                              ),
                            ),
                            const SizedBox(height: 16),
                            _image != null
                                ? Center(
                                    child: Container(
                                      width: 250,
                                      height: 250,
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.5),
                                        shape: BoxShape.rectangle,
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(10)),
                                        border: Border.all(
                                            color:
                                                Colors.white.withOpacity(0.6)),
                                        boxShadow: [AppStyles.boxShadow7],
                                      ),
                                      child: Stack(
                                        children: [
                                          ClipRRect(
                                            borderRadius:
                                                AppStyles.largeBorderRadius,
                                            child: Image.file(
                                              File(_image!.path),
                                              width: 250,
                                              height: 250,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                          Positioned(
                                            top: 10,
                                            right: 10,
                                            child: InkWell(
                                              onTap: () {
                                                setState(() {
                                                  _image = null;
                                                });
                                              },
                                              child: Container(
                                                width: 30,
                                                height: 30,
                                                decoration: BoxDecoration(
                                                  color: Colors.white
                                                      .withOpacity(0.5),
                                                  borderRadius: AppStyles
                                                      .largeBorderRadius,
                                                ),
                                                child: const Icon(
                                                  Icons.close,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                : imageUrl != ""
                                    ? Center(
                                        child: Container(
                                          width: 250,
                                          height: 250,
                                          decoration: BoxDecoration(
                                            color:
                                                Colors.white.withOpacity(0.5),
                                            shape: BoxShape.rectangle,
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(10)),
                                            border: Border.all(
                                                color: Colors.white
                                                    .withOpacity(0.6)),
                                            boxShadow: [AppStyles.boxShadow7],
                                          ),
                                          child: Stack(
                                            children: [
                                              ClipRRect(
                                                borderRadius:
                                                    AppStyles.largeBorderRadius,
                                                child: Image.network(
                                                  imageUrl,
                                                  width: 250,
                                                  height: 250,
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (context, error,
                                                          stackTrace) =>
                                                      const Center(
                                                    child: Icon(
                                                      Icons.error,
                                                      color: Colors.red,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Positioned(
                                                top: 10,
                                                right: 10,
                                                child: InkWell(
                                                  onTap: () {
                                                    setState(() {
                                                      imageUrl = "";
                                                    });
                                                  },
                                                  child: Container(
                                                    width: 30,
                                                    height: 30,
                                                    decoration: BoxDecoration(
                                                      color: Colors.white
                                                          .withOpacity(0.5),
                                                      borderRadius: AppStyles
                                                          .largeBorderRadius,
                                                    ),
                                                    child: const Icon(
                                                      Icons.close,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      )
                                    : Row(
                                        children: [
                                          Expanded(
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 20),
                                              decoration: BoxDecoration(
                                                color: Colors.white
                                                    .withOpacity(0.5),
                                                shape: BoxShape.rectangle,
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(10)),
                                                border: Border.all(
                                                    color: Colors.white
                                                        .withOpacity(0.6)),
                                                boxShadow: [
                                                  AppStyles.boxShadow7
                                                ],
                                              ),
                                              child: InkWell(
                                                onTap: () {
                                                  _pickImageFromGallery();
                                                },
                                                borderRadius:
                                                    AppStyles.largeBorderRadius,
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    SvgPicture.asset(
                                                      "assets/svg/gallery.svg",
                                                    ),
                                                    const SizedBox(height: 10),
                                                    Text(
                                                      Translate.get(
                                                          'uploadFromGallery'),
                                                      style: CustomTextStyle
                                                          .size14Weight400Text(
                                                              Colors.white),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 20),
                                          // from camera
                                          Expanded(
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 20),
                                              decoration: BoxDecoration(
                                                color: Colors.white
                                                    .withOpacity(0.5),
                                                shape: BoxShape.rectangle,
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(10)),
                                                border: Border.all(
                                                    color: Colors.white
                                                        .withOpacity(0.6)),
                                                boxShadow: [
                                                  AppStyles.boxShadow7
                                                ],
                                              ),
                                              child: InkWell(
                                                onTap: () {
                                                  _pickImageFromCamera();
                                                },
                                                borderRadius:
                                                    AppStyles.largeBorderRadius,
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    SvgPicture.asset(
                                                      "assets/svg/camera.svg",
                                                    ),
                                                    const SizedBox(height: 10),
                                                    Text(
                                                      Translate.get(
                                                          'uploadFromCamera'),
                                                      style: CustomTextStyle
                                                          .size14Weight400Text(
                                                              Colors.white),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                          ],
                        ) : SizedBox.shrink(),
                      ],
                    ),
                  ),
                ),
              ),

              Container(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        Row(
                          children: [
                            const Expanded(child: Divider(thickness: 1)),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                Translate.get('or'),
                                style: CustomTextStyle.size14Weight600Text(
                                  AppColors().secondaryTextColor,
                                ),
                              ),
                            ),
                            const Expanded(child: Divider(thickness: 1)),
                          ],
                        ),
                        // Delivery mode toggle (matches web)
                        if (_showDeliveryToggle)
                          _buildDeliveryModeToggle(),
                        const SizedBox(height: 16),

                        // Pickup points dropdown (if pickup mode)
                        if (_showDeliveryToggle && _deliveryMode == 'pickup')
                          _buildPickupPointsSelector(),

                        // Inside/Outside delivery selector
                        if (_deliveryMode == 'delivery' && _shopData != null &&
                            ((_shopData!['insideDelivery']?['enabled'] == true) ||
                             (_shopData!['outsideDelivery']?['enabled'] == true)))
                          _buildDeliveryTypeSelector(),

                        // General seat form (only when NOT using inside/outside delivery)
                        if ((_deliveryMode == 'delivery' || !_showDeliveryToggle) &&
                            !(_deliveryType == 'inside' || _deliveryType == 'outside'))
                          Column(
                            children: [
                              // Stand + Section
                              if (_showStands || _showSections)
                                Row(
                                  children: [
                                    if (_showStands)
                                      Expanded(
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(12),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withOpacity(0.05),
                                                blurRadius: 10,
                                                offset: const Offset(0, 5),
                                              ),
                                            ],
                                          ),
                                          child: FormField<String>(
                                            validator: (_) {
                                              if (_showStands && _standController.text.isEmpty) {
                                                return '${Translate.get('standLabel').toLowerCase()}';
                                              }
                                              return null;
                                            },
                                            builder: (formState) {
                                              final gallery = Translate.get('standOptionGallery');
                                              final main = Translate.get('standOptionMain');
                                              return DropdownButtonFormField<String>(
                                                value: _standController.text.isEmpty
                                                    ? null
                                                    : _standController.text,
                                                items: <String>[gallery, main]
                                                    .map((value) => DropdownMenuItem<String>(
                                                          value: value,
                                                          child: Text(value),
                                                        ))
                                                    .toList(),
                                                onChanged: (value) {
                                                  setState(() {
                                                    _standController.text = value ?? '';
                                                    formState.didChange(_standController.text);
                                                  });
                                                },
                                                decoration: InputDecoration(
                                                  fillColor: AppColors().cardColor,
                                                  filled: true,
                                                  labelText: Translate.get('standLabel'),
                                                  hintText: Translate.get('selectStand'),
                                                  labelStyle: const TextStyle(color: AppColors.primaryColor),
                                                  hintStyle: CustomTextStyle.size14Weight400Text(
                                                    AppColors().secondaryTextColor,
                                                  ),
                                                  enabledBorder: AppStyles().defaultEnabledBorder,
                                                  focusedBorder: AppStyles.defaultFocusedBorder(),
                                                  errorText: formState.errorText,
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                    if (_showStands && _showSections)
                                      const SizedBox(width: 16),
                                    if (_showSections)
                                      Expanded(
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(12),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withOpacity(0.05),
                                                blurRadius: 10,
                                                offset: const Offset(0, 5),
                                              ),
                                            ],
                                          ),
                                          child: FormField<String>(
                                            validator: (_) {
                                              if (_showSections && _entranceController.text.isEmpty) {
                                                return '${Translate.get('entranceLabel').toLowerCase()}';
                                              }
                                              return null;
                                            },
                                            builder: (formState) {
                                              return BlocBuilder<StadiumBloc, StadiumState>(
                                                builder: (context, state) {
                                                  if (state is SectionsLoading) {
                                                    return const SizedBox();
                                                  }
                                                  List<Section> sections = [];
                                                  if (state is SectionsLoaded) {
                                                    sections = state.sections;
                                                  }
                                                  return DropdownButtonFormField<String>(
                                                    value: _entranceController.text.isEmpty
                                                        ? null
                                                        : _entranceController.text,
                                                    items: sections
                                                        .map((s) => DropdownMenuItem<String>(
                                                              value: s.sectionName,
                                                              child: Text(s.sectionName),
                                                            ))
                                                        .toList(),
                                                    onChanged: (value) {
                                                      setState(() {
                                                        _entranceController.text = value ?? '';
                                                        formState.didChange(_entranceController.text);
                                                        final sel = sections.firstWhere(
                                                          (s) => s.sectionName == value,
                                                          orElse: () => Section(
                                                            id: '',
                                                            sectionId: '',
                                                            sectionName: '',
                                                            sectionNo: 0,
                                                            rows: 0,
                                                            column: 0,
                                                            isActive: true,
                                                            shops: const [],
                                                            createdAt: DateTime.fromMillisecondsSinceEpoch(0),
                                                            updatedAt: DateTime.fromMillisecondsSinceEpoch(0),
                                                          ),
                                                        );
                                                        OrderRepository.selectedDeliveryUerId = '';
                                                        OrderRepository.selectedShopId = sel.shops.first;
                                                        sectionId = sel.sectionId;
                                                        OrderRepository.customerLocation = const GeoPoint(0, 0);
                                                      });
                                                    },
                                                    decoration: InputDecoration(
                                                      fillColor: AppColors().cardColor,
                                                      filled: true,
                                                      labelText: Translate.get('sectionLabel'),
                                                      hintText: Translate.get('selectSection'),
                                                      labelStyle: const TextStyle(color: AppColors.primaryColor),
                                                      hintStyle: CustomTextStyle.size14Weight400Text(
                                                        AppColors().secondaryTextColor,
                                                      ),
                                                      enabledBorder: AppStyles().defaultEnabledBorder,
                                                      focusedBorder: AppStyles.defaultFocusedBorder(),
                                                      errorText: formState.errorText,
                                                    ),
                                                  );
                                                },
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              if (_showStands || _showSections)
                                const SizedBox(height: 16),
                              // Row
                              if (_showSeats)
                                _buildTextField(
                                  controller: _rowController,
                                  label: Translate.get('rowLabel'),
                                  hint: Translate.get('rowHint'),
                                  icon: Icons.view_week_outlined,
                                ),
                              if (_showSeats)
                                const SizedBox(height: 16),
                              // Seat
                              if (_showSeats)
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildTextField(
                                        controller: _seatNoController,
                                        label: Translate.get('seatLabel'),
                                        hint: Translate.get('seatHint'),
                                        icon: Icons.chair_outlined,
                                        keyboardType: TextInputType.number,
                                      ),
                                    ),
                                  ],
                                ),
                              if (_showSeats)
                                const SizedBox(height: 16),
                              // Floor
                              if (_showFloors && _floorsCount > 0)
                                _buildTextField(
                                  controller: _floorController,
                                  label: Translate.get('floorLabel'),
                                  hint: Translate.get('floorHint'),
                                  icon: Icons.layers_outlined,
                                  keyboardType: TextInputType.number,
                                ),
                              if (_showFloors && _floorsCount > 0)
                                const SizedBox(height: 16),
                              // Room
                              if (_showRooms)
                                _buildTextField(
                                  controller: _roomController,
                                  label: Translate.get('roomLabel'),
                                  hint: Translate.get('roomHint'),
                                  icon: Icons.meeting_room_outlined,
                                ),
                              if (_showRooms)
                                const SizedBox(height: 16),
                              // Area
                              _buildTextField(
                                controller: _areaController,
                                label: Translate.get('areaLabel'),
                                hint: Translate.get('areaHint'),
                                icon: Icons.map_outlined,
                              ),
                              const SizedBox(height: 16),
                            ],
                          ),
                        const SizedBox(height: 16),
                        // Phone number (required, editable, pre-filled from profile)
                        _buildTextField(
                          controller: _phoneController,
                          label: Translate.get('phoneNumber'),
                          hint: Translate.get('phoneNumber'),
                          icon: Icons.phone_outlined,
                          keyboardType: TextInputType.phone,
                        ),
                        const SizedBox(height: 20),
                        BlocBuilder<OrderBloc, OrderState>(
                            builder: (context, state) {
                          return Column(
                            children: [
                              PriceInfoWidget(),
                              const SizedBox(height: 20),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 30),
                                child: PrimaryButton(
                                    text: Translate.get('placeOrder'),
                                    onTap: () async {
                                      if (OrderRepository.cart.isEmpty) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(
                                                Translate.get('cartEmpty')),
                                            backgroundColor:
                                                AppColors.errorColor,
                                          ),
                                        );
                                        return;
                                      }

                                        // Validate phone
                                        if (!_validatePhone(_phoneController.text)) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text(Translate.get('phoneNumberRequired')),
                                              backgroundColor: AppColors.errorColor,
                                            ),
                                          );
                                          return;
                                        }
                                        Hive.box('myBox').put('phone', _phoneController.text.trim());
                                        if (_image != null) {
                                          // Show loading
                                          showDialog(
                                            context: context,
                                            barrierDismissible: false,
                                            builder: (context) =>
                                                const LoadingIndicator(),
                                          );

                                          try {
                                            // Upload image to firebase storage
                                            final uploadedImageUrl =
                                                await _firebaseStorageService
                                                    .uploadImage(
                                              "tickets/${DateTime.now().millisecondsSinceEpoch}",
                                              File(_image!.path),
                                            );

                                            // Hide loading
                                            Navigator.of(context).pop();

                                            final seatInfo = _buildSeatInfo(ticketImage: uploadedImageUrl);

                                            makePayment(OrderRepository.total, seatInfo);
                                          } catch (e) {
                                            // Hide loading
                                            Navigator.of(context).pop();

                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                content: Text(Translate.get(
                                                    'imageUploadError')),
                                                backgroundColor:
                                                    AppColors.errorColor,
                                              ),
                                            );
                                          }
                                        }
                                        // If no image, validate and use text fields
                                        else if (_formKey.currentState!
                                            .validate()) {
                                          final seatInfo = _buildSeatInfo();

                                          makePayment(OrderRepository.total, seatInfo);
                                        }
                                    }),
                              ),
                              const SizedBox(height: 12),
                              // Wallet pay buttons
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 30),
                                child: Column(
                                  children: [
                                    Platform.isIOS
                                        ? ApplePayButton(
                                            onPressed: () async {
                                              // Mirror the same flow as Place Order button
                                              if (OrderRepository
                                                  .cart.isEmpty) {
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  SnackBar(
                                                    content: Text(Translate.get(
                                                        'cartEmpty')),
                                                    backgroundColor:
                                                        AppColors.errorColor,
                                                  ),
                                                );
                                                return;
                                              }

                                                if (!_validatePhone(_phoneController.text)) {
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    SnackBar(
                                                      content: Text(Translate.get('phoneNumberRequired')),
                                                      backgroundColor: AppColors.errorColor,
                                                    ),
                                                  );
                                                  return;
                                                }
                                                Hive.box('myBox').put('phone', _phoneController.text.trim());
                                                if (_image != null) {
                                                  showDialog(
                                                    context: context,
                                                    barrierDismissible: false,
                                                    builder: (context) =>
                                                        const LoadingIndicator(),
                                                  );
                                                  try {
                                                    final uploadedImageUrl =
                                                        await _firebaseStorageService
                                                            .uploadImage(
                                                      "tickets/${DateTime.now().millisecondsSinceEpoch}",
                                                      File(_image!.path),
                                                    );
                                                    Navigator.of(context).pop();
                                                    final seatInfo = _buildSeatInfo(ticketImage: uploadedImageUrl);
                                                    await makeApplePayment(
                                                        OrderRepository.total,
                                                        seatInfo);
                                                  } catch (_) {
                                                    Navigator.of(context).pop();
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(
                                                      SnackBar(
                                                        content: Text(Translate.get(
                                                            'imageUploadError')),
                                                        backgroundColor:
                                                            AppColors
                                                                .errorColor,
                                                      ),
                                                    );
                                                  }
                                                } else if (_formKey
                                                    .currentState!
                                                    .validate()) {
                                                  final seatInfo = _buildSeatInfo();
                                                  await makeApplePayment(
                                                      OrderRepository.total,
                                                      seatInfo);
                                                }
                                            },
                                          )
                                        : SizedBox(),
                                    const SizedBox(height: 8),
                                    Platform.isAndroid
                                        ? GooglePayButton(
                                            onPressed: () async {
                                              final scaffoldMessenger =
                                                  ScaffoldMessenger.of(context);
                                              final googlePaySupported =
                                                  await Stripe.instance
                                                      .isPlatformPaySupported(
                                                          googlePay:
                                                              IsGooglePaySupportedParams());

                                              if (googlePaySupported) {
                                                // Same flow as Apple Pay button
                                                if (OrderRepository
                                                    .cart.isEmpty) {
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    SnackBar(
                                                      content: Text(
                                                          Translate.get(
                                                              'cartEmpty')),
                                                      backgroundColor:
                                                          AppColors.errorColor,
                                                    ),
                                                  );
                                                  return;
                                                }

                                                  if (!_validatePhone(_phoneController.text)) {
                                                    ScaffoldMessenger.of(context).showSnackBar(
                                                      SnackBar(
                                                        content: Text(Translate.get('phoneNumberRequired')),
                                                        backgroundColor: AppColors.errorColor,
                                                      ),
                                                    );
                                                    return;
                                                  }
                                                  Hive.box('myBox').put('phone', _phoneController.text.trim());

                                                  if (_image != null) {
                                                    showDialog(
                                                      context: context,
                                                      barrierDismissible: false,
                                                      builder: (context) =>
                                                          const LoadingIndicator(),
                                                    );
                                                    try {
                                                      final uploadedImageUrl =
                                                          await _firebaseStorageService
                                                              .uploadImage(
                                                        "tickets/${DateTime.now().millisecondsSinceEpoch}",
                                                        File(_image!.path),
                                                      );
                                                      Navigator.of(context)
                                                          .pop();
                                                      final seatInfo = _buildSeatInfo(ticketImage: uploadedImageUrl);
                                                      await makeGooglePayment(
                                                          OrderRepository.total,
                                                          seatInfo);
                                                    } catch (_) {
                                                      Navigator.of(context)
                                                          .pop();
                                                      ScaffoldMessenger.of(
                                                              context)
                                                          .showSnackBar(
                                                        SnackBar(
                                                          content: Text(
                                                              Translate.get(
                                                                  'imageUploadError')),
                                                          backgroundColor:
                                                              AppColors
                                                                  .errorColor,
                                                        ),
                                                      );
                                                    }
                                                  } else if (_formKey
                                                      .currentState!
                                                      .validate()) {
                                                    final seatInfo = _buildSeatInfo();
                                                    await makeGooglePayment(
                                                        OrderRepository.total,
                                                        seatInfo);
                                                  }
                                              } else {
                                                if (context.mounted) {
                                                  scaffoldMessenger
                                                      .showSnackBar(
                                                    SnackBar(
                                                        content: Text(
                                                            Translate.get('googlePayNotSupported'))),
                                                  );
                                                }
                                              }
                                            },
                                          )
                                        : SizedBox(),
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: 50,
                              ),
                            ],
                          );
                        })
                      ],
                    )),
              )
              // OR separator
            ],
          ),
        ),
      ),
    );
  }

  Map<String, dynamic> _buildSeatInfo({String ticketImage = ''}) {
    return {
      'ticketImage': ticketImage,
      'row': _rowController.text,
      'seatNo': _seatNoController.text,
      'section': _entranceController.text,
      'sectionId': sectionId,
      'stand': _standController.text,
      'floor': _floorController.text,
      'room': _roomController.text,
      'area': _areaController.text,
      'seatDetails': _deliveryNotesController.text,
    };
  }

  Map<String, dynamic>? _buildInsideDelivery() {
    if (_deliveryType != 'inside' || _shopData == null) return null;
    final data = _shopData!['insideDelivery'] as Map<String, dynamic>?;
    if (data == null) return null;

    // Handle manual entry location (matches web app)
    String finalLocation = _deliveryLocation;
    if (_deliveryLocation == 'manual_delivery_entry') {
      final parts = <String>[];
      if (_roomController.text.isNotEmpty) parts.add('Room: ${_roomController.text}');
      if (_floorController.text.isNotEmpty) parts.add('Floor: ${_floorController.text}');
      if (_entranceController.text.isNotEmpty) parts.add('Section: ${_entranceController.text}');
      finalLocation = parts.isNotEmpty ? parts.join(', ') : 'Manual Entry';
    }

    return {
      'fee': data['fee'],
      'currency': data['currency'] ?? 'ILS',
      'location': finalLocation,
      'notes': _deliveryNotesController.text,
    };
  }

  Map<String, dynamic>? _buildOutsideDelivery() {
    if (_deliveryType != 'outside' || _shopData == null) return null;
    final data = _shopData!['outsideDelivery'] as Map<String, dynamic>?;
    if (data == null) return null;
    return {
      'fee': data['fee'],
      'currency': data['currency'] ?? 'ILS',
      'location': _deliveryLocation,
      'notes': _deliveryNotesController.text,
    };
  }

  Future<void> makePayment(double total, Map<String, dynamic> seatInfo) async {
    try {
      // Resolve shop ID before payment (matches web's placeOrderAfterPayment)
      final resolvedShopId = await _resolveShopId();
      if (resolvedShopId != null) {
        OrderRepository.selectedShopId = resolvedShopId;
      }
      // STEP 1: Create Payment Intent
      paymentIntent = await createPaymentIntent(
        total.toString(),
        'ils',
      );

      await Stripe.instance
          .initPaymentSheet(
            paymentSheetParameters: SetupPaymentSheetParameters(
              paymentIntentClientSecret: (paymentIntent?['clientSecret'] ??
                  paymentIntent?['client_secret']) as String,
              style: ThemeMode.dark,
              merchantDisplayName: 'Fan Munch',
            ),
          )
          .then((value) {});

      // STEP 3: Display Payment sheet
      displayPaymentSheet(seatInfo);
    } catch (err) {
      throw Exception(err);
    }
  }

  Future<void> makeGooglePayment(
      double total, Map<String, dynamic> seatInfo) async {
    try {
      // Resolve shop ID before payment (matches web's placeOrderAfterPayment)
      final resolvedShopId = await _resolveShopId();
      if (resolvedShopId != null) {
        OrderRepository.selectedShopId = resolvedShopId;
      }
      // STEP 1: Create Payment Intent
      paymentIntent = await createPaymentIntent(
        total.toString(),
        'ils',
      );

      await Stripe.instance.confirmPlatformPayPaymentIntent(
          clientSecret: (paymentIntent?['clientSecret'] ??
              paymentIntent?['client_secret']) as String,
          confirmParams: PlatformPayConfirmParams.googlePay(
            googlePay: GooglePayParams(
              testEnv: true,
              merchantName: 'Fan Munch',
              merchantCountryCode: 'US',
              currencyCode: 'ils',
            ),
          ));

      BlocProvider.of<OrderBloc>(context).add(
        CreateOrder(
          seatInfo: seatInfo,
          deliveryMethod: _deliveryMode,
          pickupPointId: _selectedPickupPoint.isEmpty ? null : _selectedPickupPoint,
          deliveryType: _deliveryType,
          deliveryLocation: _deliveryLocation.isEmpty ? null : _deliveryLocation,
          deliveryNotes: _deliveryNotesController.text.isEmpty ? null : _deliveryNotesController.text,
          insideDelivery: _buildInsideDelivery(),
          outsideDelivery: _buildOutsideDelivery(),
        ),
      );
      paymentIntent = null;
    } catch (err) {
      throw Exception(err);
    }
  }

  Future<void> makeApplePayment(
      double total, Map<String, dynamic> seatInfo) async {
    try {
      // Resolve shop ID before payment (matches web's placeOrderAfterPayment)
      final resolvedShopId = await _resolveShopId();
      if (resolvedShopId != null) {
        OrderRepository.selectedShopId = resolvedShopId;
      }
      // Check if Apple Pay is available first
      final isApplePaySupported =
          await Stripe.instance.isPlatformPaySupported();

      // ignore: avoid_print
      print('[APPLE PAY] Apple Pay supported: $isApplePaySupported');

      if (!isApplePaySupported) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                Translate.get('applePayNotAvailable')),
            backgroundColor: AppColors.errorColor,
          ),
        );
        return;
      }

      // STEP 1: Create Payment Intent
      paymentIntent = await createPaymentIntent(
        total.toString(),
        'ils',
      );

      // ignore: avoid_print
      print(
          '[APPLE PAY] About to confirm payment with client secret: ${(paymentIntent?['clientSecret'] ?? paymentIntent?['client_secret'])}');

      final result = await Stripe.instance.confirmPlatformPayPaymentIntent(
        clientSecret: (paymentIntent?['clientSecret'] ??
            paymentIntent?['client_secret']) as String,
        confirmParams: PlatformPayConfirmParams.applePay(
          applePay: ApplePayParams(
            merchantCountryCode: 'IL',
            currencyCode: 'ILS',
            cartItems: [
              ApplePayCartSummaryItem.immediate(
                label: 'Fan Munch Order',
                amount: total.toString(),
              )
            ],
          ),
        ),
      );

      // ignore: avoid_print
      print('[APPLE PAY] Payment confirmation result: $result');

      // Create order after successful payment
      BlocProvider.of<OrderBloc>(context).add(
        CreateOrder(
          seatInfo: seatInfo,
          deliveryMethod: _deliveryMode,
          pickupPointId: _selectedPickupPoint.isEmpty ? null : _selectedPickupPoint,
          deliveryType: _deliveryType,
          deliveryLocation: _deliveryLocation.isEmpty ? null : _deliveryLocation,
          deliveryNotes: _deliveryNotesController.text.isEmpty ? null : _deliveryNotesController.text,
          insideDelivery: _buildInsideDelivery(),
          outsideDelivery: _buildOutsideDelivery(),
        ),
      );
      paymentIntent = null;
    } catch (err) {
      // ignore: avoid_print
      print('[APPLE PAY] Error: $err');
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 100.0,
              ),
              const SizedBox(height: 10.0),
              Text(
                Translate.get('paymentFailed'),
                style: CustomTextStyle.size18Weight600Text(),
              ),
              const SizedBox(height: 10.0),
              Text(
                err.toString(),
                style: CustomTextStyle.size14Weight400Text(),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }
  }

  // Shop resolution matching web's resolveShopFromSection + cart fallback
  Future<String?> _resolveShopId() async {
    final cartItems = OrderRepository.cart;
    if (cartItems.isEmpty) return null;

    // Collect all unique shop IDs from cart
    final allShopIds = <String>{};
    for (final item in cartItems) {
      if (item.shopIds.isNotEmpty) allShopIds.add(item.shopIds.first);
    }
    final uniqueShopIds = allShopIds.toList();

    // If inside/outside delivery, use cart shop (shop-specific options)
    if (_deliveryType == 'inside' || _deliveryType == 'outside') {
      if (uniqueShopIds.isNotEmpty) return uniqueShopIds.first;
    }
    // If exactly one shop in cart, use it
    if (uniqueShopIds.length == 1) return uniqueShopIds.first;

    // Fallback: resolve from section with availability check
    try {
      final box = Hive.box('myBox');
      final sel = box.get('selectedStadium') as Map<dynamic, dynamic>?;
      final stadiumId = sel?['id'] as String?;
      if (stadiumId != null && sectionId.isNotEmpty) {
        final secDoc = await FirebaseFirestore.instance
            .collection('stadiums')
            .doc(stadiumId)
            .collection('sections')
            .doc(sectionId)
            .get();
        if (secDoc.exists) {
          final secData = secDoc.data() as Map<String, dynamic>;
          final shops = (secData['shops'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [];
          final availableShops = <String>[];
          for (final shopId in shops) {
            final shopDoc = await FirebaseFirestore.instance.collection('shops').doc(shopId).get();
            if (shopDoc.exists) {
              final shopData = shopDoc.data() as Map<String, dynamic>;
              if (shopData['shopAvailability'] == true) {
                availableShops.add(shopId);
              }
            }
          }
          if (availableShops.isNotEmpty) {
            // Gallery stand -> last shop, Main -> first shop
            final stand = _standController.text.toLowerCase();
            if (stand.contains('gallery')) {
              final lastOriginal = shops.isNotEmpty ? shops.last : '';
              if (availableShops.contains(lastOriginal)) return lastOriginal;
              return availableShops.first;
            }
            return availableShops.first;
          }
        }
      }
    } catch (_) {}

    // Final fallback
    if (uniqueShopIds.isNotEmpty) return uniqueShopIds.first;
    return null;
  }

  // Phone helpers (match web app phoneHelper.js)
  String _normalizePhone(String raw) {
    if (raw.isEmpty) return '';
    String s = raw.trim();
    final hasPlus = s.startsWith('+');
    s = s.replaceAll(RegExp(r'[^0-9]'), '');
    return hasPlus ? '+$s' : s;
  }

  bool _validatePhone(String phone) {
    final s = _normalizePhone(phone);
    if (s.isEmpty) return false;
    final digits = s.startsWith('+') ? s.substring(1) : s;
    final len = digits.replaceAll(RegExp(r'\D'), '').length;
    return len >= 6 && len <= 16;
  }

  Future<void> _fetchCustomerPhone() async {
    try {
      final box = Hive.box('myBox');
      final userId = box.get('id') as String?;
      if (userId == null || userId.isEmpty) return;
      final doc = await FirebaseFirestore.instance.collection('customers').doc(userId).get();
      if (!doc.exists) return;
      final data = doc.data() as Map<String, dynamic>;
      final phone = _normalizePhone(data['phone'] ?? data['userPhoneNo'] ?? '');
      if (phone.isNotEmpty) {
        setState(() {
          _phoneController.text = phone;
        });
      }
    } catch (_) {}
  }

  Future<bool> _saveCustomerPhoneIfMissing() async {
    try {
      final box = Hive.box('myBox');
      final userId = box.get('id') as String?;
      if (userId == null || userId.isEmpty) return false;
      final normalized = _normalizePhone(_phoneController.text);
      final doc = await FirebaseFirestore.instance.collection('customers').doc(userId).get();
      if (!doc.exists) return false;
      final data = doc.data() as Map<String, dynamic>;
      final existing = _normalizePhone(data['phone'] ?? data['userPhoneNo'] ?? '');
      if (existing.isNotEmpty) return false;
      await FirebaseFirestore.instance.collection('customers').doc(userId).update({'phone': normalized});
      return true;
    } catch (_) {
      return false;
    }
  }

  Future createPaymentIntent(String amount, String currency) async {
    try {
      // Match web app's server contract: amount in major units + fee breakdown
      final double amountMajor = double.tryParse(amount) ?? 0.0;

      // Compute the same fee split locally (mirrors server/controllers/stripeController.js)
      final split = _computeStripeSplit(
        amountMajor,
        OrderRepository.deliveryFee,
        OrderRepository.tip,
      );

      // Build cart items with COG (matches web app's cartItemsWithCOG)
      final cartItems = OrderRepository.cart.map((food) {
        return <String, dynamic>{
          'id': food.id,
          'name': food.name,
          'price': food.price,
          'quantity': food.quantity,
          'costOfGoods': food.costOfGoods,
          'hasCOG': food.hasCOG,
          'currency': food.currency.toUpperCase(),
        };
      }).toList();

      // Build shopConfig matching web app's paymentShopConfig
      final Map<String, dynamic>? shopConfig = _shopData != null
          ? <String, dynamic>{
              'payment-options': _shopData!['payment-options'] ?? <String, dynamic>{
                'model': '2-way',
                'platform-fee': 0,
                'vendor-fee': 1.0,
                'delivery-destination': 'platform',
                'tip-destination': 'platform',
                'vendor-id': _shopData!['stripeConnectedAccountId'] ?? _vendorAccountId ?? null,
                'hotel-id': null,
              }
            }
          : null;

      // Print client-side split for debugging
      // ignore: avoid_print
      print('[PAYMENT] Client-side split: ' + jsonEncode(split));

      final response = await http.post(
        Uri.parse(
            'https://fans-munch-app-2-22c94417114b.herokuapp.com/api/stripe/create-intent'),
        headers: const {'Content-Type': 'application/json'},
        body: jsonEncode({
          'amount': amountMajor,
          'currency': currency,
          'shopConfig': shopConfig,
          'cartItems': cartItems,
          'deliveryFee': OrderRepository.deliveryFee,
          'tipAmount': OrderRepository.tip,
          // Client-side computed breakdown (server may ignore; useful for debugging/analytics)
          'clientComputed': {
            'amountMajor': amountMajor,
            'deliveryFeeMajor': split['deliveryFeeMajor'],
            'tipAmountMajor': split['tipAmountMajor'],
            'basePlatformFeeMajor': split['basePlatformFeeMajor'],
            'estimatedStripeFeesMajor': split['estimatedStripeFeesMajor'],
            'platformStripeFeeMajor': split['platformStripeFeeMajor'],
            'vendorStripeFeeMajor': split['vendorStripeFeeMajor'],
            'finalPlatformFeeMajor': split['finalPlatformFeeMajor'],
            'finalVendorReceivesMajor': split['finalVendorReceivesMajor'],
            'shares': {
              'platformShare': split['platformShare'],
              'vendorShare': split['vendorShare'],
            }
          }
        }),
      );

      final String text = response.body;
      final dynamic data = jsonDecode(text);
      // Print raw server response for debugging
      // ignore: avoid_print
      print('[PAYMENT] Server create-intent response: ' + text);
      if (response.statusCode >= 400 ||
          (data is Map && data['success'] == false)) {
        throw Exception((data is Map ? data['error'] : null) ??
            'Failed to create payment intent');
      }

      return data;
    } catch (err) {
      throw Exception(err.toString());
    }
  }

  String calculateAmount(String amount) {
    final doubleAmount = double.parse(amount);
    final intAmount = (doubleAmount * 100).round();
    return intAmount.toString();
  }

  Future<void> displayPaymentSheet(Map<String, dynamic> seatInfo) async {
    try {
      await Stripe.instance.presentPaymentSheet().then((value) {
        // Create order after successful payment
        BlocProvider.of<OrderBloc>(context).add(
          CreateOrder(
            seatInfo: seatInfo,
            deliveryMethod: _deliveryMode,
            pickupPointId: _selectedPickupPoint.isEmpty ? null : _selectedPickupPoint,
            deliveryType: _deliveryType,
            deliveryLocation: _deliveryLocation.isEmpty ? null : _deliveryLocation,
            deliveryNotes: _deliveryNotesController.text.isEmpty ? null : _deliveryNotesController.text,
            insideDelivery: _buildInsideDelivery(),
            outsideDelivery: _buildOutsideDelivery(),
          ),
        );

        paymentIntent = null;
      });
    } catch (e) {
      print('Error in payment: $e');
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 100.0,
              ),
              const SizedBox(height: 10.0),
              Text(
                Translate.get('paymentFailed'),
                style: CustomTextStyle.size18Weight600Text(),
              ),
              const SizedBox(height: 10.0),
              Text(
                e.toString(),
                style: CustomTextStyle.size14Weight400Text(),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }
  }
}

Future buildDialog(BuildContext context) {
  return showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(
          Translate.get('selectPayment'),
          style: CustomTextStyle.size18Weight600Text(),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              onTap: () {
                Hive.box("myBox").put("paymentMethod", "paypal");
                Navigator.of(context).pop();
              },
              title: SvgPicture.asset(
                "assets/svg/paypal.svg",
              ),
            ),
            ListTile(
              onTap: () {
                Hive.box("myBox").put("paymentMethod", "visa");
                Navigator.of(context).pop();
              },
              title: SvgPicture.asset(
                "assets/svg/visa.svg",
              ),
            ),
          ],
        ),
      );
    },
  );
}
