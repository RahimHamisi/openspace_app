import 'package:flutter/material.dart';
import 'package:openspace_mobile_app/utils/constants.dart';

class HelpPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor, // Unified background
      appBar: AppBar(
        title: const Text("Help with OSA"),
        backgroundColor: AppConstants.primaryBlue,
        elevation: 2,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Need Help?',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              'Find answers and support for common issues.',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: AppConstants.primaryBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Contact Support'),
            ),
            const SizedBox(height: 30),
            const Text(
              'FAQs',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),
            FAQItem("How do I reset my password?", "Go to settings and tap 'Reset Password'."),
            FAQItem("Where can I find my reports?", "Reports are available in 'My Reports' section."),
            FAQItem("Can I change my email?", "Yes, go to account settings and update your email."),
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
}

// Animating FAQ Expansion
class FAQItem extends StatefulWidget {
  final String question;
  final String answer;

  const FAQItem(this.question, this.answer);

  @override
  _FAQItemState createState() => _FAQItemState();
}

class _FAQItemState extends State<FAQItem> {
  bool _isExpanded = false;

  void _toggleExpansion() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: _toggleExpansion,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(widget.question, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Icon(_isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down),
              ],
            ),
          ),
        ),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: _isExpanded
              ? Padding(
            padding: const EdgeInsets.all(12),
            child: Text(widget.answer, style: const TextStyle(fontSize: 16)),
          )
              : const SizedBox.shrink(),
        ),
        const SizedBox(height: 10),
      ],
    );
  }
}
