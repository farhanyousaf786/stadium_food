import 'dart:convert';
import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';

import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:stadium_food/src/bloc/order/order_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:stadium_food/src/presentation/widgets/buttons/back_button.dart';
import 'package:stadium_food/src/presentation/widgets/loading_indicator.dart';
import 'package:stadium_food/src/presentation/widgets/price_info_widget.dart';
import 'package:stadium_food/src/presentation/utils/app_colors.dart';
import 'package:stadium_food/src/presentation/utils/custom_text_style.dart';
import 'package:stadium_food/src/core/translations/translate.dart';
import 'package:hive/hive.dart';

import 'package:firebase_storage/firebase_storage.dart';

import '../../../data/repositories/order_repository.dart';
import '../../../data/services/firebase_storage.dart';
import '../../../data/services/currency_service.dart';
import '../../utils/app_styles.dart';
import '../../widgets/buttons/primary_button.dart';


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
            if (controller == _seatDetailsController)
              return null; // Optional field
            return 'Please enter ${label.toLowerCase()}';
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

  Future<void> _processTicketImage(XFile image) async {
    final apiKey = 'AIzaSyAFZnhuiVzNJZeq5lmzw2-jgdeWQ3BxXaM';

    // Convert image to base64
    final base64Image = base64Encode(await File(image.path).readAsBytes());

    // API URL
    final url = Uri.parse(
        'https://vision.googleapis.com/v1/images:annotate?key=$apiKey');

    // Request body
    final body = jsonEncode({
      "requests": [
        {
          "image": {"content": base64Image},
          "features": [
            {
              "type": "TEXT_DETECTION"
            } // You can also try DOCUMENT_TEXT_DETECTION
          ]
        }
      ]
    });

    // Send request
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: body,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final text = data['responses'][0]['fullTextAnnotation']?['text'] ?? '';
      print("Extracted Text:\n$text");
      String cleanText = text
          .replaceAll('\n', ' ') // Replace newlines with space
          .replaceAll(RegExp(r'[^a-zA-Z0-9\s]'), '') // Remove special chars
          .toLowerCase();

      final seatRegex = RegExp(
        r"seat\s+\w{1,3}",
        caseSensitive: false,
      );
      final seatMatch = seatRegex.firstMatch(cleanText);
      if (seatMatch != null) {
        print("Seat Number: ${seatMatch.group(2)}");
      } else {
        print("Seat not found");
      }
    } else {
      print("Error: ${response.body}");
    }
  }

  // pick image from gallery
  Future<void> _pickImageFromGallery() async {
    _image = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 30,
    );

    if (_image != null) {
      await _processTicketImage(_image!);
    }

    setState(() {});
  }

  // pick image from camera
  Future<void> _pickImageFromCamera() async {
    _image = await ImagePicker().pickImage(
      source: ImageSource.camera,
      imageQuality: 30,
    );

    if (_image != null) {
      await _processTicketImage(_image!);
    }

    setState(() {});
  }

  @override
  void initState() {
    super.initState();
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

        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CustomBackButton(color: AppColors.primaryDarkColor,),
                  const SizedBox(height: 24),
                  Text(
                    Translate.get('orderConfirmTitle'),
                    style: CustomTextStyle.size18Weight600Text(),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    Translate.get('orderConfirmSubtitle'),
                    style: CustomTextStyle.size14Weight400Text(
                      AppColors().secondaryTextColor,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        Text(
                          Translate.get('uploadTicketTitle'),
                          style: CustomTextStyle.size14Weight400Text(
                            AppColors().secondaryTextColor,
                          ),
                        ),
                        const SizedBox(height: 16),

                        _image != null
                            ? Center(
                                child: Container(
                                  width: 250,
                                  height: 250,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    boxShadow: [AppStyles.boxShadow7],
                                    borderRadius: AppStyles.largeBorderRadius,
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
                                              color:
                                                  Colors.white.withOpacity(0.5),
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
                                        color: Colors.white,
                                        boxShadow: [AppStyles.boxShadow7],
                                        borderRadius:
                                            AppStyles.largeBorderRadius,
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
                                        child: Ink(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 20),
                                          decoration: BoxDecoration(
                                            color: AppColors().cardColor,
                                            boxShadow: [AppStyles.boxShadow7],
                                            borderRadius:
                                                AppStyles.largeBorderRadius,
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
                                                      .size14Weight400Text(),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 20),
                                      // from camera
                                      Expanded(
                                        child: Ink(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 20),
                                          decoration: BoxDecoration(
                                            color: AppColors().cardColor,
                                            boxShadow: [AppStyles.boxShadow7],
                                            borderRadius:
                                                AppStyles.largeBorderRadius,
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
                                                  Translate.get('frontCamera'),
                                                  style: CustomTextStyle
                                                      .size14Weight400Text(),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),

                                      const SizedBox(height: 20),
                                    ],
                                  ),
                        const SizedBox(height: 20),

                        // OR separator
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
                              child: _buildTextField(
                                controller: _standController,
                                label: Translate.get('standLabel'),
                                hint: Translate.get('standHint'),
                                icon: Icons.chair_rounded,
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
                        Row(
                          children: [
                            Expanded(
                              child:
                              _buildTextField(
                                controller: _areaController,
                                label: Translate.get('areaLabel'),
                                hint: Translate.get('areaHint'),
                                icon: Icons.category_outlined,
                              ),


                            ),

                            const SizedBox(width: 16),
                            Expanded(
                              child:
                              _buildTextField(
                                controller: _rowController,
                                label: Translate.get('rowLabel'),
                                hint: Translate.get('rowHint'),
                                icon: Icons.view_week_outlined,
                              ),

                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: _seatNoController,
                          label: Translate.get('seatLabel'),
                          hint: Translate.get('seatHint'),
                          icon: Icons.chair_outlined,
                          keyboardType: TextInputType.number,
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
                            padding: const EdgeInsets.symmetric(horizontal: 30),
                            child: PrimaryButton(
                                text: Translate.get('placeOrder'),
                                onTap: () async {
                                  if (OrderRepository.cart.isEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content:
                                        Text(Translate.get('cartEmpty')),
                                        backgroundColor: AppColors.errorColor,
                                      ),
                                    );
                                    return;
                                  }

                                    // Check if user is logged in
                                    final currentUser = FirebaseAuth.instance.currentUser;
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
                                          builder: (context) => const LoadingIndicator(),
                                        );

                                        try {
                                          // Upload image to firebase storage
                                          final uploadedImageUrl =
                                              await _firebaseStorageService.uploadImage(
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

                                          //  makePayment(OrderRepository.total, seatInfo);
                                          BlocProvider.of<OrderBloc>(context).add(
                                            CreateOrder(
                                              seatInfo: seatInfo,
                                            ),
                                          );
                                        } catch (e) {
                                          // Hide loading
                                          Navigator.of(context).pop();

                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text(Translate.get('imageUploadError')),
                                              backgroundColor: AppColors.errorColor,
                                            ),
                                          );
                                        }
                                      }
                                      // If no image, validate and use text fields
                                      else if (_formKey.currentState!.validate()) {
                                        final seatInfo = {
                                          'ticketImage': '',
                                          'row': _rowController.text,
                                          'seatNo': _seatNoController.text,
                                          'area': _areaController.text,
                                          'entrance': _entranceController.text,
                                          'stand': _standController.text,
                                          'seatDetails': _seatDetailsController.text,
                                        };

                                        //   makePayment(OrderRepository.total, seatInfo);
                                        BlocProvider.of<OrderBloc>(context).add(
                                          CreateOrder(
                                            seatInfo: seatInfo,
                                          ),
                                        );
                                      }

                                  }
                                }),
                          )
                        ],
                      );
                    })


                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> makePayment(double total, Map<String, String> seatInfo) async {
    try {
      // Convert total to USD if needed
      final currentCurrency = CurrencyService.getCurrentCurrency();
      double amountInUSD = total;
      if (currentCurrency != 'USD') {
        amountInUSD = CurrencyService.convertToUSD(total, currentCurrency);
      }

      // STEP 1: Create Payment Intent
      paymentIntent = await createPaymentIntent(
        amountInUSD.toString(),
        'USD', // Always use USD for Stripe
      );

      // STEP 2: Initialize Payment Sheet
      await Stripe.instance
          .initPaymentSheet(
            paymentSheetParameters: SetupPaymentSheetParameters(
              paymentIntentClientSecret: paymentIntent!['client_secret'],
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

  Future createPaymentIntent(String amount, String currency) async {
    try {
      Map<String, dynamic> body = {
        'amount': calculateAmount(amount),
        'currency': 'USD', // Always use USD
        'payment_method_types[]': 'card',
        'description': 'Fan Munch Order',
        'metadata': {
          'original_currency': currency,
          'original_amount': amount,
        }
      };

      var response = await http.post(
        Uri.parse('https://api.stripe.com/v1/payment_intents'),
        headers: {
          'Authorization':
              'Bearer sk_test_51NlxmGFPMwBwVLKDNEYJxJJXZGOqnTvXQwwNhEWpRRlXZJLZKtQvKEfQQpJbhkVNVHzXzuEPXrTFHFZbYQOXJGQf00Vq7HB0Ys',
          'Content-Type': 'application/x-www-form-urlencoded'
        },
        body: body,
      );
      return json.decode(response.body);
    } catch (err) {
      throw Exception(err.toString());
    }
  }

  String calculateAmount(String amount) {
    final doubleAmount = double.parse(amount);
    // Convert to smallest currency unit (cents for USD)
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
