import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stadium_food/src/bloc/login/login_bloc.dart';
import 'package:stadium_food/src/core/translations/translate.dart';
import 'package:stadium_food/src/presentation/screens/auth/privacy_policy_screen.dart';
import 'package:stadium_food/src/data/services/guest_auth_service.dart';
import 'package:stadium_food/src/presentation/widgets/buttons/back_button.dart';
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
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: 300,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    'assets/png/login_img.png',
                    fit: BoxFit.cover,
                  ),
                  // Venue color wash so login matches stadium branding
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AppColors.primaryDarkColor.withOpacity(0.55),
                          AppColors.primaryColor.withOpacity(0.35),
                          Colors.black.withOpacity(0.45),
                        ],
                      ),
                    ),
                  ),
                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: CustomBackButton(
                          color: Colors.black87,
                          backgroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          Translate.get('login_title'),
                          style: CustomTextStyle.size20Weight600Text().copyWith(
                            color: Colors.white,
                            fontSize: 24,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.55),
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: Colors.white.withOpacity(0.7)),
                            boxShadow: [AppStyles.boxShadow7],
                          ),
                          child: Image.asset(
                            'assets/png/logo.png',
                            width: 110,
                            height: 110,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            BlocListener<LoginBloc, LoginState>(
              listener: (context, state) async {
                if (state is LoginSuccess) {
                  Navigator.pop(context); // loading
                  if (widget.returnRoute != null) {
                    // Match web postLoginNext — continue checkout after sign-in
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      widget.returnRoute!,
                      (route) =>
                          route.settings.name == '/home' || route.isFirst,
                    );
                  } else {
                    // Match web: go home if stadium already selected
                    final prefs = await SharedPreferences.getInstance();
                    final hasStadium =
                        (prefs.getString('selected_stadium_id') ?? '').isNotEmpty;
                    if (!context.mounted) return;
                    if (hasStadium) {
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        '/home',
                        (route) => false,
                      );
                    } else {
                      Navigator.pushNamed(context, '/select-stadium').then((_) {
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          '/home',
                          (route) => false,
                        );
                      });
                    }
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Header image with overlay, title and logo

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
                                    style: CustomTextStyle.size14Weight400Text()
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
                                      prefixIcon: Icon(Icons.mail_rounded,
                                          color: AppColors.primaryDarkColor),
                                      fillColor: AppColors().cardColor,
                                      filled: true,
                                      hintText:
                                          Translate.get('login_email_hint'),
                                      hintStyle:
                                          CustomTextStyle.size14Weight400Text()
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
                                        borderSide: BorderSide(
                                            color: AppColors.primaryColor,
                                            width: 1.5),
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
                                    style: CustomTextStyle.size14Weight400Text()
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
                                      prefixIcon: Icon(Icons.lock_rounded,
                                          color: AppColors.primaryDarkColor),
                                      fillColor: AppColors().cardColor,
                                      filled: true,
                                      hintText:
                                          Translate.get('login_password_hint'),
                                      hintStyle:
                                          CustomTextStyle.size14Weight400Text()
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
                                        borderSide: BorderSide(
                                            color: AppColors.primaryColor,
                                            width: 1.5),
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
                                shape:
                                    const CircleBorder(), // 🔑 This makes it circular
                                side: BorderSide(
                                  // Border when not selected
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
                                    Translate.get('login_privacy_policy'),
                                    style:
                                        CustomTextStyle.size14Weight400Text(),
                                  ),
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pushNamed(
                                    context,
                                    "/login/forgot-password",
                                  );
                                },
                                child: Text(
                                  Translate.get('login_forgot_password'),
                                  style: CustomTextStyle.size14Weight400Text()
                                      .copyWith(color: Colors.grey[700]),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 30),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: PrimaryButton(
                              text: Translate.get('login_button'),
                              onTap: () async {
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
                          // Match web checkout auth: continue as guest
                          if (widget.returnRoute != null) ...[
                            Text(
                              Translate.get('orContinueAsGuest'),
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 8),
                            SizedBox(
                              width: double.infinity,
                              height: 52,
                              child: OutlinedButton(
                                onPressed: () async {
                                  showDialog(
                                    context: context,
                                    barrierDismissible: false,
                                    builder: (_) => const LoadingIndicator(),
                                  );
                                  try {
                                    await GuestAuthService.ensureGuestUser();
                                    if (!mounted) return;
                                    Navigator.pop(context); // loading
                                    Navigator.pushNamedAndRemoveUntil(
                                      context,
                                      widget.returnRoute!,
                                      (route) =>
                                          route.settings.name == '/home' ||
                                          route.isFirst,
                                    );
                                  } catch (e) {
                                    if (!mounted) return;
                                    Navigator.pop(context);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Guest login failed: $e'),
                                        backgroundColor: AppColors.errorColor,
                                      ),
                                    );
                                  }
                                },
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.black87,
                                  side: BorderSide(
                                    color: AppColors.primaryColor
                                        .withOpacity(0.35),
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                child: Text(
                                  Translate.get('loginAsGuest'),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],
                          const SizedBox(height: 24),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                Translate.get('login_no_account'),
                                style: CustomTextStyle.size16Weight400Text(),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.pushNamed(context, '/register');
                                },
                                child: Text(
                                  Translate.get('login_register_now'),
                                  style: CustomTextStyle.size16Weight400Text()
                                      .copyWith(
                                    color: AppColors.primaryColor,
                                    fontWeight: FontWeight.w700,
                                    decoration: TextDecoration.underline,
                                    decorationColor: AppColors.primaryColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    )
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
