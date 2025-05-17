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
import 'package:stadium_food/src/presentation/utils/app_styles.dart';
import 'package:stadium_food/src/presentation/utils/custom_text_style.dart';
import 'package:hive/hive.dart';

class OrderConfirmScreen extends StatefulWidget {

   const OrderConfirmScreen({super.key});

  @override
  State<OrderConfirmScreen> createState() => _OrderConfirmScreenState();
}

class _OrderConfirmScreenState extends State<OrderConfirmScreen> {
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
          Navigator.of(context).pushNamedAndRemoveUntil(
            "/order/review",
            arguments: state.order,
            (route) => false,
          );
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
                BlocProvider.of<OrderBloc>(context).add(
                  CreateOrder(),
                );
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
                  const SizedBox(height: 20),

                  // delivery address
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 15,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors().cardColor,
                      borderRadius: AppStyles.largeBorderRadius,
                      boxShadow: [AppStyles.boxShadow7],
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Delivery Address",
                              style: CustomTextStyle.size16Weight400Text(
                                AppColors().secondaryTextColor,
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                // Navigator.of(context)
                                //     .push(
                                //       MaterialPageRoute(
                                //         builder: (context) =>
                                //             const SetLocationMapScreen(),
                                //       ),
                                //     )
                                //     .then(
                                //       (value) => BlocProvider.of<OrderBloc>(
                                //               context)
                                //           .add(
                                //         UpdateUI(),
                                //       ),
                                //     );
                              },
                              child: Text(
                                "Edit",
                                style: CustomTextStyle.size16Weight600Text(
                                  AppColors.primaryColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SvgPicture.asset(
                              "assets/svg/map-pin.svg",
                            ),
                            const SizedBox(width: 14),
                            BlocBuilder<OrderBloc, OrderState>(
                              builder: (context, state) {
                                return Expanded(
                                  child: Text(
                                    "New York",
                                    style: CustomTextStyle
                                        .size16Weight400Text(),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // payment method
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 15,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors().cardColor,
                      borderRadius: AppStyles.largeBorderRadius,
                      boxShadow: [AppStyles.boxShadow7],
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Payment Method",
                              style: CustomTextStyle.size16Weight400Text(
                                AppColors().secondaryTextColor,
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                buildDialog(context).then(
                                  (value) =>
                                      BlocProvider.of<OrderBloc>(context)
                                          .add(
                                    UpdateUI(),
                                  ),
                                );
                              },
                              child: Text(
                                "Edit",
                                style: CustomTextStyle.size16Weight600Text(
                                  AppColors.primaryColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        BlocBuilder<OrderBloc, OrderState>(
                          builder: (context, state) {
                            return Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                SvgPicture.asset(
                                  Hive.box("myBox").get("paymentMethod") ==
                                          "paypal"
                                      ? "assets/svg/paypal.svg"
                                      : "assets/svg/visa.svg",
                                ),
                                const SizedBox(width: 14),
                                BlocBuilder<OrderBloc, OrderState>(
                                  builder: (context, state) {
                                    return Text(
                                      "2121 6352 8465 ****",
                                      style: CustomTextStyle
                                          .size16Weight400Text(),
                                    );
                                  },
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

   Future<void> makePayment() async {
     try {
       //STEP 1: Create Payment Intent
       paymentIntent = await createPaymentIntent('100', 'USD');

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
       displayPaymentSheet();
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
           'Authorization': 'Bearer STRIPE_SECRET',
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
     final calculatedAmout = (int.parse(amount)) * 100;
     return calculatedAmout.toString();
   }
   displayPaymentSheet() async {
     try {
       await Stripe.instance.presentPaymentSheet().then((value) {
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
