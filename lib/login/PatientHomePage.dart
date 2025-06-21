import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';
import 'package:alzheimer_app/alzhimer_home/alzhimer_app_theme.dart';
import 'package:alzheimer_app/alzhimer_home/location/LiveLocationMap.dart';
import 'package:alzheimer_app/alzhimer_home/bottom_navigation_view/patient_bottom_navigation_bar.dart';

class PatientHomePage extends StatefulWidget {
  final String patientId;
  final Map<String, dynamic> patientData;
  final AnimationController? animationController;

  const PatientHomePage({
    Key? key,
    required this.patientId,
    required this.patientData,
    this.animationController,
  }) : super(key: key);

  @override
  _PatientHomePageState createState() => _PatientHomePageState();
}

class _PatientHomePageState extends State<PatientHomePage>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  Animation<double>? topBarAnimation;
  double topBarOpacity = 0.0;
  late ScrollController scrollController;
  int _currentBottomIndex = 0;

  // Firebase Realtime Database references
  late DatabaseReference _sensorRef;
  StreamSubscription<DatabaseEvent>? _sensorSubscription;

  // Sensor data
  int _batteryLevel = 0;
  bool _isCharging = false;
  double _heartRate = 0.0;
  bool _fallDetected = false;
  bool _buttonPressed = false;
  int _rawHeartValue = 0;
  String _lastUpdateTime = 'Never updated';

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

    topBarAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Interval(0, 0.5, curve: Curves.fastOutSlowIn),
      ),
    );

    scrollController = ScrollController()..addListener(_handleScroll);
    _animationController.forward();

    // Initialize Firebase Realtime Database connection
    _initSensorConnection();
  }

  void _handleScroll() {
    if (scrollController.offset >= 24) {
      if (topBarOpacity != 1.0) {
        setState(() => topBarOpacity = 1.0);
      }
    } else if (scrollController.offset <= 24 && scrollController.offset >= 0) {
      if (topBarOpacity != scrollController.offset / 24) {
        setState(() => topBarOpacity = scrollController.offset / 24);
      }
    } else if (scrollController.offset <= 0) {
      if (topBarOpacity != 0.0) {
        setState(() => topBarOpacity = 0.0);
      }
    }
  }

  void _initSensorConnection() {
    try {
      _sensorRef = FirebaseDatabase.instance.ref(
        '/bracelet_sensors/braclet_01',
      );
      _listenToSensorUpdates();
    } catch (e) {
      debugPrint('Sensor connection error: $e');
      setState(() => _lastUpdateTime = 'Connection error: ${e.toString()}');
    }
  }

  void _listenToSensorUpdates() {
    _sensorSubscription = _sensorRef.onValue.listen(
      (event) {
        final data = event.snapshot.value as Map<dynamic, dynamic>?;

        if (data != null) {
          setState(() {
            // Update all sensor values
            _batteryLevel = (data['battery_level'] as num?)?.toInt() ?? 0;
            _isCharging = data['charging_status'] as bool? ?? false;
            _heartRate = (data['heart_rate'] as num?)?.toDouble() ?? 0.0;
            _fallDetected = data['fall_detected'] as bool? ?? false;
            _buttonPressed = data['button_pressed'] as bool? ?? false;
            _rawHeartValue = data['raw_heart_value'] as int? ?? 0;
            _lastUpdateTime = DateFormat('HH:mm:ss').format(DateTime.now());
          });
        }
      },
      onError: (error) {
        debugPrint('Sensor data error: $error');
        setState(() => _lastUpdateTime = 'Error: ${error.toString()}');
      },
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    scrollController.dispose();
    _sensorSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FitnessAppTheme.background,
      body: Stack(
        children: <Widget>[
          SingleChildScrollView(
            controller: scrollController,
            child: Column(
              children: [
                SizedBox(height: MediaQuery.of(context).padding.top + 100),
                SizedBox(height: 24),
                _buildBraceletStatusCard(),
                SizedBox(height: 24),
                _buildHealthMonitorCard(),
                SizedBox(height: 24),
                _buildLiveLocationCard(),
                SizedBox(height: 24),
                SizedBox(height: 80),
              ],
            ),
          ),
          getAppBarUI(),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget getAppBarUI() {
    return Column(
      children: <Widget>[
        AnimatedBuilder(
          animation: _animationController,
          builder: (BuildContext context, Widget? child) {
            return FadeTransition(
              opacity: topBarAnimation!,
              child: Transform(
                transform: Matrix4.translationValues(
                  0.0,
                  30 * (1.0 - topBarAnimation!.value),
                  0.0,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: FitnessAppTheme.white.withOpacity(topBarOpacity),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(32.0),
                    ),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: FitnessAppTheme.grey.withOpacity(
                          0.4 * topBarOpacity,
                        ),
                        offset: const Offset(1.1, 1.1),
                        blurRadius: 10.0,
                      ),
                    ],
                  ),
                  child: Column(
                    children: <Widget>[
                      SizedBox(height: MediaQuery.of(context).padding.top),
                      Padding(
                        padding: EdgeInsets.only(
                          left: 16,
                          right: 16,
                          top: 16 - 8.0 * topBarOpacity,
                          bottom: 12 - 8.0 * topBarOpacity,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  '${widget.patientData['fullName'] ?? 'Patient'} Dashboard',
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    fontFamily: FitnessAppTheme.fontName,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 22 + 6 - 6 * topBarOpacity,
                                    letterSpacing: 1.2,
                                    color: FitnessAppTheme.darkerText,
                                  ),
                                ),
                              ),
                            ),
                            // ... [rest of app bar UI remains the same]
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildBraceletStatusCard() {
    Color batteryColor;
    if (_isCharging) {
      batteryColor = Colors.green;
    } else if (_batteryLevel < 10) {
      batteryColor = Colors.red;
    } else if (_batteryLevel < 30) {
      batteryColor = Colors.orange;
    } else if (_batteryLevel < 50) {
      batteryColor = Colors.yellow;
    } else {
      batteryColor = Colors.green;
    }

    return AnimatedBuilder(
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
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
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
                              color: batteryColor,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Bracelet Status',
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
                      SizedBox(height: 20),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Status: ${_isCharging ? 'Charging' : 'Not Charging'}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color:
                                        _isCharging
                                            ? Colors.green
                                            : Colors.grey,
                                  ),
                                ),
                                SizedBox(height: 12),
                                Text(
                                  _batteryLevel < 10
                                      ? 'Battery Level: Critical'
                                      : _batteryLevel < 30
                                      ? 'Battery Level: Low'
                                      : _batteryLevel < 50
                                      ? 'Battery Level: Medium'
                                      : 'Battery Level: Good',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: batteryColor,
                                  ),
                                ),
                                SizedBox(height: 12),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: batteryColor.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    '$_batteryLevel%',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: batteryColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              color: FitnessAppTheme.background,
                              shape: BoxShape.circle,
                            ),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Container(
                                  width: 90,
                                  height: 90,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: batteryColor.withOpacity(0.1),
                                  ),
                                ),
                                SizedBox(
                                  width: 90,
                                  height: 90,
                                  child: CircularProgressIndicator(
                                    value: _batteryLevel / 100,
                                    backgroundColor: Colors.transparent,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      batteryColor,
                                    ),
                                    strokeWidth: 7,
                                  ),
                                ),
                                Icon(
                                  _isCharging ? Icons.bolt : Icons.battery_std,
                                  color: batteryColor,
                                  size: 26,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHealthMonitorCard() {
    final int displayHeartRate = _rawHeartValue.toInt();
    Color statusColor = Colors.green;
    if (_fallDetected || _buttonPressed) {
      statusColor = Colors.red;
    } else if (displayHeartRate > 100 || displayHeartRate < 60) {
      statusColor = Colors.orange;
    }

    return AnimatedBuilder(
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
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
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
                              color: statusColor,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Health Monitor',
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
                      SizedBox(height: 20),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildVitalRow(
                                  'Heart Rate',
                                  '$displayHeartRate bpm',
                                  displayHeartRate > 100 ||
                                          displayHeartRate < 60
                                      ? Colors.orange
                                      : Colors.green,
                                ),
                                SizedBox(height: 10),
                                _buildVitalRow(
                                  'Fall Detection',
                                  _fallDetected ? '⚠ Detected' : '✓ Safe',
                                  _fallDetected ? Colors.red : Colors.green,
                                ),
                                SizedBox(height: 10),
                                _buildVitalRow(
                                  'Emergency Button',
                                  _buttonPressed
                                      ? '⚠ Pressed'
                                      : '✓ Not Pressed',
                                  _buttonPressed ? Colors.red : Colors.green,
                                ),
                              ],
                            ),
                          ),
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                CircularProgressIndicator(
                                  value: displayHeartRate.clamp(0, 150) / 150,
                                  backgroundColor: Colors.transparent,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    statusColor,
                                  ),
                                  strokeWidth: 8,
                                ),
                                Icon(
                                  _fallDetected || _buttonPressed
                                      ? Icons.warning
                                      : Icons.favorite,
                                  color: statusColor,
                                  size: 32,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLiveLocationCard() {
    return AnimatedBuilder(
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
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                        top: 16,
                        left: 16,
                        right: 16,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Live Location',
                            style: TextStyle(
                              fontFamily: FitnessAppTheme.fontName,
                              fontWeight: FontWeight.w700,
                              fontSize: 18,
                              letterSpacing: 0.5,
                              color: FitnessAppTheme.nearlyDarkBlue,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Container(
                              height: 2,
                              width: 48,
                              decoration: BoxDecoration(
                                color: FitnessAppTheme.nearlyBlue.withOpacity(
                                  0.5,
                                ),
                                borderRadius: BorderRadius.circular(2.0),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 8, bottom: 12),
                            child: Text(
                              'Last updated: $_lastUpdateTime',
                              style: TextStyle(
                                fontFamily: FitnessAppTheme.fontName,
                                fontSize: 14,
                                color: FitnessAppTheme.grey,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 8,
                        right: 8,
                        bottom: 16,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LiveLocationMap(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildVitalRow(String label, String value, Color color) {
    return Row(
      children: [
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: FitnessAppTheme.nearlyDarkBlue,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomNavigationBar() {
    return PatientBottomNavigationBar(
      currentIndex: _currentBottomIndex,
      onTap: (index) {
        setState(() => _currentBottomIndex = index);
        if (index == 0) {
          scrollController.animateTo(
            0,
            duration: Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
        } else if (index == 2) {
          scrollController.animateTo(
            scrollController.position.maxScrollExtent * 0.6,
            duration: Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
        }
      },
      patientId: widget.patientId,
      patientName: widget.patientData['fullName'] ?? 'Patient',
    );
  }
}
