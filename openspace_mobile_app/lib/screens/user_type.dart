import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/constants.dart';

class UserTypeScreenContent extends StatelessWidget {
  final Function(String?) onUserTypeSelected;

  const UserTypeScreenContent({super.key, required this.onUserTypeSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppConstants.primaryBlue,
            AppConstants.primaryBlue.withOpacity(0.8),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            Semantics(
              label: 'Choose Your User Type',
              child: Text(
                'Join OpenSpace',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                'Sign in to track your reports and bookings, or continue anonymously to explore open spaces.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  height: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      onUserTypeSelected('Registered User');
                    },
                    style: Theme.of(context).elevatedButtonTheme.style?.copyWith(
                      minimumSize: WidgetStateProperty.all(const Size(double.infinity, 56)),
                    ),
                    child: Semantics(
                      label: 'Sign in as Registered User',
                      child: Text(
                        'Sign In as Registered User',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      onUserTypeSelected('Anonymous User');
                    },
                    style: Theme.of(context).outlinedButtonTheme.style?.copyWith(
                      minimumSize: WidgetStateProperty.all(const Size(double.infinity, 56)),
                    ),
                    child: Semantics(
                      label: 'Continue as Anonymous User',
                      child: Text(
                        'Continue as Anonymous',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () => Navigator.pushNamed(context, '/terms'),
                    child: Text(
                      'Terms & Privacy Policy',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppConstants.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}