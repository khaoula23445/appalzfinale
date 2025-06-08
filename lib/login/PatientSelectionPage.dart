import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // For date formatting

class PatientSelectionPage extends StatefulWidget {
  final List<dynamic> patientIds;

  const PatientSelectionPage({Key? key, required this.patientIds})
    : super(key: key);

  @override
  _PatientSelectionPageState createState() => _PatientSelectionPageState();
}

class _PatientSelectionPageState extends State<PatientSelectionPage>
    with TickerProviderStateMixin {
  late AnimationController animationController;
  Animation<double>? topBarAnimation;
  double topBarOpacity = 0.0;

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    topBarAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: animationController, curve: Curves.fastOutSlowIn),
    );

    animationController.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        topBarOpacity = 1.0;
      });
    });
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  Future<List<Map<String, dynamic>>> _fetchPatients() async {
    final snapshot =
        await FirebaseFirestore.instance
            .collection('patients')
            .where(FieldPath.documentId, whereIn: widget.patientIds)
            .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return data;
    }).toList();
  }

  Widget getAppBarUI() {
    return Column(
      children: <Widget>[
        AnimatedBuilder(
          animation: animationController,
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
                    color: Colors.white.withOpacity(topBarOpacity),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(32.0),
                    ),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.4 * topBarOpacity),
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
                                  'Choose Profile',
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    fontFamily: 'Roboto',
                                    fontWeight: FontWeight.w700,
                                    fontSize: 22 + 6 - 6 * topBarOpacity,
                                    letterSpacing: 1.2,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 38,
                              width: 38,
                              child: InkWell(
                                onTap: () {},
                                borderRadius: BorderRadius.circular(32.0),
                                child: const Center(
                                  child: Icon(
                                    Icons.keyboard_arrow_left,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                              ),
                              child: Row(
                                children: <Widget>[
                                  const Padding(
                                    padding: EdgeInsets.only(right: 8),
                                    child: Icon(
                                      Icons.calendar_today,
                                      color: Colors.grey,
                                      size: 18,
                                    ),
                                  ),
                                  Text(
                                    DateFormat('d MMM').format(DateTime.now()),
                                    style: const TextStyle(
                                      fontSize: 18,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              height: 38,
                              width: 38,
                              child: InkWell(
                                onTap: () {},
                                borderRadius: BorderRadius.circular(32.0),
                                child: const Center(
                                  child: Icon(
                                    Icons.keyboard_arrow_right,
                                    color: Colors.grey,
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
      backgroundColor: const Color(0xFFE6F0FA),
      appBar: AppBar(
        title: const Text(
          'Select a Patient',
          style: TextStyle(
            fontSize: 24,
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
                      "No profiles found.",
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

              return GestureDetector(
                onTap: () {
                  Navigator.pushReplacementNamed(
                    context,
                    '/home',
                    arguments: patient,
                  );
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    leading: CircleAvatar(
                      backgroundColor: const Color(0xFF1E3A8A),
                      radius: 28,
                      child: const Icon(
                        Icons.person,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    title: Text(
                      patient['fullName'] ?? 'Unnamed',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E3A8A),
                      ),
                    ),
                    subtitle: Text(
                      "Age: ${patient['age'] ?? 'N/A'}",
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
              );
            },
          );
        },
      ),
    );
  }
}
