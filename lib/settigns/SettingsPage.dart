import 'package:flutter/material.dart';
import 'package:alzheimer_app/alzhimer_home/alzhimer_app_theme.dart';

class SettingsPage extends StatefulWidget {
  final String patientName;
  final String patientAge;
  final String patientCondition;

  const SettingsPage({
    Key? key,
    required this.patientName,
    required this.patientAge,
    required this.patientCondition,
  }) : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage>
    with SingleTickerProviderStateMixin {
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = false;
  String _language = 'English';
  String _fontSize = 'Medium';
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Consistent radius values
  final double _cardRadius = 16.0;
  final double _buttonRadius = 12.0;
  final double _inputRadius = 12.0;
  final double _avatarRadius = 24.0;
  final double _dialogRadius = 24.0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FitnessAppTheme.background,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(_cardRadius),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      FitnessAppTheme.nearlyDarkBlue,
                      FitnessAppTheme.nearlyDarkBlue.withOpacity(0.7),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(_cardRadius),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 30),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Hero(
                        tag: 'profile-avatar',
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(_avatarRadius),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 10,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(_avatarRadius),
                            child: Container(
                              width: 84,
                              height: 84,
                              color: Colors.white.withOpacity(0.2),
                              child: Icon(
                                Icons.person,
                                size: 42,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      Text(
                        widget.patientName,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${widget.patientAge} years | ${widget.patientCondition}',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              const SizedBox(height: 8),
              _buildSectionHeader('APPEARANCE'),
              _buildSettingItem(
                icon: Icons.dark_mode_outlined,
                title: 'Dark Mode',
                subtitle: 'Switch between light and dark theme',
                trailing: Transform.scale(
                  scale: 0.8,
                  child: Switch(
                    value: _darkModeEnabled,
                    onChanged: (value) {
                      setState(() => _darkModeEnabled = value);
                    },
                    activeColor: FitnessAppTheme.nearlyDarkBlue,
                    activeTrackColor: FitnessAppTheme.nearlyDarkBlue
                        .withOpacity(0.4),
                  ),
                ),
              ),
              _buildSettingItem(
                icon: Icons.text_fields_rounded,
                title: 'Font Size',
                subtitle: 'Adjust the text size',
                trailing: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(_inputRadius),
                    border: Border.all(
                      color: Colors.grey.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _fontSize,
                      borderRadius: BorderRadius.circular(_inputRadius),
                      icon: const Icon(Icons.arrow_drop_down),
                      elevation: 0,
                      style: TextStyle(
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                        fontSize: 14,
                      ),
                      items:
                          ['Small', 'Medium', 'Large'].map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                ),
                                child: Text(value),
                              ),
                            );
                          }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _fontSize = value);
                        }
                      },
                    ),
                  ),
                ),
              ),
              _buildSectionHeader('PREFERENCES'),
              _buildSettingItem(
                icon: Icons.notifications_active_outlined,
                title: 'Notifications',
                subtitle: 'Enable or disable app notifications',
                trailing: Transform.scale(
                  scale: 0.8,
                  child: Switch(
                    value: _notificationsEnabled,
                    onChanged: (value) {
                      setState(() => _notificationsEnabled = value);
                    },
                    activeColor: FitnessAppTheme.nearlyDarkBlue,
                    activeTrackColor: FitnessAppTheme.nearlyDarkBlue
                        .withOpacity(0.4),
                  ),
                ),
              ),
              _buildSettingItem(
                icon: Icons.translate_rounded,
                title: 'Language',
                subtitle: 'Change app language',
                trailing: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(_inputRadius),
                    border: Border.all(
                      color: Colors.grey.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _language,
                      borderRadius: BorderRadius.circular(_inputRadius),
                      icon: const Icon(Icons.arrow_drop_down),
                      elevation: 0,
                      style: TextStyle(
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                        fontSize: 14,
                      ),
                      items:
                          ['English', 'French', 'Spanish', 'Arabic'].map((
                            String value,
                          ) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                ),
                                child: Text(value),
                              ),
                            );
                          }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _language = value);
                        }
                      },
                    ),
                  ),
                ),
              ),
              _buildSectionHeader('ACCOUNT'),
              _buildSettingItem(
                icon: Icons.person_outline_rounded,
                title: 'Edit Profile',
                subtitle: 'Update your personal information',
                onTap: () => _showEditProfileDialog(),
              ),
              _buildSettingItem(
                icon: Icons.security_rounded,
                title: 'Privacy & Security',
                subtitle: 'Manage your data and security settings',
              ),
              _buildSettingItem(
                icon: Icons.help_center_rounded,
                title: 'Help & Support',
                subtitle: 'Get help or contact support',
              ),
              _buildSectionHeader('ABOUT'),
              _buildSettingItem(
                icon: Icons.info_outline_rounded,
                title: 'About App',
                subtitle: 'Version 1.0.0',
              ),
              _buildSettingItem(
                icon: Icons.star_border_rounded,
                title: 'Rate Us',
                subtitle: 'Share your feedback',
              ),
              _buildSettingItem(
                icon: Icons.logout_rounded,
                title: 'Logout',
                textColor: Colors.redAccent,
                iconColor: Colors.redAccent,
                subtitle: 'Sign out of your account',
                onTap: () => _showLogoutConfirmation(),
              ),
              const SizedBox(height: 40),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade600,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
    Color? textColor,
    Color? iconColor,
  }) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        child: Material(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(_cardRadius),
          elevation: 0,
          child: InkWell(
            borderRadius: BorderRadius.circular(_cardRadius),
            onTap: onTap,
            splashColor: FitnessAppTheme.nearlyDarkBlue.withOpacity(0.1),
            highlightColor: FitnessAppTheme.nearlyDarkBlue.withOpacity(0.05),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(_cardRadius),
                border: Border.all(
                  color: Colors.grey.withOpacity(0.1),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: (iconColor ?? FitnessAppTheme.nearlyDarkBlue)
                          .withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      icon,
                      color: iconColor ?? FitnessAppTheme.nearlyDarkBlue,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            color:
                                textColor ??
                                Theme.of(context).textTheme.titleMedium?.color,
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                          ),
                        ),
                        if (subtitle != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Text(
                              subtitle,
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 13,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (trailing != null) trailing,
                  if (trailing == null && onTap != null)
                    Icon(Icons.chevron_right, color: Colors.grey.shade400),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showLogoutConfirmation() {
    showDialog(
      context: context,
      builder:
          (context) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(_dialogRadius),
            ),
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: Colors.redAccent.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(_avatarRadius),
                    ),
                    child: Icon(
                      Icons.exit_to_app_rounded,
                      size: 36,
                      color: Colors.redAccent,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Logout Confirmation',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Are you sure you want to logout from your account?',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 28),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                _buttonRadius,
                              ),
                            ),
                            side: BorderSide(color: Colors.grey.shade300),
                          ),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                _buttonRadius,
                              ),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            'Logout',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
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
  }

  void _showEditProfileDialog() {
    final TextEditingController nameController = TextEditingController(
      text: widget.patientName,
    );
    final TextEditingController ageController = TextEditingController(
      text: widget.patientAge,
    );
    final TextEditingController conditionController = TextEditingController(
      text: widget.patientCondition,
    );

    showDialog(
      context: context,
      builder:
          (context) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(_dialogRadius),
            ),
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Edit Profile',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: FitnessAppTheme.nearlyDarkBlue,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Stack(
                      children: [
                        Hero(
                          tag: 'profile-avatar',
                          child: Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(
                                _avatarRadius,
                              ),
                              border: Border.all(
                                color: FitnessAppTheme.nearlyDarkBlue
                                    .withOpacity(0.3),
                                width: 2,
                              ),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(
                                _avatarRadius,
                              ),
                              child: Container(
                                color: Colors.white.withOpacity(0.2),
                                child: Icon(
                                  Icons.person,
                                  size: 50,
                                  color: FitnessAppTheme.nearlyDarkBlue
                                      .withOpacity(0.5),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: () {},
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: FitnessAppTheme.nearlyDarkBlue,
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
                              ),
                              child: const Icon(
                                Icons.edit_rounded,
                                size: 18,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: 'Name',
                        prefixIcon: const Icon(Icons.person_outline_rounded),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(_inputRadius),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(_inputRadius),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: ageController,
                      decoration: InputDecoration(
                        labelText: 'Age',
                        prefixIcon: const Icon(Icons.calendar_today_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(_inputRadius),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(_inputRadius),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: conditionController,
                      decoration: InputDecoration(
                        labelText: 'Condition',
                        prefixIcon: const Icon(Icons.medical_services_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(_inputRadius),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(_inputRadius),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  _buttonRadius,
                                ),
                              ),
                              side: BorderSide(color: Colors.grey.shade300),
                            ),
                            child: const Text(
                              'Cancel',
                              style: TextStyle(fontWeight: FontWeight.w500),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: FitnessAppTheme.nearlyDarkBlue,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  _buttonRadius,
                                ),
                              ),
                              elevation: 0,
                            ),
                            child: const Text(
                              'Save Changes',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
    );
  }
}
