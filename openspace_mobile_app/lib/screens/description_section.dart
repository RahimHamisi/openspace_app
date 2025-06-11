import 'package:flutter/material.dart';
import 'package:openspace_mobile_app/screens/text_format_bar.dart'; // Assuming this is correct

class DescriptionSection extends StatelessWidget {
  final TextEditingController controller;
  final bool enabled; // <<< --- ADD THIS LINE

  const DescriptionSection({
    super.key,
    required this.controller,
    this.enabled = true, // <<< --- ADD THIS LINE with a default value
  });

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
            // Consider also disabling TextFormatBar if the field is disabled
            // if (enabled) const TextFormatBar(),
            // or pass enabled to TextFormatBar if it supports it
            const TextFormatBar(),
            const SizedBox(height: 8),
            TextFormField(
              controller: controller,
              enabled: enabled, // <<< --- USE THE ENABLED PROPERTY HERE
              maxLines: 5,
              decoration: InputDecoration(
                hintText: "Enter details...",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
              validator: (value) { // <<< --- ADD A VALIDATOR
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a description.';
                }
                if (value.trim().length < 10) {
                  return 'Description must be at least 10 characters.';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }
}