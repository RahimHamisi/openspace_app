import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';

class LocationService {
  final Location _location = Location();

  Future<LatLng?> getUserLocation() async {
    try {
      var userLocation = await _location.getLocation();
      return LatLng(userLocation.latitude!, userLocation.longitude!);
    } catch (e) {
      return null;
    }
  }
}
