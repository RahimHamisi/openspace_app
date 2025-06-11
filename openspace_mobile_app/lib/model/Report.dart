// You can put this in a new file, e.g., models/report_model.dart
// or directly in reported_issue.dart if it's only used here for now.

class Report {
  final String id; // GraphQL ID
  final String reportId; // Your custom reportId
  final String? description;
  final DateTime? createdAt; // Assuming it's a DateTime from GraphQL
  final double? latitude;
  final double? longitude;
  final String? spaceName;
  final String? file; // Assuming this is a URL or path to the file

  Report({
    required this.id,
    required this.reportId,
    this.description,
    this.createdAt,
    this.latitude,
    this.longitude,
    this.spaceName,
    this.file,
  });

  factory Report.fromJson(Map<String, dynamic> json) {
    return Report(
      id: json['id'] as String,
      reportId: json['reportId'] as String,
      description: json['description'] as String?,
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt'] as String) : null,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      spaceName: json['spaceName'] as String?,
      file: json['file'] as String?,
    );
  }

  // Helper to convert to your existing _IssueData if needed
  // This is where you map fields from Report to _IssueData
  _IssueData toIssueData() {
    return _IssueData(
      // Assuming you want to use the report's description as the title for the card
      // and a shortened version or default for the card's description.
      // Adjust this mapping as needed.
      title: description?.isNotEmpty == true
          ? (description!.length > 50 ? '${description!.substring(0, 47)}...' : description!)
          : 'Report: $reportId',
      description: spaceName ?? 'Details unavailable', // Or use a snippet of the main description
      dateReported: createdAt != null
          ? "${createdAt!.toLocal().year}-${createdAt!.toLocal().month.toString().padLeft(2, '0')}-${createdAt!.toLocal().day.toString().padLeft(2, '0')}"
          : "Date N/A",
      // You might need a status field from your GraphQL query if you want to display it.
      // For now, I'm setting a default.
      status: "Pending", // Or determine based on other data
      location: (latitude != null && longitude != null)
          ? "Lat: ${latitude!.toStringAsFixed(2)}, Lon: ${longitude!.toStringAsFixed(2)}"
          : (spaceName ?? "Location N/A"),
      // Determine iconPath based on 'file' type or other criteria
      iconPath: (file != null && (file!.toLowerCase().endsWith('.jpg') || file!.toLowerCase().endsWith('.png')))
          ? 'assets/images/image_report_icon.png' // Placeholder for actual image icon
          : 'assets/images/default_report_icon.png', // Placeholder
      route: '/issue_detail/$reportId', // Example route for detail page
    );
  }
}

// Your existing _IssueData class (keep as is or adapt if Report model is sufficient)
class _IssueData {
  final String iconPath;
  final String title;
  final String description;
  final String dateReported;
  final String status; // Renamed from 'Status' to follow Dart conventions
  final String location;
  final String route;

  const _IssueData({
    required this.iconPath,
    required this.title,
    required this.description,
    required this.dateReported,
    required this.status,
    required this.location,
    required this.route,
  });
}