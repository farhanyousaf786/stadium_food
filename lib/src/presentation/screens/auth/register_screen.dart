import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stadium_food/src/bloc/register/register_bloc.dart';
import 'package:stadium_food/src/core/translations/translate.dart';
import 'package:stadium_food/src/presentation/screens/auth/privacy_policy_screen.dart';
import 'package:stadium_food/src/presentation/widgets/loading_indicator.dart';
import 'package:stadium_food/src/presentation/widgets/buttons/primary_button.dart';
import 'package:stadium_food/src/presentation/utils/app_colors.dart';
import 'package:stadium_food/src/presentation/utils/app_styles.dart';
import 'package:stadium_food/src/presentation/utils/custom_text_style.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  bool hidePassword = true;
  bool _privacyPolicyAccepted = false;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      body: BlocListener<RegisterBloc, RegisterState>(
        listener: (context, state) {
          if (state is RegisterSuccess) {
            Navigator.pop(context);
            Navigator.pushNamedAndRemoveUntil(
              context,
              "/register/process",
              (route) => false,
            );
          }

          if (state is RegisterError) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: AppColors.errorColor,
                content: Text(state.error),
              ),
            );
          }

          if (state is RegisterLoading) {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) {
                return const LoadingIndicator();
              },
            );
          }
        },
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Header (match login)
              SizedBox(
                height: 350,
                width: double.infinity,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(
                      'assets/png/login_img.png',
                      fit: BoxFit.fill,
                    ),
                    Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            Translate.get('register_title'),
                            style: CustomTextStyle.size20Weight600Text().copyWith(
                              color: Colors.white,
                              fontSize: 24,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(

                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.5),
                              shape: BoxShape.circle,
                              // borderRadius: BorderRadius.all(Radius.circular(10)),
                              border: Border.all(
                                  color: Colors.white.withOpacity(0.6)),
                              boxShadow: [AppStyles.boxShadow7],
                            ),
                            child:  Image.asset(
                              'assets/png/logo.png',
                              width: 120,
                              height: 120,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Form + actions
              Padding(
                padding: const EdgeInsets.all(25.0),
                child: Column(
                  children: [
                    Form(
                      child: Column(
                        children: [
                          // Email label
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              Translate.get('email'),
                              style: CustomTextStyle
                                  .size14Weight400Text()
                                  .copyWith(color: Colors.black87),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [AppStyles.boxShadow7],
                            ),
                            child: TextFormField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              decoration: InputDecoration(
                                prefixIcon: const Icon(
                                  Icons.mail_rounded,
                                  color: AppColors.primaryDarkColor,
                                ),
                                fillColor: AppColors().cardColor,
                                filled: true,
                                hintText:
                                    Translate.get('register_email_hint'),
                                hintStyle: CustomTextStyle
                                    .size14Weight400Text()
                                    .copyWith(color: Colors.grey),
                                border: OutlineInputBorder(
                                  borderSide: BorderSide.none,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide.none,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                      color: Color(0xFF4169E1), width: 1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          // Password label
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              Translate.get('password'),
                              style: CustomTextStyle
                                  .size14Weight400Text()
                                  .copyWith(color: Colors.black87),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [AppStyles.boxShadow7],
                            ),
                            child: TextFormField(
                              controller: _passwordController,
                              obscureText: hidePassword,
                              decoration: InputDecoration(
                                prefixIcon: const Icon(
                                  Icons.lock_rounded,
                                  color: AppColors.primaryDarkColor,
                                ),
                                fillColor: AppColors().cardColor,
                                filled: true,
                                hintText:
                                    Translate.get('register_password_hint'),
                                hintStyle: CustomTextStyle
                                    .size14Weight400Text()
                                    .copyWith(color: Colors.grey),
                                border: OutlineInputBorder(
                                  borderSide: BorderSide.none,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    hidePassword
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                    color: AppColors.primaryDarkColor,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      hidePassword = !hidePassword;
                                    });
                                  },
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide.none,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                      color: Color(0xFF4169E1), width: 1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Checkbox(
                          value: _privacyPolicyAccepted,
                          activeColor: AppColors.primaryColor,
                          checkColor: Colors.white,
                          shape: const CircleBorder(),
                          side: BorderSide(
                            color: AppColors.primaryColor,
                            width: 2,
                          ),
                          onChanged: (value) {
                            setState(() {
                              _privacyPolicyAccepted = value ?? false;
                            });
                          },
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const PrivacyPolicyScreen(),
                                ),
                              );
                            },
                            child: Text(
                              Translate.get('register_privacy_policy'),
                              style: CustomTextStyle.size14Weight400Text(),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 30),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 60),
                      child: PrimaryButton(
                        text: Translate.get('register_button'),
                        onTap: () {
                          // print email and password
                          debugPrint(_emailController.text.trim());
                          debugPrint(_passwordController.text);

                          // Validate
                          if (_emailController.text.trim().isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                backgroundColor: AppColors.errorColor,
                                content: Text(Translate.get(
                                    'register_error_email_required')),
                              ),
                            );
                            return;
                          }
                          if (_passwordController.text.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                backgroundColor: AppColors.errorColor,
                                content: Text(Translate.get(
                                    'register_error_password_required')),
                              ),
                            );
                            return;
                          }
                          if (!_privacyPolicyAccepted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                backgroundColor: AppColors.errorColor,
                                content: Text(Translate.get(
                                    'register_error_privacy_policy')),
                              ),
                            );
                            return;
                          }

                          // Submit
                          BlocProvider.of<RegisterBloc>(context).add(
                            RegisterSubmitted(
                              email: _emailController.text.trim(),
                              password: _passwordController.text,
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 50),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          Translate.get('register_have_account'),
                          style: CustomTextStyle.size14Weight400Text(),
                        ),
                        const SizedBox(width: 4),
                        GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(context, '/login');
                          },
                          child: ShaderMask(
                            shaderCallback: (bounds) => LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: AppColors.primaryGradient,
                            ).createShader(bounds),
                            blendMode: BlendMode.srcIn,
                            child: Text(
                              Translate.get('register_login_now'),
                              style: CustomTextStyle.size14Weight400Text()
                                  .copyWith(
                                /* decoration: TextDecoration.underline,*/
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
