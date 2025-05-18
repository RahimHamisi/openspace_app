import 'package:flutter/material.dart';

class TrackProgressScreen extends StatefulWidget {
  const TrackProgressScreen({super.key});

  @override
  _TrackProgressScreenState createState() => _TrackProgressScreenState();
}

class _TrackProgressScreenState extends State<TrackProgressScreen> {
  final TextEditingController _referenceIdController = TextEditingController();
  Map<String, dynamic>? reportData;

  // Mock report database (Replace with API later)
  final List<Map<String, dynamic>> _mockReports = [
    {'referenceId': 'A123', 'reportId': '1234', 'type': 'Pollution Hazard', 'location': 'Central Park', 'date': 'May 16, 2025', 'status': 'Pending', 'description': 'Observed excessive smoke near the park.', 'attachments': []},
    {'referenceId': 'B456', 'reportId': '5678', 'type': 'Traffic Hazard', 'location': 'Downtown Area', 'date': 'May 15, 2025', 'status': 'Ref Sm', 'description': 'Broken traffic lights causing congestion.', 'attachments': ['file1.png', 'file2.jpg']},
  ];

  void _fetchReportDetails() {
    final enteredRefId = _referenceIdController.text.trim();
    final foundReport = _mockReports.firstWhere((report) => report['referenceId'] == enteredRefId, orElse: () => {});

    setState(() {
      reportData = foundReport.isNotEmpty ? foundReport : null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('Track Progress'),
        centerTitle: true,
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Enter Reference ID", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _referenceIdController,
                    decoration: InputDecoration(
                      hintText: "Enter Reference ID...",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _fetchReportDetails,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                  child: const Text("Search"),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // ✅ Report Details Section
            Expanded(
              child: reportData == null
                  ? const Center(child: Text("No report found", style: TextStyle(fontSize: 16, color: Colors.grey)))
                  : SingleChildScrollView(
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
                            Text(reportData!['type'], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                          ],
                        ),
                        const SizedBox(height: 12),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(children: [const Icon(Icons.location_on, size: 16, color: Colors.blue), const SizedBox(width: 5), Text(reportData!['location'])]),
                            Row(children: [const Icon(Icons.calendar_today, size: 16, color: Colors.blue), const SizedBox(width: 5), Text(reportData!['date'])]),
                            Container(
                              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                              decoration: BoxDecoration(
                                color: reportData!['status'] == "Ref Sm" ? Colors.red : reportData!['status'] == "Pending" ? Colors.orange : Colors.green,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(reportData!['status'], style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        const Text("Description", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 8),
                        Text(reportData!['description'], style: const TextStyle(fontSize: 14, color: Colors.grey)),

                        const SizedBox(height: 12),

                        const Text("Attachments", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 8),
                        reportData!['attachments'].isEmpty
                            ? const Text("No attachments available", style: TextStyle(color: Colors.grey))
                            : Wrap(
                          spacing: 10,
                          children: reportData!['attachments'].map<Widget>((file) {
                            return Chip(
                              avatar: const Icon(Icons.insert_drive_file, color: Colors.blue),
                              label: Text(file, overflow: TextOverflow.ellipsis),
                            );
                          }).toList(),
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
