import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';
import 'package:alzheimer_app/alzhimer_home/alzhimer_app_theme.dart';

class GpsHistoryPage extends StatefulWidget {
  const GpsHistoryPage({Key? key}) : super(key: key);

  @override
  State<GpsHistoryPage> createState() => _GpsHistoryPageState();
}

class _GpsHistoryPageState extends State<GpsHistoryPage>
    with TickerProviderStateMixin {
  final databaseRef = FirebaseDatabase.instance.ref(
    'bracelet_sensors/braclet_01/history_gps',
  );
  List<Map<String, dynamic>> gpsHistory = [];
  bool _isLoading = true;
  String _lastError = 'None';
  LatLng? _selectedLocation;
  String _lastUpdateTime = 'Never';

  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.fastOutSlowIn,
      ),
    );

    _animationController.forward();
    fetchGpsHistory();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void fetchGpsHistory() async {
    try {
      final snapshot = await databaseRef.get();

      if (snapshot.exists) {
        final data = Map<String, dynamic>.from(snapshot.value as Map);
        final history =
            data.entries.map((entry) {
              final gpsData = Map<String, dynamic>.from(entry.value);
              return {
                'timestamp': gpsData['timestamp'] ?? '',
                'latitude': gpsData['latitude'] ?? 0.0,
                'longitude': gpsData['longitude'] ?? 0.0,
              };
            }).toList();

        history.sort((a, b) => b['timestamp'].compareTo(a['timestamp']));

        setState(() {
          gpsHistory = history;
          if (history.isNotEmpty) {
            _selectedLocation = LatLng(
              history.first['latitude'] as double,
              history.first['longitude'] as double,
            );
            _lastUpdateTime = DateFormat('HH:mm:ss').format(DateTime.now());
          }
          _isLoading = false;
          _lastError = 'None';
        });
      } else {
        setState(() {
          _isLoading = false;
          _lastError = 'No GPS history data found';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _lastError = 'Error fetching data: ${e.toString()}';
      });
    }
  }

  String formatTimestamp(String timestamp) {
    try {
      final dateTime = DateTime.parse(timestamp);
      return DateFormat('yyyy-MM-dd – HH:mm').format(dateTime);
    } catch (e) {
      return timestamp;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FitnessAppTheme.background,
      body: AnimatedBuilder(
        animation: _animationController,
        builder: (BuildContext context, Widget? child) {
          return FadeTransition(
            opacity: _animation,
            child: Transform(
              transform: Matrix4.translationValues(
                0.0,
                30 * (1.0 - _animation.value),
                0.0,
              ),
              child: Column(
                children: [
                  // Header Card
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: FitnessAppTheme.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(8.0),
                          bottomLeft: Radius.circular(8.0),
                          bottomRight: Radius.circular(8.0),
                          topRight: Radius.circular(68.0),
                        ),
                        boxShadow: <BoxShadow>[
                          BoxShadow(
                            color: FitnessAppTheme.grey.withOpacity(0.2),
                            offset: Offset(1.1, 1.1),
                            blurRadius: 10.0,
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 4,
                                  height: 28,
                                  decoration: BoxDecoration(
                                    color: FitnessAppTheme.nearlyBlue,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'GPS History',
                                  style: TextStyle(
                                    fontFamily: FitnessAppTheme.fontName,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 18,
                                    color: FitnessAppTheme.nearlyDarkBlue,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 4),
                            Padding(
                              padding: const EdgeInsets.only(left: 12),
                              child: Text(
                                'Last updated: $_lastUpdateTime',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: FitnessAppTheme.grey,
                                ),
                              ),
                            ),
                            if (_lastError != 'None')
                              Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(
                                  _lastError,
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Map Section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Container(
                      decoration: BoxDecoration(
                        color: FitnessAppTheme.white,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: <BoxShadow>[
                          BoxShadow(
                            color: FitnessAppTheme.grey.withOpacity(0.2),
                            offset: Offset(1.1, 1.1),
                            blurRadius: 10.0,
                          ),
                        ],
                      ),
                      child: SizedBox(
                        height: 300,
                        child:
                            _isLoading
                                ? Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      CircularProgressIndicator(),
                                      SizedBox(height: 10),
                                      Text('Loading GPS history...'),
                                    ],
                                  ),
                                )
                                : gpsHistory.isEmpty
                                ? Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.location_off,
                                        color: Colors.orange,
                                        size: 40,
                                      ),
                                      SizedBox(height: 10),
                                      Text('No GPS history available'),
                                    ],
                                  ),
                                )
                                : ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: FlutterMap(
                                    options: MapOptions(
                                      center: _selectedLocation,
                                      zoom: 15,
                                      interactiveFlags:
                                          InteractiveFlag.all &
                                          ~InteractiveFlag.rotate,
                                    ),
                                    children: [
                                      TileLayer(
                                        urlTemplate:
                                            'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                                        subdomains: const ['a', 'b', 'c'],
                                        userAgentPackageName: 'com.example.app',
                                      ),
                                      MarkerLayer(
                                        markers:
                                            gpsHistory.map((location) {
                                              final latLng = LatLng(
                                                location['latitude'] as double,
                                                location['longitude'] as double,
                                              );
                                              return Marker(
                                                point: latLng,
                                                width: 40,
                                                height: 40,
                                                child: Icon(
                                                  Icons.location_on,
                                                  size: 40,
                                                  color:
                                                      _selectedLocation ==
                                                              latLng
                                                          ? Colors.red
                                                          : FitnessAppTheme
                                                              .nearlyBlue,
                                                ),
                                              );
                                            }).toList(),
                                      ),
                                    ],
                                  ),
                                ),
                      ),
                    ),
                  ),

                  // List Header
                  Padding(
                    padding: const EdgeInsets.fromLTRB(32, 16, 32, 8),
                    child: Row(
                      children: [
                        Icon(Icons.history, color: FitnessAppTheme.nearlyBlue),
                        SizedBox(width: 8),
                        Text(
                          'Location History',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: FitnessAppTheme.nearlyDarkBlue,
                          ),
                        ),
                        Spacer(),
                        Text(
                          'Total: ${gpsHistory.length}',
                          style: TextStyle(color: FitnessAppTheme.grey),
                        ),
                      ],
                    ),
                  ),

                  // List Section - Made scrollable with white cards
                  Expanded(
                    child:
                        _isLoading
                            ? Center(child: CircularProgressIndicator())
                            : gpsHistory.isEmpty
                            ? Center(
                              child: Text(
                                _lastError != 'None'
                                    ? _lastError
                                    : 'No GPS history available',
                                style: TextStyle(
                                  color:
                                      _lastError != 'None'
                                          ? Colors.red
                                          : Colors.grey,
                                ),
                              ),
                            )
                            : ListView.builder(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              itemCount: gpsHistory.length,
                              itemBuilder: (context, index) {
                                final item = gpsHistory[index];
                                final latLng = LatLng(
                                  item['latitude'] as double,
                                  item['longitude'] as double,
                                );
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.white, // White background
                                    borderRadius: BorderRadius.circular(8),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.2),
                                        spreadRadius: 1,
                                        blurRadius: 3,
                                        offset: Offset(0, 1),
                                      ),
                                    ],
                                  ),
                                  child: ListTile(
                                    leading: Icon(
                                      Icons.location_on,
                                      color:
                                          _selectedLocation == latLng
                                              ? Colors.red
                                              : FitnessAppTheme.nearlyBlue,
                                      size: 30,
                                    ),
                                    title: Text(
                                      '${formatTimestamp(item['timestamp'])}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    subtitle: Text(
                                      'Lat: ${item['latitude'].toStringAsFixed(4)}, Lng: ${item['longitude'].toStringAsFixed(4)}',
                                    ),
                                    onTap: () {
                                      setState(() {
                                        _selectedLocation = latLng;
                                      });
                                    },
                                  ),
                                );
                              },
                            ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: fetchGpsHistory,
        backgroundColor: FitnessAppTheme.nearlyBlue,
        child: Icon(Icons.refresh, color: Colors.white),
      ),
    );
  }
}
