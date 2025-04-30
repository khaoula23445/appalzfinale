import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:alzheimer_app/alzhimer_home/alzhimer_app_theme.dart';

class MedicationPage extends StatefulWidget {
  const MedicationPage({Key? key}) : super(key: key);

  @override
  _MedicationPageState createState() => _MedicationPageState();
}

class _MedicationPageState extends State<MedicationPage> {
  // Color scheme
  static const Color _primaryColor = Color(0xFF1E3A8A);
  static const Color _accentColor = Color(0xFFFF5252);
  static const Color _successColor = Color(0xFF4CAF50);
  static const Color _warningColor = Color(0xFFFFC107);

  // Medication list
  final List<Map<String, dynamic>> _medications = [
    {
      'name': 'Aspirin',
      'dose': '100mg',
      'time': TimeOfDay(hour: TimeOfDay.now().hour, minute: 0),
      'taken': false,
      'imagePath': 'assets/pill.png',
    },
    {
      'name': 'Vitamin D',
      'dose': '2000 IU',
      'time': TimeOfDay(hour: TimeOfDay.now().hour + 1, minute: 0),
      'taken': false,
      'imagePath': 'assets/pill.png',
    },
  ];

  List<Map<String, dynamic>> get medications => _medications;

  // Form controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _doseController = TextEditingController();
  TimeOfDay _selectedTime = TimeOfDay.now();
  String? _newImagePath;

  @override
  void initState() {
    super.initState();
    _checkMedicationTimes();
  }

  void _checkMedicationTimes() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    // Create a sorted copy of medications to avoid modifying the original list directly
    final sortedMedications = List<Map<String, dynamic>>.from(_medications)
      ..sort((a, b) {
        final now = TimeOfDay.now();
        final aDue = _isDueNow(a['time']) && !a['taken'];
        final bDue = _isDueNow(b['time']) && !b['taken'];
        final aPassed = _hasTimePassed(a['time']) && !a['taken'];
        final bPassed = _hasTimePassed(b['time']) && !b['taken'];

        if (aDue || bDue) return aDue ? -1 : 1;
        if (aPassed || bPassed) return aPassed ? -1 : 1;
        if (a['taken'] != b['taken']) return a['taken'] ? 1 : -1;
        return a['time'].hour.compareTo(b['time'].hour);
      });

    return Container(
      color: FitnessAppTheme.background,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text(
            "My Medications",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          backgroundColor: Colors.white,
          foregroundColor: _primaryColor,
          elevation: 0,
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _showAddMedicationDialog,
                  child: const Text(
                    "Add New Medication",
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ),
            Expanded(
              child:
                  _medications.isEmpty
                      ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.medication_outlined,
                              size: 60,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              "No medications added yet",
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Tap the button above to add your first medication",
                              style: TextStyle(color: Colors.grey[500]),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      )
                      : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: sortedMedications.length,
                        itemBuilder: (context, index) {
                          final med = sortedMedications[index];
                          final isDue = _isDueNow(med['time']);
                          final isLate =
                              _hasTimePassed(med['time']) && !med['taken'];

                          return Dismissible(
                            key: Key(
                              '${med['name']}_${med['time'].hour}_${med['time'].minute}',
                            ),
                            background: Container(
                              color: _accentColor,
                              alignment: Alignment.centerLeft,
                              padding: const EdgeInsets.only(left: 20),
                              child: const Icon(
                                Icons.delete,
                                color: Colors.white,
                              ),
                            ),
                            secondaryBackground: Container(
                              color: _accentColor,
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 20),
                              child: const Icon(
                                Icons.delete,
                                color: Colors.white,
                              ),
                            ),
                            confirmDismiss: (direction) async {
                              return await showDialog(
                                context: context,
                                builder:
                                    (context) => AlertDialog(
                                      title: const Text("Confirm Delete"),
                                      content: Text(
                                        "Are you sure you want to delete ${med['name']}?",
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed:
                                              () =>
                                                  Navigator.pop(context, false),
                                          child: const Text("Cancel"),
                                        ),
                                        TextButton(
                                          onPressed:
                                              () =>
                                                  Navigator.pop(context, true),
                                          child: const Text(
                                            "Delete",
                                            style: TextStyle(
                                              color: _accentColor,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                              );
                            },
                            onDismissed: (direction) {
                              setState(() {
                                _medications.removeWhere(
                                  (m) =>
                                      m['name'] == med['name'] &&
                                      m['time'].hour == med['time'].hour &&
                                      m['time'].minute == med['time'].minute,
                                );
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text("${med['name']} deleted"),
                                  backgroundColor: _accentColor,
                                ),
                              );
                            },
                            child: _buildMedicationCard(
                              med,
                              isDue: isDue,
                              isLate: isLate,
                            ),
                          );
                        },
                      ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMedicationCard(
    Map<String, dynamic> med, {
    bool isDue = false,
    bool isLate = false,
  }) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color:
              isLate
                  ? _accentColor
                  : (isDue ? _warningColor : Colors.transparent),
          width: 2,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                // Medication Image
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: _primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child:
                        med['imagePath'].startsWith('assets/')
                            ? Image.asset(med['imagePath'], fit: BoxFit.cover)
                            : Image.file(
                              File(med['imagePath']),
                              fit: BoxFit.cover,
                            ),
                  ),
                ),
                const SizedBox(width: 16),

                // Medication Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        med['name'],
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isLate ? _accentColor : _primaryColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text("Dose: ${med['dose']}"),
                      Text(
                        "Time: ${_formatTime(med['time'])}",
                        style: TextStyle(
                          color:
                              isDue
                                  ? _warningColor
                                  : (isLate ? _accentColor : Colors.grey),
                          fontWeight:
                              isDue || isLate
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                        ),
                      ),
                      if (isDue) const SizedBox(height: 4),
                      if (isDue)
                        Text(
                          "TIME TO TAKE!",
                          style: TextStyle(
                            color: _warningColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Taken Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: med['taken'] ? _successColor : _primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  setState(() {
                    final index = _medications.indexWhere(
                      (m) =>
                          m['name'] == med['name'] &&
                          m['time'].hour == med['time'].hour &&
                          m['time'].minute == med['time'].minute,
                    );
                    if (index != -1) {
                      _medications[index]['taken'] =
                          !_medications[index]['taken'];
                      if (_medications[index]['taken']) {
                        _medications[index]['takenTime'] = TimeOfDay.now();
                      }
                    }
                  });
                },
                child: Text(
                  med['taken']
                      ? "TAKEN (${_formatTime(med['takenTime'])})"
                      : "MARK AS TAKEN",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddMedicationDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text("Add Medication"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: () async {
                        final pickedFile = await ImagePicker().pickImage(
                          source: ImageSource.gallery,
                          maxWidth: 800,
                          maxHeight: 800,
                          imageQuality: 85,
                        );
                        if (pickedFile != null) {
                          setState(() => _newImagePath = pickedFile.path);
                        }
                      },
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey),
                        ),
                        child:
                            _newImagePath != null
                                ? ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.file(
                                    File(_newImagePath!),
                                    fit: BoxFit.cover,
                                  ),
                                )
                                : const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.add_a_photo, size: 30),
                                    Text("Add Photo"),
                                  ],
                                ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: "Medication Name",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _doseController,
                      decoration: InputDecoration(
                        labelText: "Dose (e.g. 100mg)",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      title: const Text("Time"),
                      trailing: Text(_formatTime(_selectedTime)),
                      onTap: () async {
                        final time = await showTimePicker(
                          context: context,
                          initialTime: _selectedTime,
                        );
                        if (time != null) {
                          setState(() => _selectedTime = time);
                        }
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    _nameController.clear();
                    _doseController.clear();
                    _newImagePath = null;
                    Navigator.pop(context);
                  },
                  child: const Text(
                    "Cancel",
                    style: TextStyle(color: _accentColor),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryColor,
                  ),
                  onPressed: () {
                    if (_nameController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Please enter medication name"),
                          backgroundColor: _accentColor,
                        ),
                      );
                      return;
                    }

                    if (_doseController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Please enter medication dose"),
                          backgroundColor: _accentColor,
                        ),
                      );
                      return;
                    }

                    setState(() {
                      _medications.add({
                        'name': _nameController.text,
                        'dose': _doseController.text,
                        'time': _selectedTime,
                        'taken': false,
                        'imagePath': _newImagePath ?? 'assets/pill.png',
                      });
                      _nameController.clear();
                      _doseController.clear();
                      _newImagePath = null;
                    });
                    Navigator.pop(context);
                  },
                  child: const Text(
                    "Add",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  String _formatTime(TimeOfDay time) {
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    return DateFormat.jm().format(dt);
  }

  bool _isDueNow(TimeOfDay time) {
    final now = TimeOfDay.now();
    return now.hour == time.hour &&
        now.minute >= time.minute &&
        now.minute <= time.minute + 30;
  }

  bool _hasTimePassed(TimeOfDay time) {
    final now = TimeOfDay.now();
    return now.hour > time.hour ||
        (now.hour == time.hour && now.minute > time.minute);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _doseController.dispose();
    super.dispose();
  }
}
