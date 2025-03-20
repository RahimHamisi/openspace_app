import 'package:flutter/material.dart';
import '../utils/constants.dart';

class SplashScreenContent extends StatelessWidget {
  const SplashScreenContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.primaryBlue,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.public,
              size: 100,
              color: AppConstants.white,
            ),
            const SizedBox(height: 16),
            Text(
              AppConstants.appName,
              style: Theme.of(context)
                  .textTheme
                  .headlineLarge
                  ?.copyWith(color: AppConstants.white),
            ),
          ],
        ),
      ),
    );
  }
}