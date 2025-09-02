import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:stadium_food/src/bloc/user_profile/user_profile_bloc.dart';
import 'package:stadium_food/src/core/translations/translate.dart';
import 'package:stadium_food/src/presentation/widgets/buttons/back_button.dart';
import 'package:stadium_food/src/presentation/widgets/buttons/primary_button.dart';
import 'package:stadium_food/src/presentation/widgets/loading_indicator.dart';
import 'package:stadium_food/src/presentation/utils/app_colors.dart';
import 'package:stadium_food/src/presentation/utils/app_styles.dart';
import 'package:stadium_food/src/presentation/utils/custom_text_style.dart';
import 'package:stadium_food/src/presentation/utils/helpers.dart';
import 'package:hive/hive.dart';

class RegisterProcessScreen extends StatefulWidget {
  const RegisterProcessScreen({super.key});

  @override
  State<RegisterProcessScreen> createState() => _RegisterProcessScreenState();
}

class _RegisterProcessScreenState extends State<RegisterProcessScreen> {
  // get data from hive
  var box = Hive.box('myBox');

  // form key
  final _formKey = GlobalKey<FormState>();
  // controllers for form fields
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  late final UserProfileBloc _userProfileBloc;
  String _fcmToken='';

  @override
  void initState() {
    super.initState();
    _userProfileBloc = UserProfileBloc();
    // set data to form fields
    _firstNameController.text = box.get('firstName', defaultValue: '');
    _lastNameController.text = box.get('lastName', defaultValue: '');
    _phoneController.text = box.get('phone', defaultValue: '');
    
    // Get FCM token
    FirebaseMessaging.instance.getToken().then((token) {
      if (token != null) {
        _fcmToken = token;
      }
    });
  }

  @override
  void dispose() {
    _userProfileBloc.close();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<UserProfileBloc>(
        create: (context) => _userProfileBloc,
        child: BlocListener<UserProfileBloc, UserProfileState>(
          listener: (context, state) {
            if (state is UserProfileSuccess) {
              Navigator.pushNamed(context, '/register/upload-photo');
            }

            if (state is UserProfileError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: AppColors.errorColor,
                  content: Text(state.error),
                ),
              );
            }

            if (state is UserProfileLoading) {
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => const LoadingIndicator(),
              );
            }
          },
          child: Scaffold(
            backgroundColor: AppColors.bgColor,
            body: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Header (match login look)
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
                                Translate.get('register_process_title'),
                                textAlign: TextAlign.center,
                                style: CustomTextStyle
                                    .size20Weight600Text()
                                    .copyWith(color: Colors.white, fontSize: 24),
                              ),
                              const SizedBox(height: 12),
                              Image.asset(
                                'assets/png/logo.png',
                                width: 120,
                                height: 120,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Content
                  Padding(
                    padding: const EdgeInsets.all(25.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          Translate.get('register_process_subtitle'),
                          style: CustomTextStyle.size14Weight400Text(),
                        ),
                        const SizedBox(height: 20),
                        Form(
                          key: _formKey,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          child: Column(
                            children: [
                              // First name
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  Translate.get('register_process_first_name'),
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
                                  controller: _firstNameController,
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return Translate.get(
                                          'register_process_error_first_name');
                                    }
                                    return null;
                                  },
                                  decoration: InputDecoration(
                                    prefixIcon: const Icon(
                                      Icons.person_outline,
                                      color: AppColors.primaryDarkColor,
                                    ),
                                    fillColor: AppColors().cardColor,
                                    filled: true,
                                    hintText: Translate.get(
                                        'register_process_first_name'),
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
                                    errorBorder: AppStyles.defaultErrorBorder,
                                    focusedErrorBorder:
                                        AppStyles.defaultFocusedErrorBorder,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              // Last name
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  Translate.get('register_process_last_name'),
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
                                  controller: _lastNameController,
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return Translate.get(
                                          'register_process_error_last_name');
                                    }
                                    return null;
                                  },
                                  decoration: InputDecoration(
                                    prefixIcon: const Icon(
                                      Icons.person_outline,
                                      color: AppColors.primaryDarkColor,
                                    ),
                                    fillColor: AppColors().cardColor,
                                    filled: true,
                                    hintText: Translate.get(
                                        'register_process_last_name'),
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
                                    errorBorder: AppStyles.defaultErrorBorder,
                                    focusedErrorBorder:
                                        AppStyles.defaultFocusedErrorBorder,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              // Phone
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  Translate.get('register_process_mobile'),
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
                                  controller: _phoneController,
                                  validator: (value) {
                                    if (!validatePhoneNumber(value!)) {
                                      return Translate.get(
                                          'register_process_error_phone');
                                    }
                                    return null;
                                  },
                                  keyboardType: TextInputType.phone,
                                  decoration: InputDecoration(
                                    prefixIcon: const Icon(
                                      Icons.phone_rounded,
                                      color: AppColors.primaryDarkColor,
                                    ),
                                    fillColor: AppColors().cardColor,
                                    filled: true,
                                    hintText:
                                        Translate.get('register_process_mobile'),
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
                                    errorBorder: AppStyles.defaultErrorBorder,
                                    focusedErrorBorder:
                                        AppStyles.defaultFocusedErrorBorder,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 30),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 60),
                          child: PrimaryButton(
                            text: Translate.get('register_process_next'),
                            onTap: () {
                              // validate form
                              if (!_formKey.currentState!.validate()) {
                                return;
                              }

                              // save data to hive
                              var box = Hive.box('myBox');
                              box.put('firstName',
                                  _firstNameController.text.trim());
                              box.put('lastName',
                                  _lastNameController.text.trim());
                              box.put('phone', _phoneController.text.trim());
                              box.put('fcmToken', _fcmToken);

                              // update user profile in Firebase
                              _userProfileBloc.add(UpdateUserProfile(
                                fcmToken: _fcmToken,
                                firstName: _firstNameController.text.trim(),
                                lastName: _lastNameController.text.trim(),
                                phone: _phoneController.text.trim(),
                              ));
                            },
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ));
  }
}
