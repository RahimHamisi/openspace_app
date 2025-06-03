import 'package:latlong2/latlong.dart';

class OpenSpaceMarker {
  final String id;
  final String name;
  final String district;
  final bool isAvailable;
  final LatLng point;

  OpenSpaceMarker({
    required this.id,
    required this.name,
    required this.district,
    required this.isAvailable,
    required this.point,
  });

  factory OpenSpaceMarker.fromJson(Map<String, dynamic> json) {
    return OpenSpaceMarker(
      id: json['id'],
      name: json['name'],
      district: json['district'],
      isAvailable: json['status'] == 'Available',
      point: LatLng(
        double.parse(json['latitude'].toString()),
        double.parse(json['longitude'].toString()),
      ),
    );
  }
}
