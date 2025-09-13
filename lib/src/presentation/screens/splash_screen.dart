import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:stadium_food/src/presentation/screens/onboarding/onboarding_screen.dart';
import 'package:stadium_food/src/presentation/screens/server.dart';
import 'package:stadium_food/src/services/onboarding_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/app_colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _visible = false;
  @override
  void initState() {
    super.initState();
    GetServerKey().getServerKeyToken();
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        _visible = true;
      });
    });
    Future.delayed(const Duration(milliseconds: 1500), () async {
      // Decide next screen based on onboarding completion and stadium selection
      final hasSeenOnboarding = await OnboardingService.hasSeenOnboarding();
      if (!mounted) return;

      if (!hasSeenOnboarding) {
        // Show onboarding screens first
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const OnboardingScreen()),
        );
        return;
      }

      // Onboarding completed: check if a stadium is selected
      final prefs = await SharedPreferences.getInstance();
      final selectedStadiumId = prefs.getString('selected_stadium_id');
      if (!mounted) return;

      if (selectedStadiumId != null && selectedStadiumId.isNotEmpty) {
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        Navigator.pushReplacementNamed(context, '/select-stadium');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      body: Stack(
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.black, Colors.transparent],
              ).createShader(bounds),
              blendMode: BlendMode.dstIn,
              child: SvgPicture.asset(
                "assets/svg/pattern-big.svg",
              ),
            ),
          ),
          AnimatedPositioned(
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
            top: _visible ? 0 : 1000,
            bottom: 0,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: 200,
                height: 200,
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
            ),
          ),
        ],
      ),
    );
  }
}
