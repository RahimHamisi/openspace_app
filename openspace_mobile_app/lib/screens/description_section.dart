import 'package:flutter/material.dart';
import 'package:openspace_mobile_app/screens/text_format_bar.dart';

class DescriptionSection extends StatelessWidget {
  final TextEditingController controller;

  const DescriptionSection({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Description", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            const TextFormatBar(), // ✅ Calls formatting toolbar from another file
            const SizedBox(height: 8),
            TextFormField(
              controller: controller,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: "Enter details...",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
