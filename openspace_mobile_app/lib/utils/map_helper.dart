import 'package:latlong2/latlong.dart';

LatLng onMapTap(LatLng tapPosition) {
  // ignore: avoid_print
  print("Tapped at: ${tapPosition.latitude}, ${tapPosition.longitude}");
  return tapPosition;
}
