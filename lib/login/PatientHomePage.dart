import 'package:alzheimer_app/alzhimer_home/bottom_navigation_view/patient_bottom_navigation_bar.dart';

import 'package:alzheimer_app/contact/PatientContactsPage.dart';
import 'package:alzheimer_app/games/MemoryQuizGame.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:alzheimer_app/alzhimer_home/alzhimer_app_theme.dart';
import 'package:alzheimer_app/alzhimer_home/location/LiveLocationMap.dart';
import 'package:intl/intl.dart';

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
  late Future<Map<String, dynamic>> _braceletData;
  late Future<Map<String, dynamic>> _healthData;
  late AnimationController _animationController;
  late Animation<double> _animation;
  Animation<double>? topBarAnimation;
  double topBarOpacity = 0.0;
  late ScrollController scrollController;
  int _currentBottomIndex = 0;

  @override
  void initState() {
    super.initState();
    _braceletData = _fetchBraceletData();
    _healthData = _fetchHealthData();
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

    scrollController =
        ScrollController()..addListener(() {
          if (scrollController.offset >= 24) {
            if (topBarOpacity != 1.0) {
              setState(() {
                topBarOpacity = 1.0;
              });
            }
          } else if (scrollController.offset <= 24 &&
              scrollController.offset >= 0) {
            if (topBarOpacity != scrollController.offset / 24) {
              setState(() {
                topBarOpacity = scrollController.offset / 24;
              });
            }
          } else if (scrollController.offset <= 0) {
            if (topBarOpacity != 0.0) {
              setState(() {
                topBarOpacity = 0.0;
              });
            }
          }
        });

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    scrollController.dispose();
    super.dispose();
  }

  Future<Map<String, dynamic>> _fetchBraceletData() async {
    try {
      if (widget.patientData['braceletId'] == null ||
          widget.patientData['braceletId'].toString().isEmpty) {
        return {'error': 'No bracelet assigned'};
      }

      final braceletSnapshot =
          await FirebaseFirestore.instance
              .collection('Bracelets')
              .doc(widget.patientData['braceletId'].toString())
              .get();

      if (braceletSnapshot.exists) {
        final data = braceletSnapshot.data()!;
        return {
          'batteryLevel': data['batterylevel']?.toInt() ?? 0,
          'status': data['status']?.toString() ?? 'N/A',
          'lastUpdate': data['lastUpdate']?.toString() ?? 'N/A',
        };
      } else {
        return {'error': 'Bracelet not found'};
      }
    } catch (e) {
      return {'error': 'Failed to fetch data: $e'};
    }
  }

  Future<Map<String, dynamic>> _fetchHealthData() async {
    await Future.delayed(Duration(milliseconds: 500));
    return {'heartRate': 78, 'temperature': 36.8, 'fallDetected': false};
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

                SizedBox(height: 80), // Extra space for the bottom bar
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
                            SizedBox(
                              height: 38,
                              width: 38,
                              child: InkWell(
                                highlightColor: Colors.transparent,
                                borderRadius: const BorderRadius.all(
                                  Radius.circular(32.0),
                                ),
                                onTap: () {},
                                child: Center(
                                  child: Icon(
                                    Icons.keyboard_arrow_left,
                                    color: FitnessAppTheme.grey,
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 8, right: 8),
                              child: Row(
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.only(right: 8),
                                    child: Icon(
                                      Icons.calendar_today,
                                      color: FitnessAppTheme.grey,
                                      size: 18,
                                    ),
                                  ),
                                  Text(
                                    DateFormat('d MMM').format(DateTime.now()),
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                      fontFamily: FitnessAppTheme.fontName,
                                      fontWeight: FontWeight.normal,
                                      fontSize: 18,
                                      letterSpacing: -0.2,
                                      color: FitnessAppTheme.darkerText,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              height: 38,
                              width: 38,
                              child: InkWell(
                                highlightColor: Colors.transparent,
                                borderRadius: const BorderRadius.all(
                                  Radius.circular(32.0),
                                ),
                                onTap: () {},
                                child: Center(
                                  child: Icon(
                                    Icons.keyboard_arrow_right,
                                    color: FitnessAppTheme.grey,
                                  ),
                                ),
                              ),
                            ),
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
                              'Current position',
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

  Widget _buildBraceletStatusCard() {
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
                child: FutureBuilder<Map<String, dynamic>>(
                  future: _braceletData,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        heightFactor: 4,
                        child: CircularProgressIndicator(),
                      );
                    }

                    if (snapshot.hasError ||
                        snapshot.data?.containsKey('error') == true) {
                      return Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          snapshot.data?['error'] ?? 'Error loading data',
                          style: TextStyle(
                            color: Colors.red,
                            fontFamily: FitnessAppTheme.fontName,
                          ),
                        ),
                      );
                    }

                    final data = snapshot.data!;
                    final batteryLevel = data['batteryLevel'] ?? 0;
                    final isCharging =
                        data['status']?.toString().toLowerCase().contains(
                          'charging',
                        ) ??
                        false;

                    Color batteryColor;
                    if (isCharging) {
                      batteryColor = Colors.green;
                    } else if (batteryLevel < 10) {
                      batteryColor = Colors.red;
                    } else if (batteryLevel < 30) {
                      batteryColor = Colors.orange;
                    } else if (batteryLevel < 50) {
                      batteryColor = Colors.yellow;
                    } else {
                      batteryColor = Colors.green;
                    }

                    return Padding(
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
                                'Bracelet Battery Monitor',
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
                              'Ensuring patient safety through power tracking',
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
                                      'Status: ${isCharging ? 'Charging' : 'Not Charging'}',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color:
                                            isCharging
                                                ? Colors.green
                                                : Colors.grey,
                                      ),
                                    ),
                                    SizedBox(height: 12),
                                    Text(
                                      batteryLevel < 10
                                          ? 'Battery Level: Critical'
                                          : batteryLevel < 30
                                          ? 'Battery Level: Low'
                                          : batteryLevel < 50
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
                                        '$batteryLevel%',
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
                                        value: batteryLevel / 100,
                                        backgroundColor: Colors.transparent,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              batteryColor,
                                            ),
                                        strokeWidth: 7,
                                      ),
                                    ),
                                    Icon(
                                      isCharging
                                          ? Icons.bolt
                                          : Icons.battery_std,
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
                    );
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHealthMonitorCard() {
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
            child: FutureBuilder<Map<String, dynamic>>(
              future: _healthData,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError ||
                    snapshot.data == null ||
                    snapshot.data!.containsKey('error')) {
                  return Padding(
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
                        child: Center(
                          child: Text(
                            snapshot.data?['error'] ??
                                'Error loading health data',
                            style: TextStyle(
                              color: Colors.red,
                              fontFamily: FitnessAppTheme.fontName,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }

                final data = snapshot.data!;
                final int heartRate = data['heartRate'] ?? 0;
                final double temperature =
                    data['temperature']?.toDouble() ?? 0.0;
                final bool fallDetected = data['fallDetected'] ?? false;

                Color statusColor =
                    (heartRate > 100 || temperature > 38 || fallDetected)
                        ? Colors.orange
                        : Colors.green;

                return Padding(
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
                              'Real-time vital signs from the smart bracelet',
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
                                      '$heartRate bpm',
                                      heartRate > 100
                                          ? Colors.red
                                          : Colors.green,
                                    ),
                                    SizedBox(height: 10),
                                    _buildVitalRow(
                                      'Temperature',
                                      '${temperature.toStringAsFixed(1)} °C',
                                      temperature > 38
                                          ? Colors.orange
                                          : Colors.green,
                                    ),
                                    SizedBox(height: 10),
                                    _buildVitalRow(
                                      'Fall Detection',
                                      fallDetected ? '⚠ Detected' : '✓ Safe',
                                      fallDetected ? Colors.red : Colors.green,
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
                                      value: heartRate.clamp(0, 150) / 150,
                                      backgroundColor: Colors.transparent,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        statusColor,
                                      ),
                                      strokeWidth: 8,
                                    ),
                                    Icon(
                                      Icons.favorite,
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
                );
              },
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

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontFamily: FitnessAppTheme.fontName,
                fontWeight: FontWeight.w500,
                fontSize: 14,
                color: FitnessAppTheme.grey.withOpacity(0.5),
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: TextStyle(
                fontFamily: FitnessAppTheme.fontName,
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: FitnessAppTheme.darkerText,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () {
            // Add action here
          },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                SizedBox(width: 16),
                Text(
                  label,
                  style: TextStyle(
                    fontFamily: FitnessAppTheme.fontName,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: FitnessAppTheme.darkerText,
                  ),
                ),
                Spacer(),
                Icon(
                  Icons.chevron_right,
                  color: FitnessAppTheme.grey.withOpacity(0.5),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return PatientBottomNavigationBar(
      currentIndex: _currentBottomIndex,
      onTap: (index) {
        setState(() {
          _currentBottomIndex = index;
        });

        // Handle home and location navigation here since they're page-specific
        if (index == 0) {
          // Home
          scrollController.animateTo(
            0,
            duration: Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
        } else if (index == 2) {
          // Location
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
