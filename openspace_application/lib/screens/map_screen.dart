import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:latlong2/latlong.dart';
import '../utils/location_service.dart';
import '../utils/map_utils.dart';
import 'user_details_screen.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  MapScreenState createState() => MapScreenState();
}

class MapScreenState extends State<MapScreen> with SingleTickerProviderStateMixin {
  late final MapController _mapController;
  final LocationService _locationService = LocationService();
  bool isSatelliteView = false;
  bool isDroppingPin = false;
  bool _isTracking = false; // Variable to track whether location tracking is active
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;

  LatLng _initialPosition = const LatLng(-6.7741, 39.2026); // Kinondoni
  final List<Marker> kinondoniSpaces = getKinondoniSpaces();
  final List<Marker> reportMarkers = [];

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _getUserLocation();

    // Initialize the AnimationController for blinking effect
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 1),
      lowerBound: 0.0,
      upperBound: 1.0,
    )..repeat(reverse: true);  // Repeat the animation to create blinking effect

    // Set up the opacity animation for blinking effect
    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose(); // Don't forget to dispose of the controller
    super.dispose();
  }

  Future<void> _getUserLocation() async {
    final userLocation = await _locationService.getUserLocation();
    if (userLocation != null) {
      setState(() => _initialPosition = userLocation);
      _mapController.move(userLocation, 10.0);
    }
  }

  void _reportCurrentLocation() async {
    final userLocation = await _locationService.getUserLocation();
    if (userLocation != null) {
      final areaName = await _locationService.getAreaName(userLocation) ?? "Current Location";
      _navigateToReportForm(userLocation, areaName);
    } else {
      // Replace print with proper logging in production
      debugPrint("Failed to get user's current location.");
    }
  }

  void _navigateToReportForm(LatLng location, String areaName) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => UserDetailsScreen(
          location: location,
          areaName: areaName,
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(0.0, 1.0);
          const end = Offset.zero;
          const curve = Curves.easeInOut;
          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          return SlideTransition(position: animation.drive(tween), child: child);
        },
      ),
    ).then((newMarker) {
      if (newMarker != null) setState(() => reportMarkers.add(newMarker));
    });
  }

  void _toggleLocationTracking() {
    setState(() {
      _isTracking = !_isTracking;
      if (_isTracking) {
        _controller.forward(); // Start blinking when tracking is on
      } else {
        _controller.stop(); // Stop blinking when tracking is off
        _controller.value = 1.0; // Ensure the icon stays fully visible when tracking is off
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("OpenStreetMap - Kinondoni"),
        actions: [
          IconButton(
            icon: Icon(isSatelliteView ? Icons.map : Icons.photo),
            onPressed: () => setState(() => isSatelliteView = !isSatelliteView),
          ),
        ],
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.drag | InteractiveFlag.pinchZoom,
              ),
              initialCenter: _initialPosition,
              initialZoom: 10.0,
              maxZoom: 26.0,
              minZoom: 6.0,
              onTap: (tapPosition, point) async {
                if (isDroppingPin) {
                  setState(() => isDroppingPin = false);
                  final areaName = await _locationService.getAreaName(point) ?? "Unknown Area";
                  _navigateToReportForm(point, areaName);
                } else {
                  setState(() => _initialPosition = point);
                  _mapController.move(point, 15.0);
                }
              },
            ),
            children: [
              TileLayer(
                key: ValueKey(isSatelliteView),
                urlTemplate: isSatelliteView
                    ? "https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}"
                    : "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                subdomains: const ['a', 'b', 'c'],
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: _initialPosition,
                    width: 80.0,
                    height: 80.0,
                    child: const Icon(Icons.location_pin, color: Colors.red, size: 40),
                  ),
                  ...kinondoniSpaces,
                  ...reportMarkers,
                ],
              ),
            ],
          ),
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
              suggestionsCallback: (pattern) async => await _locationService.searchLocation(pattern),
              itemBuilder: (context, suggestion) => ListTile(
                leading: const Icon(Icons.location_on),
                title: Text(suggestion.name),
              ),
              onSelected: (suggestion) {
                setState(() => _initialPosition = suggestion.position);
                _mapController.move(suggestion.position, 15.0);
              },
            ),
          ),
          Positioned(
            bottom: 20,
            right: 20,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Zoom In Button
                FloatingActionButton(
                  onPressed: () => zoomIn(_mapController),
                  heroTag: "zoomIn",
                  mini: true,  // Makes the button smaller
                  child: const Icon(
                    Icons.add,
                    size: 24,  // Adjust icon size
                  ),
                ),
                const SizedBox(height: 10),
                
                // Zoom Out Button
                FloatingActionButton(
                  onPressed: () => zoomOut(_mapController),
                  heroTag: "zoomOut",
                  mini: true,  // Makes the button smaller
                  child: const Icon(
                    Icons.remove,
                    size: 20,  // Adjust icon size as per your requirement
                  ),
                ),
                const SizedBox(height: 10),
                
                // Locate Me Button with Blinking Effect
                FloatingActionButton(
                  onPressed: _toggleLocationTracking,  // Toggle location tracking and blinking
                  heroTag: "locateMe",
                  mini: true,  // Makes the button smaller
                  child: AnimatedBuilder(
                    animation: _opacityAnimation,
                    builder: (context, child) {
                      return Opacity(
                        opacity: _opacityAnimation.value,  // Control blinking via opacity
                        child: const Icon(
                          Icons.my_location,
                          size: 24,  // Adjust icon size if needed
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 10),
                
                // Report Pin Button
                FloatingActionButton(
                  onPressed: () => setState(() => isDroppingPin = true),
                  heroTag: "reportPin",
                  backgroundColor: Colors.green,
                  mini: true,  // Makes the button smaller
                  child: const Icon(
                    Icons.report,
                    size: 24,  // Adjust icon size
                  ),
                ),
                const SizedBox(height: 10),
                
                // Report Current Location Button
                FloatingActionButton(
                  onPressed: _reportCurrentLocation,
                  heroTag: "reportCurrent",
                  backgroundColor: const Color(0xFFFF9800),
                  mini: true,  // Makes the button smaller
                  child: const Icon(
                    Icons.location_on,
                    size: 24,  // Adjust icon size
                  ),
                ),
              ],
            ),
          )

        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.pushReplacementNamed(context, '/map');
              break;
            case 1:
              Navigator.pushReplacementNamed(context, '/report');
              break;
            case 2:
              Navigator.pushReplacementNamed(context, '/profile');
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Map'),
          BottomNavigationBarItem(icon: Icon(Icons.report), label: 'Report'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
