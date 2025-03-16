import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import 'dart:collection'; // For LRU cache

class LocationService {
  final Location _location = Location();
  static const String _nominatimBaseUrl = 'https://nominatim.openstreetmap.org';
  static const Map<String, String> _headers = {'User-Agent': 'OpenSpaceApp/1.0 (your.email@example.com)'}; // Add your User-Agent

  // Simple LRU cache for reverse geocoding to avoid repeated API calls
  final _cache = LinkedHashMap<LatLng, String?>(equals: (a, b) => a == b, hashCode: (latlng) => latlng.hashCode);
  static const int _cacheSize = 50;

  // Get user's current location
  Future<LatLng?> getUserLocation() async {
    try {
      bool serviceEnabled = await _location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await _location.requestService();
        if (!serviceEnabled) return null;
      }

      PermissionStatus permission = await _location.hasPermission();
      if (permission == PermissionStatus.denied) {
        permission = await _location.requestPermission();
        if (permission != PermissionStatus.granted) return null;
      }

      final locationData = await _location.getLocation();
      if (locationData.latitude != null && locationData.longitude != null) {
        return LatLng(locationData.latitude!, locationData.longitude!);
      }
    } catch (e) {
      print('Error fetching user location: $e');
    }
    return null;
  }

  // Search location using Nominatim API with caching
  Future<List<LocationSuggestion>> searchLocation(String query) async {
    final url = Uri.parse('$_nominatimBaseUrl/search?format=json&q=$query&limit=5');
    try {
      final response = await http.get(url, headers: _headers);
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) {
          final lat = double.parse(item['lat']);
          final lon = double.parse(item['lon']);
          final displayName = item['display_name'];
          return LocationSuggestion(name: displayName, position: LatLng(lat, lon));
        }).toList();
      } else {
        print('Search failed with status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error searching location: $e');
    }
    return [];
  }

  // Reverse geocode to get location name from coordinates with caching
  Future<String?> getAreaName(LatLng position) async {
    // Check cache first
    if (_cache.containsKey(position)) {
      return _cache[position];
    }

    final url = Uri.parse(
      '$_nominatimBaseUrl/reverse?format=json&lat=${position.latitude}&lon=${position.longitude}&addressdetails=1',
    );
    try {
      final response = await http.get(url, headers: _headers);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        String? displayName = data['display_name'];
        if (displayName != null) {
          // Maintain cache size
          if (_cache.length >= _cacheSize) {
            _cache.remove(_cache.keys.first);
          }
          _cache[position] = displayName;
          return displayName;
        }
      } else {
        print('Reverse geocoding failed with status: ${response.statusCode}');
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