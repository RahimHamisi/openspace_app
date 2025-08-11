import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../model/Report.dart';
import '../service/userreports.dart';
import '../utils/constants.dart';

class UserReportsPage extends StatefulWidget {
  const UserReportsPage({super.key});

  @override
  State<UserReportsPage> createState() => _UserReportsPageState();
}

class _UserReportsPageState extends State<UserReportsPage> with SingleTickerProviderStateMixin {
  late Future<List<Report>> _futureReports;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _futureReports = ReportService().fetchUserReports();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String formatDate(DateTime date) {
    return DateFormat.yMMMd().add_jm().format(date);
  }

  Widget _buildReportCard(Report report) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: AppConstants.white,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.report, color: Colors.redAccent, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    report.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _buildDetailRow('ID', report.reportId),
            if (report.spaceName != null) _buildDetailRow('Space', report.spaceName!),
            if (report.status != null)
              _buildDetailRow('Status', report.status!, valueColor: _getStatusColor(report.status!)),
            _buildDetailRow('Date', formatDate(report.createdAt)),
            if (report.user != null) _buildDetailRow('By', report.user!.username ?? "User"),
            if (report.file != null)
              Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  icon: const Icon(Icons.attach_file, color: AppConstants.primaryBlue),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('File URL: ${report.file}')),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'resolved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Widget _buildDetailRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black54,
              fontWeight: FontWeight.w500,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                color: valueColor ?? Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportTab(bool Function(Report) filter) {
    return FutureBuilder<List<Report>>(
      future: _futureReports,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final reports = snapshot.data ?? [];
        final filteredReports = reports.where(filter).toList();
        if (filteredReports.isEmpty) {
          return const Center(child: Text('No reports found.'));
        }

        return RefreshIndicator(
          onRefresh: () async {
            setState(() {
              _futureReports = ReportService().fetchUserReports();
            });
          },
          child: ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: filteredReports.length,
            itemBuilder: (context, index) => _buildReportCard(filteredReports[index]),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Reports', style: TextStyle(color: AppConstants.white)),
        backgroundColor: AppConstants.primaryBlue,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppConstants.white),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppConstants.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: AppConstants.white,
          tabs: const [
            Tab(text: 'Pending'),
            Tab(text: 'Resolved'),
            Tab(text: 'Rejected'),
          ],
        ),
      ),
      body: Container(
        color: AppConstants.white,
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildReportTab((report) => report.status?.toLowerCase() == 'pending'),
            _buildReportTab((report) => report.status?.toLowerCase() == 'resolved'),
            _buildReportTab((report) => report.status?.toLowerCase() == 'rejected'),
          ],
        ),
      ),
    );
  }
}
