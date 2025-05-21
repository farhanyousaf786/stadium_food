import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:flutter_svg/svg.dart';
import 'package:stadium_food/src/bloc/order/order_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:stadium_food/src/presentation/widgets/buttons/back_button.dart';
import 'package:stadium_food/src/presentation/widgets/loading_indicator.dart';
import 'package:stadium_food/src/presentation/widgets/price_info_widget.dart';
import 'package:stadium_food/src/presentation/utils/app_colors.dart';

import 'package:stadium_food/src/presentation/utils/custom_text_style.dart';
import 'package:hive/hive.dart';

import '../../../data/repositories/order_repository.dart';
import '../../utils/app_styles.dart';

class OrderConfirmScreen extends StatefulWidget {

   const OrderConfirmScreen({super.key});

  @override
  State<OrderConfirmScreen> createState() => _OrderConfirmScreenState();
}

class _OrderConfirmScreenState extends State<OrderConfirmScreen> {
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
  final _roofNoController = TextEditingController();
  final _rowController = TextEditingController();
  final _seatNoController = TextEditingController();
  final _sectionController = TextEditingController();
  final _seatDetailsController = TextEditingController();

   Map<String, dynamic>? paymentIntent;

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
        bottomNavigationBar: BlocBuilder<OrderBloc, OrderState>(
          builder: (context, state) {
            return PriceInfoWidget(
              onTap: () {
                if (_formKey.currentState!.validate()) {
                  // Create seat info map
                  final seatInfo = {
                    'roofNo': _roofNoController.text,
                    'row': _rowController.text,
                    'seatNo': _seatNoController.text,
                    'section': _sectionController.text,
                    'seatDetails': _seatDetailsController.text,
                  };

                final total=  OrderRepository.total;
                  makePayment(total,seatInfo);
                 

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
                            Expanded(
                              child: _buildTextField(
                                controller: _roofNoController,
                                label: 'Roof No.',
                                hint: 'e.g. 1',
                                icon: Icons.roofing_outlined,
                                keyboardType: TextInputType.number,
                              ),
                            ),
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
