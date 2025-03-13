import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:latlong2/latlong.dart';
// ignore: unused_import
// import 'package:open_space_application/utils/map_helper.dart';
import '../utils/location_service.dart'; // Import location service
// import '../utils/map_helper.dart';

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
  bool isSatelliteView = false;

  @override
  void initState() {
    super.initState();
    _getUserLocation();
  }

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
    );
  }

  // Zoom Out
  void _zoomOut() {
    _mapController.move(
      _mapController.camera.center,
      _mapController.camera.zoom - 1,
    );
  }

  void _searchAndNavigate(LatLng position) {
    setState(() => _initialPosition = position);
    _mapController.move(position, 15.0);
  }

  // Toggle Map View
  void _toggleMapView() {
    setState(() {
      isSatelliteView = !isSatelliteView;
    });
  }

  // Function to report current location
  void _reportCurrentLocation() async {
    LatLng? userLocation = await _locationService.getUserLocation();
    if (userLocation != null) {
      print(
        "User's current location: Lat: ${userLocation.latitude}, Lng: ${userLocation.longitude}",
      );
      // Later, you can integrate this with your backend
    } else {
      print("Failed to get user's current location.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("OpenStreetMap - Kinondoni"),
        actions: [
          IconButton(
            icon: Icon(isSatelliteView ? Icons.map : Icons.photo),
            onPressed: _toggleMapView, // Toggle between street and satellite
          ),
        ],
      ),
      body: Stack(
        children: [
          // Map Implementation
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              interactionOptions: InteractionOptions(
                flags: InteractiveFlag.drag | InteractiveFlag.pinchZoom,
              ),
              initialCenter:
                  _initialPosition, // ✅ Use 'initialCenter' instead of 'center'
              initialZoom: 14.0, // ✅ Use 'initialZoom' instead of 'zoom'
              maxZoom: 18.0,
              minZoom: 6.0,
              // onTap: (tapPosition, point) {
              //   setState(() {
              //     _initialPosition = onMapTap(point); // Update marker position
              //   });
              // },
              onTap: (tapPosition, point) => _searchAndNavigate(point),
            ),

            children: [
              TileLayer(
                key: ValueKey(isSatelliteView), // Forces rebuild
                urlTemplate:
                    isSatelliteView
                        ? "https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}"
                        : "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
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
                    ),
                  ),
                ],
              ),
            ],
          ),
          // / Search Bar
          Positioned(
            top: 40,
            left: 20,
            right: 10,
            child: TypeAheadField<LocationSuggestion>(
              builder: (context, controller, focusNode) {
                return TextField(
                  controller: controller,
                  focusNode: focusNode,
                  decoration: InputDecoration(
                    hintText: 'Search public open space',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                  ),
                );
              },
              suggestionsCallback: (pattern) async {
                return await _locationService.searchLocation(pattern);
              },
              itemBuilder: (context, LocationSuggestion suggestion) {
                return ListTile(
                  leading: const Icon(Icons.location_on),
                  title: Text(suggestion.name),
                );
              },
              onSelected: (LocationSuggestion suggestion) {
                _searchAndNavigate(suggestion.position);
              },
            ),
          ),

          // Zoom and Locate Buttons
          Positioned(
            bottom: 20,
            right: 20,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FloatingActionButton(
                  onPressed: _zoomIn,
                  heroTag: "zoomIn",
                  child: const Icon(Icons.add),
                ),
                const SizedBox(height: 10),
                FloatingActionButton(
                  onPressed: _zoomOut,
                  heroTag: "zoomOut",
                  child: const Icon(Icons.remove),
                ),
                const SizedBox(height: 10),
                FloatingActionButton(
                  onPressed: _getUserLocation,
                  heroTag: "locateMe",
                  child: const Icon(Icons.my_location),
                ),
                const SizedBox(height: 10),
                FloatingActionButton(
                  onPressed: _reportCurrentLocation,
                  heroTag: "reportLocation",
                  child: const Icon(Icons.report),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
