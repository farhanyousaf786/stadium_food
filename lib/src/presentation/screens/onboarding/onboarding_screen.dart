import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:stadium_food/src/core/translations/translate.dart';
import 'package:stadium_food/src/data/services/language_service.dart';
import '../../../services/onboarding_service.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  List<OnboardingContent> get _contents => [
    OnboardingContent(
      title: Translate.get('onboarding_first_title'),
      subTitle: Translate.get('onboarding_first_subtitle'),
      description: Translate.get('onboarding_first_description'),
      image: 'assets/png/onboarding_1.png',
    ),
    OnboardingContent(
      title: Translate.get('onboarding_second_title'),
      subTitle: Translate.get('onboarding_second_subtitle'),
      description: Translate.get('onboarding_second_description'),
      image: 'assets/png/onboarding_2.png',
    ),
    OnboardingContent(
      title: Translate.get('onboarding_third_title'),
      subTitle: Translate.get('onboarding_third_subtitle'),
      description: Translate.get('onboarding_third_description'),
      image: 'assets/png/onboarding_3.png',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          // PageView with background images + title only
          Expanded(
              child: Stack(
            children: [
              PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: _contents.length,
                itemBuilder: (context, index) {
                  return OnboardingPage(content: _contents[index]);
                },
              ),
              Positioned(
                top: 10,
                right: 10,
                child: SafeArea(
                  child: PopupMenuButton<String>(
                    icon: Container(
                      width: 45,
                      height: 45,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(22.5),
                        border: Border.all(color: Colors.white.withOpacity(0.25)),
                      ),
                      child: SvgPicture.asset(
                        "assets/svg/ic_lang.svg",
                        colorFilter: const ColorFilter.mode(
                          Colors.white,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                    onSelected: (String languageCode) {
                      LanguageService.setLanguage(languageCode);
                      setState(() {});
                    },
                    itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                      const PopupMenuItem<String>(
                        value: 'en',
                        child: Text('English'),
                      ),
                      const PopupMenuItem<String>(
                        value: 'he',
                        child: Text('Hebrew'),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                    height: 150,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.white.withOpacity(0.9),
                          // strong white at bottom
                          Colors.white.withOpacity(0.0),
                          // transparent fade
                        ],
                        stops: [0.0, 0.9], // adjust spread
                      ),
                    )),
              ),
            ],
          )),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 20, bottom: 50),
            decoration: const BoxDecoration(color: Colors.white),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Text(
                    _contents[_currentPage].description,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFF666666),
                      fontSize: 16,
                      fontFamily: 'Lato',
                      height: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                SmoothPageIndicator(
                  controller: _pageController,
                  count: _contents.length,
                  effect: CustomizableEffect(
                    spacing: 10,
                    activeDotDecoration: DotDecoration(
                      width: 16,
                      height: 16,
                      color: Color(0xFF3C67E3),
                      borderRadius: BorderRadius.circular(8),
                      dotBorder:
                          const DotBorder(color: Color(0xFF4169E1), width: 2),
                    ),
                    dotDecoration: DotDecoration(
                      width: 12,
                      height: 12,
                      color: Color(0xFFD7E1FF),
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: ElevatedButton(
                    onPressed: () async {
                      if (_currentPage == _contents.length - 1) {
                        await OnboardingService.markOnboardingComplete();
                        if (context.mounted) {
                          Navigator.of(context).pushReplacementNamed('/home');
                        }
                      } else {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeIn,
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4169E1),
                      minimumSize: const Size(65, 65),
                      shape: const CircleBorder(),
                      elevation: 0,
                    ),
                    child: Image.asset(
                      'assets/png/onboarding_arrow.png',
                      width: 20,
                      height: 20,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class OnboardingContent {
  final String title;
  final String subTitle;
  final String description;
  final String image;

  OnboardingContent({
    required this.title,
    required this.subTitle,
    required this.description,
    required this.image,
  });
}

class OnboardingPage extends StatefulWidget {
  final OnboardingContent content;

  const OnboardingPage({
    super.key,
    required this.content,
  });

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _headlineController;
  late Animation<double> _headlineScaleAnimation;
  late Animation<double> _headlineRotateAnimation;

  @override
  void initState() {
    super.initState();

    _headlineController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    // Repeat with a gentle pause, like GoalScreen
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

    _headlineController.forward();
  }

  @override
  void dispose() {
    _headlineController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final content = widget.content;
    return Stack(
      children: [
        // Background image
        Positioned.fill(
          child: Image.asset(
            content.image,
            fit: BoxFit.cover,
          ),
        ),

        Align(
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center, // 👈 Centers vertically
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Align(
                alignment: Alignment.center,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: AnimatedBuilder(
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
                    child: TweenAnimationBuilder<double>(
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
                        content.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Lato',
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ),

              Align(
                alignment: Alignment.center,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Text(
                    content.subTitle,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      // fontWeight: FontWeight.bold,
                      fontFamily: 'Lato',
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        )
        // Title higher up (like Figma design)

      ],
    );
  }
}
