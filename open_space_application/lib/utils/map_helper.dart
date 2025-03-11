import 'package:latlong2/latlong.dart';

// Function to handle map tap and return tapped position
LatLng onMapTap(LatLng tapPosition) {
  // You can add custom logic here to handle the tap (e.g., show the coordinates, trigger an action)
  print("Tapped position: ${tapPosition.latitude}, ${tapPosition.longitude}");
  return tapPosition;
}
