import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:openspace_mobile_app/screens/action_button.dart';
// import 'package:openspace_mobile_app/screens/action_buttons.dart';
import 'package:openspace_mobile_app/screens/report_type_section.dart';
import 'package:openspace_mobile_app/screens/description_section.dart';
import 'package:openspace_mobile_app/screens/file_attachment_section.dart';

class ReportIssuePage extends StatefulWidget {
  const ReportIssuePage({super.key});

  @override
  State<ReportIssuePage> createState() => _ReportIssuePageState();
}

class _ReportIssuePageState extends State<ReportIssuePage> {
  final _formKey = GlobalKey<FormState>();
  String? selectedReportType;
  final TextEditingController _descriptionController = TextEditingController();
  final List<File> _selectedFiles = [];
  bool _isSubmitting = false;
  final ImagePicker _picker = ImagePicker(); // ✅ File Picker Instance

  Future<void> _pickFiles() async {
    try {
      final List<XFile> images = await _picker.pickMultiImage();
      if (images.isNotEmpty) {
        setState(() {
          _selectedFiles.addAll(images.map((xFile) => File(xFile.path)).toList());
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error picking files: $e")));
    }
  }

  void _removeFile(int index) {
    setState(() => _selectedFiles.removeAt(index));
  }

  void _submitReport() async {
    setState(() => _isSubmitting = true);
    await Future.delayed(const Duration(seconds: 1));
    setState(() => _isSubmitting = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('Report'),
        centerTitle: true,
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ReportTypeSection(
                selectedReportType: selectedReportType,
                onSelected: (type) => setState(() => selectedReportType = type),
              ),
              const SizedBox(height: 12),
              DescriptionSection(controller: _descriptionController),
              const SizedBox(height: 12),
              FileAttachmentSection(
                selectedFiles: _selectedFiles,
                pickFiles: _pickFiles, // ✅ Ensures button works correctly
                removeFile: _removeFile,
              ),
              const SizedBox(height: 12),
              ActionButtons(
                isSubmitting: _isSubmitting,
                submitReport: _submitReport,
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
