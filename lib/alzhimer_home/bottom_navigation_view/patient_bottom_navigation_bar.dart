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

  void _showSettingsBottomSheet(BuildContext context) {
    bool _notificationsEnabled = true;
    bool _darkModeEnabled = false;
    String _language = 'English';
    String _fontSize = 'Medium';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Container(
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
              ),
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Drag handle
                  Container(
                    margin: EdgeInsets.only(top: 12, bottom: 4),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[400],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  // Title
                  Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      'Settings',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 3, 110, 145),
                      ),
                    ),
                  ),
                  Divider(height: 1),
                  // Settings content
                  Expanded(
                    child: ListView(
                      padding: EdgeInsets.zero,
                      children: [
                        _buildSectionHeader('Appearance'),
                        _buildSettingItem(
                          icon: Icons.dark_mode,
                          title: 'Dark Mode',
                          trailing: Switch(
                            value: _darkModeEnabled,
                            onChanged: (value) {
                              setState(() => _darkModeEnabled = value);
                            },
                            activeColor: Color.fromARGB(255, 3, 110, 145),
                          ),
                        ),
                        _buildSettingItem(
                          icon: Icons.text_fields,
                          title: 'Font Size',
                          trailing: DropdownButton<String>(
                            value: _fontSize,
                            underline: Container(),
                            items:
                                ['Small', 'Medium', 'Large'].map((
                                  String value,
                                ) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                }).toList(),
                            onChanged: (value) {
                              if (value != null) {
                                setState(() => _fontSize = value);
                              }
                            },
                          ),
                        ),
                        _buildSectionHeader('Preferences'),
                        _buildSettingItem(
                          icon: Icons.notifications,
                          title: 'Notifications',
                          trailing: Switch(
                            value: _notificationsEnabled,
                            onChanged: (value) {
                              setState(() => _notificationsEnabled = value);
                            },
                            activeColor: Color.fromARGB(255, 3, 110, 145),
                          ),
                        ),
                        SizedBox(height: 20),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Colors.grey.shade600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    Widget? trailing,
    VoidCallback? onTap,
    Color? textColor,
    Color? iconColor,
  }) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Color.fromARGB(255, 3, 110, 145).withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: iconColor ?? Color.fromARGB(255, 3, 110, 145)),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: textColor ?? Colors.black,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: trailing ?? const Icon(Icons.chevron_right, size: 20),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
    );
  }

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
      items: const <Widget>[
        Icon(Icons.home, size: 30, color: Color.fromARGB(255, 3, 110, 145)),
        Icon(Icons.quiz, size: 30, color: Color.fromARGB(255, 3, 110, 145)),
        Icon(
          Icons.location_on,
          size: 30,
          color: Color.fromARGB(255, 3, 110, 145),
        ),
        Icon(
          Icons.contact_page,
          size: 30,
          color: Color.fromARGB(255, 3, 110, 145),
        ),
        Icon(Icons.settings, size: 30, color: Color.fromARGB(255, 3, 110, 145)),
      ],
    );
  }

  void _handleNavigation(BuildContext context, int index) {
    switch (index) {
      case 1: // Quiz Management
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => PatientQuizPage(
                  patientId: patientId,
                  patientName: patientName, // Replace with actual patient name
                ),
          ),
        );
        break;
      case 3: // Contact
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
    }
  }
}
