import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:alzheimer_app/alzhimer_home/alzhimer_app_theme.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class SafeZonePage extends StatefulWidget {
  const SafeZonePage({Key? key}) : super(key: key);

  @override
  _SafeZonePageState createState() => _SafeZonePageState();
}

class _SafeZonePageState extends State<SafeZonePage> {
  // Color scheme
  static const Color _primaryColor = Color(0xFF1E3A8A);
  static const Color _accentColor = Color(0xFFFF5252);
  static const Color _successColor = Color(0xFF4CAF50);
  static const Color _warningColor = Color(0xFFFFC107);

  // Map related variables
  final MapController _mapController = MapController();
  LatLng? _currentPosition;
  List<SafeZone> _safeZones = [];
  bool _isDrawingZone = false;
  List<LatLng> _currentZonePoints = [];
  int _currentIndex = 0; // For bottom navigation bar
  @override
  void initState() {
    super.initState();
    _determinePosition();
    // Initialize with empty safe zones
    _safeZones = [];
  }

  Future<void> _determinePosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are disabled
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Location services are disabled. Please enable them.'),
          backgroundColor: _accentColor,
        ),
      );
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Location permissions are denied'),
            backgroundColor: _accentColor,
          ),
        );
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Location permissions are permanently denied. Please enable them in app settings.'),
          backgroundColor: _accentColor,
        ),
      );
      await openAppSettings();
      return;
    }

    // Get the current position
    Position position = await Geolocator.getCurrentPosition();
    setState(() {
      _currentPosition = LatLng(position.latitude, position.longitude);
      
      // Add a sample safe zone around current location (500m radius)
      _safeZones = [
        SafeZone(
          name: "Home Area",
          points: _createCircularZone(
            _currentPosition!, 
            radiusInMeters: 500, 
            points: 12
          ),
          isActive: true,
        ),
      ];
    });
    
    // Center map on current location
    _mapController.move(_currentPosition!, 15.0);
  }

  List<LatLng> _createCircularZone(LatLng center, {required double radiusInMeters, required int points}) {
    List<LatLng> zonePoints = [];
    for (int i = 0; i < points; i++) {
      double angle = 2 * pi * i / points;
      // Convert meters to degrees (approximate)
      double latOffset = (radiusInMeters / 111320) * cos(angle);
      double lngOffset = (radiusInMeters / 111320) * sin(angle) / cos(center.latitude * pi / 180);
      
      zonePoints.add(LatLng(
        center.latitude + latOffset,
        center.longitude + lngOffset,
      ));
    }
    return zonePoints;
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      color: FitnessAppTheme.background,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text(
            "Safe Zone Tracker",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          backgroundColor: Colors.white,
          foregroundColor: _primaryColor,
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: _startDrawingZone,
              tooltip: 'Add new safe zone',
            ),
          ],
        ),
        body: Stack(
          children: [
            // Map View
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                center: _currentPosition,
                zoom: 15.0,
                onTap: _handleMapTap,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.alzheimer_app',
                ),
                // Draw current position marker
                
                if (_currentPosition != null)
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: _currentPosition!,
                        child: const Icon(
                          Icons.location_on,
                          color: _accentColor,
                          size: 40,
                        ),
                      ),
                    ],
                  ),
                // Draw existing safe zones
                PolygonLayer(
                  polygons:
                      _safeZones
                          .where((zone) => zone.isActive)
                          .map(
                            (zone) => Polygon(
                              points: zone.points,
                              color: _primaryColor.withOpacity(0.3),
                              borderColor: _primaryColor,
                              borderStrokeWidth: 2,
                              isFilled: true,
                            ),
                          )
                      .toList(),
                ),
                // Draw current zone being created
                if (_isDrawingZone && _currentZonePoints.length > 1)
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: _currentZonePoints,
                        color: _warningColor,
                        strokeWidth: 2,
                      ),
                    ],
                  ),
              ],
            ),
            // Safe Zones List
            Positioned(
              bottom: 80, // Adjusted for bottom navigation bar
              left: 16,
              right: 16,
              child: _buildSafeZonesList(),
            ),
            // Drawing controls
            if (_isDrawingZone)
              Positioned(
                top: 16,
                right: 16,
                child: Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.check, color: _successColor),
                          onPressed: _finishDrawingZone,
                          tooltip: 'Finish zone',
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: _accentColor),
                          onPressed: _cancelDrawingZone,
                          tooltip: 'Cancel',
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          selectedItemColor: _primaryColor,
          unselectedItemColor: Colors.grey,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
              // Add navigation logic here if needed
            });
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.notifications),
              label: 'Alerts',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSafeZonesList() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                "Safe Zones",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: _primaryColor,
                ),
              ),
            ),
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 200),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _safeZones.length,
                itemBuilder: (context, index) {
                  final zone = _safeZones[index];
                  return ListTile(
                    leading: Checkbox(
                      value: zone.isActive,
                      onChanged: (value) {
                        setState(() {
                          _safeZones[index].isActive = value ?? false;
                        });
                      },
                      activeColor: _primaryColor,
                    ),
                    title: Text(zone.name),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.delete, color: _accentColor),
                          onPressed: () => _deleteZone(index),
                        ),
                      ],
                    ),
                    onTap: () => _focusOnZone(zone),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _startDrawingZone() {
    setState(() {
      _isDrawingZone = true;
      _currentZonePoints = [];
    });
  }

  void _cancelDrawingZone() {
    setState(() {
      _isDrawingZone = false;
      _currentZonePoints = [];
    });
  }

  void _finishDrawingZone() {
    if (_currentZonePoints.length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('A zone needs at least 3 points'),
          backgroundColor: _accentColor,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) {
        final nameController = TextEditingController();
        return AlertDialog(
          title: const Text("Save Safe Zone"),
          content: TextField(
            controller: nameController,
            decoration: const InputDecoration(
              labelText: "Zone Name",
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                "Cancel",
                style: TextStyle(color: _accentColor),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: _primaryColor),
              onPressed: () {
                if (nameController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter a name for the zone'),
                      backgroundColor: _accentColor,
                    ),
                  );
                  return;
                }

                setState(() {
                  _safeZones.add(
                    SafeZone(
                      name: nameController.text,
                      points: List.from(_currentZonePoints),
                      isActive: true,
                    ),
                  );
                  _isDrawingZone = false;
                  _currentZonePoints = [];
                });
                Navigator.pop(context);
              },
              child: const Text("Save", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _handleMapTap(TapPosition tapPosition, LatLng point) {
    if (!_isDrawingZone) return;

    setState(() {
      _currentZonePoints.add(point);
    });
  }

  void _deleteZone(int index) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text("Delete Zone"),
            content: Text(
              "Are you sure you want to delete ${_safeZones[index].name}?",
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  "Cancel",
                  style: TextStyle(color: _accentColor),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: _accentColor),
                onPressed: () {
                  setState(() {
                    _safeZones.removeAt(index);
                  });
                  Navigator.pop(context);
                },
                child: const Text(
                  "Delete",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
    );
  }

  void _focusOnZone(SafeZone zone) {
    // Calculate center of the zone
    double latSum = 0, lngSum = 0;
    for (var point in zone.points) {
      latSum += point.latitude;
      lngSum += point.longitude;
    }
    final center = LatLng(
      latSum / zone.points.length,
      lngSum / zone.points.length,
    );

    _mapController.move(center, 15.0);
  }
}

class SafeZone {
  final String name;
  final List<LatLng> points;
  bool isActive;

  SafeZone({required this.name, required this.points, this.isActive = true});
}


