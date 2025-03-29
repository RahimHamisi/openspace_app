import 'package:flutter/material.dart';
import '../utils/constants.dart';

class UserTypeScreenContent extends StatelessWidget {
  final Function(String?) onUserTypeSelected;

  const UserTypeScreenContent({super.key, required this.onUserTypeSelected});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.primaryBlue,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            Text(
              'Report any kind of an open space at your own privacy',
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: AppConstants.white),
            ),
            const SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  filled: true,
                  fillColor: AppConstants.white,
                  labelText: 'User Type',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'Registered User',
                    child: Text('Registered User'),
                  ),
                  DropdownMenuItem(
                    value: 'Anonymous User',
                    child: Text('Anonymous User'),
                  ),
                ],
                onChanged: onUserTypeSelected,
              ),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}