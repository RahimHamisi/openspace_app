import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../providers/user_provider.dart';
import '../utils/constants.dart';
import 'onboarding_screen.dart';
import 'sign_up.dart';
import 'splash_screen.dart';
import 'user_type.dart';
import '../model/user_model.dart';

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
    if (!mounted || !_pageController.hasClients) {
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
    if (!mounted || !_pageController.hasClients) {
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
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    if (userType == 'Registered User') {
      userProvider.setUser(User.anonymous()); // Reset to anonymous until login
      Navigator.pushReplacementNamed(context, '/login');
    } else {
      userProvider.setUser(User.anonymous());
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
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
          Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: Column(
              children: [
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
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _currentPage > 0
                          ? TextButton(
                        onPressed: _previousPage,
                        child: const Text(
                          'Back',
                          style: TextStyle(color: AppConstants.white),
                        ),
                      )
                          : const SizedBox(width: 60),
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