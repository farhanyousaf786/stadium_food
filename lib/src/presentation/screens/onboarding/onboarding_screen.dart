import 'package:flutter/material.dart';
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

  final List<OnboardingContent> _contents = [
    OnboardingContent(
      title: 'Tap. Sit. Order.',
      description:
          'Enjoy food, drinks and merch delivered right to your seat-so you can stay in the action, not in the line.',
      image: 'assets/png/onboarding_1.png',
    ),
    OnboardingContent(
      title: 'Tap. Sit. Munch.',
      description:
          'Order from your phone and get everything you need without ever leaving your seat. Enjoy!',
      image: 'assets/png/onboarding_2.png',
    ),
    OnboardingContent(
      title: 'Tap. Sit. Enjoy.',
      description:
          'Enjoy food, drinks and merch delivered right to your seat-so you can stay in the action, not in the line.',
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
  final String description;
  final String image;

  OnboardingContent({
    required this.title,
    required this.description,
    required this.image,
  });
}

class OnboardingPage extends StatelessWidget {
  final OnboardingContent content;

  const OnboardingPage({
    super.key,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Background image
        Positioned.fill(
          child: Image.asset(
            content.image,
            fit: BoxFit.cover,
          ),
        ),

        // Title higher up (like Figma design)
        Align(
          alignment: Alignment.center,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              content.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 50,
                fontWeight: FontWeight.bold,
                fontFamily: 'Lato',
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }
}
