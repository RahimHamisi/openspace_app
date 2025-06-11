import 'dart:async';
import 'dart:io' as io;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:openspace_mobile_app/service/file_uploadservice.dart';
import 'package:openspace_mobile_app/service/openspace_service.dart';
import 'package:openspace_mobile_app/screens/action_button.dart';
import 'package:openspace_mobile_app/screens/description_section.dart';
import 'package:openspace_mobile_app/screens/file_attachment_section.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';

class ReportIssuePage extends StatefulWidget {
  final double? latitude;
  final double? longitude;
  final String? spaceName;

  const ReportIssuePage({
    super.key,
    this.latitude,
    this.longitude,
    this.spaceName,
  });

  @override
  State<ReportIssuePage> createState() => _ReportIssuePageState();
}

class _ReportIssuePageState extends State<ReportIssuePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final List<UploadableFile> _filesToUpload = [];

  bool _isSubmittingOverall = false;

  final ImagePicker _imagePicker = ImagePicker();
  final OpenSpaceService _openSpaceService = OpenSpaceService();
  final FileUploadService _fileUploadService = FileUploadService();

  @override
  void initState() {
    super.initState();
    _prefillDescription();
  }

  void _prefillDescription() {
    if (widget.spaceName != null &&
        widget.latitude != null &&
        widget.longitude != null) {
      _descriptionController.text =
          "Reporting issue for: ${widget.spaceName}\nLocation: Lat: ${widget.latitude?.toStringAsFixed(5)}, Lon: ${widget.longitude?.toStringAsFixed(5)}\n\nDescription: ";
    } else if (widget.spaceName != null) {
      _descriptionController.text =
          "Reporting issue for: ${widget.spaceName}\n\nDescription: ";
    } else if (widget.latitude != null && widget.longitude != null) {
      _descriptionController.text =
          "Reporting issue at Location: Lat: ${widget.latitude?.toStringAsFixed(5)}, Lon: ${widget.longitude?.toStringAsFixed(5)}\n\nDescription: ";
    } else {
      _descriptionController.text = "Description: ";
    }
  }

  Future<void> _pickImages() async {
    if (_isSubmittingOverall) return;
    try {
      final List<XFile> pickedImages = await _imagePicker.pickMultiImage(
        imageQuality: 70,
      );
      if (pickedImages.isNotEmpty) {
        for (var xFile in pickedImages) {
          if (!_filesToUpload.any((f) => f.name == xFile.name)) {
            final bytes = await xFile.readAsBytes();
            if (mounted) {
              setState(() {
                _filesToUpload.add(
                  UploadableFile(name: xFile.name, bytes: bytes),
                );
              });
            }
          }
        }
      }
    } catch (e) {
      if (mounted) {
        _showErrorAlert(
          "Error picking images: ${e.toString().split(':').last.trim()}",
        );
      }
    }
  }

  Future<void> _pickGeneralFiles() async {
    if (_isSubmittingOverall) return;
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        withData: !kIsWeb,
        type: FileType.any,
      ); // Ensure withData is true for non-web
      if (result != null && result.files.isNotEmpty) {
        for (var pFile in result.files) {
          if (!_filesToUpload.any((f) => f.name == pFile.name)) {
            Uint8List? fileBytes;
            if (pFile.bytes != null) {
              // For web and sometimes mobile if withData is true
              fileBytes = pFile.bytes!;
            } else if (!kIsWeb && pFile.path != null) {
              // For mobile if path is available
              fileBytes = await io.File(pFile.path!).readAsBytes();
            }
            if (fileBytes != null && mounted) {
              setState(() {
                _filesToUpload.add(
                  UploadableFile(name: pFile.name, bytes: fileBytes!),
                );
              });
            } else if (mounted) {
              _showErrorAlert("Could not read file: ${pFile.name}");
            }
          }
        }
      }
    } catch (e) {
      if (mounted) {
        _showErrorAlert(
          "Error picking files: ${e.toString().split(':').last.trim()}",
        );
      }
    }
  }

  void _removeFile(int index) {
    if (_isSubmittingOverall) return;
    if (index < 0 || index >= _filesToUpload.length) return;
    if (mounted) {
      setState(() {
        _filesToUpload.removeAt(index);
      });
    }
  }

  Future<void> _showSuccessAlert(String reportId) async {
    if (!mounted) return;
    return QuickAlert.show(
      context: context,
      type: QuickAlertType.success,
      title: 'Report Submitted!',
      barrierDismissible: false,
      widget: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          "Your report (ID: $reportId) has been successfully submitted. Thank you!",
          textAlign: TextAlign.center,
        ),
      ),
      confirmBtnText: 'OK',
      confirmBtnColor: Colors.green,
      onConfirmBtnTap: () {
        if (mounted) Navigator.of(context, rootNavigator: true).pop();
      },
    );
  }

  Future<void> _showErrorAlert(String message) async {
    if (!mounted) return;
    return QuickAlert.show(
      context: context,
      type: QuickAlertType.error,
      title: 'Oops...',
      text: message, // The refined message will be shown here
      confirmBtnText: 'OK',
      confirmBtnColor: Colors.red,
      onConfirmBtnTap: () {
        if (mounted) Navigator.of(context, rootNavigator: true).pop();
      },
    );
  }

  void _clearFormAndFiles() {
    _descriptionController.clear();
    _emailController.clear();
    _phoneController.clear();
    if (mounted) {
      setState(() {
        _filesToUpload.clear();
      });
    }
    _formKey.currentState?.reset();
    _prefillDescription(); // Re-prefill after clearing
  }

  Future<void> _submitReport() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    if (!mounted) return;
    setState(() {
      _isSubmittingOverall = true;
    });

    const Duration minLoadingDisplayTime = Duration(milliseconds: 700);
    final DateTime processingAlertShownTime = DateTime.now();

    QuickAlert.show(
      context: context,
      type: QuickAlertType.loading,
      title: 'Processing...',
      text: "Submitting your report, please wait...",
      barrierDismissible: false,
    );
    final Future<void> processingAlertDisplayFuture = Future.delayed(
      minLoadingDisplayTime,
    );

    String? finalReportId;
    String? errorMessage;

    try {
      List<String> uploadedFilePaths = [];
      if (_filesToUpload.isNotEmpty) {
        for (int i = 0; i < _filesToUpload.length; i++) {
          UploadableFile fileData = _filesToUpload[i];
          String? singleUploadedPath = await _fileUploadService.uploadFile(
            fileName: fileData.name,
            fileBytes: fileData.bytes,
            // reportId: "TEMP_ID", // Optional: If your backend needs/can handle an ID before final report creation
          );

          if (singleUploadedPath == null) {
            errorMessage = "Failed to upload file: ${fileData.name}.";
            break;
          }
          uploadedFilePaths.add(singleUploadedPath);
        }
      }

      if (errorMessage == null) {
        String? filePathPayload =
            uploadedFilePaths.isNotEmpty ? uploadedFilePaths.join(',') : null;
        String? email =
            _emailController.text.trim().isNotEmpty
                ? _emailController.text.trim()
                : null;
        String? phone =
            _phoneController.text.trim().isNotEmpty
                ? _phoneController.text.trim()
                : null; // Ensure your service handles this

        final Map<String, dynamic>? reportData = await _openSpaceService
            .createReport(
              description: _descriptionController.text.trim(),
              filePath: filePathPayload,
              spaceName: widget.spaceName,
              latitude: widget.latitude,
              longitude: widget.longitude,
              email: email,
            );

        if (reportData != null && reportData['reportId'] != null) {
          finalReportId = reportData['reportId'].toString();
        } else if (reportData == null && errorMessage == null) {
          // If service returned null without throwing an error we already caught
          errorMessage =
              "Failed to submit report. Server returned incomplete data.";
        }
      }
    } on TimeoutException catch (_) {
      errorMessage =
          "The operation timed out. Please check your connection and try again.";
    } catch (e) {
      errorMessage = e.toString().replaceFirst(RegExp(r'^Exception:\s*'), '');
      if (!errorMessage.endsWith('.')) {
        errorMessage += '.';
      }
      if (!errorMessage.toLowerCase().contains("timed out") &&
          !errorMessage.toLowerCase().contains("network") &&
          !errorMessage.toLowerCase().contains("server") &&
          !errorMessage.toLowerCase().contains("upload failed") &&
          !errorMessage.toLowerCase().contains("invalid response") &&
          _filesToUpload.isNotEmpty &&
          errorMessage.startsWith("Failed to upload file")) {
      } else if (!errorMessage.startsWith("The") &&
          !errorMessage.startsWith("Network") &&
          !errorMessage.startsWith("Error") &&
          !errorMessage.startsWith("Failed")) {
        errorMessage = "An unexpected error occurred: $errorMessage";
      }
    } finally {
      final Duration timeSinceProcessingAlertShown = DateTime.now().difference(
        processingAlertShownTime,
      );
      if (mounted) {
        if (timeSinceProcessingAlertShown < minLoadingDisplayTime) {
          await processingAlertDisplayFuture;
        }
        Navigator.of(context, rootNavigator: true).pop();
      }

      if (!mounted) return;

      if (finalReportId != null) {
        await _showSuccessAlert(finalReportId);
        if (mounted) {
          _clearFormAndFiles();
          Navigator.pop(context);
        }
      } else if (errorMessage != null) {
        await _showErrorAlert(errorMessage);
      } else {
        await _showErrorAlert("An unknown error occurred. Please try again.");
      }

      if (mounted) {
        setState(() {
          _isSubmittingOverall = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  InputDecoration _textFieldDecoration({
    required String labelText,
    required String hintText,
    IconData? prefixIcon,
  }) {
    return InputDecoration(
      labelText: labelText,
      hintText: hintText,
      prefixIcon:
          prefixIcon != null ? Icon(prefixIcon, color: Colors.blueGrey) : null,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(
        vertical: 15.0,
        horizontal: 12.0,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
        borderSide: BorderSide(color: Colors.grey.shade300, width: 1.0),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
        borderSide: const BorderSide(color: Colors.blue, width: 2.0),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
        borderSide: BorderSide(color: Colors.red.shade700, width: 1.0),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
        borderSide: BorderSide(color: Colors.red.shade700, width: 2.0),
      ),
      labelStyle: TextStyle(color: Colors.grey.shade700),
      hintStyle: TextStyle(color: Colors.grey.shade500),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('Report an Issue'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _isSubmittingOverall ? null : () => Navigator.pop(context),
        ),
      ),
      body: AbsorbPointer(
        absorbing: _isSubmittingOverall,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.stretch,
                children: [
                  if (widget.spaceName != null) ...[
                    Text(
                      "Reporting for: ${widget.spaceName}",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                  ],
                  if (widget.latitude != null &&
                      widget.longitude != null &&
                      widget.spaceName == null) ...[
                    Text(
                      "Location: Lat: ${widget.latitude?.toStringAsFixed(5)}, Lon: ${widget.longitude?.toStringAsFixed(5)}",
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                  if (widget.spaceName != null ||
                      (widget.latitude != null && widget.longitude != null))
                    const SizedBox(height: 16),

                  TextFormField(
                    controller: _emailController,
                    enabled: !_isSubmittingOverall,
                    decoration: _textFieldDecoration(
                      labelText: 'Email (Optional)',
                      hintText: 'Enter your email address',
                      prefixIcon: Icons.email_outlined,
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return null; // Optional field
                      }
                      if (!RegExp(
                        r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
                      ).hasMatch(value)) {
                        return 'Please enter a valid email address';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _phoneController,
                    enabled: !_isSubmittingOverall,
                    decoration: _textFieldDecoration(
                      labelText: 'Phone Number (Optional)',
                      hintText: 'Enter your phone number',
                      prefixIcon: Icons.phone_outlined,
                    ),
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return null; // Optional field
                      }
                      if (!RegExp(r'^\+?([0-9\s-]{7,15})$').hasMatch(value)) {
                        return 'Please enter a valid phone number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  DescriptionSection(
                    controller: _descriptionController,
                    enabled: !_isSubmittingOverall,
                  ),
                  const SizedBox(height: 12),
                  FileAttachmentSection(
                    selectedFileNames:
                        _filesToUpload.map((f) => f.name).toList(),
                    pickImages: _isSubmittingOverall ? null : _pickImages,
                    pickGeneralFiles:
                        _isSubmittingOverall ? null : _pickGeneralFiles,
                    removeFile: _isSubmittingOverall ? null : _removeFile,
                  ),
                  const SizedBox(height: 24),
                  ActionButtons(
                    isSubmitting: _isSubmittingOverall,
                    submitReport: _submitReport,
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class UploadableFile {
  final String name;
  final Uint8List bytes;
  UploadableFile({required this.name, required this.bytes});
}
