import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hive/hive.dart';
import 'package:stadium_food/src/presentation/screens/server.dart';

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
    Future.delayed(const Duration(milliseconds: 1500), () {
      var box = Hive.box('myBox');

      if (box.get('isRegistered') == true) {
        Navigator.pushReplacementNamed(context, "/home");
      } else if (FirebaseAuth.instance.currentUser != null) {
        Navigator.pushReplacementNamed(context, "/register/process");
      } else {
        Navigator.pushReplacementNamed(context, "/onboarding/first");
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
