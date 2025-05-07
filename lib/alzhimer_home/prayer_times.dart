import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PrayerTimesPage extends StatefulWidget {
  @override
  _PrayerTimesPageState createState() => _PrayerTimesPageState();
}

class _PrayerTimesPageState extends State<PrayerTimesPage> {
  final Map<String, String> prayerTimes = {
    'Fajr': '04:30 AM',
    'Sunrise': '06:00 AM',
    'Dhuhr': '12:15 PM',
    'Asr': '03:45 PM',
    'Maghrib': '06:30 PM',
    'Isha': '08:00 PM',
  };

  final Map<String, String> arabicNames = {
    'Fajr': 'الفجر',
    'Sunrise': 'الشروق',
    'Dhuhr': 'الظهر',
    'Asr': 'العصر',
    'Maghrib': 'المغرب',
    'Isha': 'العشاء',
  };

  final Map<String, Color> prayerColors = {
    'Fajr': Color(0xFF0A2463),
    'Sunrise': Color(0xFFFB3640),
    'Dhuhr': Color(0xFF1E91D6),
    'Asr': Color(0xFF247BA0),
    'Maghrib': Color(0xFFFF7F11),
    'Isha': Color(0xFF2A2D34),
  };

  String? nextPrayer;
  Duration? timeUntilNext;
  Timer? _timer;
  DateTime now = DateTime.now();

  @override
  void initState() {
    super.initState();
    _updateNextPrayer();
    _timer = Timer.periodic(Duration(seconds: 1), (_) {
      setState(() {
        now = DateTime.now();
      });
      _updateNextPrayer();
    });
  }

  void _updateNextPrayer() {
    final format = DateFormat('hh:mm a');
    for (var entry in prayerTimes.entries) {
      final time = format.parse(entry.value);
      final prayerTime = DateTime(
        now.year,
        now.month,
        now.day,
        time.hour,
        time.minute,
      );
      if (prayerTime.isAfter(now)) {
        setState(() {
          nextPrayer = entry.key;
          timeUntilNext = prayerTime.difference(now);
        });
        return;
      }
    }
    final tomorrowFajr = format.parse(prayerTimes['Fajr']!);
    final prayerTime = DateTime(
      now.year,
      now.month,
      now.day + 1,
      tomorrowFajr.hour,
      tomorrowFajr.minute,
    );
    setState(() {
      nextPrayer = 'Fajr';
      timeUntilNext = prayerTime.difference(now);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String formatDuration(Duration? duration) {
    if (duration == null) return '';
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$hours:$minutes:$seconds';
  }

  String getCurrentTime() {
    return DateFormat('h:mm a').format(now);
  }

  String getCurrentDate() {
    return DateFormat('EEEE, MMMM d').format(now);
  }

  @override
  Widget build(BuildContext context) {
    final currentColor =
        nextPrayer != null ? prayerColors[nextPrayer] : Color(0xFF0A2463);

    return Scaffold(
      backgroundColor: Colors.white, // Light background
      body: SafeArea(
        child: Column(
          children: [
            // Header with date and time
            Container(
              padding: EdgeInsets.all(20),
              child: Column(
                children: [
                  Text(
                    getCurrentTime(),
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.w300,
                      color: Colors.black, // Dark text
                    ),
                  ),
                  Text(
                    getCurrentDate(),
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.black.withOpacity(0.9), // Dark text
                    ),
                  ),
                ],
              ),
            ),

            // Next prayer card
            if (nextPrayer != null && timeUntilNext != null)
              Container(
                margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.1), // Dark card background
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: Colors.black.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      'Next Prayer',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black.withOpacity(0.8),
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      arabicNames[nextPrayer!]!,
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      nextPrayer!,
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.black.withOpacity(0.8),
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      prayerTimes[nextPrayer!]!,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'in ${formatDuration(timeUntilNext)}',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.black.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),

            // Prayer times list with smooth scrolling
            Expanded(
              child: Container(
                margin: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.1), // Dark list background
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.black.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: ListView.separated(
                    padding: EdgeInsets.zero,
                    itemCount: prayerTimes.length,
                    separatorBuilder:
                        (_, __) => Divider(
                          color: Colors.black.withOpacity(0.1),
                          height: 1,
                          indent: 20,
                          endIndent: 20,
                        ),
                    itemBuilder: (context, index) {
                      final name = prayerTimes.keys.elementAt(index);
                      final time = prayerTimes[name]!;
                      final arabic = arabicNames[name]!;
                      final isCurrent = nextPrayer == name;

                      return Container(
                        decoration: BoxDecoration(
                          color:
                              isCurrent
                                  ? Colors.black.withOpacity(0.2)
                                  : Colors.transparent,
                        ),
                        child: ListTile(
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          leading: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: prayerColors[name]!.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                arabic.substring(0, 1),
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          title: Text(
                            name,
                            style: TextStyle(
                              color: Colors.black.withOpacity(0.9), // Dark text
                              fontSize: 16,
                            ),
                          ),
                          subtitle: Text(
                            arabic,
                            style: TextStyle(
                              color: Colors.black.withOpacity(0.7), // Dark text
                              fontSize: 14,
                            ),
                          ),
                          trailing: Text(
                            time,
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),

            // Footer with dua
            Padding(
              padding: EdgeInsets.all(20),
              child: Text(
                'رب اجعلني مقيم الصلاة ومن ذريتي',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black.withOpacity(0.8), // Dark text
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
