import 'package:alzheimer_app/alzhimer_home/quize/PatientQuizPage.dart';
import 'package:alzheimer_app/alzhimer_home/quize/TakeQuizPage.dart';
import 'package:alzheimer_app/safe_zone/DoorAlertPage.dart';
import 'package:alzheimer_app/safe_zone/GpsHistoryPage.dart';
import 'package:alzheimer_app/settigns/SettingsPage.dart';
import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:alzheimer_app/games/MemoryQuizGame.dart';
import 'package:alzheimer_app/contact/PatientContactsPage.dart';

class PatientBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final String patientId;
  final String patientName;
  final ScrollController? scrollController;

  const PatientBottomNavigationBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
    required this.patientId,
    required this.patientName,
    this.scrollController,
  }) : super(key: key);

  // ... (keep all your existing methods like _showSettingsBottomSheet, etc.)

  @override
  Widget build(BuildContext context) {
    return CurvedNavigationBar(
      backgroundColor: Colors.transparent,
      color: Colors.white,
      buttonBackgroundColor: Colors.white,
      animationDuration: const Duration(milliseconds: 300),
      index: currentIndex,
      onTap: (index) {
        onTap(index);
        _handleNavigation(context, index);
      },
      items: [
        Icon(Icons.home, size: 30, color: Color.fromARGB(255, 3, 110, 145)),
        Icon(Icons.quiz, size: 30, color: Color.fromARGB(255, 3, 110, 145)),
        Icon(
          Icons.location_on,
          size: 30,
          color: Color.fromARGB(255, 3, 110, 145),
        ),
        Icon(
          Icons.door_sliding,
          size: 30,
          color: Color.fromARGB(255, 3, 110, 145),
        ), // Alternative door icon
        Icon(Icons.contacts, size: 30, color: Color.fromARGB(255, 3, 110, 145)),
        Icon(
          Icons.settings,
          size: 30,
          color: Color.fromARGB(255, 3, 110, 145),
        ), // New
      ],
    );
  }

  void _handleNavigation(BuildContext context, int index) {
    switch (index) {
      case 0: // Home
        // Handle home navigation if needed
        break;
      case 1: // Quiz Management
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => PatientQuizPage(
                  patientId: patientId,
                  patientName: patientName,
                ),
          ),
        );
        break;
      case 2: // Location
        // Handle location navigation if needed
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => GpsHistoryPage()),
        );
        break;

      case 3: // Door Device
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => SmartDoorBraceletPage()),
        );
        break;
      case 4: // Contacts
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => PatientContactsPage(
                  patientId: patientId,
                  patientName: patientName,
                ),
          ),
        );
        break;
      case 5: // Settings
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SettingsPage(patientId: patientId),
          ),
        );
        break;
    }
  }
}
