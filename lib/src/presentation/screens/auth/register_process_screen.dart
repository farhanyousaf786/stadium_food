import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:stadium_food/src/bloc/user_profile/user_profile_bloc.dart';
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
            resizeToAvoidBottomInset: false,
            body: Stack(
              children: [
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding:
                        const EdgeInsets.only(bottom: 60, left: 25, right: 25),
                    child: PrimaryButton(
                      text: "Next",
                      onTap: () {
                        // validate form
                        if (!_formKey.currentState!.validate()) {
                          return;
                        }

                        // save data to hive
                        var box = Hive.box('myBox');
                        box.put('firstName', _firstNameController.text.trim());
                        box.put('lastName', _lastNameController.text.trim());
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
                        // check if previous page exists
                        if (ModalRoute.of(context)!.canPop) ...[
                          const CustomBackButton(),
                        ],
                        const SizedBox(height: 20),
                        Text(
                          "Fill in your bio to get \nstarted",
                          style: CustomTextStyle.size25Weight600Text(),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          "This data will be displayed in your account \nprofile for security",
                          style: CustomTextStyle.size14Weight400Text(),
                        ),
                        const SizedBox(height: 20),
                        // form fields, first name, last name, mobile number
                        Form(
                          key: _formKey,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          child: Column(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  boxShadow: [AppStyles.boxShadow7],
                                ),
                                child: TextFormField(
                                  controller: _firstNameController,
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return "First name is required";
                                    }
                                    return null;
                                  },
                                  decoration: InputDecoration(
                                    fillColor: AppColors().cardColor,
                                    filled: true,
                                    hintText: "First name",
                                    hintStyle:
                                        CustomTextStyle.size14Weight400Text(
                                      AppColors().secondaryTextColor,
                                    ),
                                    contentPadding: const EdgeInsets.only(
                                      left: 20,
                                    ),
                                    enabledBorder:
                                        AppStyles().defaultEnabledBorder,
                                    focusedBorder:
                                        AppStyles.defaultFocusedBorder(),
                                    errorBorder: AppStyles.defaultErrorBorder,
                                    focusedErrorBorder:
                                        AppStyles.defaultFocusedErrorBorder,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              Container(
                                decoration: BoxDecoration(
                                  boxShadow: [AppStyles.boxShadow7],
                                ),
                                child: TextFormField(
                                  controller: _lastNameController,
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return "Last name is required";
                                    }
                                    return null;
                                  },
                                  decoration: InputDecoration(
                                    fillColor: AppColors().cardColor,
                                    filled: true,
                                    hintText: "Last name",
                                    hintStyle:
                                        CustomTextStyle.size14Weight400Text(
                                      AppColors().secondaryTextColor,
                                    ),
                                    contentPadding: const EdgeInsets.only(
                                      left: 20,
                                    ),
                                    enabledBorder:
                                        AppStyles().defaultEnabledBorder,
                                    focusedBorder:
                                        AppStyles.defaultFocusedBorder(),
                                    errorBorder: AppStyles.defaultErrorBorder,
                                    focusedErrorBorder:
                                        AppStyles.defaultFocusedErrorBorder,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              Container(
                                decoration: BoxDecoration(
                                  boxShadow: [AppStyles.boxShadow7],
                                ),
                                child: TextFormField(
                                  controller: _phoneController,
                                  validator: (value) {
                                    if (!validatePhoneNumber(value!)) {
                                      return "Invalid phone number";
                                    }
                                    return null;
                                  },
                                  keyboardType: TextInputType.phone,
                                  decoration: InputDecoration(
                                    fillColor: AppColors().cardColor,
                                    filled: true,
                                    hintText: "Mobile number",
                                    hintStyle:
                                        CustomTextStyle.size14Weight400Text(
                                      AppColors().secondaryTextColor,
                                    ),
                                    contentPadding: const EdgeInsets.only(
                                      left: 20,
                                    ),
                                    enabledBorder:
                                        AppStyles().defaultEnabledBorder,
                                    focusedBorder:
                                        AppStyles.defaultFocusedBorder(),
                                    errorBorder: AppStyles.defaultErrorBorder,
                                    focusedErrorBorder:
                                        AppStyles.defaultFocusedErrorBorder,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}
