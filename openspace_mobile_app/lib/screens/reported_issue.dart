import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:openspace_mobile_app/utils/constants.dart';
import '../service/openspace_service.dart';
import '../model/Report.dart';

class ReportedIssuesPage extends StatefulWidget {
  const ReportedIssuesPage({super.key});

  @override
  _ReportedIssuesPageState createState() => _ReportedIssuesPageState();
}

class _ReportedIssuesPageState extends State<ReportedIssuesPage> {
  final int itemsPerPage = 5;
  int currentPage = 0;
  bool _isLoading = true;
  String? _errorMessage;
  List<Report> _allFetchedIssues = [];
  late final OpenSpaceService _openSpaceService;

  @override
  void initState() {
    super.initState();
    _openSpaceService = OpenSpaceService();
    _fetchReports();
  }

  Future<void> _fetchReports() async {
    if (!mounted) return; // Avoid calling setState if the widget is disposed
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final reports = await _openSpaceService.getAllReports();
      if (!mounted) return;
      setState(() {
        _allFetchedIssues = reports;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString().replaceFirst(RegExp(r'^Exception:\s*'), '');
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Report> displayedIssues = _allFetchedIssues.length > itemsPerPage
        ? _allFetchedIssues
        .skip(currentPage * itemsPerPage)
        .take(itemsPerPage)
        .toList()
        : _allFetchedIssues;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppConstants.primaryBlue,
        elevation: 3,
        toolbarHeight: 80,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(20))),
        title: const Text('Reported Issues',
            style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white)),
        centerTitle: true,
        leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context)),
        actions: [
          IconButton(
              icon: const Icon(Icons.search, color: Colors.white),
              onPressed: () {
                // TODO: Implement search functionality
                print("Search button pressed");
              }),
        ],
      ),
      body: _buildBodyContent(displayedIssues),
    );
  }

  Widget _buildBodyContent(List<Report> displayedIssues) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red, fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _fetchReports,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                child: const Text('Retry', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      );
    }

    if (_allFetchedIssues.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.info_outline, color: Colors.grey, size: 48),
              const SizedBox(height: 16),
              const Text(
                'No issues reported yet.',
                style: TextStyle(fontSize: 18, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _fetchReports, // Option to retry fetching
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                child: const Text('Refresh', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      );
    }

    // Display list and pagination if there are issues
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0), // Adjust padding
            itemCount: displayedIssues.length,
            itemBuilder: (context, index) =>
                _buildIssueCard(context, displayedIssues[index]),
          ),
        ),
        if (_allFetchedIssues.length > itemsPerPage)
          _buildPaginationControls(),
      ],
    );
  }

  Widget _buildIssueCard(BuildContext context, Report issue) {
    final formattedDate = DateFormat('yyyy-MM-dd').format(issue.createdAt.toLocal());

    final String imageUrl = (issue.file != null && issue.file!.isNotEmpty)
        ? issue.file!
        : 'https://via.placeholder.com/150'; // Fallback placeholder URL

    final bool hasCoordinates = issue.latitude != null && issue.longitude != null;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12), // Increased bottom padding
      child: Card(
        elevation: 3,
        shadowColor: Colors.black.withOpacity(0.15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        clipBehavior: Clip.antiAlias, // Ensures InkWell ripple stays within card bounds
        child: InkWell(
          onTap: () => Navigator.pushNamed(context, '/issue_detail', arguments: issue),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Image.network(
                    imageUrl,
                    width: 60,  // Slightly larger image
                    height: 60,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Image.asset(
                      'assets/images/report1.jpg',
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                    ),
                    loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                      if (loadingProgress == null) return child;
                      return SizedBox(
                        width: 60,
                        height: 60,
                        child: Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2.0,
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                : null,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        issue.spaceName ?? 'Unnamed Space',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        issue.description, // Assuming description is non-nullable from your Report model
                        style: TextStyle(fontSize: 13.5, color: Colors.grey[700]),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded( // Allow this Row to take available space before the date
                            child: InkWell(
                              onTap: hasCoordinates
                                  ? () => Navigator.pushNamed(context, '/map', arguments: {
                                "latitude": issue.latitude,
                                "longitude": issue.longitude,
                              })
                                  : null,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Image.asset(
                                    'assets/images/location.jpg',
                                    height: 18,
                                    width: 18,
                                    fit: BoxFit.cover,
                                    color: hasCoordinates ? Colors.blue : Colors.grey, // Indicate if tappable
                                  ),
                                  const SizedBox(width: 5),
                                  Flexible(
                                    child: Text(
                                      issue.spaceName ?? 'Location N/A',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                        color: hasCoordinates ? Colors.blue : Colors.grey[600],
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 8), // Spacer
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Image.asset(
                                'assets/images/calendar2.jpg',
                                height: 18,
                                width: 18,
                                fit: BoxFit.cover,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                formattedDate,
                                style: TextStyle(fontSize: 13, color: Colors.grey[800]),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPaginationControls() {
    int totalPages = (_allFetchedIssues.length / itemsPerPage).ceil();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            color: Colors.blue,
            disabledColor: Colors.grey,
            onPressed: currentPage > 0
                ? () => setState(() => currentPage--)
                : null,
          ),
          Text(
            "Page ${currentPage + 1} of $totalPages",
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward_ios),
            color: Colors.blue,
            disabledColor: Colors.grey,
            onPressed: (currentPage + 1) * itemsPerPage < _allFetchedIssues.length
                ? () => setState(() => currentPage++)
                : null,
          ),
        ],
      ),
    );
  }
}