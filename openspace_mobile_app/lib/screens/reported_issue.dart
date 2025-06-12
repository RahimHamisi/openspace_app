import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final reports = await _openSpaceService.getAllReports();
      setState(() {
        _allFetchedIssues = reports;
        _isLoading = false;
      });
    } catch (e) {
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
        backgroundColor: Colors.blue,
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
              onPressed: () {}),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_errorMessage!,
                style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _fetchReports,
              child: const Text('Retry'),
            ),
          ],
        ),
      )
          : Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: displayedIssues.length,
              itemBuilder: (context, index) =>
                  _buildIssueCard(context, displayedIssues[index]),
            ),
          ),
          if (_allFetchedIssues.length > itemsPerPage)
            _buildPaginationControls(),
        ],
      ),
    );
  }

  Widget _buildIssueCard(BuildContext context, Report issue) {
    // Format the createdAt date
    final formattedDate = DateFormat('yyyy-MM-dd')
        .format(DateTime.parse(issue.createdAt).toLocal());

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Card(
        elevation: 4,
        shadowColor: Colors.black.withOpacity(0.2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: InkWell(
          onTap: () => Navigator.pushNamed(context, '/issue_detail',
              arguments: issue),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.network(
                  issue.file.isNotEmpty
                      ? issue.file
                      : 'https://via.placeholder.com/40',
                  width: 40,
                  height: 40,
                  errorBuilder: (context, error, stackTrace) => Image.asset(
                    'assets/images/report1.jpg',
                    width: 40,
                    height: 40,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(issue.spaceName,
                          style: const TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w600)),
                      Text(issue.description,
                          style: const TextStyle(
                              fontSize: 13, color: Colors.grey),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: InkWell(
                                  onTap: () => Navigator.pushNamed(context,'/map',arguments: {
                                    "latitude" : issue.latitude,
                                    "longitude" : issue.longitude,
                                  }),
                                  child: Image.asset(
                                    'assets/images/location.jpg',
                                    height: 20,
                                    width: 20,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 5),
                              InkWell(
                                  onTap: () => Navigator.pushNamed(context,'/map',arguments: {
                                    "latitude" : issue.latitude,
                                    "longitude" : issue.longitude,
                                  }),
                                child: Text(
                                  issue.spaceName,
                                  style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.blue),
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.asset(
                                  'assets/images/calendar2.jpg',
                                  height: 20,
                                  width: 20,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(formattedDate,
                                  style: const TextStyle(
                                      fontSize: 13,
                                    )),
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            onPressed: currentPage > 0
                ? () => setState(() => currentPage--)
                : null,
          ),
          Text(
              "Page ${currentPage + 1} / ${(_allFetchedIssues.length / itemsPerPage).ceil()}",
              style: const TextStyle(fontSize: 16)),
          IconButton(
            icon: const Icon(Icons.arrow_forward_ios),
            onPressed: (currentPage + 1) * itemsPerPage < _allFetchedIssues.length
                ? () => setState(() => currentPage++)
                : null,
          ),
        ],
      ),
    );
  }


}