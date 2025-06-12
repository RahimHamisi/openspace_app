import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../model/Report.dart';
import '../service/openspace_service.dart';
import '../utils/constants.dart';


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
      setState(() {
        _errorMessage = 'Please enter a Reference ID';
        reportData = null;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      reportData = null;
    });

    try {
      final reports = await _openSpaceService.getAllReports();
      final matchingReport = reports.firstWhere(
            (report) => report.reportId == enteredRefId,
        orElse: () => null as Report,
      );
      setState(() {
        reportData = matchingReport;
        _isLoading = false;
        if (matchingReport == null) {
          _errorMessage = 'No report found for Reference ID: $enteredRefId';
        }
      });
    } catch (e) {
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
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _fetchReportDetails,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                  ),
                  child: const Text(
                    "Search",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _errorMessage != null
                  ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _errorMessage!,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.red,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _fetchReportDetails,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                      ),
                      child: const Text(
                        'Retry',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              )
                  : reportData == null
                  ? const Center(
                child: Text(
                  "No report found",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
              )
                  : SingleChildScrollView(
                child: Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.report_problem,
                              size: 24,
                              color: Colors.blue,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              reportData!.type.isNotEmpty
                                  ? reportData!.type
                                  : 'Issue Report',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.location_on,
                                  size: 16,
                                  color: Colors.blue,
                                ),
                                const SizedBox(width: 5),
                                Text(reportData!.spaceName),
                              ],
                            ),
                            Row(
                              children: [
                                const Icon(
                                  Icons.calendar_today,
                                  size: 16,
                                  color: Colors.blue,
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  DateFormat('MMMM dd, yyyy')
                                      .format(DateTime.parse(
                                      reportData!.createdAt)),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                vertical: 6,
                                horizontal: 12,
                              ),
                              decoration: BoxDecoration(
                                color: reportData!.status ==
                                    'Ref Sm'
                                    ? Colors.red
                                    : reportData!.status ==
                                    'Pending'
                                    ? Colors.orange
                                    : Colors.green,
                                borderRadius:
                                BorderRadius.circular(8),
                              ),
                              child: Text(
                                reportData!.status,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          "Description",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          reportData!.description,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          "Attachments",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        reportData!.file.isEmpty
                            ? const Text(
                          "No attachments available",
                          style:
                          TextStyle(color: Colors.grey),
                        )
                            : Wrap(
                          spacing: 10,
                          children: [
                            Chip(
                              avatar: const Icon(
                                Icons.insert_drive_file,
                                color: Colors.blue,
                              ),
                              label: Text(
                                reportData!.file
                                    .split('/')
                                    .last,

                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}