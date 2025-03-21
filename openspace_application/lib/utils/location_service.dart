import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart' as loc;
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'dart:collection'; // For LRU cache

class LocationService {
  final loc.Location _location = loc.Location();
  static const String _nominatimBaseUrl = 'https://nominatim.openstreetmap.org';
  static const Map<String, String> _headers = {
    'User-Agent': 'OpenSpaceApp/1.0 (your.email@example.com)', // Replace with your email
  };

  // LRU cache for reverse geocoding
  final _cache = LinkedHashMap<String, String?>(
    equals: (a, b) => a == b,
    hashCode: (key) => key.hashCode,
  );
  static const int _cacheSize = 50;

  // Cache for current location to avoid frequent GPS requests
  LatLng? _lastKnownLocation;
  DateTime? _lastLocationTime;
  static const Duration _locationCacheTimeout = Duration(minutes: 1);

  // Check and request location permissions
  Future<bool> _checkAndRequestPermission() async {
    bool serviceEnabled = await _location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _location.requestService();
      if (!serviceEnabled) return false;
    }

    loc.PermissionStatus permission = await _location.hasPermission();
    if (permission == loc.PermissionStatus.denied) {
      permission = await _location.requestPermission();
      if (permission == loc.PermissionStatus.deniedForever) return false;
      if (permission != loc.PermissionStatus.granted) return false;
    }
    return true;
  }

  // Get user's current location with caching
  Future<LatLng?> getUserLocation({bool useCache = true}) async {
    if (useCache &&
        _lastKnownLocation != null &&
        _lastLocationTime != null &&
        DateTime.now().difference(_lastLocationTime!) < _locationCacheTimeout) {
      return _lastKnownLocation;
    }

    try {
      bool serviceEnabled = await _location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await _location.requestService();
        if (!serviceEnabled) return null;
      }

      loc.PermissionStatus permission = await _location.hasPermission();
      if (permission == loc.PermissionStatus.denied) {
        permission = await _location.requestPermission();
        if (permission == loc.PermissionStatus.deniedForever) return null;
        if (permission != loc.PermissionStatus.granted) return null;
      }

      await _location.changeSettings(
        accuracy: loc.LocationAccuracy.high,
        interval: 10000, // 10 seconds
        distanceFilter: 10, // 10 meters
      );

      final locationData = await _location.getLocation();
      final lat = locationData.latitude;
      final lon = locationData.longitude;

      if (lat != null && lon != null) {
        _lastKnownLocation = LatLng(lat, lon);
        _lastLocationTime = DateTime.now();
        return _lastKnownLocation;
      }
    } catch (e) {
      print('Error fetching user location: $e');
    }
    return null;
  }

  // Stream for real-time location updates (for flutter_map_location_marker)
  Stream<LocationMarkerPosition> getLocationStream() async* {
    if (await _checkAndRequestPermission()) {
      await _location.changeSettings(
        accuracy: loc.LocationAccuracy.high,
        interval: 10000, // 10 seconds, consistent with getUserLocation
        distanceFilter: 10, // 10 meters
      );
      await for (final data in _location.onLocationChanged) {
        if (data.latitude != null && data.longitude != null) {
          final position = LocationMarkerPosition(
            latitude: data.latitude!,
            longitude: data.longitude!,
            accuracy: data.accuracy ?? 0.0,
          );
          // Update cache
          _lastKnownLocation = LatLng(data.latitude!, data.longitude!);
          _lastLocationTime = DateTime.now();
          yield position;
        }
      }
    }
    // Stream remains empty if permissions/service are denied
  }

  // Search location using Nominatim API with minimum characters
  Future<List<LocationSuggestion>> searchLocation(String query) async {
    if (query.trim().length < 3) {
      return [];
    }

    final url = Uri.parse(
      '$_nominatimBaseUrl/search?format=json&q=${Uri.encodeQueryComponent(query)}&limit=5',
    );

    try {
      final response = await http.get(url, headers: _headers);
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data
            .map((item) {
              final lat = double.tryParse(item['lat']?.toString() ?? '');
              final lon = double.tryParse(item['lon']?.toString() ?? '');
              final displayName = item['display_name']?.toString();

              if (lat != null && lon != null && displayName != null) {
                return LocationSuggestion(name: displayName, position: LatLng(lat, lon));
              }
              return null;
            })
            .whereType<LocationSuggestion>()
            .toList();
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
    final cacheKey =
        '${position.latitude.toStringAsFixed(5)}_${position.longitude.toStringAsFixed(5)}';

    if (_cache.containsKey(cacheKey)) {
      final value = _cache.remove(cacheKey);
      _cache[cacheKey] = value;
      return value;
    }

    final url = Uri.parse(
      '$_nominatimBaseUrl/reverse?format=json&lat=${position.latitude}&lon=${position.longitude}&addressdetails=1&zoom=18',
    );

    try {
      final response = await http.get(url, headers: _headers);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        String? displayName = data['display_name']?.toString();

        if (displayName != null) {
          if (_cache.length >= _cacheSize) {
            _cache.remove(_cache.keys.first);
          }
          _cache[cacheKey] = displayName;
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