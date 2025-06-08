import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:alzheimer_app/alzhimer_home/alzhimer_app_theme.dart';
import 'package:intl/intl.dart';

class PatientContactsPage extends StatefulWidget {
  final String patientId;
  final String patientName;

  const PatientContactsPage({
    Key? key,
    required this.patientId,
    required this.patientName,
  }) : super(key: key);

  @override
  _PatientContactsPageState createState() => _PatientContactsPageState();
}

class _PatientContactsPageState extends State<PatientContactsPage>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _labelController = TextEditingController();
  String _priority = 'Normal';
  final List<String> _priorityOptions = ['Normal', 'High', 'Emergency'];
  String _currentFilter = 'All';

  late AnimationController _animationController;
  late Animation<double> _animation;
  Animation<double>? topBarAnimation;
  double topBarOpacity = 0.0;
  late ScrollController scrollController;

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
    _nameController.dispose();
    _phoneController.dispose();
    _labelController.dispose();
    super.dispose();
  }

  Future<void> _addContact() async {
    if (_formKey.currentState!.validate()) {
      try {
        await FirebaseFirestore.instance
            .collection('patients')
            .doc(widget.patientId)
            .collection('contacts')
            .add({
              'name': _nameController.text,
              'phone': _phoneController.text,
              'label': _labelController.text,
              'priority': _priority,
              'createdAt': FieldValue.serverTimestamp(),
            });

        _nameController.clear();
        _phoneController.clear();
        _labelController.clear();
        setState(() => _priority = 'Normal');

        if (mounted) {
          Navigator.pop(context); // Close the form dialog
          _showSuccessDialog('Contact added successfully');
        }
      } catch (e) {
        if (mounted) {
          _showErrorDialog('Error adding contact: $e');
        }
      }
    }
  }

  Future<void> _updateContact(String contactId) async {
    if (_formKey.currentState!.validate()) {
      try {
        await FirebaseFirestore.instance
            .collection('patients')
            .doc(widget.patientId)
            .collection('contacts')
            .doc(contactId)
            .update({
              'name': _nameController.text,
              'phone': _phoneController.text,
              'label': _labelController.text,
              'priority': _priority,
            });

        _nameController.clear();
        _phoneController.clear();
        _labelController.clear();
        setState(() => _priority = 'Normal');

        if (mounted) {
          Navigator.pop(context); // Close the form dialog
          _showSuccessDialog('Contact updated successfully');
        }
      } catch (e) {
        if (mounted) {
          _showErrorDialog('Error updating contact: $e');
        }
      }
    }
  }

  Future<void> _deleteContact(String contactId) async {
    try {
      await FirebaseFirestore.instance
          .collection('patients')
          .doc(widget.patientId)
          .collection('contacts')
          .doc(contactId)
          .delete();

      if (mounted) {
        _showSuccessDialog('Contact deleted successfully');
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog('Error deleting contact: $e');
      }
    }
  }

  void _showDeleteConfirmation(String contactId) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Confirm Delete'),
            content: Text('Are you sure you want to delete this contact?'),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _deleteContact(contactId);
                },
                child: Text('Delete', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
    );
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check_circle, color: Colors.green, size: 48),
                  SizedBox(height: 16),
                  Text(
                    'Success',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  SizedBox(height: 8),
                  Text(message),
                  SizedBox(height: 16),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('OK'),
                  ),
                ],
              ),
            ),
          ),
    );

    // Auto-close after 2 seconds
    Future.delayed(Duration(seconds: 2), () {
      if (mounted && Navigator.of(context).canPop()) {
        Navigator.pop(context);
      }
    });
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Error'),
            content: Text(message),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('OK'),
              ),
            ],
          ),
    );
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'Emergency':
        return Colors.red;
      case 'High':
        return Colors.orange;
      default:
        return Colors.green;
    }
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
                                  '${widget.patientName} Contacts',
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
                          ],
                        ),
                      ),
                      _buildFilterChips(),
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

  Widget _buildFilterChips() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Wrap(
        spacing: 8.0,
        children:
            ['All', 'Normal', 'High', 'Emergency'].map((String priority) {
              return FilterChip(
                label: Text(priority),
                selected: _currentFilter == priority,
                onSelected: (bool selected) {
                  setState(() {
                    _currentFilter = selected ? priority : 'All';
                  });
                },
                selectedColor: _getPriorityColor(priority).withOpacity(0.2),
                backgroundColor: Colors.grey[200],
                labelStyle: TextStyle(
                  color:
                      _currentFilter == priority
                          ? _getPriorityColor(priority)
                          : Colors.black,
                ),
                checkmarkColor: _getPriorityColor(priority),
              );
            }).toList(),
      ),
    );
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
                SizedBox(height: MediaQuery.of(context).padding.top + 140),
                _buildContactsList(),
                SizedBox(height: 80),
              ],
            ),
          ),
          getAppBarUI(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showContactDialog(context),
        child: Icon(Icons.add, color: Colors.white),
        backgroundColor: FitnessAppTheme.nearlyDarkBlue,
        elevation: 4.0,
      ),
    );
  }

  Widget _buildContactsList() {
    Query contactsQuery = FirebaseFirestore.instance
        .collection('patients')
        .doc(widget.patientId)
        .collection('contacts');

    if (_currentFilter != 'All') {
      contactsQuery = contactsQuery.where(
        'priority',
        isEqualTo: _currentFilter,
      );
    }

    return StreamBuilder<QuerySnapshot>(
      stream: contactsQuery.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'No contacts found. Tap + to add a new contact.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ),
          );
        }

        var docs = snapshot.data!.docs;
        docs.sort((a, b) {
          var aTime = a['createdAt'] as Timestamp?;
          var bTime = b['createdAt'] as Timestamp?;
          if (aTime == null || bTime == null) return 0;
          return bTime.compareTo(aTime);
        });

        return ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final doc = docs[index];
            final contact = doc.data() as Map<String, dynamic>;
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: ListTile(
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                leading: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: _getPriorityColor(
                      contact['priority'] ?? 'Normal',
                    ).withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(
                      Icons.person,
                      color: _getPriorityColor(contact['priority'] ?? 'Normal'),
                    ),
                  ),
                ),
                title: Text(
                  contact['name'] ?? '',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.phone, size: 16, color: Colors.grey),
                        SizedBox(width: 4),
                        Text(
                          contact['phone'] ?? '',
                          style: TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                    if (contact['label']?.isNotEmpty ?? false) ...[
                      SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.label, size: 16, color: Colors.grey),
                          SizedBox(width: 4),
                          Text(
                            contact['label'] ?? '',
                            style: TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ],
                    SizedBox(height: 4),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getPriorityColor(
                          contact['priority'] ?? 'Normal',
                        ).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        contact['priority'] ?? 'Normal',
                        style: TextStyle(
                          color: _getPriorityColor(
                            contact['priority'] ?? 'Normal',
                          ),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                trailing: PopupMenuButton<String>(
                  icon: Icon(Icons.more_vert),
                  itemBuilder:
                      (BuildContext context) => [
                        PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit, color: Colors.blue),
                              SizedBox(width: 8),
                              Text('Edit'),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete, color: Colors.red),
                              SizedBox(width: 8),
                              Text('Delete'),
                            ],
                          ),
                        ),
                      ],
                  onSelected: (String value) {
                    if (value == 'edit') {
                      _showContactDialog(context, doc.id, contact);
                    } else if (value == 'delete') {
                      _showDeleteConfirmation(doc.id);
                    }
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showContactDialog(
    BuildContext context, [
    String? contactId,
    Map<String, dynamic>? contact,
  ]) {
    final isEditing = contactId != null;

    if (isEditing) {
      _nameController.text = contact?['name'] ?? '';
      _phoneController.text = contact?['phone'] ?? '';
      _labelController.text = contact?['label'] ?? '';
      _priority = contact?['priority'] ?? 'Normal';
    }

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.circular(20.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10.0,
                  offset: Offset(0.0, 10.0),
                ),
              ],
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    isEditing ? 'Edit Contact' : 'Add New Contact',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: FitnessAppTheme.nearlyDarkBlue,
                    ),
                  ),
                  SizedBox(height: 20),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _nameController,
                          decoration: InputDecoration(
                            labelText: 'Name',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            prefixIcon: Icon(Icons.person),
                          ),
                          validator:
                              (value) =>
                                  value?.isEmpty ?? true ? 'Required' : null,
                        ),
                        SizedBox(height: 16),
                        TextFormField(
                          controller: _phoneController,
                          decoration: InputDecoration(
                            labelText: 'Phone',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            prefixIcon: Icon(Icons.phone),
                          ),
                          keyboardType: TextInputType.phone,
                          validator:
                              (value) =>
                                  value?.isEmpty ?? true ? 'Required' : null,
                        ),
                        SizedBox(height: 16),
                        TextFormField(
                          controller: _labelController,
                          decoration: InputDecoration(
                            labelText: 'Label (Optional)',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            prefixIcon: Icon(Icons.label),
                          ),
                        ),
                        SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          value: _priority,
                          items:
                              _priorityOptions.map((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 12,
                                        height: 12,
                                        decoration: BoxDecoration(
                                          color: _getPriorityColor(value),
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      SizedBox(width: 8),
                                      Text(value),
                                    ],
                                  ),
                                );
                              }).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() => _priority = value);
                            }
                          },
                          decoration: InputDecoration(
                            labelText: 'Priority',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                          ),
                        ),
                        SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                                _nameController.clear();
                                _phoneController.clear();
                                _labelController.clear();
                                setState(() => _priority = 'Normal');
                              },
                              child: Text(
                                'CANCEL',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ),
                            SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: () async {
                                if (isEditing) {
                                  await _updateContact(contactId!);
                                } else {
                                  await _addContact();
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: FitnessAppTheme.nearlyDarkBlue,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.0),
                                ),
                              ),
                              child: Text(
                                isEditing ? 'UPDATE' : 'SAVE',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
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
    );
  }
}
