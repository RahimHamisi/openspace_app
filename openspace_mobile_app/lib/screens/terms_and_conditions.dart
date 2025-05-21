import 'package:flutter/material.dart';
import 'package:openspace_mobile_app/utils/constants.dart';

class TermsAndConditionsPage extends StatelessWidget {
  const TermsAndConditionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100], // Subtle background
      appBar: AppBar(
        title: const Text("Terms & Conditions",style:TextStyle(color: AppConstants.white)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppConstants.white),
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/home'); // Ensure '/home' is defined in routes
          },
        ),
        backgroundColor: AppConstants.primaryBlue,
        elevation: 2,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Terms & Conditions',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            const Text(
              "Effective date: 16 August 2023",
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 15),
            const Text(
              'Provide your own license or terms information here.',
              style: TextStyle(fontSize: 16, color: Colors.black87),
            ),
            const SizedBox(height: 20),
            _sectionTitle("Hosting"),
            _sectionContent("Ensure your data is accurate and secure when hosting files."),
            _sectionTitle("Liability"),
            _sectionContent("Users are responsible for complying with usage policies."),
            _sectionTitle("Contact"),
            _sectionContent("For any legal inquiries, contact support."),
            const SizedBox(height: 20),
            const Center(
              child: Text(
                "© 2023 President Manager Corp",
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Text(
        title,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
      ),
    );
  }

  Widget _sectionContent(String content) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Text(content, style: const TextStyle(fontSize: 16, color: Colors.black54)),
    );
  }
}
