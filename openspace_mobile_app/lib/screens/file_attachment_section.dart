import 'dart:io';
import 'package:flutter/material.dart';

class FileAttachmentSection extends StatelessWidget {
  final List<File> selectedFiles;
  final VoidCallback pickFiles;
  final Function(int) removeFile;

  const FileAttachmentSection({super.key, required this.selectedFiles, required this.pickFiles, required this.removeFile});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Attach Files", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),

            // ✅ File Picker Button
            OutlinedButton.icon(
              onPressed: pickFiles,
              icon: const Icon(Icons.attach_file),
              label: const Text("Choose Files"),
            ),

            const SizedBox(height: 12),

            selectedFiles.isEmpty
                ? const Center(child: Text("No File Chosen", style: TextStyle(color: Colors.grey)))
                : SizedBox(
              height: 80, // ✅ Added height for better display
              child: ListView.builder(
                scrollDirection: Axis.horizontal, // ✅ Enables horizontal scrolling
                itemCount: selectedFiles.length,
                itemBuilder: (context, index) {
                  return Chip(
                    avatar: const Icon(Icons.insert_drive_file, color: Colors.blue),
                    label: Text(selectedFiles[index].path.split("/").last, overflow: TextOverflow.ellipsis),
                    deleteIcon: const Icon(Icons.close),
                    onDeleted: () => removeFile(index),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
