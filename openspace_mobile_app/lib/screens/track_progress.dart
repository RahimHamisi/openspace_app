import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../model/Report.dart'; // Your Report model
import '../service/openspace_service.dart'; // Your service
import '../utils/constants.dart'; // Your constants

class TrackProgressScreen extends StatefulWidget {
  const TrackProgressScreen({super.key});

  @override
  _TrackProgressScreenState createState() => _TrackProgressScreenState();
}

class _TrackProgressScreenState extends State<TrackProgressScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _referenceIdController = TextEditingController();
  Report? reportData;
  bool _isLoading = false;
  String? _errorMessage;
  late final OpenSpaceService _openSpaceService;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _openSpaceService = OpenSpaceService();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _referenceIdController.dispose();
    _animationController.dispose();
    super.dispose();
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
      final reports = await _openSpaceService.getAllReports();
      Report? matchingReport;
      try {
        matchingReport = reports.firstWhere(
              (report) => report.reportId == enteredRefId,
        );
      } catch (e) {
        matchingReport = null;
      }

      if (!mounted) return;
      setState(() {
        reportData = matchingReport;
        _isLoading = false;
        if (matchingReport == null) {
          _errorMessage = 'No report found for Reference ID: $enteredRefId';
        } else {
          _animationController.forward(from: 0);
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
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Track Progress',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: AppConstants.white,
            fontSize: 24,
          ),
        ),
        backgroundColor: AppConstants.primaryBlue,
        elevation: 0,
        centerTitle: true,
        leading: Semantics(
          label: 'Back to previous screen',
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppConstants.white),
            onPressed: () {
              HapticFeedback.lightImpact();
              Navigator.pop(context);
            },
            tooltip: 'Back',
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppConstants.primaryBlue.withOpacity(0.8),
              Colors.white,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Semantics(
                  label: 'Enter Reference ID',
                  child: Text(
                    'Enter Reference ID',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppConstants.white,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _referenceIdController,
                        decoration: InputDecoration(
                          hintText: 'Enter Reference ID...',
                          hintStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppConstants.grey,
                          ),
                          border: Theme.of(context).inputDecorationTheme.border,
                          focusedBorder: Theme.of(context).inputDecorationTheme.focusedBorder,
                          filled: true,
                          fillColor: AppConstants.white,
                        ),
                        style: Theme.of(context).textTheme.bodyMedium,
                        onFieldSubmitted: (_) => _fetchReportDetails(),
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _fetchReportDetails,
                      style: Theme.of(context).elevatedButtonTheme.style?.copyWith(
                        padding: WidgetStateProperty.all(
                          const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppConstants.white,
                        ),
                      )
                          : Semantics(
                        label: 'Search',
                        child: Text(
                          'Search',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppConstants.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: _buildReportDetailsView(reportData),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReportDetailsView(Report? currentReport) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppConstants.white),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Semantics(
              label: 'Error message',
              child: Text(
                _errorMessage!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.redAccent,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _fetchReportDetails,
              style: Theme.of(context).elevatedButtonTheme.style,
              child: Semantics(
                label: 'Retry',
                child: Text(
                  'Retry',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppConstants.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (currentReport == null) {
      return Center(
        child: Semantics(
          label: 'No report message',
          child: Text(
            'Enter a Reference ID and click Search to view report details.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppConstants.white,
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    final String reportId = currentReport.reportId;
    final String spaceName = currentReport.spaceName ?? 'N/A';
    final String formattedDate = DateFormat('MMMM dd, yyyy').format(currentReport.createdAt.toLocal());
    final String description = currentReport.description;
    final String email = currentReport.email ?? 'N/A';
    final String? fileUrl = currentReport.file;
    final bool hasAttachment = fileUrl != null && fileUrl.isNotEmpty;
    final String attachmentName = hasAttachment ? fileUrl.split('/').last : 'No attachments available';
    final String status = currentReport.status ?? 'Pending';
    final Color statusColor = _getStatusColor(status);
    final String userName = currentReport.user?.username ?? 'Anonymous User';

    return SingleChildScrollView(
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: AppConstants.white,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.report_problem, size: 24, color: AppConstants.primaryBlue),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Semantics(
                      label: 'Report ID',
                      child: Text(
                        'Report ID: $reportId',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontSize: 20,
                          color: AppConstants.primaryBlue,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
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
                        const Icon(Icons.location_on, size: 16, color: AppConstants.primaryBlue),
                        const SizedBox(width: 5),
                        Flexible(
                          child: Semantics(
                            label: 'Space Name',
                            child: Text(
                              spaceName,
                              style: Theme.of(context).textTheme.bodyMedium,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.calendar_today, size: 16, color: AppConstants.primaryBlue),
                        const SizedBox(width: 5),
                        Semantics(
                          label: 'Date',
                          child: Text(
                            formattedDate,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                  ),
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
                        const Icon(Icons.person, size: 16, color: AppConstants.primaryBlue),
                        const SizedBox(width: 5),
                        Flexible(
                          child: Semantics(
                            label: 'Submitted By',
                            child: Text(
                              userName,
                              style: Theme.of(context).textTheme.bodyMedium,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.email, size: 16, color: AppConstants.primaryBlue),
                        const SizedBox(width: 5),
                        Flexible(
                          child: Semantics(
                            label: 'Email',
                            child: Text(
                              email,
                              style: Theme.of(context).textTheme.bodyMedium,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: Semantics(
                  label: 'Status',
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                    decoration: BoxDecoration(
                      color: statusColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      status,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppConstants.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Semantics(
                label: 'Description',
                child: Text(
                  'Description',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppConstants.primaryBlue,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Semantics(
                label: 'Description Content',
                child: Text(
                  description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppConstants.grey,
                    height: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Semantics(
                label: 'Attachments',
                child: Text(
                  'Attachments',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppConstants.primaryBlue,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              hasAttachment
                  ? Semantics(
                label: 'Attachment',
                child: Wrap(
                  spacing: 10,
                  children: [
                    ActionChip(
                      avatar: const Icon(Icons.insert_drive_file, color: AppConstants.primaryBlue),
                      label: Text(
                        attachmentName,
                        style: Theme.of(context).textTheme.bodyMedium,
                        overflow: TextOverflow.ellipsis,
                      ),
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Attachment viewing not yet implemented'),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              )
                  : Semantics(
                label: 'No attachments available',
                child: Text(
                  'No attachments available',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppConstants.grey,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              if (currentReport.latitude != null && currentReport.longitude != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Semantics(
                      label: 'Location',
                      child: Text(
                        'Location',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppConstants.primaryBlue,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Semantics(
                      label: 'Location Coordinates',
                      child: Text(
                        'Latitude: ${currentReport.latitude}, Longitude: ${currentReport.longitude}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppConstants.grey,
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'in progress':
        return Colors.blue;
      case 'resolved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}