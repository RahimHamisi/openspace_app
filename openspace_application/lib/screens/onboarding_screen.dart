import 'package:flutter/material.dart';
import '../utils/constants.dart';

class OnboardingScreenContent extends StatelessWidget {
  const OnboardingScreenContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.primaryBlue,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            const Icon(
              Icons.map,
              size: 150,
              color: AppConstants.white,
            ),
            const SizedBox(height: 24),
            Text(
              'WELCOME TO OSA',
              style: Theme.of(context)
                  .textTheme
                  .headlineLarge
                  ?.copyWith(color: AppConstants.white),
            ),
            const SizedBox(height: 16),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                'Access the map anywhere and see the available open space in your areas',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppConstants.white, fontSize: 16),
              ),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}