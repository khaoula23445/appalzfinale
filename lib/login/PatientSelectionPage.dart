import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PatientSelectionPage extends StatelessWidget {
  final List<dynamic> patientIds;

  const PatientSelectionPage({Key? key, required this.patientIds}) : super(key: key);

  Future<List<Map<String, dynamic>>> _fetchPatients() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('patients')
        .where(FieldPath.documentId, whereIn: patientIds)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return data;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final List<Color> _cardColors = [
      Colors.blue.shade100,
      Colors.green.shade100,
      Colors.purple.shade100,
      Colors.orange.shade100,
      Colors.teal.shade100,
      Colors.pink.shade100,
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      appBar: AppBar(
  leading: IconButton(
    icon: const Icon(Icons.arrow_back, color: Colors.white),
    onPressed: () {
      Navigator.pop(context);
    },
  ),
  title: const Text(
    'Select a Patient',
    style: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    ),
  ),
  backgroundColor: const Color(0xFF1E3A8A),
  elevation: 0,
),

      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchPatients(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                "No patients found.",
                style: TextStyle(fontSize: 18, color: Colors.black54),
              ),
            );
          }

          final patients = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: patients.length,
            itemBuilder: (context, index) {
              final patient = patients[index];
              final color = _cardColors[index % _cardColors.length];

              return _AnimatedPatientCard(
                patient: patient,
                color: color,
                onTap: () {
                  Navigator.pushReplacementNamed(
                    context,
                    '/home',
                    arguments: patient,
                  );
                },
              );
            },
          );
        },
      ),

      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        child: ElevatedButton(
          onPressed: () {
            Navigator.pushNamed(context, '/signup');
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1E3A8A),
            padding: const EdgeInsets.symmetric(vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          child: const Text(
            "ADD PATIENT",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

class _AnimatedPatientCard extends StatefulWidget {
  final Map<String, dynamic> patient;
  final Color color;
  final VoidCallback onTap;

  const _AnimatedPatientCard({
    required this.patient,
    required this.color,
    required this.onTap,
  });

  @override
  State<_AnimatedPatientCard> createState() => _AnimatedPatientCardState();
}

class _AnimatedPatientCardState extends State<_AnimatedPatientCard> {
  double _scale = 1.0;

  void _onEnter(PointerEvent details) {
    setState(() {
      _scale = 1.05; // zoom in a bit on hover
    });
  }

  void _onExit(PointerEvent details) {
    setState(() {
      _scale = 1.0; // back to normal when cursor leaves
    });
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: _onEnter,
      onExit: _onExit,
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        child: GestureDetector(
          onTap: widget.onTap,
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: widget.color,
              borderRadius: BorderRadius.circular(18),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              leading: const CircleAvatar(
                backgroundColor: Colors.white,
                radius: 28,
                child: Icon(
                  Icons.person,
                  color: Color(0xFF1E3A8A),
                  size: 28,
                ),
              ),
              title: Text(
                widget.patient['fullName'] ?? 'Unnamed',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E3A8A),
                ),
              ),
              subtitle: Text(
                "Age: ${widget.patient['age'] ?? 'N/A'}",
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
              trailing: const Icon(
                Icons.arrow_forward_ios,
                color: Colors.black45,
                size: 20,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
