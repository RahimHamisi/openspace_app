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
import '../utils/constants.dart'; // Assumed for AppTheme consistency

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
  bool _isGuidelinesExpanded = false;

  final ImagePicker _imagePicker = ImagePicker();
  final OpenSpaceService _openSpaceService = OpenSpaceService();
  final FileUploadService _fileUploadService = FileUploadService();

  @override
  void initState() {
    super.initState();
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
        _showErrorAlert("Error picking images");
        print("Error picking images: $e");
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
      );
      if (result != null && result.files.isNotEmpty) {
        for (var pFile in result.files) {
          if (!_filesToUpload.any((f) => f.name == pFile.name)) {
            Uint8List fileBytes;
            if (pFile.bytes != null) {
              fileBytes = pFile.bytes!; // Non-nullable since checked
            } else if (!kIsWeb && pFile.path != null) {
              fileBytes = await io.File(pFile.path!).readAsBytes(); // Non-nullable return
            } else {
              if (mounted) _showErrorAlert("Could not read file: ${pFile.name}");
              continue; // Skip to next file if bytes unavailable
            }
            if (mounted) {
              setState(() {
                _filesToUpload.add(
                  UploadableFile(name: pFile.name, bytes: fileBytes),
                );
              });
            }
          }
        }
      }
    } catch (e) {
      if (mounted) {
        _showErrorAlert("Error picking files");
        print("Error picking files: $e");
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
          "Your report (Reference ID: $reportId) has been successfully submitted. Use this Reference ID to track the progress of your report. Thank you for contributing to public service improvement!",
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium,
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
      text: message,
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
        _emailController.text.trim().isNotEmpty ? _emailController.text.trim() : null;
        String? phone =
        _phoneController.text.trim().isNotEmpty ? _phoneController.text.trim() : null;

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

  InputDecoration _textFieldDecoration({
    required String labelText,
    required String hintText,
    IconData? prefixIcon,
  }) {
    return InputDecoration(
      labelText: labelText,
      hintText: hintText,
      prefixIcon: prefixIcon != null ? Icon(prefixIcon, color: AppConstants.primaryBlue) : null,
      filled: true,
      fillColor: AppConstants.white,
      contentPadding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 10.0),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide(color: Colors.grey.shade300, width: 1.0),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide(color: AppConstants.primaryBlue, width: 2.0),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide(color: Colors.red.shade700, width: 1.0),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide(color: Colors.red.shade700, width: 2.0),
      ),
      labelStyle: TextStyle(color: Colors.grey.shade700),
      hintStyle: TextStyle(color: Colors.grey.shade500),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.white,
      appBar: AppBar(
        title: const Text('Citizen Report Submission'),
        backgroundColor: AppConstants.primaryBlue,
        foregroundColor: AppConstants.white,
        elevation: 0,
        centerTitle: true,
        leading: Semantics(
          label: 'Back to previous screen',
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppConstants.white),
            onPressed: _isSubmittingOverall ? null : () => Navigator.pop(context),
            padding: const EdgeInsets.all(12.0),
          ),
        ),
      ),
      body: AbsorbPointer(
        absorbing: _isSubmittingOverall,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (widget.spaceName != null) ...[
                      Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        color: AppConstants.white,
                        margin: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Text(
                            "Reporting for: ${widget.spaceName}",
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppConstants.primaryBlue,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                    if (widget.latitude != null && widget.longitude != null && widget.spaceName == null) ...[
                      Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        color: AppConstants.white,
                        margin: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Text(
                            "Location: Lat: ${widget.latitude?.toStringAsFixed(5)}, Lon: ${widget.longitude?.toStringAsFixed(5)}",
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      color: AppConstants.white,
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextFormField(
                          controller: _emailController,
                          enabled: !_isSubmittingOverall,
                          decoration: _textFieldDecoration(
                            labelText: 'Email (Optional)',
                            hintText: 'Enter your email address',
                            prefixIcon: Icons.email_outlined,
                          ),
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.isEmpty) return null;
                            if (!RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(value)) {
                              return 'Please enter a valid email address';
                            }
                            return null;
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    DescriptionSection(
                      controller: _descriptionController,
                      enabled: !_isSubmittingOverall,
                    ),
                    const SizedBox(height: 8),
                    FileAttachmentSection(
                      selectedFileNames: _filesToUpload.map((f) => f.name).toList(),
                      pickImages: _isSubmittingOverall ? null : _pickImages,
                      pickGeneralFiles: _isSubmittingOverall ? null : _pickGeneralFiles,
                      removeFile: _isSubmittingOverall ? null : _removeFile,
                    ),
                    const SizedBox(height: 16),
                    ActionButtons(
                      isSubmitting: _isSubmittingOverall,
                      submitReport: _submitReport,
                    ),
                    const SizedBox(height: 16),
                    // Moved Reporting Guidelines here
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      color: AppConstants.white,
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Theme(
                        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                        child: ExpansionTile(
                          title: const Text(
                            'Reporting Guidelines',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppConstants.primaryBlue,
                            ),
                          ),
                          trailing: Icon(
                            _isGuidelinesExpanded
                                ? Icons.expand_less
                                : Icons.expand_more,
                            color: AppConstants.primaryBlue,
                          ),
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  Text(
                                    '1. Provide accurate details to assist government officials.',
                                    style: TextStyle(fontSize: 14),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    '2. Avoid duplicate reports; check existing submissions.',
                                    style: TextStyle(fontSize: 14),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    '3. Submit issues that benefit the public (e.g., infrastructure, safety).',
                                    style: TextStyle(fontSize: 14),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    '4. Attach clear evidence (photos, documents) if available.',
                                    style: TextStyle(fontSize: 14),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          onExpansionChanged: (bool expanded) {
                            if (mounted) {
                              setState(() {
                                _isGuidelinesExpanded = expanded;
                              });
                            }
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }
}

class UploadableFile {
  final String name;
  final Uint8List bytes;
  UploadableFile({required this.name, required this.bytes});
}