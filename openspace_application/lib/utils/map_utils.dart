import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

List<Marker> getKinondoniSpaces() {
  return [
    Marker(point: const LatLng(-6.7450, 39.2626), child: const Icon(Icons.pin_drop, color: Colors.blue, size: 30)),
    Marker(point: const LatLng(-6.7738, 39.2255), child: const Icon(Icons.pin_drop, color: Colors.blue, size: 30)),
    Marker(point: const LatLng(-6.8160, 39.2100), child: const Icon(Icons.pin_drop, color: Colors.blue, size: 30)),
    Marker(point: const LatLng(-6.7540, 39.2730), child: const Icon(Icons.pin_drop, color: Colors.blue, size: 30)),
    Marker(point: const LatLng(-6.7890, 39.2250), child: const Icon(Icons.pin_drop, color: Colors.blue, size: 30)),
  ];
}

void zoomIn(MapController controller) {
  controller.move(controller.camera.center, controller.camera.zoom + 1);
}

void zoomOut(MapController controller) {
  controller.move(controller.camera.center, controller.camera.zoom - 1);
}