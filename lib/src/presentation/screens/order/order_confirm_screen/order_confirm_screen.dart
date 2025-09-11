import 'dart:convert';
import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:stadium_food/src/bloc/order/order_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:stadium_food/src/presentation/widgets/buttons/back_button.dart';
import 'package:stadium_food/src/presentation/widgets/loading_indicator.dart';
import 'package:stadium_food/src/presentation/widgets/price_info_widget.dart';
import 'package:stadium_food/src/presentation/utils/app_colors.dart';
import 'package:stadium_food/src/presentation/utils/custom_text_style.dart';
import 'package:stadium_food/src/core/translations/translate.dart';
import 'package:hive/hive.dart';

import '../../../../data/repositories/order_repository.dart';
import '../../../../data/services/firebase_storage.dart';
import '../../../../data/services/currency_service.dart';
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
            if (controller == _seatDetailsController ||
                controller == _areaController) return null; // Optional field
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
  final _areaController = TextEditingController();
  final _entranceController = TextEditingController();
  final _seatDetailsController = TextEditingController();

  Map<String, dynamic>? paymentIntent;
  XFile? _image;
  String imageUrl = '';

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

    final double platformShare = amountInCents == 0 ? 0 : basePlatformFees / amountInCents;
    final double vendorShare = amountInCents == 0 ? 0 : vendorAmount / amountInCents;

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

  // Show dialog to prompt user to login or register
  void _showAuthDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/png/logo.png',
                  height: 80,
                  width: 80,
                ),
                const SizedBox(height: 20),
                Text(
                  Translate.get('accountRequired'),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  Translate.get('loginOrRegister'),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context); // Close dialog
                      // Navigate to login without removing previous screens
                      Navigator.pushNamed(
                        context,
                        '/login',
                        arguments: '/order-confirm',
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      Translate.get('login'),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context); // Close dialog
                    // Navigate to register without removing previous screens
                    Navigator.pushNamed(context, '/register');
                  },
                  child: Text(
                    Translate.get('createAccount'),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryColor,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context); // Close dialog
                    Navigator.pop(context); // Go back to cart
                  },
                  child: Text(
                    Translate.get('cancel'),
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return BlocListener<OrderBloc, OrderState>(
      listener: (context, state) {
        if (state is OrderCreated) {
          // remove loading
          Navigator.of(context).pop();
          // show success message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(Translate.get('orderSuccess')),
              backgroundColor: AppColors.primaryColor,
            ),
          );
          // Navigate to order list screen
          Future.delayed(const Duration(seconds: 1), () {
            Navigator.of(context, rootNavigator: true).pop(); // Close dialog
            Navigator.pushNamedAndRemoveUntil(
              context,
              "/home",
              (route) => false,
            );
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
          child: Stack(
            children: [
              Image.asset(
                'assets/png/order_confirm_bg.png',
                width: double.infinity,
                height: size.height * 0.5,
                fit: BoxFit.fill,
              ),

              SafeArea(
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
                      Column(
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
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(10)),
                                      border: Border.all(
                                          color: Colors.white.withOpacity(0.6)),
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
                                                borderRadius:
                                                    AppStyles.largeBorderRadius,
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
                                          color: Colors.white.withOpacity(0.5),
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
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 20),
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
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 20),
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
                          const SizedBox(height: 50),
                        ],
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),

              Container(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                margin: EdgeInsets.only(
                  top: size.height * 0.5,
                ),
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
                        const SizedBox(height: 20),
                        Row(
                          children: [
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
                                    if (_standController.text.isEmpty) {
                                      return '${Translate.get('pleaseEnter')} ${Translate.get('standLabel').toLowerCase()}';
                                    }
                                    return null;
                                  },
                                  builder: (formState) {
                                    final gallery =
                                        Translate.get('standOptionGallery');
                                    final main =
                                        Translate.get('standOptionMain');
                                    return DropdownButtonFormField<String>(
                                      value: _standController.text.isEmpty
                                          ? null
                                          : _standController.text,
                                      items: <String>[gallery, main]
                                          .map((value) =>
                                              DropdownMenuItem<String>(
                                                value: value,
                                                child: Text(value),
                                              ))
                                          .toList(),
                                      onChanged: (value) {
                                        setState(() {
                                          _standController.text = value ?? '';
                                          formState
                                              .didChange(_standController.text);
                                        });
                                      },
                                      decoration: InputDecoration(
                                        fillColor: AppColors().cardColor,
                                        filled: true,
                                        labelText: Translate.get('standLabel'),
                                        hintText: Translate.get('standHint'),
                                        labelStyle: const TextStyle(
                                          color: AppColors.primaryColor,
                                        ),
                                        hintStyle:
                                            CustomTextStyle.size14Weight400Text(
                                          AppColors().secondaryTextColor,
                                        ),
                                        enabledBorder:
                                            AppStyles().defaultEnabledBorder,
                                        focusedBorder:
                                            AppStyles.defaultFocusedBorder(),
                                        errorText: formState.errorText,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _buildTextField(
                                controller: _areaController,
                                label:
                                    '${Translate.get('areaLabel')} (${Translate.get('optional')})',
                                hint:
                                    '${Translate.get('areaHint')} (${Translate.get('optional')})',
                                icon: Icons.category_outlined,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildTextField(
                                controller: _rowController,
                                label: Translate.get('rowLabel'),
                                hint: Translate.get('rowHint'),
                                icon: Icons.view_week_outlined,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
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
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildTextField(
                                controller: _entranceController,
                                label: Translate.get('entranceLabel'),
                                hint: Translate.get('entranceHint'),
                                icon: Icons.info_outline,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: _seatDetailsController,
                          label: Translate.get('additionalDetailsLabel'),
                          hint: Translate.get('additionalDetailsHint'),
                          icon: Icons.info_outline,
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

                                      // Check if user is logged in
                                      final currentUser =
                                          FirebaseAuth.instance.currentUser;
                                      if (currentUser == null) {
                                        // Show login/signup dialog
                                        _showAuthDialog(context);
                                      } else {
                                        // Check if image is selected
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

                                            // Create seat info with uploaded image URL
                                            final seatInfo = {
                                              'ticketImage': uploadedImageUrl,
                                              'row': '',
                                              'seatNo': '',
                                              'stand': '',
                                              'entrance': '',
                                              'area': '',
                                              'seatDetails': '',
                                            };

                                            makePayment(OrderRepository.total,
                                                seatInfo);
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
                                          final seatInfo = {
                                            'ticketImage': '',
                                            'row': _rowController.text,
                                            'seatNo': _seatNoController.text,
                                            'area': _areaController.text,
                                            'entrance':
                                                _entranceController.text,
                                            'stand': _standController.text,
                                            'seatDetails':
                                                _seatDetailsController.text,
                                          };

                                          makePayment(
                                              OrderRepository.total, seatInfo);
                                          // BlocProvider.of<OrderBloc>(context).add(
                                          //   CreateOrder(
                                          //     seatInfo: seatInfo,
                                          //   ),
                                          // );
                                        }
                                      }
                                    }),
                              ),
                              const SizedBox(height: 12),
                              // Wallet pay buttons
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 30),
                                child: Column(
                                  children: [
                                    ApplePayButton(
                                      onPressed: () async {
                                        // Mirror the same flow as Place Order button
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

                                        final currentUser =
                                            FirebaseAuth.instance.currentUser;
                                        if (currentUser == null) {
                                          _showAuthDialog(context);
                                        } else {
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
                                              final seatInfo = {
                                                'ticketImage': uploadedImageUrl,
                                                'row': '',
                                                'seatNo': '',
                                                'stand': '',
                                                'entrance': '',
                                                'area': '',
                                                'seatDetails': '',
                                              };
                                              await makePayment(
                                                  OrderRepository.total,
                                                  seatInfo);
                                            } catch (_) {
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
                                          } else if (_formKey.currentState!
                                              .validate()) {
                                            final seatInfo = {
                                              'ticketImage': '',
                                              'row': _rowController.text,
                                              'seatNo': _seatNoController.text,
                                              'area': _areaController.text,
                                              'entrance':
                                                  _entranceController.text,
                                              'stand': _standController.text,
                                              'seatDetails':
                                                  _seatDetailsController.text,
                                            };
                                            await makePayment(
                                                OrderRepository.total,
                                                seatInfo);
                                          }
                                        }
                                      },
                                    ),
                                    const SizedBox(height: 8),
                                    GooglePayButton(
                                      onPressed: () async {
                                        // Same flow as Apple Pay button
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

                                        final currentUser =
                                            FirebaseAuth.instance.currentUser;
                                        if (currentUser == null) {
                                          _showAuthDialog(context);
                                        } else {
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
                                              final seatInfo = {
                                                'ticketImage': uploadedImageUrl,
                                                'row': '',
                                                'seatNo': '',
                                                'stand': '',
                                                'entrance': '',
                                                'area': '',
                                                'seatDetails': '',
                                              };
                                              await makePayment(
                                                  OrderRepository.total,
                                                  seatInfo);
                                            } catch (_) {
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
                                          } else if (_formKey.currentState!
                                              .validate()) {
                                            final seatInfo = {
                                              'ticketImage': '',
                                              'row': _rowController.text,
                                              'seatNo': _seatNoController.text,
                                              'area': _areaController.text,
                                              'entrance':
                                                  _entranceController.text,
                                              'stand': _standController.text,
                                              'seatDetails':
                                                  _seatDetailsController.text,
                                            };
                                            await makePayment(
                                                OrderRepository.total,
                                                seatInfo);
                                          }
                                        }
                                      },
                                    ),
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

  Future<void> makePayment(double total, Map<String, String> seatInfo) async {
    try {
      // STEP 1: Create Payment Intent
      paymentIntent = await createPaymentIntent(
        total.toString(),
        'ils',
      );


      await Stripe.instance
          .initPaymentSheet(
            paymentSheetParameters: SetupPaymentSheetParameters(
              paymentIntentClientSecret: (paymentIntent?['clientSecret'] ?? paymentIntent?['client_secret']) as String,
              style: ThemeMode.dark,
              merchantDisplayName: 'Fan Munch',
              // Only enable Apple Pay on iOS to avoid assertion when merchantIdentifier isn't configured
              applePay: Platform.isIOS
                  ? const PaymentSheetApplePay(
                      merchantCountryCode: 'IL',
                    )
                  : null,
              // Only enable Google Pay on Android
              googlePay: Platform.isAndroid
                  ? PaymentSheetGooglePay(
                      merchantCountryCode: 'US',
                      testEnv: true,
                      buttonType: PlatformButtonType.book,
                    )
                  : null,
            ),
          )
          .then((value) {});

      // STEP 3: Display Payment sheet
      displayPaymentSheet(seatInfo);
    } catch (err) {
      throw Exception(err);
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
      // Print client-side split for debugging
      // ignore: avoid_print
      print('[PAYMENT] Client-side split: ' + jsonEncode(split));

      final response = await http.post(
        Uri.parse('https://fans-munch-app-2-22c94417114b.herokuapp.com/api/stripe/create-intent'),
        headers: const {'Content-Type': 'application/json'},
        body: jsonEncode({
          'amount': amountMajor,
          'currency': 'ils',
          'vendorConnectedAccountId': 'acct_1S570jKWPD2pzAyo',
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
      if (response.statusCode >= 400 || (data is Map && data['success'] == false)) {
        throw Exception((data is Map ? data['error'] : null) ?? 'Failed to create payment intent');
      }
      // Server returns { success, intentId, clientSecret, mode }
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

  Future<void> displayPaymentSheet(Map<String, String> seatInfo) async {
    try {
      await Stripe.instance.presentPaymentSheet().then((value) {
        // Create order after successful payment
        BlocProvider.of<OrderBloc>(context).add(
          CreateOrder(
            seatInfo: seatInfo,
          ),
        );

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
                  "Amount: ${CurrencyService.getCurrencySymbol(CurrencyService.getCurrentCurrency())}${OrderRepository.total.toStringAsFixed(2)}",
                  style: CustomTextStyle.size16Weight400Text(),
                ),
              ],
            ),
          ),
        );

        paymentIntent = null;
        Future.delayed(const Duration(seconds: 2), () {
          Navigator.of(context, rootNavigator: true).pop(); // Close dialog
          Navigator.pushNamedAndRemoveUntil(
            context,
            "/home",
            (route) => false,
          );
        });
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
