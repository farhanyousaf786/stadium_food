import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:stadium_food/src/bloc/forgot_password/forgot_password_bloc.dart';
import 'package:stadium_food/src/core/translations/translate.dart';
import 'package:stadium_food/src/presentation/utils/app_colors.dart';
import 'package:stadium_food/src/presentation/utils/app_styles.dart';
import 'package:stadium_food/src/presentation/utils/custom_text_style.dart';
import 'package:stadium_food/src/presentation/widgets/buttons/back_button.dart';
import 'package:stadium_food/src/presentation/widgets/buttons/primary_button.dart';
import 'package:stadium_food/src/presentation/widgets/loading_indicator.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return BlocListener<ForgotPasswordBloc, ForgotPasswordState>(
      listener: (context, state) {
        if (state is ForgotPasswordLoading) {
          showDialog(
            context: context,
            builder: (_) => const LoadingIndicator(),
          );
        }
        if (state is ForgotPasswordSuccess) {
          Navigator.pop(context);
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.primaryColor,
            ),
          );
        }
        if (state is ForgotPasswordFailure) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.error),
              backgroundColor: AppColors.errorColor,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.bgColor,
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.only(
            bottom: 60,
            left: 25,
            right: 25,
          ),
          child: PrimaryButton(
            text: Translate.get('forgot_password_send_button'),
            onTap: () {
              BlocProvider.of<ForgotPasswordBloc>(context).add(
                SendResetPasswordLink(
                  email: _emailController.text,
                ),
              );
            },
          ),
        ),
        body: Stack(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: SvgPicture.asset(
                "assets/svg/pattern-small.svg",
              ),
            ),
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).padding.top + 40,
                    ),
                    const CustomBackButton(),
                    const SizedBox(height: 20),
                    Text(
                      Translate.get('forgot_password_title'),
                      style: CustomTextStyle.size25Weight600Text(),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      Translate.get('forgot_password_description'),
                      style: CustomTextStyle.size14Weight400Text(),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      height: AppStyles.defaultTextFieldHeight,
                      decoration: BoxDecoration(
                        boxShadow: [AppStyles.boxShadow7],
                      ),
                      child: TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          fillColor: AppColors().cardColor,
                          filled: true,
                          hintText: Translate.get('forgot_password_email_hint'),
                          hintStyle: CustomTextStyle.size14Weight400Text(
                            AppColors().secondaryTextColor,
                          ),
                          enabledBorder: AppStyles().defaultEnabledBorder,
                          focusedBorder: AppStyles.defaultFocusedBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
