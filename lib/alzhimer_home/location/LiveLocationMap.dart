import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:firebase_database/firebase_database.dart';

class LiveLocationMap extends StatefulWidget {
  @override
  State<LiveLocationMap> createState() => _LiveLocationMapState();
}

class _LiveLocationMapState extends State<LiveLocationMap> {
  LatLng? _currentLatLng;
  bool _gettingLocation = false;
  bool _connectionActive = false;
  String _lastUpdateTime = 'Never';
  String _lastError = 'None';
  late DatabaseReference _gpsRef;
  StreamSubscription<DatabaseEvent>? _gpsSubscription;

  @override
  void initState() {
    super.initState();
    _initFirebaseConnection();
  }

  void _initFirebaseConnection() {
    try {
      _gpsRef = FirebaseDatabase.instance.ref(
        '/bracelet_sensors/braclet_01/gps',
      );
      _listenToGpsUpdates();
    } catch (e) {
      setState(() {
        _lastError = 'Init failed: ${e.toString()}';
      });
    }
  }

  @override
  void dispose() {
    _gpsSubscription?.cancel();
    super.dispose();
  }

  void _listenToGpsUpdates() {
    setState(() {
      _gettingLocation = true;
      _connectionActive = false;
    });

    _gpsSubscription = _gpsRef.onValue.listen(
      (event) {
        final data = event.snapshot.value as Map<dynamic, dynamic>?;

        if (data != null) {
          try {
            final latitude = data['latitude'] as double;
            final longitude = data['longitude'] as double;
            final updateTime = DateTime.now().toString().substring(11, 19);

            if (mounted) {
              setState(() {
                _currentLatLng = LatLng(latitude, longitude);
                _gettingLocation = false;
                _connectionActive = true;
                _lastUpdateTime = updateTime;
                _lastError = 'None';
              });
            }
          } catch (e) {
            setState(() {
              _lastError = 'Data format error: ${e.toString()}';
            });
          }
        }
      },
      onError: (error) {
        if (mounted) {
          setState(() {
            _gettingLocation = false;
            _connectionActive = false;
            _lastError = 'Connection error: ${error.toString()}';
          });
        }
      },
      onDone: () {
        setState(() {
          _connectionActive = false;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Debug information panel
        SizedBox(
          height: 300,
          child:
              _currentLatLng == null
                  ? Center(
                    child:
                        _gettingLocation
                            ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircularProgressIndicator(),
                                SizedBox(height: 10),
                                Text('Connecting to Firebase...'),
                              ],
                            )
                            : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.warning,
                                  color: Colors.orange,
                                  size: 40,
                                ),
                                SizedBox(height: 10),
                                Text('Waiting for GPS data...'),
                                if (_lastError != 'None')
                                  Text(
                                    _lastError,
                                    style: TextStyle(color: Colors.red),
                                    textAlign: TextAlign.center,
                                  ),
                              ],
                            ),
                  )
                  : FlutterMap(
                    options: MapOptions(
                      initialCenter: _currentLatLng!,
                      initialZoom: 15,
                      interactiveFlags:
                          InteractiveFlag.all & ~InteractiveFlag.rotate,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                        subdomains: const ['a', 'b', 'c'],
                        userAgentPackageName: 'com.example.alzheimer_app',
                      ),
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: _currentLatLng!,
                            width: 40,
                            height: 40,
                            child: Icon(
                              Icons.location_on,
                              size: 40,
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
        ),
      ],
    );
  }
}
