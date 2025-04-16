import 'package:alzheimer_app/alzhimer_home/fitness_app_theme.dart';
import 'package:alzheimer_app/main.dart';
import 'package:battery_plus/battery_plus.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

class MediterranesnDietView extends StatelessWidget {
  final AnimationController? animationController;
  final Animation<double>? animation;

  const MediterranesnDietView({
    Key? key,
    this.animationController,
    this.animation,
  }) : super(key: key);
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
                                            return CircularProgressIndicator();
                                          }
                                          if (snapshot.hasError) {
                                            return Text(
                                              'Error loading battery info',
                                            );
                                          }

                                          final batteryLevel =
                                              snapshot.data?['level'] ?? 0;
                                          final batteryStatus =
                                              snapshot.data?['status'] ??
                                              'unknown';

                                          return Row(
                                            children: [
                                              // Text content
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: <Widget>[
                                                    Text(
                                                      'Battery',
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
                                                        Text(
                                                          _getStatusText(
                                                            batteryStatus,
                                                          ),
                                                          style: TextStyle(
                                                            fontFamily:
                                                                FitnessAppTheme
                                                                    .fontName,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            fontSize: 12,
                                                            letterSpacing: -0.2,
                                                            color:
                                                                FitnessAppTheme
                                                                    .grey
                                                                    .withOpacity(
                                                                      0.5,
                                                                    ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              // Add more spacing here to move circle left
                                              SizedBox(
                                                width: 32,
                                              ), // Increased from 16 to 32
                                              // Battery Circle
                                              Container(
                                                width: 60,
                                                height: 60,
                                                child: CustomPaint(
                                                  painter: _BatteryLevelPainter(
                                                    level: batteryLevel,
                                                    baseColor: _getBaseColor(
                                                      batteryStatus,
                                                      batteryLevel,
                                                    ),
                                                    glowColor: _getGlowColor(
                                                      batteryStatus,
                                                      batteryLevel,
                                                    ),
                                                    isCharging:
                                                        batteryStatus ==
                                                        BatteryState.charging,
                                                  ),
                                                ),
                                              ),
                                              // Add this empty SizedBox to prevent the circle from going to extreme right
                                              SizedBox(
                                                width: 16,
                                              ), // Additional space on the right
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

  Color _getBaseColor(BatteryState status, int level) {
    if (status == BatteryState.charging) return Colors.green;
    if (level < 20) return Colors.red;
    if (level < 40) return Colors.orange;
    return Colors.green;
  }

  Color _getGlowColor(BatteryState status, int level) {
    if (status == BatteryState.charging) return Colors.lightGreenAccent;
    if (level < 20) return Colors.redAccent;
    if (level < 40) return Colors.orangeAccent;
    return Colors.lightGreenAccent;
  }

  String _getStatusText(BatteryState status) {
    switch (status) {
      case BatteryState.charging:
        return 'Charging';
      case BatteryState.discharging:
        return 'Discharging';
      case BatteryState.full:
        return 'Full';
      default:
        return 'Unknown';
    }
  }

  Future<Map<String, dynamic>> _getBatteryData() async {
    final battery = Battery();
    final level = await battery.batteryLevel;
    final status = await battery.batteryState;
    return {'level': level, 'status': status};
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
    final strokeWidth = 10.0; // Thicker stroke for curved appearance
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) * 0.9; // Larger radius

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
          ..strokeCap = StrokeCap.round; // This creates the curved ends

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
