import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:stadium_food/src/bloc/order/order_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:stadium_food/src/presentation/widgets/buttons/back_button.dart';
import 'package:stadium_food/src/presentation/widgets/loading_indicator.dart';
import 'package:stadium_food/src/presentation/widgets/price_info_widget.dart';
import 'package:stadium_food/src/presentation/utils/app_colors.dart';
import 'package:stadium_food/src/presentation/utils/custom_text_style.dart';
import 'package:hive/hive.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:google_ml_kit/google_ml_kit.dart' as ml_kit;

import '../../../data/repositories/order_repository.dart';
import '../../../data/services/firebase_storage.dart';
import '../../utils/app_styles.dart';

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
          labelStyle: const TextStyle(
            color: AppColors.primaryColor
          ),
          hintStyle:
          CustomTextStyle.size14Weight400Text(
            AppColors().secondaryTextColor,
          ),
          enabledBorder:
          AppStyles().defaultEnabledBorder,
          focusedBorder:
          AppStyles.defaultFocusedBorder(),
        ),

        validator: (value) {
          if (value == null || value.isEmpty) {
            if (controller == _seatDetailsController) return null; // Optional field
            return 'Please enter $label';
          }
          return null;
        },
      ),
    );
  }
  final _formKey = GlobalKey<FormState>();
  final _rowController = TextEditingController();
  final _seatNoController = TextEditingController();
  final _sectionController = TextEditingController();
  final _seatDetailsController = TextEditingController();

   Map<String, dynamic>? paymentIntent;
  XFile? _image;
  String imageUrl='';

  Future<void> _processTicketImage(XFile image) async {
    final inputImage = ml_kit.InputImage.fromFilePath(image.path);
    final textRecognizer = ml_kit.TextRecognizer(script: ml_kit.TextRecognitionScript.latin);

    try {
      final ml_kit.RecognizedText recognizedText = await textRecognizer.processImage(inputImage);
      
      // Process each block of text to find seat information
      for (ml_kit.TextBlock block in recognizedText.blocks) {
        String text = block.text.toLowerCase();
        
        // Look for common patterns in ticket text
        if (text.contains('SEC')) {
          _sectionController.text = _extractValue(text, 'SEC');
        }
        if (text.contains('ROW')) {
          _rowController.text = _extractValue(text, 'ROW');
        }
        if (text.contains('SEAT')) {
          _seatNoController.text = _extractValue(text, 'SEAT');
        }
      }

      setState(() {});
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error processing ticket image. Please try again or enter details manually.'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      textRecognizer.close();
    }
  }

  String _extractValue(String text, String field) {
    // Remove the field name and any common separators
    text = text.replaceAll(field, '').trim();
    text = text.replaceAll(':', '').replaceAll('#', '').trim();
    
    // Split by spaces and get the first word (likely the number/value we want)
    final parts = text.split(' ');
    return parts.isNotEmpty ? parts[0].toUpperCase() : '';
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
  Widget build(BuildContext context) {
    return BlocListener<OrderBloc, OrderState>(
      listener: (context, state) {
        if (state is OrderCreated) {
          // remove loading
          Navigator.of(context).pop();
          // show success message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Order created successfully"),
              backgroundColor: AppColors.primaryColor,
            ),
          );
          // Navigator.of(context).pushNamedAndRemoveUntil(
          //   "/order/review",
          //   arguments: state.order,
          //   (route) => false,
          // );
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
        bottomNavigationBar: BlocBuilder<OrderBloc, OrderState>(
          builder: (context, state) {
            return PriceInfoWidget(
              onTap: () async {
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
                    final uploadedImageUrl = await _firebaseStorageService.uploadImage(
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
                      'section': '',
                      'seatDetails': '',
                    };
                    
                    final total = OrderRepository.total;
                    makePayment(total, seatInfo);
                  } catch (e) {
                    // Hide loading
                    Navigator.of(context).pop();
                    
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Failed to upload image. Please try again.'),
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
                    'section': _sectionController.text,
                    'seatDetails': _seatDetailsController.text,
                  };

                  final total = OrderRepository.total;
                  makePayment(total, seatInfo);
                }
              },
            );
          },
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CustomBackButton(),
                  const SizedBox(height: 20),
                  Text(
                    "Confirm Order",
                    style: CustomTextStyle.size25Weight600Text(),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Please enter your seat details for delivery",
                    style: CustomTextStyle.size14Weight400Text(
                      AppColors().secondaryTextColor,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _buildTextField(
                                controller: _sectionController,
                                label: 'Section',
                                hint: 'e.g. A',
                                icon: Icons.category_outlined,
                              ),
                            ),
                            const SizedBox(width: 16),

                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _buildTextField(
                                controller: _rowController,
                                label: 'Row',
                                hint: 'e.g. 5',
                                icon: Icons.view_week_outlined,

                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildTextField(
                                controller: _seatNoController,
                                label: 'Seat No.',
                                hint: 'e.g. 23',
                                icon: Icons.chair_outlined,
                                keyboardType: TextInputType.number,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: _seatDetailsController,
                          label: 'Additional Details (Optional)',
                          hint: 'e.g. Near the stairs',
                          icon: Icons.info_outline,
                          maxLines: 3,
                        ),

                        const SizedBox(height: 20),
                        
                        // OR separator
                        Row(
                          children: [
                            const Expanded(child: Divider(thickness: 1)),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                'OR',
                                style: CustomTextStyle.size14Weight600Text(
                                  AppColors().secondaryTextColor,
                                ),
                              ),
                            ),
                            const Expanded(child: Divider(thickness: 1)),
                          ],
                        ),
                        const SizedBox(height: 20),
                        
                        Text(
                          'Upload ticket image',
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
                                  borderRadius: AppStyles.largeBorderRadius,
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
                                        color: Colors.white.withOpacity(0.5),
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
                              borderRadius: AppStyles.largeBorderRadius,
                            ),
                            child: Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: AppStyles.largeBorderRadius,
                                  child: Image.network(
                                    imageUrl,
                                    width: 250,
                                    height: 250,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
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
                            : Row(
                          children: [
                            Expanded(
                              child: Ink(
                                padding: const EdgeInsets.symmetric(vertical: 20),
                                decoration: BoxDecoration(
                                  color: AppColors().cardColor,
                                  boxShadow: [AppStyles.boxShadow7],
                                  borderRadius: AppStyles.largeBorderRadius,
                                ),
                                child: InkWell(
                                  onTap: () {
                                    _pickImageFromGallery();
                                  },
                                  borderRadius: AppStyles.largeBorderRadius,
                                  child: Column(
                                    mainAxisAlignment:
                                    MainAxisAlignment.center,
                                    children: [
                                      SvgPicture.asset(
                                        "assets/svg/gallery.svg",
                                      ),
                                      const SizedBox(height: 10),
                                      Text(
                                        "From Gallery",
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
                                padding: const EdgeInsets.symmetric(vertical: 20),
                                decoration: BoxDecoration(
                                  color: AppColors().cardColor,
                                  boxShadow: [AppStyles.boxShadow7],
                                  borderRadius: AppStyles.largeBorderRadius,
                                ),
                                child: InkWell(
                                  onTap: () {
                                    _pickImageFromCamera();
                                  },
                                  borderRadius: AppStyles.largeBorderRadius,
                                  child: Column(
                                    mainAxisAlignment:
                                    MainAxisAlignment.center,
                                    children: [
                                      SvgPicture.asset(
                                        "assets/svg/camera.svg",
                                      ),
                                      const SizedBox(height: 10),
                                      Text(
                                        "From Camera",
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
       //STEP 1: Create Payment Intent
       paymentIntent = await createPaymentIntent(total.toString(), 'USD');

       //STEP 2: Initialize Payment Sheet
       await Stripe.instance
           .initPaymentSheet(

           paymentSheetParameters: SetupPaymentSheetParameters(
               paymentIntentClientSecret: paymentIntent![
               'client_secret'], //Gotten from payment intent
               style: ThemeMode.light,
               merchantDisplayName: 'Ikay'))
           .then((value) {});

       //STEP 3: Display Payment sheet
       displayPaymentSheet(seatInfo);
     } catch (err) {
       throw Exception(err);
     }
   }
   createPaymentIntent(String amount, String currency) async {
     try {
       //Request body
       Map<String, dynamic> body = {
         'amount': calculateAmount(amount),
         'currency': currency,
       };

       //Make post request to Stripe
       var response = await http.post(
         Uri.parse('https://api.stripe.com/v1/payment_intents'),
         headers: {
           'Authorization': 'Bearer sk_test_51QvCefKdX3OWUtfrEgTAjqz3l7IUOE1owMd1oiUkw4TIQPYwfPBfiKT1DxaUjN5VcU43hGlfHwpHJ1wCliZe7LC400S8CyD9us',
           'Content-Type': 'application/x-www-form-urlencoded'
         },
         body: body,
       );
       return json.decode(response.body);
     } catch (err) {
       throw Exception(err.toString());
     }
   }
   calculateAmount(String amount) {
     final doubleAmount = double.parse(amount);
     final intAmount = (doubleAmount * 100).round(); // Rounds to nearest cent
     return intAmount.toString();
   }
   displayPaymentSheet(Map<String, String> seatInfo) async {
     try {
       await Stripe.instance.presentPaymentSheet().then((value) {
         BlocProvider.of<OrderBloc>(context).add(
           CreateOrder(seatInfo: seatInfo),
         );

         showDialog(
             context: context,
             builder: (_) => const AlertDialog(
               content: Column(
                 mainAxisSize: MainAxisSize.min,
                 children: [
                   Icon(
                     Icons.check_circle,
                     color: Colors.green,
                     size: 100.0,
                   ),
                   SizedBox(height: 10.0),
                   Text("Payment Successful!"),
                 ],
               ),
             ));

         paymentIntent = null;
         Future.delayed(const Duration(seconds: 1), () {
           Navigator.of(context, rootNavigator: true).pop(); // Close dialog
           Navigator.pushNamedAndRemoveUntil(
             context,
             "/home",
                 (route) => false,
           ); // Go to home screen
         });
       }).onError((error, stackTrace) {
         throw Exception(error);
       });
     } on StripeException catch (e) {
       print('Error is:---> $e');
       const AlertDialog(
         content: Column(
           mainAxisSize: MainAxisSize.min,
           children: [
             Row(
               children: [
                 Icon(
                   Icons.cancel,
                   color: Colors.red,
                 ),
                 Text("Payment Failed"),
               ],
             ),
           ],
         ),
       );
     } catch (e) {
       print('$e');
     }
   }
}



buildDialog(BuildContext context) {
  return showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(
          "Select Payment Method",
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
