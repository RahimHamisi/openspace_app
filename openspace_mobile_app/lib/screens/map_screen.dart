import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:latlong2/latlong.dart';
import '../model/openspace.dart';
import '../service/openspace_service.dart';
import '../utils/location_service.dart';
import 'package:geolocator/geolocator.dart'; // For calculating distance

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});
  @override
  MapScreenState createState() => MapScreenState();
}

class MapScreenState extends State<MapScreen> with TickerProviderStateMixin {
  late final MapController _mapController;
  final LocationService _locationService = LocationService();
  final OpenSpaceService _openSpaceService = OpenSpaceService();

  bool isSatelliteView = false;
  bool _isTracking = false;
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;

  LatLng _currentPosition = const LatLng(-6.7741, 39.2026); // Kinondoni
  double _currentZoom = 13.0;

  List<OpenSpaceMarker> _spaces = [];
  OpenSpaceMarker? _selectedSpace;
  LatLng? _selectedPosition;
  String? _selectedAreaName;
  int _selectedIndex = 1;

  bool _isLoading = true;
  String? _error;

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

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _getUserLocation();
      await _fetchSpaces();
    });

    _locationService.getLocationStream().listen((position) {
      if (_isTracking && mounted) {
        setState(() {
          _currentPosition = LatLng(position.latitude, position.longitude);
        });
        _mapController.move(_currentPosition, _currentZoom);
      }
    });
  }

  Future<void> _fetchSpaces() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final data = await _openSpaceService.getAllOpenSpaces();
      setState(() {
        _spaces = data.map((json) => OpenSpaceMarker.fromJson(json)).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error loading spaces: $_error")),
      );
    }
  }

  Future<void> _getUserLocation() async {
    try {
      final userLocation = await _locationService.getUserLocation(useCache: true);
      if (mounted && userLocation != null) {
        setState(() {
          _currentPosition = userLocation;
          _currentZoom = 15.0;
        });
        _mapController.move(userLocation, _currentZoom);
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
    final userLocation = await _locationService.getUserLocation(useCache: false);
    if (userLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Unable to fetch your current location.")),
      );
      return;
    }

    final distance = Geolocator.distanceBetween(
      userLocation.latitude,
      userLocation.longitude,
      destination.latitude,
      destination.longitude,
    );

    final distanceInKm = (distance / 1000).toStringAsFixed(2);

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

  List<Marker> get _markers => _spaces.map((space) {
    return Marker(
      point: space.point,
      width: 30,
      height: 30,
      builder: (_) => GestureDetector(
        onTap: () => _showLocationPopup(space.point, openSpace: space),
        child: Icon(
          Icons.place,
          color: space.isAvailable ? Colors.green : Colors.red,
        ),
      ),
    );
  }).toList();

  @override
  void dispose() {
    _controller.dispose();
    _mapController.dispose();
    super.dispose();
  }

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

  Widget _buildDetailRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
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
              fontWeight: FontWeight.w600,
              color: valueColor ?? Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("OpenStreetMap - Kinondoni"),
          centerTitle: true,
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
            center: _currentPosition,
            zoom: _currentZoom,
            maxZoom: 19.0,
            minZoom: 6.0,
            onPositionChanged: (MapPosition position, bool hasGesture) {
              if (position.zoom != null && position.center != null) {
                setState(() {
                  _currentZoom = position.zoom!;
                  _currentPosition = position.center!;
                });
              }
            },
            interactionOptions: const InteractionOptions(
              flags: InteractiveFlag.drag | InteractiveFlag.pinchZoom,
            ),
            onTap: (tapPosition, point) async {
              if (!mounted) return;

              final clickedSpace = _spaces.firstWhere(
                    (space) =>
                (space.point.latitude - point.latitude).abs() < 0.0001 &&
                    (space.point.longitude - point.longitude).abs() < 0.0001,
                orElse: () => OpenSpaceMarker(

                  name: '',
                  district: '',
                  latitude: '',
                  longitude: '',
                  status: '',
                  is

                ),
              );

              if (clickedSpace.name.isNotEmpty) {
                _showLocationPopup(point, openSpace: clickedSpace);
              } else {
                _showLocationPopup(point);
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
              tileProvider: const CancellableNetworkTileProvider(),
            ),
            LocationMarkerLayer(
              position: _currentPosition,
              marker: DefaultLocationMarker(
                color: Colors.blue,
                child: const Icon(Icons.my_location, size: 24, color: Colors.white),
              ),
            ),
            MarkerLayer(markers: _markers),
          ],
        ),

        // Pop-up detail panel
        if (_selectedPosition != null)
    Positioned(
      bottom: 40,
      left: 20,
      right: 20,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 10,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _selectedAreaName ?? "Unknown Area",
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              if (_selectedSpace != null)
                Column(
                  children: [
                    _buildDetailRow("District", _selectedSpace!.district),
                    _buildDetailRow("Street Name", _selectedSpace!.streetName),
                    _buildDetailRow(
                      "Availability",
                      _selectedSpace!.isAvailable ? "Available" : "Not Available",
                      valueColor: _selectedSpace!.isAvailable ? Colors.green : Colors.red,
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton.icon(
                          onPressed: _selectedSpace!.isAvailable ? _bookSpace : null,
                          icon: const Icon(Icons.book_online),
                          label: const Text("Book"),
                        ),
                        ElevatedButton.icon(
                          onPressed: () => _getDirections(_selectedPosition!),
                          icon: const Icon(Icons.directions),
                          label: const Text("Directions"),
                        ),
                        ElevatedButton.icon(
                          onPressed: _closePopup,
                          icon: const Icon(Icons.close),
                          label: const Text("Close"),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                        ),
                      ],
                    ),
                  ],
                )
              else
                ElevatedButton.icon(
                  onPressed: _closePopup,
                  icon: const Icon(Icons.close),
                  label: const Text("Close"),
                ),
            ],
          ),
        ),
      ),
      ],
      ],
    ),

    floatingActionButton: Column(
    mainAxisSize: MainAxisSize.min,
    children: [
    _buildFloatingButton(
    icon: Icons.location_searching,
    onPressed: _toggleLocationTracking,
    heroTag: "locationTrackingBtn",
    animated: true,
    ),
    const SizedBox(height: 10),
    _buildFloatingButton(
    icon: isSatelliteView ? Icons.map : Icons.photo,
    onPressed: () => setState(() => isSatelliteView = !isSatelliteView),
    heroTag: "toggleMapViewBtn",
    ),
    ],
    ),
    );
    }
}
