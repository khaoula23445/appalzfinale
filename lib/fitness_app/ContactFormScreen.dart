import 'package:alzheimer_app/fitness_app/bottom_navigation_view/bottom_bar_view.dart';
import 'package:alzheimer_app/fitness_app/fitness_app_home_screen.dart';
import 'package:alzheimer_app/fitness_app/fitness_app_theme.dart';
import 'package:alzheimer_app/fitness_app/models/tabIcon_data.dart';
import 'package:alzheimer_app/fitness_app/training/GameSelectionScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ContactPage extends StatefulWidget {
  const ContactPage({Key? key}) : super(key: key);

  @override
  State<ContactPage> createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage>
    with TickerProviderStateMixin {
  // Bottom navigation variables
  List<TabIconData> tabIconsList = TabIconData.tabIconsList;
  late AnimationController animationController;
  Widget tabBody = Container(color: FitnessAppTheme.background);

  // Form controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _labelController = TextEditingController();

  // Form key
  final GlobalKey<FormState> _trustedContactsFormKey = GlobalKey<FormState>();

  // State variables
  String _countryCode = '+1';
  String? _priority;
  final List<Map<String, dynamic>> _trustedContacts = [];

  // Color palette
  static const Color _primaryColor = Color(0xFF1E3A8A);
  static const Color _secondaryColor = Color(0xFFE6F0FA);
  static const Color _accentColor = Color(0xFFFF5252);
  static const Color _textPrimary = Color(0xFF333333);
  static const Color _textSecondary = Color(0xFF666666);
  static const Color _borderColor = Color(0xFFDDDDDD);

  // Constants
  static const double _cardElevation = 2.0;
  static const double _borderRadius = 12.0;
  static const EdgeInsets _defaultPadding = EdgeInsets.all(16.0);
  static const EdgeInsets _inputPadding = EdgeInsets.symmetric(
    horizontal: 12,
    vertical: 16,
  );

  // Country data
  final List<Map<String, String>> _countries = [
    {'code': '+1', 'flag': '🇺🇸', 'name': 'United States'},
    {'code': '+44', 'flag': '🇬🇧', 'name': 'United Kingdom'},
    {'code': '+33', 'flag': '🇫🇷', 'name': 'France'},
    {'code': '+49', 'flag': '🇩🇪', 'name': 'Germany'},
    {'code': '+81', 'flag': '🇯🇵', 'name': 'Japan'},
    {'code': '+86', 'flag': '🇨🇳', 'name': 'China'},
    {'code': '+91', 'flag': '🇮🇳', 'name': 'India'},
    {'code': '+7', 'flag': '🇷🇺', 'name': 'Russia'},
    {'code': '+20', 'flag': '🇪🇬', 'name': 'Egypt'},
    {'code': '+971', 'flag': '🇦🇪', 'name': 'UAE'},
  ];

  // Priority options
  final List<String> _priorityOptions = ['High', 'Medium', 'Low'];

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Sort contacts by priority
    _trustedContacts.sort((a, b) {
      final priorityOrder = {'High': 1, 'Medium': 2, 'Low': 3};
      return priorityOrder[a['priority']]!.compareTo(
        priorityOrder[b['priority']]!,
      );
    });

    return Container(
      color: FitnessAppTheme.background,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text(
            "Trusted Contacts",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          backgroundColor: Colors.white,
          foregroundColor: _primaryColor,
          elevation: 0,
        ),
        body: FutureBuilder<bool>(
          future: getData(),
          builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
            if (!snapshot.hasData) {
              return const SizedBox();
            } else {
              return Stack(
                children: <Widget>[
                  SingleChildScrollView(
                    padding: _defaultPadding,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Add Emergency Contacts Section
                        _buildSectionHeader("Add Emergency Contacts"),
                        const SizedBox(height: 20),

                        // Contact Form
                        Card(
                          elevation: _cardElevation,
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(_borderRadius),
                          ),
                          child: Padding(
                            padding: _defaultPadding,
                            child: _buildContactForm(),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Trusted Contacts List
                        _buildTrustedContactsList(),
                        const SizedBox(height: 24),

                        // Quick Emergency Numbers
                        _buildEmergencyNumbersSection(),
                        const SizedBox(height: 80), // Space for bottom bar
                      ],
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: _buildBottomBar(),
                  ),
                ],
              );
            }
          },
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return BottomBarView(
      tabIconsList: tabIconsList,
      addClick: () {
        // Action for center button
      },
      changeIndex: (int index) {
        if (!mounted) return;

        animationController.reverse().then<dynamic>((data) {
          if (!mounted) return;

          setState(() {
            switch (index) {
              case 0:
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FitnessAppHomeScreen(),
                  ),
                );
                break;
              case 1:
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => GameSelectionScreen(),
                  ),
                );
                break;
              case 2:
                // Already on contacts page
                break;
              case 3:
                // Add your settings screen here
                break;
            }
          });
        });
      },
    );
  }

  Future<bool> getData() async {
    await Future<dynamic>.delayed(const Duration(milliseconds: 200));
    return true;
  }

  // Rest of your existing methods (_buildSectionHeader, _buildContactForm, etc.)
  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: _textPrimary,
      ),
    );
  }

  Widget _buildContactForm() {
    return Form(
      key: _trustedContactsFormKey,
      child: Column(
        children: [
          TextFormField(
            controller: _nameController,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              labelText: "Contact Name",
              labelStyle: const TextStyle(color: _textSecondary),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(_borderRadius),
                borderSide: const BorderSide(color: _borderColor),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(_borderRadius),
                borderSide: const BorderSide(color: _borderColor),
              ),
              prefixIcon: const Icon(Icons.person, color: _textSecondary),
              contentPadding: _inputPadding,
            ),
            validator:
                (value) =>
                    value?.isEmpty ?? true ? 'Please enter a name' : null,
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Container(
                width: 140,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: _borderColor),
                  borderRadius: BorderRadius.circular(_borderRadius),
                ),
                child: DropdownButton<String>(
                  value: _countryCode,
                  isExpanded: true,
                  underline: const SizedBox(),
                  icon: const Icon(
                    Icons.arrow_drop_down,
                    color: _textSecondary,
                  ),
                  items:
                      _countries.map((country) {
                        return DropdownMenuItem<String>(
                          value: country['code'],
                          child: Row(
                            children: [
                              Text(country['flag']!),
                              const SizedBox(width: 8),
                              Text(country['code']!),
                            ],
                          ),
                        );
                      }).toList(),
                  onChanged: (String? newValue) {
                    setState(() => _countryCode = newValue!);
                  },
                ),
              ),
              const SizedBox(width: 8),

              Expanded(
                child: TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    labelText: "Phone Number",
                    labelStyle: const TextStyle(color: _textSecondary),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(_borderRadius),
                      borderSide: const BorderSide(color: _borderColor),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(_borderRadius),
                      borderSide: const BorderSide(color: _borderColor),
                    ),
                    contentPadding: _inputPadding,
                  ),
                  validator:
                      (value) =>
                          value?.isEmpty ?? true
                              ? 'Please enter a phone number'
                              : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          TextFormField(
            controller: _labelController,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              labelText: "Label (e.g., Doctor, Family)",
              labelStyle: const TextStyle(color: _textSecondary),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(_borderRadius),
                borderSide: const BorderSide(color: _borderColor),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(_borderRadius),
                borderSide: const BorderSide(color: _borderColor),
              ),
              prefixIcon: const Icon(Icons.label, color: _textSecondary),
              contentPadding: _inputPadding,
            ),
            validator:
                (value) =>
                    value?.isEmpty ?? true ? 'Please enter a label' : null,
          ),
          const SizedBox(height: 16),

          DropdownButtonFormField<String>(
            value: _priority,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              labelText: "Priority",
              labelStyle: const TextStyle(color: _textSecondary),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(_borderRadius),
                borderSide: const BorderSide(color: _borderColor),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(_borderRadius),
                borderSide: const BorderSide(color: _borderColor),
              ),
              prefixIcon: const Icon(
                Icons.priority_high,
                color: _textSecondary,
              ),
              contentPadding: _inputPadding,
            ),
            items:
                _priorityOptions.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Row(
                      children: [
                        _getPriorityIcon(value, size: 20),
                        const SizedBox(width: 8),
                        Text(value),
                      ],
                    ),
                  );
                }).toList(),
            onChanged:
                (String? newValue) => setState(() => _priority = newValue),
            validator:
                (value) => value == null ? 'Please select priority' : null,
          ),
          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(_borderRadius),
                ),
                elevation: 0,
              ),
              onPressed: _addContact,
              child: const Text(
                "Add Emergency Contact",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrustedContactsList() {
    if (_trustedContacts.isEmpty) {
      return Column(
        children: [
          const Divider(),
          const SizedBox(height: 20),
          Center(
            child: Column(
              children: [
                const Icon(Icons.emergency, size: 50, color: _textSecondary),
                const SizedBox(height: 8),
                Text(
                  "No emergency contacts added yet",
                  style: TextStyle(color: _textSecondary),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader("Your Emergency Contacts"),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _trustedContacts.length,
          itemBuilder: (context, index) {
            final contact = _trustedContacts[index];
            return Card(
              elevation: _cardElevation,
              color: Colors.white,
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(_borderRadius),
              ),
              child: ListTile(
                leading: _getPriorityIcon(contact['priority']),
                title: Text(
                  contact['name'],
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(contact['phone']),
                    Text(
                      contact['label'],
                      style: const TextStyle(color: _textSecondary),
                    ),
                  ],
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: _accentColor),
                  onPressed: () => _removeContact(index),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildEmergencyNumbersSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader("Quick Emergency Numbers"),
        const SizedBox(height: 16),
        _buildEmergencyContactRow(
          Icons.local_police,
          "Police",
          "911",
          _accentColor,
        ),
        const SizedBox(height: 12),
        _buildEmergencyContactRow(
          Icons.local_hospital,
          "Ambulance",
          "911",
          _accentColor,
        ),
        const SizedBox(height: 12),
        _buildEmergencyContactRow(
          Icons.security,
          "Security",
          "+1 234 567 890",
          Colors.orange,
        ),
      ],
    );
  }

  Widget _buildEmergencyContactRow(
    IconData icon,
    String label,
    String number,
    Color color,
  ) {
    return Card(
      elevation: _cardElevation,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_borderRadius),
        side: BorderSide(color: color.withOpacity(0.2), width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(fontWeight: FontWeight.bold, color: color),
                  ),
                  Text(number),
                ],
              ),
            ),
            IconButton(
              icon: Icon(Icons.call, color: color),
              onPressed: () => _callNumber(number),
            ),
          ],
        ),
      ),
    );
  }

  Widget _getPriorityIcon(String? priority, {double size = 30}) {
    switch (priority) {
      case 'High':
        return Icon(Icons.priority_high, color: _accentColor, size: size);
      case 'Medium':
        return Icon(Icons.low_priority, color: Colors.orange, size: size);
      case 'Low':
        return Icon(Icons.arrow_circle_down, color: Colors.green, size: size);
      default:
        return Icon(Icons.person, color: _primaryColor, size: size);
    }
  }

  void _addContact() {
    if (_trustedContactsFormKey.currentState!.validate()) {
      setState(() {
        _trustedContacts.add({
          'name': _nameController.text,
          'phone': '$_countryCode${_phoneController.text}',
          'label': _labelController.text,
          'priority': _priority,
        });
        _nameController.clear();
        _phoneController.clear();
        _labelController.clear();
        _priority = null;
      });
    }
  }

  void _removeContact(int index) {
    setState(() => _trustedContacts.removeAt(index));
  }

  void _callNumber(String number) {
    // Implement call functionality
    debugPrint('Calling $number');
  }
}
