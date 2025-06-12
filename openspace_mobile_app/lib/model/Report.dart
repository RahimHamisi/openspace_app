class Report {
  final String id;
  final String description;
  final String createdAt;
  final double latitude;
  final double longitude;
  final String reportId;
  final String spaceName;
  final String file;
  final String type;
  final String status;

  Report({
    required this.id,
    required this.description,
    required this.createdAt,
    required this.latitude,
    required this.longitude,
    required this.reportId,
    required this.spaceName,
    required this.file,
    required this.type,
    required this.status,
  });

  factory Report.fromJson(Map<String, dynamic> json) {
    return Report(
      id: json['id'] as String,
      description: json['description'] as String,
      createdAt: json['createdAt'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      reportId: json['reportId'] as String,
      spaceName: json['spaceName'] as String,
      file: json['file'] as String? ?? '',
      type: json['type'] as String? ?? 'Issue Report',
      status: json['status'] as String? ?? 'Pending',
    );
  }
}