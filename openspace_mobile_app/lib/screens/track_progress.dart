import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../model/Report.dart'; // Ensure this path is correct
import '../service/openspace_service.dart'; // Ensure this path is correct
import '../utils/constants.dart'; // Ensure this path is correct

class TrackProgressScreen extends StatefulWidget {
  const TrackProgressScreen({super.key});

  @override
  _TrackProgressScreenState createState() => _TrackProgressScreenState();
}

class _TrackProgressScreenState extends State<TrackProgressScreen> {
  final TextEditingController _referenceIdController = TextEditingController();
  Report? reportData;
  bool _isLoading = false;
  String? _errorMessage;
  late final OpenSpaceService _openSpaceService;

  @override
  void initState() {
    super.initState();
    _openSpaceService = OpenSpaceService();
  }

  Future<void> _fetchReportDetails() async {
    final enteredRefId = _referenceIdController.text.trim();
    if (enteredRefId.isEmpty) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Please enter a Reference ID';
        reportData = null;
      });
      return;
    }

    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      reportData = null;
    });

    try {
      // Assuming getAllReports fetches all and then you filter client-side.
      // If you have a service method like getReportById(enteredRefId), that would be more efficient.
      final reports = await _openSpaceService.getAllReports();
      Report? matchingReport;
      try {
        matchingReport = reports.firstWhere(
              (report) => report.reportId == enteredRefId,
        );
      } catch (e) {
        // firstWhere throws if no element is found and orElse is not provided or orElse returns null.
        matchingReport = null;
      }

      if (!mounted) return;
      setState(() {
        reportData = matchingReport;
        _isLoading = false;
        if (matchingReport == null) {
          _errorMessage = 'No report found for Reference ID: $enteredRefId';
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString().replaceFirst(RegExp(r'^Exception:\s*'), '');
        reportData = null;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Local variable for cleaner access inside the build method when reportData is not null
    final Report? currentReport = reportData;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Track Progress',
          style: TextStyle(color: AppConstants.white),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Enter Reference ID",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _referenceIdController,
                    decoration: InputDecoration(
                      hintText: "Enter Reference ID...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    onFieldSubmitted: (_) => _fetchReportDetails(),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _isLoading ? null : _fetchReportDetails,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                      : const Text(
                    "Search",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: _buildReportDetailsView(currentReport),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportDetailsView(Report? currentReport) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _errorMessage!, // We've already checked _errorMessage != null
              style: const TextStyle(fontSize: 16, color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _fetchReportDetails,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
              child: const Text('Retry', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
    }

    if (currentReport == null) {
      // This handles both the initial state (before search) and "No report found" after a search.
      return const Center(
        child: Text(
          "Enter a Reference ID and click Search to view report details.",
          style: TextStyle(fontSize: 16, color: Colors.grey),
          textAlign: TextAlign.center,
        ),
      );
    }

    // --- Null-safe access and defaults for reportData fields ---
    // final String reportType = (currentReport.type != null && currentReport.type!.isNotEmpty)
    //     ? currentReport.type!
    //     : 'Issue Report';

    final String spaceName = currentReport.spaceName ?? 'N/A';

    // Fix for Date: Use createdAt directly as it's already DateTime
    final String formattedDate = DateFormat('MMMM dd, yyyy').format(currentReport.createdAt.toLocal());

    final String status = currentReport.status ?? 'Unknown';
    Color statusColor;
    switch (status) {
      case 'Ref Sm': // Assuming this is one of your actual status strings
        statusColor = Colors.red;
        break;
      case 'Pending':
        statusColor = Colors.orange;
        break;
      case 'Resolved': // Example, adjust to your actual status
        statusColor = Colors.green;
        break;
      default:
        statusColor = Colors.grey;
    }
    final String description = currentReport.description;

    final String? fileUrl = currentReport.file;
    final bool hasAttachment = fileUrl != null && fileUrl.isNotEmpty;
    final String attachmentName = hasAttachment ? fileUrl.split('/').last : "No attachments available";


    return SingleChildScrollView(
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.report_problem, size: 24, color: Colors.blue),
                  const SizedBox(width: 8),
                  // Text(
                  //   style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  // ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.location_on, size: 16, color: Colors.blue),
                        const SizedBox(width: 5),
                        Flexible(child: Text(spaceName, overflow: TextOverflow.ellipsis)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8), // Spacer
                  Flexible(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.calendar_today, size: 16, color: Colors.blue),
                        const SizedBox(width: 5),
                        Text(formattedDate),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Align( // Center the status badge or place it as desired
                alignment: Alignment.centerRight,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    status,
                    style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const Text("Description", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Text(description, style: const TextStyle(fontSize: 14, color: Colors.grey)),
              const SizedBox(height: 12),
              const Text("Attachments", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              hasAttachment
                  ? Wrap(
                spacing: 10,
                children: [
                  Chip(
                    avatar: const Icon(Icons.insert_drive_file, color: Colors.blue),
                    label: Text(attachmentName, overflow: TextOverflow.ellipsis,),
                    // onTap: () { /* TODO: Implement file opening/downloading */ }
                  ),
                ],
              )
                  : const Text("No attachments available", style: TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      ),
    );
  }
}