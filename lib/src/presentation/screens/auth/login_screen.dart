import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:stadium_food/src/bloc/login/login_bloc.dart';
import 'package:stadium_food/src/core/translations/translate.dart';
import 'package:stadium_food/src/presentation/screens/auth/privacy_policy_screen.dart';
import 'package:stadium_food/src/presentation/widgets/buttons/primary_button.dart';
import 'package:stadium_food/src/presentation/widgets/loading_indicator.dart';
import 'package:stadium_food/src/presentation/utils/app_colors.dart';
import 'package:stadium_food/src/presentation/utils/app_styles.dart';
import 'package:stadium_food/src/presentation/utils/custom_text_style.dart';

class LoginScreen extends StatefulWidget {
  final String? returnRoute;
  const LoginScreen({super.key, this.returnRoute});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool hidePassword = true;
  bool _privacyPolicyAccepted = false;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _fcmToken = '';

  @override
  void initState() {
    super.initState();
    // Get FCM token
    FirebaseMessaging.instance.getToken().then((token) {
      if (token != null) {
        _fcmToken = token;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      body: BlocListener<LoginBloc, LoginState>(
        listener: (context, state) {
          if (state is LoginSuccess) {
            Navigator.pop(context);
            if (widget.returnRoute != null) {
              Navigator.pop(context);
            } else {
              // Default flow: show stadium selection then home
              Navigator.pushNamed(context, '/select-stadium').then((_) {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/home',
                  (route) => false,
                );
              });
            }
          }

          if (state is LoginError) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: AppColors.errorColor,
                content: Text(state.error),
              ),
            );
          }

          if (state is LoginLoading) {
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
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).padding.top + 50,
                      ),
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 20,
                              spreadRadius: 5,
                            ),
                          ],
                          image: DecorationImage(
                            image: AssetImage("assets/png/logo.png"),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(height: 60),
                      Text(
                        Translate.get('login_title'),
                        style: CustomTextStyle.size20Weight600Text(),
                      ),
                      const SizedBox(height: 40),
                      Form(
                        child: Column(
                          children: [
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
                                  hintText: Translate.get('login_email_hint'),
                                  hintStyle:
                                      CustomTextStyle.size14Weight400Text()
                                          .copyWith(
                                    color: Colors.grey,
                                  ),
                                  border: InputBorder.none,
                                  enabledBorder:
                                      AppStyles().defaultEnabledBorder,
                                  focusedBorder:
                                      AppStyles.defaultFocusedBorder(),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            Container(
                              height: AppStyles.defaultTextFieldHeight,
                              decoration: BoxDecoration(
                                boxShadow: [AppStyles.boxShadow7],
                              ),
                              child: TextFormField(
                                controller: _passwordController,
                                obscureText: hidePassword,
                                decoration: InputDecoration(
                                  fillColor: AppColors().cardColor,
                                  filled: true,
                                  hintText:
                                      Translate.get('login_password_hint'),
                                  hintStyle:
                                      CustomTextStyle.size14Weight400Text()
                                          .copyWith(
                                    color: Colors.grey,
                                  ),
                                  border: InputBorder.none,
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      hidePassword
                                          ? Icons.visibility_off
                                          : Icons.visibility,
                                      color: Colors.grey,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        hidePassword = !hidePassword;
                                      });
                                    },
                                  ),
                                  enabledBorder:
                                      AppStyles().defaultEnabledBorder,
                                  focusedBorder:
                                      AppStyles.defaultFocusedBorder(),
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
                                Translate.get('login_privacy_policy'),
                                style: CustomTextStyle.size14Weight400Text(),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      TextButton(
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            "/login/forgot-password",
                          );
                        },
                        child: ShaderMask(
                          shaderCallback: (bounds) => LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: AppColors.primaryGradient,
                          ).createShader(bounds),
                          blendMode: BlendMode.srcIn,
                          child: Text(
                            Translate.get('login_forgot_password'),
                            style:
                                CustomTextStyle.size14Weight400Text().copyWith(
                                    // decoration: TextDecoration.underline,
                                    ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: PrimaryButton(
                          text: Translate.get('login_button'),
                          onTap: () {
                            if (_emailController.text.trim().isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  backgroundColor: AppColors.errorColor,
                                  content: Text(Translate.get(
                                      'login_error_email_required')),
                                ),
                              );
                              return;
                            }
                            if (_passwordController.text.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  backgroundColor: AppColors.errorColor,
                                  content: Text(Translate.get(
                                      'login_error_password_required')),
                                ),
                              );
                              return;
                            }
                            if (!_privacyPolicyAccepted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  backgroundColor: AppColors.errorColor,
                                  content: Text(Translate.get(
                                      'login_error_privacy_policy')),
                                ),
                              );
                              return;
                            }
                            debugPrint(_emailController.text.trim());
                            debugPrint(_passwordController.text);
                            BlocProvider.of<LoginBloc>(context).add(
                              LoginSubmitted(
                                email: _emailController.text.trim(),
                                password: _passwordController.text,
                                fcmToken: _fcmToken,
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            Translate.get('login_no_account'),
                            style: CustomTextStyle.size14Weight400Text(),
                          ),
                          const SizedBox(width: 4),
                          GestureDetector(
                            onTap: () {
                              Navigator.pushNamed(context, '/register');
                            },
                            child: ShaderMask(
                              shaderCallback: (bounds) => LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: AppColors.primaryGradient,
                              ).createShader(bounds),
                              blendMode: BlendMode.srcIn,
                              child: Text(
                                Translate.get('login_register_now'),
                                style: CustomTextStyle.size14Weight400Text()
                                    .copyWith(
                                        // decoration: TextDecoration.underline,
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
      ),
    );
  }
}
