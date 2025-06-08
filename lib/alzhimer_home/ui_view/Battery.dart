import 'package:alzheimer_app/alzhimer_home/alzhimer_app_theme.dart';
import 'package:alzheimer_app/main.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math' as math;

class BatteryView extends StatelessWidget {
  final AnimationController? animationController;
  final Animation<double>? animation;

  const BatteryView({Key? key, this.animationController, this.animation})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animationController!,
      builder: (BuildContext context, Widget? child) {
        return FadeTransition(
          opacity: animation!,
          child: Transform(
            transform: Matrix4.translationValues(
              0.0,
              30 * (1.0 - animation!.value),
              0.0,
            ),
            child: Padding(
              padding: const EdgeInsets.only(
                left: 24,
                right: 24,
                top: 16,
                bottom: 18,
              ),
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
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(
                        top: 16,
                        left: 16,
                        right: 16,
                      ),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(
                                left: 8,
                                right: 8,
                                top: 4,
                              ),
                              child: Row(
                                children: <Widget>[
                                  Container(
                                    height: 48,
                                    width: 2,
                                    decoration: BoxDecoration(
                                      color: HexColor(
                                        '#87A0E5',
                                      ).withOpacity(0.5),
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(4.0),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: FutureBuilder<
                                        Map<String, dynamic>
                                      >(
                                        future: _getBatteryData(),
                                        builder: (context, snapshot) {
                                          if (snapshot.connectionState ==
                                              ConnectionState.waiting) {
                                            return Center(
                                              child:
                                                  CircularProgressIndicator(),
                                            );
                                          }
                                          if (snapshot.hasError) {
                                            return Text(
                                              'Error loading battery info',
                                              style: TextStyle(
                                                color: Colors.red,
                                              ),
                                            );
                                          }

                                          final batteryLevel =
                                              snapshot.data?['level'] ?? 0;
                                          final isCharging =
                                              snapshot.data?['isCharging'] ??
                                              false;

                                          return Row(
                                            children: [
                                              // Text content
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: <Widget>[
                                                    Text(
                                                      'Bracelet Battery',
                                                      style: TextStyle(
                                                        fontFamily:
                                                            FitnessAppTheme
                                                                .fontName,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        fontSize: 16,
                                                        letterSpacing: -0.1,
                                                        color: FitnessAppTheme
                                                            .grey
                                                            .withOpacity(0.5),
                                                      ),
                                                    ),
                                                    Row(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .end,
                                                      children: <Widget>[
                                                        Text(
                                                          '$batteryLevel%',
                                                          style: TextStyle(
                                                            fontFamily:
                                                                FitnessAppTheme
                                                                    .fontName,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            fontSize: 18,
                                                            color:
                                                                FitnessAppTheme
                                                                    .darkerText,
                                                          ),
                                                        ),
                                                        SizedBox(width: 4),
                                                        if (isCharging)
                                                          Text(
                                                            'Charging',
                                                            style: TextStyle(
                                                              fontFamily:
                                                                  FitnessAppTheme
                                                                      .fontName,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              fontSize: 12,
                                                              letterSpacing:
                                                                  -0.2,
                                                              color:
                                                                  Colors.green,
                                                            ),
                                                          ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              SizedBox(width: 32),
                                              // Battery Circle
                                              Container(
                                                width: 60,
                                                height: 60,
                                                child: CustomPaint(
                                                  painter: _BatteryLevelPainter(
                                                    level: batteryLevel,
                                                    baseColor: _getBaseColor(
                                                      batteryLevel,
                                                      isCharging,
                                                    ),
                                                    glowColor: _getGlowColor(
                                                      batteryLevel,
                                                      isCharging,
                                                    ),
                                                    isCharging: isCharging,
                                                  ),
                                                ),
                                              ),
                                              SizedBox(width: 16),
                                            ],
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                ],
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
          ),
        );
      },
    );
  }

  Color _getBaseColor(int level, bool isCharging) {
    if (isCharging) return Colors.green;
    if (level < 10) return Colors.red;
    if (level < 50) return Colors.orange;
    return Colors.green;
  }

  Color _getGlowColor(int level, bool isCharging) {
    if (isCharging) return Colors.lightGreenAccent;
    if (level < 10) return Colors.redAccent;
    if (level < 50) return Colors.orangeAccent;
    return Colors.lightGreenAccent;
  }

  Future<Map<String, dynamic>> _getBatteryData() async {
    try {
      // 1. Get current user
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        return {'level': 0, 'isCharging': false};
      }

      // 2. Query patient document where assistantId matches current user UID
      final patientQuery =
          await FirebaseFirestore.instance
              .collection('patients')
              .where('assistantId', isEqualTo: user.uid)
              .limit(1)
              .get();

      if (patientQuery.docs.isEmpty) {
        return {'level': 0, 'isCharging': false};
      }

      final patientData = patientQuery.docs.first.data();
      final braceletId = patientData['braceletId'] as String?;

      if (braceletId == null || braceletId.isEmpty) {
        return {'level': 0, 'isCharging': false};
      }

      // 3. Get bracelet document
      final braceletDoc =
          await FirebaseFirestore.instance
              .collection('Bracelets')
              .doc(braceletId)
              .get();

      if (!braceletDoc.exists) {
        return {'level': 0, 'isCharging': false};
      }

      final braceletData = braceletDoc.data();
      final batteryLevel = braceletData?['batterylevel'] as int? ?? 0;
      final isCharging = braceletData?['charging'] as bool? ?? false;

      return {'level': batteryLevel, 'isCharging': isCharging};
    } catch (e) {
      print('Error fetching battery data: $e');
      return {'level': 0, 'isCharging': false};
    }
  }
}

class _BatteryLevelPainter extends CustomPainter {
  final int level;
  final Color baseColor;
  final Color glowColor;
  final bool isCharging;

  _BatteryLevelPainter({
    required this.level,
    required this.baseColor,
    required this.glowColor,
    required this.isCharging,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final strokeWidth = 10.0;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) * 0.9;

    // Background circle
    final backgroundPaint =
        Paint()
          ..color = Colors.grey.withOpacity(0.1)
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth;

    canvas.drawCircle(center, radius, backgroundPaint);

    // Battery level arc with curved ends
    final sweepAngle = 2 * math.pi * (level / 100);
    final startAngle = -math.pi / 2;

    final arcPaint =
        Paint()
          ..color = baseColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..strokeCap = StrokeCap.round;

    if (isCharging) {
      arcPaint.shader = SweepGradient(
        colors: [glowColor, baseColor],
        stops: [0.3, 1.0],
        startAngle: startAngle,
        endAngle: startAngle + sweepAngle,
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    }

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      arcPaint,
    );

    // Glow effect
    if (isCharging || level > 70) {
      final glowPaint =
          Paint()
            ..color = glowColor.withOpacity(0.3)
            ..maskFilter = MaskFilter.blur(BlurStyle.normal, 8.0);

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        glowPaint,
      );
    }

    // Center text
    final textPainter = TextPainter(
      text: TextSpan(
        text: '$level%',
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: baseColor,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        center.dx - textPainter.width / 2,
        center.dy - textPainter.height / 2,
      ),
    );
  }

  @override
  bool shouldRepaint(covariant _BatteryLevelPainter oldDelegate) {
    return level != oldDelegate.level ||
        isCharging != oldDelegate.isCharging ||
        baseColor != oldDelegate.baseColor;
  }
}
