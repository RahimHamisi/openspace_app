import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:latlong2/latlong.dart';
import '../utils/location_service.dart';
import '../utils/map_utils.dart';
import 'package:geolocator/geolocator.dart'; // For calculating distance

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});
  @override
  MapScreenState createState() => MapScreenState();
}

class MapScreenState extends State<MapScreen> with TickerProviderStateMixin {
  late final MapController _mapController;
  final LocationService _locationService = LocationService();
  bool isSatelliteView = false;
  bool _isTracking = false;
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;
  LatLng _initialPosition = const LatLng(-6.7741, 39.2026); // Kinondoni
  late final List<OpenSpaceMarker> kinondoniSpaces = getKinondoniSpaces();
  OpenSpaceMarker? _selectedSpace;
  LatLng? _selectedPosition;
  String? _selectedAreaName;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
      lowerBound: 0.0,
      upperBound: 1.0,
    );
    _opacityAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(_controller);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkMapInitialization();
    });

    _locationService.getLocationStream().listen((position) {
      if (_isTracking && mounted) {
        setState(() {
          _initialPosition = LatLng(position.latitude, position.longitude);
        });
        _mapController.move(LatLng(position.latitude, position.longitude), _mapController.camera.zoom);
      }
    });
  }

  void _checkMapInitialization() {
    try {
      _getUserLocation();
        } catch (e) {
      Future.delayed(const Duration(milliseconds: 100), _checkMapInitialization);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _mapController.dispose();
    super.dispose();
  }

  Future<void> _getUserLocation() async {
    try {
      final userLocation = await _locationService.getUserLocation(useCache: true);
      if (mounted) {
        setState(() {
          if (userLocation != null) {
            _initialPosition = userLocation;
          }
        });
        if (userLocation != null) {
          _mapController.move(userLocation, 15.0);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Unable to fetch location.")),
          );
        }
      }
    } catch (e) {
      debugPrint('Error getting user location: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e")),
        );
      }
    }
  }

  void _toggleLocationTracking() {
    setState(() {
      _isTracking = !_isTracking;
      if (_isTracking) {
        _controller.repeat(reverse: true);
        _getUserLocation();
      } else {
        _controller.stop();
        _controller.value = 1.0;
      }
    });
  }

  Future<void> _showLocationPopup(LatLng position, {OpenSpaceMarker? openSpace}) async {
    setState(() {
      _selectedSpace = openSpace;
      _selectedPosition = position;
    });

    // Fetch area name for the clicked position
    final areaName = await _locationService.getAreaName(position) ?? "Unknown Area";
    if (mounted) {
      setState(() {
        _selectedAreaName = areaName;
      });
    }
  }

  void _closePopup() {
    setState(() {
      _selectedPosition = null;
      _selectedSpace = null;
      _selectedAreaName = null;
    });
  }

  void _bookSpace() {
    if (_selectedSpace != null && _selectedSpace!.isAvailable) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Booking functionality to be implemented")),
      );
    }
  }

  Future<void> _getDirections(LatLng destination) async {
    // Get the user's current location
    final userLocation = await _locationService.getUserLocation(useCache: false);
    if (userLocation == null) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Unable to fetch your current location.")),
      );
      return;
    }

    // Calculate straight-line distance (as a placeholder for directions)
    final distance = Geolocator.distanceBetween(
      userLocation.latitude,
      userLocation.longitude,
      destination.latitude,
      destination.longitude,
    );

    // Convert distance to kilometers
    final distanceInKm = (distance / 1000).toStringAsFixed(2);

    // Show a simple directions message (placeholder)
    // ignore: use_build_context_synchronously
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "Directions to $_selectedAreaName:\n"
          "Straight-line distance: $distanceInKm km.\n"
          "(Implement a directions API for detailed navigation.)",
        ),
        duration: const Duration(seconds: 5),
      ),
    );
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
              initialZoom: 13.0,
              maxZoom: 19.0,
              minZoom: 6.0,
              onTap: (tapPosition, point) async {
                if (!mounted) return;

                final clickedSpace = kinondoniSpaces.firstWhere(
                  (space) =>
                      (space.point.latitude - point.latitude).abs() < 0.0001 &&
                      (space.point.longitude - point.longitude).abs() < 0.0001,
                  orElse: () => OpenSpaceMarker(
                    point: point,
                    name: '',
                    district: '',
                    streetName: '',
                    isAvailable: false,
                  ),
                );

                if (clickedSpace.name.isNotEmpty) {
                  _showLocationPopup(point, openSpace: clickedSpace);
                } else {
                  _showLocationPopup(point); // Show details for any clicked area
                }
              },
            ),
            children: [
              TileLayer(
                key: ValueKey(isSatelliteView),
                urlTemplate: isSatelliteView
                    ? "https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}"
                    : "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                userAgentPackageName: "com.example.openspace_mobile_app",
                tileProvider: CancellableNetworkTileProvider(),
                keepBuffer: 5,
                maxZoom: 19,
              ),
              CurrentLocationLayer(
                positionStream: _locationService.getLocationStream(),
              ),
              MarkerLayer(
                markers: [
                  ...kinondoniSpaces.map((space) => Marker(
                        point: space.point,
                        width: 30,
                        height: 30,
                        child: GestureDetector(
                          onTap: () => _showLocationPopup(space.point, openSpace: space),
                          child: Icon(
                            Icons.place,
                            color: space.isAvailable ? Colors.green : Colors.red,
                          ),
                        ),
                      )),
                ],
              ),
            ],
          ),
          Positioned(
            top: 40,
            left: 20,
            right: 10,
            child: TypeAheadField<LocationSuggestion>(
              debounceDuration: const Duration(milliseconds: 500),
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
                if (pattern.length < 3) return [];
                return await _locationService.searchLocation(pattern);
              },
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
          // Floating buttons (Zoom In, Zoom Out, Location)
          Positioned(
            bottom: 20,
            right: 20,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildFloatingButton(
                  icon: Icons.add,
                  onPressed: () => zoomIn(_mapController),
                  heroTag: "zoomIn",
                ),
                const SizedBox(height: 10),
                _buildFloatingButton(
                  icon: Icons.remove,
                  onPressed: () => zoomOut(_mapController),
                  heroTag: "zoomOut",
                ),
                const SizedBox(height: 10),
                _buildFloatingButton(
                  icon: Icons.my_location,
                  onPressed: _toggleLocationTracking,
                  heroTag: "locateMe",
                  animated: true,
                ),
              ],
            ),
          ),
          // Popup Card (Non-modal)
          if (_selectedPosition != null)
            Positioned(
              top: 100,
              left: 20,
              right: 20,
              child: Material(
                elevation: 8,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Stack(
                    children: [
                      // Close button (X) at the top-right
                      Positioned(
                        right: 0,
                        top: 0,
                        child: IconButton(
                          icon: const Icon(Icons.close, size: 20, color: Colors.black54),
                          onPressed: _closePopup,
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center, // Center the content
                        children: [
                          Text(
                            _selectedAreaName ?? "Unknown Area",
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                          _buildDetailRow("Latitude", _selectedPosition!.latitude.toStringAsFixed(6)),
                          _buildDetailRow("Longitude", _selectedPosition!.longitude.toStringAsFixed(6)),
                          if (_selectedSpace != null) ...[
                            const Divider(height: 24),
                            const Text(
                              "Open Space Details",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 12),
                            _buildDetailRow("Name", _selectedSpace!.name),
                            _buildDetailRow("Region", "Dar es Salaam"),
                            _buildDetailRow("District", _selectedSpace!.district),
                            _buildDetailRow("Street", _selectedSpace!.streetName),
                            _buildDetailRow(
                              "Status",
                              _selectedSpace!.isAvailable ? "Available" : "Booked",
                              valueColor: _selectedSpace!.isAvailable ? Colors.green : Colors.red,
                            ),
                            _buildDetailRow("Area Size", "500 sqm"),
                            _buildDetailRow("Price", "TZS 5000"),
                          ],
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center, // Center the buttons
                            children: [
                              ElevatedButton(
                                onPressed: () => _getDirections(_selectedPosition!),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: const Text(
                                  "Get Directions",
                                  style: TextStyle(color: Colors.white, fontSize: 14),
                                ),
                              ),
                              if (_selectedSpace != null) ...[
                                const SizedBox(width: 16), // Space between buttons
                                ElevatedButton(
                                  onPressed: _selectedSpace?.isAvailable == true ? _bookSpace : null,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue,
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: const Text(
                                    "Book Now",
                                    style: TextStyle(color: Colors.white, fontSize: 14),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 8),
                          // Cancel button at the bottom
                          TextButton(
                            onPressed: _closePopup,
                            child: const Text(
                              "Cancel",
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor:  Color.fromARGB(255, 192, 195, 195),
        currentIndex: 0,
        onTap: (index) {
          switch (index) {
            case 0:
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
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Report'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  // Helper method to build styled floating buttons
  Widget _buildFloatingButton({
    required IconData icon,
    required VoidCallback onPressed,
    required String heroTag,
    bool animated = false,
  }) {
    return FloatingActionButton(
      onPressed: onPressed,
      heroTag: heroTag,
      mini: true,
      backgroundColor: Colors.white,
      elevation: 2,
      shape: const CircleBorder(),
      child: animated
          ? AnimatedBuilder(
              animation: _opacityAnimation,
              builder: (context, child) {
                return Opacity(
                  opacity: _isTracking ? _opacityAnimation.value : 1.0,
                  child: Icon(icon, size: 20, color: Colors.black87),
                );
              },
            )
          : Icon(icon, size: 20, color: Colors.black87),
    );
  }

  // Helper method to build detail rows with centered content
  Widget _buildDetailRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center, // Center the row content
        children: [
          Text(
            "$label: ",
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black54,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              color: valueColor ?? Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}

class OpenSpaceMarker {
  final LatLng point;
  final String name;
  final String district;
  final String streetName;
  final bool isAvailable;

  OpenSpaceMarker({
    required this.point,
    required this.name,
    required this.district,
    required this.streetName,
    required this.isAvailable,
  });
}

List<OpenSpaceMarker> getKinondoniSpaces() {
  return [
    OpenSpaceMarker(
      point: const LatLng(-6.7741, 39.2026),
      name: "Football Ground",
      district: "Kinondoni",
      streetName: "Mkwajuni",
      isAvailable: true,
    ),
    OpenSpaceMarker(
      point: const LatLng(-6.7800, 39.2100),
      name: "Beachfront Space",
      district: "Kinondoni",
      streetName: "Ocean Drive",
      isAvailable: false,
    ),
  ];
}