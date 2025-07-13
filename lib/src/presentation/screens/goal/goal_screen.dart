import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:lottie/lottie.dart';
import 'dart:math' as math;
import 'package:hive/hive.dart';
import 'package:stadium_food/src/presentation/utils/app_colors.dart';

class GoalScreen extends StatefulWidget {
  const GoalScreen({Key? key}) : super(key: key);

  @override
  State<GoalScreen> createState() => _GoalScreenState();
}

class _GoalScreenState extends State<GoalScreen> with TickerProviderStateMixin {
  late AnimationController _headlineController;
  late AnimationController _sublineController;
  late AnimationController _controller; // For food icons animation
  late Animation<double> _headlineScaleAnimation;
  late Animation<double> _headlineRotateAnimation;
  late Animation<Offset> _sublineSlideAnimation;
  late Animation<double> _sublineOpacityAnimation;
  
  // App color scheme
  final List<Color> gradientColors = [
    AppColors.primaryColor,
    AppColors.primaryLightColor,
    AppColors.primaryDarkColor,
    AppColors.primaryColor,
  ];

  // Helper method to build animated food icons
  Widget _buildFoodIcon(IconData icon, double size, Color color) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        // Ensure the controller value is valid
        final value = _controller.value;
        // Use simple sine wave animation that's guaranteed to be in range
        final scale = 0.8 + 0.2 * math.sin(value * math.pi);
        final opacity = 0.7 + 0.3 * math.sin(value * math.pi);
        
        return Transform.scale(
          scale: scale,
          child: Opacity(
            opacity: opacity,
            child: Container(
              
              padding: const EdgeInsets.all(12),
              child: Icon(
                icon,
                size: size,
                color: Colors.white.withOpacity(0.2),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    
    // Headline animations
    _headlineController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    
    // Set up repeating animation for the headline
    _headlineController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Future.delayed(const Duration(milliseconds: 1000), () {
          if (mounted) _headlineController.reverse();
        });
      } else if (status == AnimationStatus.dismissed) {
        Future.delayed(const Duration(milliseconds: 1000), () {
          if (mounted) _headlineController.forward();
        });
      }
    });
    
    _headlineScaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _headlineController,
      curve: Curves.elasticOut,
    ));
    
    _headlineRotateAnimation = Tween<double>(
      begin: -0.1,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _headlineController,
      curve: Curves.elasticOut,
    ));
    
    // Subline animations
    _sublineController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    
    _sublineOpacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _sublineController,
      curve: Curves.easeIn,
    ));
    
    _sublineSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _sublineController,
      curve: Curves.easeOutCubic,
    ));
    

    
    // Food icons animation
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );
    
    // Start animations with a slight delay between them
    _headlineController.forward();
    Future.delayed(const Duration(milliseconds: 1000), () {
      _sublineController.forward();
    });

    _controller.repeat(); // Repeat food icons animation
  }

  @override
  void dispose() {
    _headlineController.dispose();
    _sublineController.dispose();

    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Solid color background
          Container(
            width: double.infinity,
            height: double.infinity,
            color: AppColors.primaryColor,
          ),
          
          // Floating food icons animation
          Positioned.fill(
            child: Stack(
              children: [
                // Top row food icons
                Positioned(
                  top: 50,
                  left: 30,
                  child: _buildFoodIcon(Icons.fastfood, 40, AppColors.primaryLightColor.withOpacity(0.4)),
                ),
                Positioned(
                  top: 80,
                  left: 120,
                  child: _buildFoodIcon(Icons.lunch_dining, 45, AppColors.primaryColor.withOpacity(0.4)),
                ),
                Positioned(
                  top: 40,
                  right: 60,
                  child: _buildFoodIcon(Icons.local_pizza, 50, AppColors.secondaryColor.withOpacity(0.4)),
                ),
                
                // Middle row food icons
                Positioned(
                  top: MediaQuery.of(context).size.height * 0.3,
                  left: 40,
                  child: _buildFoodIcon(Icons.local_drink, 45, AppColors.primaryDarkColor.withOpacity(0.4)),
                ),
                Positioned(
                  top: MediaQuery.of(context).size.height * 0.35,
                  right: 50,
                  child: _buildFoodIcon(Icons.icecream, 35, AppColors.secondaryLightColor.withOpacity(0.4)),
                ),
                
                // Bottom row food icons
                Positioned(
                  bottom: 120,
                  left: 60,
                  child: _buildFoodIcon(Icons.bakery_dining, 42, AppColors.primaryLightColor.withOpacity(0.4)),
                ),
                Positioned(
                  bottom: 80,
                  right: 70,
                  child: _buildFoodIcon(Icons.emoji_food_beverage, 38, AppColors.secondaryColor.withOpacity(0.4)),
                ),
                Positioned(
                  bottom: 180,
                  right: 140,
                  child: _buildFoodIcon(Icons.sports_bar, 36, AppColors.primaryDarkColor.withOpacity(0.4)),
                ),
                
                
              ],
            ),
          ),
          
          // Stadium animation at top
          Positioned(
            top: 80,
            left: 0,
            right: 0,
            child: Center(
              child: Lottie.asset(
                'assets/animations/staduim.json',
                width: 200,
                height: 200,
                fit: BoxFit.contain,
              ),
            ),
          ),
          
          // Content
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Headline with scale and rotation animation
                    AnimatedBuilder(
                      animation: _headlineController,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _headlineScaleAnimation.value,
                        child: Transform.rotate(
                          angle: _headlineRotateAnimation.value,
                          child: child,
                        ),
                      );
                    },
                    child: Column(
                      children: [

                        const SizedBox(height: 16),
                        // Pulsating text animation
                        TweenAnimationBuilder<double>(
                          tween: Tween<double>(begin: 0.95, end: 1.05),
                          duration: const Duration(milliseconds: 1500),
                          curve: Curves.easeInOut,
                          builder: (context, scale, child) {
                            return Transform.scale(
                              scale: scale,
                              child: child,
                            );
                          },
                          child: Text(
                            'Tap. Sit. Enjoy.',
                            style: TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                              color: Colors.white,
                              shadows: [
                                Shadow(
                                  blurRadius: 10.0,
                                  color: Colors.white.withOpacity(0.3),
                                  offset: const Offset(0, 0),
                                ),
                              ],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                    
                    const SizedBox(height: 40),
                    
                    // Subline with fade and slide animation
                    AnimatedBuilder(
                      animation: _sublineController,
                    builder: (context, child) {
                      return FadeTransition(
                        opacity: _sublineOpacityAnimation,
                        child: SlideTransition(
                          position: _sublineSlideAnimation,
                          child: child,
                        ),
                      );
                    },
                    child: Column(
                      children: [

                        Text(
                          "Enjoy food, drinks and merch delivered right to your seat - so you can stay in the action, not the line.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 16),


                        Text(
                          "Skip the lines. Never Miss a Moment.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            height: 1.5,
                          ),
                        ),
                        
                      ],
                    ),
                  ),
                    
                  ],
                ),
              ),
            ),
          ),
          
          // Button positioned at bottom right with smooth animation
          Positioned(
            bottom: 40,
            right: 30,
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 1200),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) {
                return Opacity(
                  opacity: value,
                  child: Transform.translate(
                    offset: Offset(50 * (1 - value), 0),
                    child: child,
                  ),
                );
              },
              child: ElevatedButton(
                      onPressed: () {
                        var box = Hive.box('myBox');
                        
                        // Check if user has already selected a stadium
                        if (box.get('selectedStadium') != null) {
                          // If stadium is selected, go to home
                          Navigator.of(context).pushReplacementNamed('/home');
                        } else {
                          // Check if user has seen onboarding
                          bool hasSeenOnboarding = box.get('hasSeenOnboarding', defaultValue: false);
                          
                          if (hasSeenOnboarding) {
                            // If user has seen onboarding, go to stadium selection
                            Navigator.of(context).pushReplacementNamed('/select-stadium');
                          } else {
                            // If user hasn't seen onboarding, show onboarding screens first
                            Navigator.of(context).pushReplacementNamed('/onboarding/first');
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 254, 254, 254),
                        foregroundColor: Colors.white,
                        elevation: 4,
                        shadowColor: AppColors.primaryColor.withOpacity(0.4),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 40,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text(
                        "Let's Go!",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryColor,
                        ),
                      ),
              ),
            ),
      )],
      ),
    );
  }
}


