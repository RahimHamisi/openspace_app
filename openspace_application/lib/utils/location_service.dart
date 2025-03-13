import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';

class LocationService {
  final Location _location = Location();

  // Get user's current location
  Future<LatLng?> getUserLocation() async {
    try {
      final hasPermission = await _location.requestPermission();
      if (hasPermission == PermissionStatus.granted) {
        final locationData = await _location.getLocation();
        return LatLng(locationData.latitude!, locationData.longitude!);
      }
    } catch (e) {
      print('Error fetching user location: $e');
    }
    return null;
  }

  // Search location using OpenStreetMap Nominatim API
  Future<List<LocationSuggestion>> searchLocation(String query) async {
    final url = Uri.parse(
      'https://nominatim.openstreetmap.org/search?format=json&q=$query',
    );
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) {
          final lat = double.parse(item['lat']);
          final lon = double.parse(item['lon']);
          final displayName = item['display_name'];
          return LocationSuggestion(
            name: displayName,
            position: LatLng(lat, lon),
          );
        }).toList();
      }
    } catch (e) {
      print('Error searching location: $e');
    }
    return [];
  }

  // / Reverse geocode to get location name from coordinates
  Future<String?> getLocationName(LatLng position) async {
    final url = Uri.parse(
      'https://nominatim.openstreetmap.org/reverse?format=json&lat=${position.latitude}&lon=${position.longitude}',
    );
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['display_name'];
      }
    } catch (e) {
      print('Error reverse geocoding: $e');
    }
    return null;
  }
}

class LocationSuggestion {
  final String name;
  final LatLng position;

  LocationSuggestion({required this.name, required this.position});
}
