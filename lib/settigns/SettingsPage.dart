import 'package:flutter/material.dart';
import 'package:alzheimer_app/alzhimer_home/alzhimer_app_theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class SettingsPage extends StatefulWidget {
  final AnimationController? animationController;
  final String patientId;

  const SettingsPage({
    Key? key,
    this.animationController,
    required this.patientId,
  }) : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  Animation<double>? topBarAnimation;
  double topBarOpacity = 0.0;
  late ScrollController scrollController;
  Map<String, dynamic>? patientData;
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _fullNameController;
  late TextEditingController _ageController;
  late TextEditingController _locationController;
  late TextEditingController _medicalNotesController;
  late TextEditingController _braceletIdController;

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

    // Initialize controllers
    _fullNameController = TextEditingController();
    _ageController = TextEditingController();
    _locationController = TextEditingController();
    _medicalNotesController = TextEditingController();
    _braceletIdController = TextEditingController();

    // Fetch patient data when the page loads
    _fetchPatientData();
  }

  Future<void> _fetchPatientData() async {
    try {
      DocumentSnapshot doc =
          await FirebaseFirestore.instance
              .collection('patients')
              .doc(widget.patientId)
              .get();

      if (doc.exists) {
        setState(() {
          patientData = doc.data() as Map<String, dynamic>;
          // Update controllers with fetched data
          _fullNameController.text = patientData!['fullName'] ?? '';
          _ageController.text = patientData!['age']?.toString() ?? '';
          _locationController.text = patientData!['location'] ?? '';
          _medicalNotesController.text = patientData!['medicalNotes'] ?? '';
          _braceletIdController.text = patientData!['braceletId'] ?? '';
        });
      }
    } catch (e) {
      print('Error fetching patient data: $e');
    }
  }

  Future<void> _updatePatientData() async {
    if (_formKey.currentState!.validate()) {
      try {
        await FirebaseFirestore.instance
            .collection('patients')
            .doc(widget.patientId)
            .update({
              'fullName': _fullNameController.text,
              'age': int.tryParse(_ageController.text) ?? 0,
              'location': _locationController.text,
              'medicalNotes': _medicalNotesController.text,
              'braceletId': _braceletIdController.text,
              'updatedAt': FieldValue.serverTimestamp(),
            });

        // Refresh the data
        await _fetchPatientData();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Patient information updated successfully'),
          ),
        );

        Navigator.pop(context); // Close the dialog
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating patient information: $e')),
        );
      }
    }
  }

  void _showPatientInfoDialog() {
    if (patientData == null) return;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: FitnessAppTheme.white,
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Patient Information',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: FitnessAppTheme.nearlyDarkBlue,
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.close, color: FitnessAppTheme.grey),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Form Content
                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildEditableField('Full Name', _fullNameController),
                        const SizedBox(height: 12),
                        _buildEditableField(
                          'Age',
                          _ageController,
                          isNumber: true,
                        ),
                        const SizedBox(height: 12),
                        _buildEditableField('Location', _locationController),
                        const SizedBox(height: 12),
                        _buildEditableField(
                          'Medical Notes',
                          _medicalNotesController,
                        ),
                        const SizedBox(height: 12),
                        _buildEditableField(
                          'Bracelet ID',
                          _braceletIdController,
                        ),
                        const SizedBox(height: 12),
                        _buildReadOnlyField(
                          'Created At',
                          patientData!['createdAt'] != null
                              ? DateFormat('dd MMM yyyy').format(
                                (patientData!['createdAt'] as Timestamp)
                                    .toDate(),
                              )
                              : 'N/A',
                        ),
                        if (patientData!['updatedAt'] != null) ...[
                          const SizedBox(height: 12),
                          _buildReadOnlyField(
                            'Last Updated',
                            DateFormat('dd MMM yyyy').format(
                              (patientData!['updatedAt'] as Timestamp).toDate(),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Action Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            color: FitnessAppTheme.grey,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: _updatePatientData,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: FitnessAppTheme.nearlyDarkBlue,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 2,
                        ),
                        child: const Text(
                          'Save Changes',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
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
    );
  }

  Widget _buildEditableField(
    String label,
    TextEditingController controller, {
    bool isNumber = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: FitnessAppTheme.nearlyDarkBlue,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey[100],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
          style: TextStyle(color: FitnessAppTheme.darkerText, fontSize: 16),
          keyboardType: isNumber ? TextInputType.number : TextInputType.text,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter $label';
            }
            if (isNumber && int.tryParse(value) == null) {
              return 'Please enter a valid number';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildReadOnlyField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: FitnessAppTheme.nearlyDarkBlue,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            value,
            style: TextStyle(color: FitnessAppTheme.darkerText, fontSize: 16),
          ),
        ),
      ],
    );
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

  @override
  void dispose() {
    _animationController.dispose();
    scrollController.dispose();
    _fullNameController.dispose();
    _ageController.dispose();
    _locationController.dispose();
    _medicalNotesController.dispose();
    _braceletIdController.dispose();
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
                const SizedBox(height: 24),
                _buildAccountCard(),
                const SizedBox(height: 24),
                _buildPreferencesCard(),
                const SizedBox(height: 24),
                _buildOtherSettingsCard(),
                const SizedBox(height: 24),
                const SizedBox(height: 80),
              ],
            ),
          ),
          getAppBarUI(),
        ],
      ),
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
                                  'Settings',
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
                              width: 38,
                              height: 38,
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

  Widget _buildAccountCard() {
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
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(8.0),
                    bottomLeft: Radius.circular(8.0),
                    bottomRight: Radius.circular(8.0),
                    topRight: Radius.circular(68.0),
                  ),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: FitnessAppTheme.grey.withOpacity(0.2),
                      offset: const Offset(1.1, 1.1),
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
                          const SizedBox(width: 8),
                          Text(
                            'Account',
                            style: TextStyle(
                              fontFamily: FitnessAppTheme.fontName,
                              fontWeight: FontWeight.w600,
                              fontSize: 18,
                              color: FitnessAppTheme.nearlyDarkBlue,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      const Divider(height: 1, indent: 72),
                      _buildSettingItem(
                        icon: Icons.medical_services_outlined,
                        title: "Patient Info",
                        subtitle: "View and edit patient details",
                        color: FitnessAppTheme.nearlyDarkBlue,
                        onTap: _showPatientInfoDialog,
                      ),
                      const Divider(height: 1, indent: 72),
                      _buildSettingItem(
                        icon: Icons.lock_outline,
                        title: "Change Password",
                        subtitle: "Manage your account security",
                        color: FitnessAppTheme.nearlyBlue,
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

  Widget _buildPreferencesCard() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

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
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(8.0),
                    bottomLeft: Radius.circular(8.0),
                    bottomRight: Radius.circular(8.0),
                    topRight: Radius.circular(68.0),
                  ),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: FitnessAppTheme.grey.withOpacity(0.2),
                      offset: const Offset(1.1, 1.1),
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
                              color: FitnessAppTheme.nearlyDarkBlue,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Preferences',
                            style: TextStyle(
                              fontFamily: FitnessAppTheme.fontName,
                              fontWeight: FontWeight.w600,
                              fontSize: 18,
                              color: FitnessAppTheme.nearlyDarkBlue,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        secondary: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: FitnessAppTheme.nearlyDarkBlue.withOpacity(
                              0.1,
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.dark_mode_outlined,
                            color: FitnessAppTheme.nearlyDarkBlue,
                            size: 20,
                          ),
                        ),
                        title: Text(
                          'Dark Mode',
                          style: TextStyle(
                            fontFamily: FitnessAppTheme.fontName,
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                            color: FitnessAppTheme.nearlyDarkBlue,
                          ),
                        ),
                        value: isDarkMode,
                        onChanged: (value) {
                          // Implement theme switching
                        },
                      ),
                      const Divider(height: 1, indent: 72),
                      _buildSettingItem(
                        icon: Icons.language_outlined,
                        title: "Language",
                        subtitle: "English (US)",
                        color: FitnessAppTheme.nearlyBlue,
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

  Widget _buildOtherSettingsCard() {
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
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(8.0),
                    bottomLeft: Radius.circular(8.0),
                    bottomRight: Radius.circular(8.0),
                    topRight: Radius.circular(68.0),
                  ),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: FitnessAppTheme.grey.withOpacity(0.2),
                      offset: const Offset(1.1, 1.1),
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
                              color: Colors.orange,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Other',
                            style: TextStyle(
                              fontFamily: FitnessAppTheme.fontName,
                              fontWeight: FontWeight.w600,
                              fontSize: 18,
                              color: FitnessAppTheme.nearlyDarkBlue,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _buildSettingItem(
                        icon: Icons.info_outline,
                        title: "About App",
                        subtitle: "Version 1.0.0",
                        color: Colors.orange,
                      ),
                      const Divider(height: 1, indent: 72),
                      _buildSettingItem(
                        icon: Icons.help_outline,
                        title: "Help & Support",
                        color: FitnessAppTheme.nearlyBlue,
                      ),
                      const Divider(height: 1, indent: 72),
                      _buildSettingItem(
                        icon: Icons.logout,
                        title: "Logout",
                        color: Colors.red,
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

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    String? subtitle,
    required Color color,
    VoidCallback? onTap,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 20, color: color),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontFamily: FitnessAppTheme.fontName,
          fontWeight: FontWeight.w500,
          fontSize: 16,
          color: color == Colors.red ? color : FitnessAppTheme.nearlyDarkBlue,
        ),
      ),
      subtitle:
          subtitle != null
              ? Text(
                subtitle,
                style: TextStyle(
                  fontFamily: FitnessAppTheme.fontName,
                  fontSize: 12,
                  color: FitnessAppTheme.grey,
                ),
              )
              : null,
      trailing: Icon(Icons.keyboard_arrow_right, color: FitnessAppTheme.grey),
      onTap: onTap,
    );
  }
}
