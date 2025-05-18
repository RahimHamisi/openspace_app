import 'package:flutter/material.dart';

class ReportedIssuesPage extends StatefulWidget {
  const ReportedIssuesPage({super.key});

  @override
  _ReportedIssuesPageState createState() => _ReportedIssuesPageState();
}

class _ReportedIssuesPageState extends State<ReportedIssuesPage> {
  final int itemsPerPage = 5;
  int currentPage = 0;

  @override
  Widget build(BuildContext context) {
    final List<_IssueData> displayedIssues = _reportedIssues.length > itemsPerPage
        ? _reportedIssues.skip(currentPage * itemsPerPage).take(itemsPerPage).toList()
        : _reportedIssues;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        elevation: 3,
        toolbarHeight: 80,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(bottom: Radius.circular(20))),
        title: const Text('Reported Issues', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white)),
        centerTitle: true,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context)),
        actions: [IconButton(icon: const Icon(Icons.search, color: Colors.white), onPressed: () {})],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: displayedIssues.length,
              itemBuilder: (context, index) => _buildIssueCard(context, displayedIssues[index]),
            ),
          ),
          if (_reportedIssues.length > itemsPerPage) _buildPaginationControls(),
          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/report-issue'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                textStyle: const TextStyle(fontSize: 16),
              ),
              child: const Text('Add Report'),
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildIssueCard(BuildContext context, _IssueData issue) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: SizedBox(
        height: 140, // Adjust card size as needed
        child: InkWell(
          onTap: () => Navigator.pushNamed(context, issue.route),
          borderRadius: BorderRadius.circular(12),
          child: Card(
            elevation: 4,
            shadowColor: Colors.black.withOpacity(0.2),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Image.asset(issue.iconPath, width: 40, height: 40),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                             Text(issue.title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                             Text(issue.description, style: const TextStyle(fontSize: 13, color: Colors.grey)),
                             // Text(issue.Status ? '✅ Solved' : '⏳ Pending', style: const TextStyle(color: Colors.white, fontSize: 14)),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    const SizedBox(height: 10),
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.asset(
                                        'assets/images/location.jpg',
                                        height: 20,
                                        width: 20,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    const SizedBox(width: 5),
                                    Text(issue.location, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                                  ],
                                ),
                                Row(
                                  children: [
                                    const SizedBox(height: 10),
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.asset(
                                        'assets/images/calendar2.jpg',
                                        height: 30,
                                        width:30,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    // const Icon(Icons.calendar_today, size: 16, color: Colors.blue),
                                    const SizedBox(width: 10),
                                    Text(issue.dateReported, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                                  ],
                                ),
                              ],
                            ),

                          ],
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
            onPressed: currentPage > 0 ? () => setState(() => currentPage--) : null,
          ),
          Text("Page ${currentPage + 1} / ${( _reportedIssues.length / itemsPerPage).ceil()}", style: const TextStyle(fontSize: 16)),
          IconButton(
            icon: const Icon(Icons.arrow_forward_ios),
            onPressed: (currentPage + 1) * itemsPerPage < _reportedIssues.length ? () => setState(() => currentPage++) : null,
          ),

        ],
      ),
    );
  }
}

class _IssueData {
  final String iconPath;
  final String title;
  final String description;
  final String dateReported;
  final String Status;
  final String location;
  final String route;

  const _IssueData({
    required this.iconPath,
    required this.title,
    required this.description,
    required this.dateReported,
    required this.Status,
    required this.location,
    required this.route,
  });
}

final List<_IssueData> _reportedIssues = [
  _IssueData(iconPath: 'assets/images/report1.jpg', title: 'Broken Bench in Park', description: 'Wooden bench damaged', dateReported: '2 days ago',  Status: 'solved', location: 'Central Park', route: '/issue_detail'),
  _IssueData(iconPath: 'assets/images/report1.jpg', title: 'Flooded Pathway', description: 'Water overflowed due to rain', dateReported: '5 days ago', Status: 'solved', location: 'Riverside Walkway', route: '/issue_detail'),
  _IssueData(iconPath: 'assets/images/report1.jpg', title: 'Damaged Streetlight', description: 'Light pole fallen', dateReported: '1 week ago',  Status: 'solved', location: 'Downtown Square', route: '/issue_detail'),
  _IssueData(iconPath: 'assets/images/report1.jpg', title: 'Broken Bench in Park', description: 'Wooden bench damaged', dateReported: '2 days ago',  Status: 'solved', location: 'Central Park', route: '/issue_detail'),
  _IssueData(iconPath: 'assets/images/report1.jpg', title: 'Flooded Pathway', description: 'Water overflowed due to rain', dateReported: '5 days ago',   Status: 'solved', location: 'Riverside Walkway', route: '/issue_detail'),
  _IssueData(iconPath: 'assets/images/report1.jpg', title: 'Damaged Streetlight', description: 'Light pole fallen', dateReported: '1 week ago',  Status: 'solved', location: 'Downtown Square', route: '/issue_detail'),
  _IssueData(iconPath: 'assets/images/report1.jpg', title: 'Broken Bench in Park', description: 'Wooden bench damaged', dateReported: '2 days ago', Status: 'solved', location: 'Central Park', route: '/issue_detail'),
  _IssueData(iconPath: 'assets/images/report1.jpg', title: 'Flooded Pathway', description: 'Water overflowed due to rain', dateReported: '5 days ago', Status: 'solved', location: 'Riverside Walkway', route: '/issue_detail'),
  _IssueData(iconPath: 'assets/images/report1.jpg', title: 'Damaged Streetlight', description: 'Light pole fallen', dateReported: '1 week ago', Status: 'solved', location: 'Downtown Square', route: '/issue_detail'),
];
