import 'package:flutter/material.dart';

class ActionButtons extends StatelessWidget {
  final bool isSubmitting;
  final VoidCallback submitReport;

  const ActionButtons({super.key, required this.isSubmitting, required this.submitReport});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(foregroundColor: Colors.red, side: const BorderSide(color: Colors.red)),
            child: const Text("Cancel"),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: isSubmitting ? null : submitReport,
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            child: isSubmitting
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Text("Submit Report"),
          ),
        ),
      ],
    );
  }
}
