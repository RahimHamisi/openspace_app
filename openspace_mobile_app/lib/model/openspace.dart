import 'package:latlong2/latlong.dart';

class OpenSpaceMarker {
  final String id;
  final String name;
  final String district;
  final double latitude;
  final double longitude;
  final bool isActive;
  final String status;

  OpenSpaceMarker({
    required this.id,
    required this.name,
    required this.district,
    required this.latitude,
    required this.longitude,
    required this.isActive,
    required this.status,
  });

  factory OpenSpaceMarker.fromJson(Map<String, dynamic> json) {
    return OpenSpaceMarker(
      id: json['id'],
      name: json['name'],
      district: json['district'],
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      isActive: json['isActive'],
      status: json['status'],
    );
  }
}
