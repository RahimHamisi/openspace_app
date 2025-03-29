import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../utils/constants.dart';
import 'onboarding_screen.dart';
import 'sign_up.dart';
import 'splash_screen.dart';
import 'user_type.dart';

class IntroSliderScreen extends StatefulWidget {
  const IntroSliderScreen({super.key});

  @override
  State<IntroSliderScreen> createState() => _IntroSliderScreenState();
}

class _IntroSliderScreenState extends State<IntroSliderScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    if (_currentPage == 0) {
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted && _pageController.hasClients && _currentPage == 0) {
          _nextPage();
        } else {
          // print("Skipped auto-advance: Widget unmounted or controller detached");
        }
      });
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  void _nextPage() {
    if (!mounted ||!_pageController.hasClients) {
    //  print("Cannot proceed: Widget unmounted or controller detached");
      return;
    }
    if (_currentPage < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousPage() {
    if (!mounted ||!_pageController.hasClients){
    //  print("Cannot proceed: Widget unmounted or controller detached");
      return;
    } 
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _onUserTypeSelected(String? userType) {
    if (userType == 'Registered User') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const SignUpScreen()),
      );
    } else {
      Navigator.pushReplacementNamed(context, '/map');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // PageView for sliding between screens
          PageView(
            controller: _pageController,
            onPageChanged: _onPageChanged,
            physics: const BouncingScrollPhysics(),
            children: [
              const SplashScreenContent(),
              const OnboardingScreenContent(),
              UserTypeScreenContent(onUserTypeSelected: _onUserTypeSelected),
            ],
          ),
          // Page indicator and navigation buttons
          Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: Column(
              children: [
                // SmoothPageIndicator for showing current page
                SmoothPageIndicator(
                  controller: _pageController,
                  count: 3,
                  effect: const WormEffect(
                    dotColor: AppConstants.grey,
                    activeDotColor: AppConstants.white,
                    dotHeight: 8,
                    dotWidth: 8,
                    spacing: 16,
                    type: WormType.thin,
                  ),
                  onDotClicked: (index) {
                    _pageController.animateToPage(
                      index,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                ),
                const SizedBox(height: 16),
                // Navigation buttons (Back and Next)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Back button (hidden on the first page)
                      _currentPage > 0
                          ? TextButton(
                              onPressed: _previousPage,
                              child: const Text(
                                'Back',
                                style: TextStyle(color: AppConstants.white),
                              ),
                            )
                          : const SizedBox(width: 60),
                      // Next button (hidden on the last page)
                      _currentPage < 2
                          ? ElevatedButton(
                              onPressed: _nextPage,
                              child: const Text('Next'),
                            )
                          : const SizedBox(width: 60),
                    ],
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