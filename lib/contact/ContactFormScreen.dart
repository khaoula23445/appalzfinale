import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:alzheimer_app/alzhimer_home/alzhimer_app_theme.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactPage extends StatefulWidget {
  const ContactPage({Key? key}) : super(key: key);

  @override
  State<ContactPage> createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _labelController = TextEditingController();
  String? _priority;
  bool _isSaving = false;
  String? _patientId;
  String? _patientName;
  String? _filterPriority;
  bool _isLoadingPatient = true;
  late TabController _tabController;

  // Color palette
  static const Color _primaryColor = Color(0xFF1E3A8A);
  static const Color _secondaryColor = Color(0xFFE6F0FA);
  static const Color _accentColor = Color(0xFFFF5252);
  static const Color _textPrimary = Color(0xFF333333);
  static const Color _textSecondary = Color(0xFF666666);
  static const Color _borderColor = Color(0xFFDDDDDD);
  static const Color _filterActiveColor = Color(0xFF1E3A8A);

  // Constants
  static const double _cardElevation = 2.0;
  static const double _borderRadius = 12.0;
  static const EdgeInsets _defaultPadding = EdgeInsets.all(16.0);
  static const EdgeInsets _inputPadding = EdgeInsets.symmetric(
    horizontal: 12,
    vertical: 16,
  );

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _getCurrentPatient();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _labelController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentPatient() async {
    setState(() => _isLoadingPatient = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        setState(() => _isLoadingPatient = false);
        return;
      }

      final patientQuery =
          await FirebaseFirestore.instance
              .collection('patients')
              .where('assistantId', isEqualTo: user.uid)
              .limit(1)
              .get();

      if (patientQuery.docs.isNotEmpty) {
        setState(() {
          _patientId = patientQuery.docs.first.id;
          _patientName = patientQuery.docs.first['fullName'];
          _isLoadingPatient = false;
        });
      } else {
        setState(() => _isLoadingPatient = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("No patient assigned to your account"),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      setState(() => _isLoadingPatient = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error loading patient: ${e.toString()}"),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  String? validatePhone(String? value) {
    if (value == null || value.isEmpty) return 'Enter phone number';
    if (!RegExp(r'^(05|06|07)\d{8}$').hasMatch(value)) {
      return 'Enter valid Algerian number';
    }
    return null;
  }

  Future<void> _saveContact() async {
    if (!_formKey.currentState!.validate() || _isSaving || _patientId == null) {
      return;
    }

    setState(() => _isSaving = true);

    try {
      final contact = {
        'name': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'label': _labelController.text.trim(),
        'priority': _priority ?? 'Low',
        'createdAt': FieldValue.serverTimestamp(),
        'patientId': _patientId,
        'patientName': _patientName,
      };

      await FirebaseFirestore.instance
          .collection('TrustedContacts')
          .add(contact);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Contact added successfully"),
          behavior: SnackBarBehavior.floating,
        ),
      );

      // Clear form fields
      _nameController.clear();
      _phoneController.clear();
      _labelController.clear();
      setState(() {
        _priority = null;
        _isSaving = false;
        _tabController.animateTo(1); // Switch to list tab after saving
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to add contact: ${e.toString()}"),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      setState(() => _isSaving = false);
    }
  }

  Widget _getPriorityIcon(String? priority, {double size = 24}) {
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

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      throw 'Could not launch $launchUri';
    }
  }

  Future<void> _deleteContact(String contactId) async {
    try {
      await FirebaseFirestore.instance
          .collection('TrustedContacts')
          .doc(contactId)
          .delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Contact deleted successfully"),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to delete contact: ${e.toString()}"),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Widget _buildContactForm() {
    return SingleChildScrollView(
      padding: _defaultPadding,
      child: Card(
        color: Colors.white, // White card background
        elevation: 4, // Card shadow
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_borderRadius),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                if (_patientName != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Text(
                      "Patient: $_patientName",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: _primaryColor,
                      ),
                    ),
                  ),
                const Text(
                  "Add New Contact",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: _primaryColor,
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: const Color.fromARGB(
                      255,
                      238,
                      238,
                      238,
                    ), // White input background

                    labelText: "Full Name",
                    labelStyle: TextStyle(color: _textSecondary),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(_borderRadius),
                      borderSide: BorderSide(color: _borderColor),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(_borderRadius),
                      borderSide: BorderSide(color: _borderColor),
                    ),
                    contentPadding: _inputPadding,
                    prefixIcon: Icon(Icons.person, color: _textSecondary),
                  ),
                  validator:
                      (val) => val == null || val.isEmpty ? 'Enter name' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _phoneController,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: const Color.fromARGB(
                      255,
                      238,
                      238,
                      238,
                    ), // White input background
                    labelText: "Phone Number",
                    labelStyle: TextStyle(color: _textSecondary),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(_borderRadius),
                      borderSide: BorderSide(color: _borderColor),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(_borderRadius),
                      borderSide: BorderSide(color: _borderColor),
                    ),
                    contentPadding: _inputPadding,
                    prefixIcon: Icon(Icons.phone, color: _textSecondary),
                  ),
                  keyboardType: TextInputType.phone,
                  validator: validatePhone,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _labelController,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: const Color.fromARGB(
                      255,
                      238,
                      238,
                      238,
                    ), // White input background

                    labelText: "Label (e.g. Mom, Friend)",
                    labelStyle: TextStyle(color: _textSecondary),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(_borderRadius),
                      borderSide: BorderSide(color: _borderColor),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(_borderRadius),
                      borderSide: BorderSide(color: _borderColor),
                    ),
                    contentPadding: _inputPadding,
                    prefixIcon: Icon(Icons.label, color: _textSecondary),
                  ),
                  validator:
                      (val) =>
                          val == null || val.isEmpty ? 'Enter label' : null,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _priority,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: const Color.fromARGB(
                      255,
                      238,
                      238,
                      238,
                    ), // White input background
                    labelText: "Priority Level",
                    labelStyle: TextStyle(color: _textSecondary),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(_borderRadius),
                      borderSide: BorderSide(color: _borderColor),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(_borderRadius),
                      borderSide: BorderSide(color: _borderColor),
                    ),
                    contentPadding: _inputPadding,
                    prefixIcon: Icon(
                      Icons.priority_high,
                      color: _textSecondary,
                    ),
                  ),
                  items:
                      ['High', 'Medium', 'Low']
                          .map(
                            (level) => DropdownMenuItem(
                              value: level,
                              child: Row(
                                children: [
                                  _getPriorityIcon(level, size: 20),
                                  const SizedBox(width: 8),
                                  Text(level),
                                ],
                              ),
                            ),
                          )
                          .toList(),
                  onChanged: (val) => setState(() => _priority = val),
                  validator: (val) => val == null ? 'Select priority' : null,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _saveContact,
                    child:
                        _isSaving
                            ? SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                            : const Text(
                              "SAVE CONTACT",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(_borderRadius),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContactList() {
    if (_isLoadingPatient) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_patientId == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.warning, size: 48, color: Colors.orange),
            const SizedBox(height: 16),
            const Text("No patient assigned", style: TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _getCurrentPatient,
              child: const Text("Retry"),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream:
                FirebaseFirestore.instance
                    .collection('TrustedContacts')
                    .where('patientId', isEqualTo: _patientId)
                    .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.contacts, size: 48, color: _textSecondary),
                      const SizedBox(height: 16),
                      Text(
                        "No contacts added yet",
                        style: TextStyle(color: _textSecondary),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Add your first contact using the form",
                        style: TextStyle(color: _textSecondary),
                      ),
                      TextButton(
                        onPressed: () => _tabController.animateTo(0),
                        child: const Text("Go to Add Contact"),
                      ),
                    ],
                  ),
                );
              }

              // Filter contacts by priority if filter is set
              var contacts =
                  snapshot.data!.docs.where((doc) {
                    if (_filterPriority == null) return true;
                    final data = doc.data() as Map<String, dynamic>;
                    return data['priority'] == _filterPriority;
                  }).toList();

              // Sort contacts
              contacts.sort((a, b) {
                final aData = a.data() as Map<String, dynamic>;
                final bData = b.data() as Map<String, dynamic>;

                // First sort by priority
                final priorityOrder = {'High': 1, 'Medium': 2, 'Low': 3};
                final aPriority = priorityOrder[aData['priority']] ?? 4;
                final bPriority = priorityOrder[bData['priority']] ?? 4;
                if (aPriority != bPriority) {
                  return aPriority.compareTo(bPriority);
                }

                // Then sort by name
                return (aData['name'] ?? '').compareTo(bData['name'] ?? '');
              });

              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        const Text(
                          "Trusted Contacts",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: _primaryColor,
                          ),
                        ),
                        const Spacer(),
                        PopupMenuButton<String>(
                          icon: const Icon(Icons.filter_list),
                          onSelected: (value) {
                            setState(() {
                              _filterPriority = value == 'All' ? null : value;
                            });
                          },
                          itemBuilder:
                              (context) => [
                                const PopupMenuItem(
                                  value: 'All',
                                  child: Text('All Contacts'),
                                ),
                                const PopupMenuItem(
                                  value: 'High',
                                  child: Text('High Priority'),
                                ),
                                const PopupMenuItem(
                                  value: 'Medium',
                                  child: Text('Medium Priority'),
                                ),
                                const PopupMenuItem(
                                  value: 'Low',
                                  child: Text('Low Priority'),
                                ),
                              ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      itemCount: contacts.length,
                      itemBuilder: (context, index) {
                        final contact = contacts[index];
                        final data = contact.data() as Map<String, dynamic>;

                        return Card(
                          elevation: _cardElevation,
                          margin: const EdgeInsets.symmetric(
                            vertical: 4,
                            horizontal: 8,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(_borderRadius),
                          ),
                          color: Colors.white,
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Row(
                              children: [
                                _getPriorityIcon(data['priority']),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        data['name'],
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        data['phone'],
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: _textSecondary,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${data['label']} • ${data['priority']}',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: _textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.call,
                                    color: Colors.green,
                                  ),
                                  onPressed:
                                      () => _makePhoneCall(data['phone']),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: _accentColor,
                                  ),
                                  onPressed: () => _deleteContact(contact.id),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: FitnessAppTheme.background,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text(
            "Trusted Contacts",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          ),
          centerTitle: true,
          backgroundColor: _primaryColor,
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.search, color: Colors.white),
              onPressed: () {
                if (_patientId != null) {
                  showSearch(
                    context: context,
                    delegate: ContactSearchDelegate(_patientId!),
                  );
                }
              },
            ),
          ],
          bottom: TabBar(
            controller: _tabController,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white.withOpacity(0.7),
            indicatorColor: Colors.white,
            tabs: const [
              Tab(icon: Icon(Icons.person_add, color: Colors.white)),
              Tab(icon: Icon(Icons.contacts, color: Colors.white)),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [_buildContactForm(), _buildContactList()],
        ),
      ),
    );
  }
}

class ContactSearchDelegate extends SearchDelegate {
  final String patientId;

  ContactSearchDelegate(this.patientId);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSearchResults();
  }

  Widget _buildSearchResults() {
    return StreamBuilder<QuerySnapshot>(
      stream:
          FirebaseFirestore.instance
              .collection('TrustedContacts')
              .where('patientId', isEqualTo: patientId)
              .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final results =
            snapshot.data!.docs.where((doc) {
              final data = doc.data() as Map<String, dynamic>;
              return data['name'].toString().toLowerCase().contains(
                    query.toLowerCase(),
                  ) ||
                  data['phone'].toString().contains(query) ||
                  data['label'].toString().toLowerCase().contains(
                    query.toLowerCase(),
                  );
            }).toList();

        return ListView.builder(
          itemCount: results.length,
          itemBuilder: (context, index) {
            final contact = results[index];
            final data = contact.data() as Map<String, dynamic>;

            return Card(
              color: Colors.white,
              margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: ListTile(
                leading: Icon(
                  Icons.person,
                  color: _ContactPageState._primaryColor,
                ),
                title: Text(data['name']),
                subtitle: Text(data['phone']),
                trailing: IconButton(
                  icon: const Icon(Icons.call, color: Colors.green),
                  onPressed: () {
                    final Uri launchUri = Uri(
                      scheme: 'tel',
                      path: data['phone'],
                    );
                    launchUrl(launchUri);
                  },
                ),
                onTap: () {
                  close(context, contact.id);
                },
              ),
            );
          },
        );
      },
    );
  }
}
