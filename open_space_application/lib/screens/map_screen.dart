import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../utils/location_service.dart'; // Import location service

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  MapScreenState createState() => MapScreenState();
}

class MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  LatLng _initialPosition = LatLng(
    -6.7741,
    39.2026,
  ); // Kinondoni, Dar es Salaam
  final LocationService _locationService = LocationService();

  @override
  void initState() {
    super.initState();
    _getUserLocation();
  }

  // Get User Location and Update Map
  void _getUserLocation() async {
    LatLng? userLocation = await _locationService.getUserLocation();
    if (userLocation != null) {
      setState(() {
        _initialPosition = userLocation;
      });
      _mapController.move(userLocation, 15.0);
    }
  }

  // Zoom In
  void _zoomIn() {
    _mapController.move(
      _mapController.camera.center,
      _mapController.camera.zoom + 1,
    ); // ✅ Use 'camera.center'
  }

  // Zoom Out
  void _zoomOut() {
    _mapController.move(
      _mapController.camera.center,
      _mapController.camera.zoom - 1,
    ); // ✅ Use 'camera.center'
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("OpenStreetMap - Kinondoni")),
      body: Stack(
        children: [
          // Map Implementation
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter:
                  _initialPosition, // ✅ Use 'initialCenter' instead of 'center'
              initialZoom: 14.0, // ✅ Use 'initialZoom' instead of 'zoom'
              maxZoom: 18.0,
              minZoom: 6.0,
            ),
            children: [
              TileLayer(
                urlTemplate:
                    "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                subdomains: ['a', 'b', 'c'],
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: _initialPosition,
                    width: 80.0,
                    height: 80.0,
                    child: Icon(
                      Icons.location_pin,
                      color: Colors.red,
                      size: 40,
                    ), // ✅ Change 'builder' to 'child'
                  ),
                ],
              ),
            ],
          ),

          // Zoom Controls
          Positioned(
            bottom: 50,
            right: 10,
            child: Column(
              children: [
                FloatingActionButton(
                  onPressed: _zoomIn,
                  heroTag: "zoomIn",
                  child: Icon(Icons.add),
                ),
                SizedBox(height: 10),
                FloatingActionButton(
                  onPressed: _zoomOut,
                  heroTag: "zoomOut",
                  child: Icon(Icons.remove),
                ),
              ],
            ),
          ),

          // Locate Me Button
          Positioned(
            bottom: 120,
            right: 10,
            child: FloatingActionButton(
              onPressed: _getUserLocation,
              heroTag: "locateMe",
              child: Icon(Icons.my_location),
            ),
          ),
        ],
      ),
    );
  }
}
