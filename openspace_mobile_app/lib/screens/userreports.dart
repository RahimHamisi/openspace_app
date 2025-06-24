// screens/user_reports_page.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../model/Report.dart';
import '../service/userreports.dart';


class UserReportsPage extends StatefulWidget {
  const UserReportsPage({super.key});

  @override
  State<UserReportsPage> createState() => _UserReportsPageState();
}

class _UserReportsPageState extends State<UserReportsPage> {
  late Future<List<Report>> _futureReports;

  @override
  void initState() {
    super.initState();
    _futureReports = ReportService().fetchUserReports();
  }

  String formatDate(DateTime date) {
    return DateFormat.yMMMd().add_jm().format(date);
  }

  Widget _buildReportCard(Report report) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        leading: const Icon(Icons.report, color: Colors.redAccent),
        title: Text(report.description, maxLines: 2, overflow: TextOverflow.ellipsis),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ID: ${report.reportId}'),
            if (report.spaceName != null) Text('Space: ${report.spaceName}'),
            if (report.status != null) Text('Status: ${report.status}'),
            Text('Date: ${formatDate(report.createdAt)}'),
            if (report.user != null) Text('By: ${report.user!.username ?? "User"}'),
          ],
        ),
        trailing: report.file != null
            ? IconButton(
          icon: const Icon(Icons.attach_file),
          onPressed: () {
            // Optional: Implement download/view
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('File URL: ${report.file}')),
            );
          },
        )
            : null,
        onTap: () {
          // Optional: Navigate to detail page
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text('My Reports'),
          backgroundColor: Colors.blue,
         foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
         leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed:() => Navigator.pop(context),
        ),

      ),
      body: FutureBuilder<List<Report>>(
        future: _futureReports,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final reports = snapshot.data ?? [];
          if (reports.isEmpty) {
            return const Center(child: Text('No reports found.'));
          }

          return RefreshIndicator(
            onRefresh: () async {
              setState(() {
                _futureReports = ReportService().fetchUserReports();
              });
            },
            child: ListView.builder(
              itemCount: reports.length,
              itemBuilder: (context, index) => _buildReportCard(reports[index]),
            ),
          );
        },
      ),
    );
  }
}
