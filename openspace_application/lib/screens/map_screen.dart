// ignore_for_file: unnecessary_null_comparison, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
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
  bool _isTracking = false;
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;
  LatLng _initialPosition = const LatLng(-6.7741, 39.2026); // Kinondoni
  late final List<Marker> kinondoniSpaces = getKinondoniSpaces();
  final List<Marker> reportMarkers = [];
  bool _isLoading = true;
  bool _isMapReady = false;

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

    // Listen to location stream for tracking
    _locationService.getLocationStream().listen((position) {
      if (_isTracking && _isMapReady && mounted) {
        _mapController.move(LatLng(position.latitude, position.longitude), 15.0);
      }
    });
  }

  void _checkMapInitialization() {
    try {
      if (_mapController.camera != null) {
        setState(() => _isMapReady = true);
        _getUserLocation();
      } else {
        Future.delayed(const Duration(milliseconds: 100), _checkMapInitialization);
      }
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
    setState(() => _isLoading = true);
    try {
      final userLocation = await _locationService.getUserLocation(useCache: true);
      if (userLocation != null && mounted) {
        setState(() {
          _initialPosition = userLocation;
          _isLoading = false;
        });
        if (_isMapReady) {
          _mapController.move(userLocation, 15.0);
        }
      } else {
        if (mounted) setState(() => _isLoading = false);
      }
    } catch (e) {
      debugPrint('Error getting user location: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _reportCurrentLocation() async {
    if (!mounted) return;
    final currentContext = context;

    showDialog(
      context: currentContext,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Center(child: CircularProgressIndicator());
      },
    );

    try {
      final userLocation = await _locationService.getUserLocation(useCache: false);
      Navigator.of(currentContext).pop();

      if (userLocation != null && mounted) {
        final areaName = await _locationService.getAreaName(userLocation) ?? "Current Location";
        _navigateToReportForm(userLocation, areaName);
      } else {
        ScaffoldMessenger.of(currentContext).showSnackBar(
          const SnackBar(content: Text("Failed to get your current location.")),
        );
      }
    } catch (e) {
      Navigator.of(currentContext).pop();
      if (mounted) {
        ScaffoldMessenger.of(currentContext).showSnackBar(
          SnackBar(content: Text("Error: ${e.toString()}")),
        );
      }
    }
  }

  void _navigateToReportForm(LatLng location, String areaName) {
    if (!mounted) return;

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
      if (newMarker != null && mounted) setState(() => reportMarkers.add(newMarker));
    });
  }

  void _toggleLocationTracking() {
    setState(() {
      _isTracking = !_isTracking;
      if (_isTracking) {
        _controller.repeat(reverse: true);
        _getUserLocation(); // Initial update when tracking starts
      } else {
        _controller.stop();
        _controller.value = 1.0;
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
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    interactionOptions: const InteractionOptions(
                      flags: InteractiveFlag.drag | InteractiveFlag.pinchZoom,
                    ),
                    initialCenter: _initialPosition,
                    initialZoom: 13.0,
                    maxZoom: 19.0,
                    minZoom: 6.0,
                    onMapEvent: (event) {
                      if (!_isMapReady && event.source == MapEventSource.mapController) {
                        setState(() => _isMapReady = true);
                      }
                    },
                    onTap: (tapPosition, point) async {
                      if (!mounted) return;

                      if (isDroppingPin) {
                        setState(() => isDroppingPin = false);
                        final currentContext = context;

                        showDialog(
                          context: currentContext,
                          barrierDismissible: false,
                          builder: (BuildContext context) {
                            return const Center(child: CircularProgressIndicator());
                          },
                        );

                        final areaName = await _locationService.getAreaName(point) ?? "Unknown Area";
                        if (!mounted) return;
                        Navigator.of(currentContext).pop();
                        _navigateToReportForm(point, areaName);
                      } else {
                        if (_isMapReady) {
                          _mapController.move(point, _mapController.camera.zoom);
                        }
                      }
                    },
                  ),
                  children: [
                    TileLayer(
                      key: ValueKey(isSatelliteView),
                      urlTemplate: isSatelliteView
                          ? "http://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}"
                          : "http://tile.openstreetmap.org/{z}/{x}/{y}.png",
                      userAgentPackageName: "com.example.openspace_application",
                      tileProvider: CancellableNetworkTileProvider(),
                      keepBuffer: 5,
                      maxZoom: 19,
                    ),
                    CurrentLocationLayer( // Updated for user location
                      positionStream: _locationService.getLocationStream(),
                      // Removed followOnLocationUpdate; handled manually via _isTracking
                    ),
                    MarkerLayer(
                      markers: [
                        ...kinondoniSpaces.map((marker) => Marker(
                              point: marker.point,
                              width: marker.width,
                              height: marker.height,
                              child: GestureDetector(
                                onTap: () {
                                  if (_isMapReady) {
                                    _mapController.move(marker.point, 15.0);
                                  }
                                },
                                child: marker.child,
                              ),
                            )),
                        ...reportMarkers.map((marker) => Marker(
                              point: marker.point,
                              width: marker.width,
                              height: marker.height,
                              child: GestureDetector(
                                onTap: () {
                                  if (_isMapReady) {
                                    _mapController.move(marker.point, 15.0);
                                  }
                                },
                                child: marker.child,
                              ),
                            )),
                      ],
                    ),
                  ],
                ),

          // Rest of the Stack (search field, pin drop overlay, action buttons) remains unchanged
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
                if (_isMapReady) {
                  _mapController.move(suggestion.position, 15.0);
                }
              },
            ),
          ),

          if (isDroppingPin)
            Positioned(
              top: 20,
              left: 0,
              right: 0,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 50),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  "Tap on map to drop a pin",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),

          Positioned(
            bottom: 20,
            right: 20,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FloatingActionButton(
                  onPressed: () => zoomIn(_mapController),
                  heroTag: "zoomIn",
                  mini: true,
                  child: const Icon(Icons.add, size: 24),
                ),
                const SizedBox(height: 10),
                FloatingActionButton(
                  onPressed: () => zoomOut(_mapController),
                  heroTag: "zoomOut",
                  mini: true,
                  child: const Icon(Icons.remove, size: 20),
                ),
                const SizedBox(height: 10),
                FloatingActionButton(
                  onPressed: _toggleLocationTracking,
                  heroTag: "locateMe",
                  mini: true,
                  child: AnimatedBuilder(
                    animation: _opacityAnimation,
                    builder: (context, child) {
                      return Opacity(
                        opacity: _isTracking ? _opacityAnimation.value : 1.0,
                        child: const Icon(Icons.my_location, size: 24),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 10),
                FloatingActionButton(
                  onPressed: () => setState(() => isDroppingPin = true),
                  heroTag: "reportPin",
                  backgroundColor: Colors.green,
                  mini: true,
                  child: const Icon(Icons.report, size: 24),
                ),
                const SizedBox(height: 10),
                FloatingActionButton(
                  onPressed: _reportCurrentLocation,
                  heroTag: "reportCurrent",
                  backgroundColor: const Color(0xFFFF9800),
                  mini: true,
                  child: const Icon(Icons.location_on, size: 24),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
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
          BottomNavigationBarItem(icon: Icon(Icons.report), label: 'Report'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}