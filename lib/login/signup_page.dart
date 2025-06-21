import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:google_fonts/google_fonts.dart';

class ManualBraceletSignupPage extends StatefulWidget {
  @override
  _ManualBraceletSignupPageState createState() =>
      _ManualBraceletSignupPageState();
}

class _ManualBraceletSignupPageState extends State<ManualBraceletSignupPage> {
  final _formKey = GlobalKey<FormState>();

  // Step control
  int currentStep = 1;

  // Controllers
  final braceletIdController = TextEditingController();
  final fullNameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneNumberController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final patientNameController = TextEditingController();
  final ageController = TextEditingController();
  final medicalNotesController = TextEditingController();

  // Internal state
  String? error;
  String? braceletId;
  DocumentSnapshot? existingPatient;
  bool assistantEmailExists = false;
  String? existingAssistantId;

  // Validators
  String? validatePhone(String? value) {
    if (value == null || value.isEmpty) return 'Enter phone number';
    if (!RegExp(r'^(05|06|07)\d{8}$').hasMatch(value))
      return 'Invalid Algerian number';
    return null;
  }

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Enter email';
    if (!value.endsWith('@gmail.com')) return 'Must be @gmail.com';
    return null;
  }

  String? validatePassword(String? value) {
    if (!assistantEmailExists) {
      if (value == null || value.isEmpty) return 'Enter password';
      if (value.length < 8) return 'Minimum 8 characters';
      if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value))
        return 'Include special character';
    }
    return null;
  }

  String? validateConfirmPassword(String? value) {
    if (!assistantEmailExists) {
      if (value != passwordController.text) return 'Passwords do not match';
    }
    return null;
  }

  Future<void> checkBraceletId() async {
    final id = braceletIdController.text.trim();
    if (id.isEmpty) {
      setState(() {
        error = "Please enter bracelet ID.";
      });
      return;
    }

    final doc =
        await FirebaseFirestore.instance.collection('Bracelets').doc(id).get();
    if (!doc.exists) {
      setState(() {
        error = "Bracelet does not exist.";
      });
      return;
    }

    final patientQuery =
        await FirebaseFirestore.instance
            .collection('patients')
            .where('braceletId', isEqualTo: id)
            .limit(1)
            .get();

    if (patientQuery.docs.isNotEmpty) {
      final patient = patientQuery.docs.first;
      final assistants = List<String>.from(patient['assistantId'] ?? []);

      if (assistants.length >= 3) {
        setState(() {
          error = "Patient already has 3 assistants.";
        });
        return;
      } else {
        patientNameController.text = patient['fullName'] ?? '';
        ageController.text = patient['age']?.toString() ?? '';
        medicalNotesController.text = patient['medicalNotes'] ?? '';

        setState(() {
          braceletId = id;
          existingPatient = patient;
          error = null;
          currentStep = 2;
          assistantEmailExists = false;
        });
      }
    } else {
      patientNameController.clear();
      ageController.clear();
      medicalNotesController.clear();

      setState(() {
        braceletId = id;
        existingPatient = null;
        error = null;
        currentStep = 2;
        assistantEmailExists = false;
      });
    }
  }

  Future<void> checkAssistantEmail() async {
    final email = emailController.text.trim();
    if (email.isEmpty) {
      setState(() {
        error = "Enter assistant email.";
      });
      return;
    }
    final query =
        await FirebaseFirestore.instance
            .collection('Users')
            .where('email', isEqualTo: email)
            .limit(1)
            .get();

    if (query.docs.isNotEmpty) {
      setState(() {
        assistantEmailExists = true;
        existingAssistantId = query.docs.first.id;
        error = null;
        currentStep = 3;
      });
    } else {
      setState(() {
        assistantEmailExists = false;
        existingAssistantId = null;
        error = null;
        currentStep = 3;
      });
    }
  }

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) return;

    final fullName = fullNameController.text.trim();
    final email = emailController.text.trim();
    final phone = phoneNumberController.text.trim();
    final bId = braceletId;
    if (bId == null) return;

    final patientName = patientNameController.text.trim();
    final age = int.tryParse(ageController.text.trim());
    final notes = medicalNotesController.text.trim();

    if (patientName.isEmpty || age == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Please enter valid patient name and age.",
            style: GoogleFonts.outfit(),
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      String assistantId;

      if (!assistantEmailExists) {
        final password = passwordController.text.trim();
        final userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(email: email, password: password);
        assistantId = userCredential.user!.uid;

        await FirebaseFirestore.instance
            .collection('Users')
            .doc(assistantId)
            .set({
              'email': email,
              'fullName': fullName,
              'phoneNumber': phone,
              'patients': [],
              'createdAt': FieldValue.serverTimestamp(),
            });
      } else {
        assistantId = existingAssistantId!;
      }

      String patientId;

      if (existingPatient != null) {
        patientId = existingPatient!.id;
        await FirebaseFirestore.instance
            .collection('patients')
            .doc(patientId)
            .update({
              'assistantId': FieldValue.arrayUnion([assistantId]),
            });
      } else {
        final newPatient = await FirebaseFirestore.instance
            .collection('patients')
            .add({
              'fullName': patientName,
              'age': age,
              'medicalNotes': notes,
              'braceletId': bId,
              'assistantId': [assistantId],
              'createdAt': FieldValue.serverTimestamp(),
            });
        patientId = newPatient.id;

        await FirebaseFirestore.instance
            .collection('Bracelets')
            .doc(bId)
            .update({'status': 'registered'});
      }

      final assistantDoc =
          await FirebaseFirestore.instance
              .collection('Users')
              .doc(assistantId)
              .get();
      final List patients = assistantDoc.get('patients') ?? [];
      if (!patients.contains(patientId)) {
        await FirebaseFirestore.instance
            .collection('Users')
            .doc(assistantId)
            .update({
              'patients': FieldValue.arrayUnion([patientId]),
            });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Signup successful!", style: GoogleFonts.outfit()),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pushReplacementNamed(context, '/home');
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Signup failed: ${e.message}",
            style: GoogleFonts.outfit(),
          ),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Signup failed: $e", style: GoogleFonts.outfit()),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    braceletIdController.dispose();
    fullNameController.dispose();
    emailController.dispose();
    phoneNumberController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    patientNameController.dispose();
    ageController.dispose();
    medicalNotesController.dispose();
    super.dispose();
  }

  Widget buildTextField(
    TextEditingController controller,
    String label, {
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    bool readOnly = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        validator: validator,
        readOnly: readOnly,
        style: GoogleFonts.outfit(color: const Color(0xFF0D47A1)),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.outfit(
            color: const Color(0xFF0D47A1),
            fontSize: 16,
          ),
          border: const UnderlineInputBorder(),
          suffixIcon: _getIconForLabel(label),
        ),
      ),
    );
  }

  Icon? _getIconForLabel(String label) {
    if (label.contains('ID'))
      return Icon(Icons.qr_code, color: Color(0xFF0D47A1));
    if (label.contains('Name'))
      return Icon(Icons.person, color: Color(0xFF0D47A1));
    if (label.contains('Email'))
      return Icon(Icons.email, color: Color(0xFF0D47A1));
    if (label.contains('Phone'))
      return Icon(Icons.phone, color: Color(0xFF0D47A1));
    if (label.contains('Password'))
      return Icon(Icons.lock, color: Color(0xFF0D47A1));
    if (label.contains('Age'))
      return Icon(Icons.numbers, color: Color(0xFF0D47A1));
    if (label.contains('Notes'))
      return Icon(Icons.medical_services, color: Color(0xFF0D47A1));
    return null;
  }

  Widget buildStep1() {
    final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
    const darkBlue = Color(0xFF0D47A1);

    return Stack(
      children: [
        Image.asset(
          'assets/background.png',
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: SafeArea(
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: darkBlue),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Text(
                'Bracelet Signup\nStep 1: Scan Bracelet QR Code',
                style: GoogleFonts.outfit(
                  color: darkBlue,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
                child: QRView(
                  key: qrKey,
                  onQRViewCreated: (QRViewController controller) {
                    controller.scannedDataStream.listen((scanData) {
                      controller.pauseCamera();
                      final scannedId = scanData.code;
                      if (scannedId != null && scannedId.isNotEmpty) {
                        setState(() {
                          braceletIdController.text = scannedId;
                          error = null;
                        });
                        checkBraceletId();
                      } else {
                        setState(() {
                          error = "Invalid QR code";
                        });
                        controller.resumeCamera();
                      }
                    });
                  },
                  overlay: QrScannerOverlayShape(
                    borderColor: darkBlue,
                    borderRadius: 10,
                    borderLength: 30,
                    borderWidth: 10,
                    cutOutSize: 250,
                  ),
                ),
              ),
            ),

            if (error != null)
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 20,
                ),
                child: Text(
                  error!,
                  style: GoogleFonts.outfit(color: Colors.red, fontSize: 16),
                ),
              ),
            const SizedBox(height: 20),
          ],
        ),
      ],
    );
  }

  Widget buildStep2() {
    const darkBlue = Color(0xFF0D47A1);

    return Stack(
      children: [
        Image.asset(
          'assets/background.png',
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: SafeArea(
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: darkBlue),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Text(
                'Bracelet Signup\nStep 2: Assistant Information',
                style: GoogleFonts.outfit(
                  color: darkBlue,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Container(
                padding: const EdgeInsets.fromLTRB(20, 40, 20, 20),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40),
                  ),
                ),
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        buildTextField(
                          fullNameController,
                          'Full Name',
                          validator:
                              (val) =>
                                  val == null || val.isEmpty
                                      ? "Enter full name"
                                      : null,
                        ),
                        const SizedBox(height: 20),
                        buildTextField(
                          emailController,
                          'Email',
                          keyboardType: TextInputType.emailAddress,
                          validator: validateEmail,
                        ),
                        const SizedBox(height: 20),
                        buildTextField(
                          phoneNumberController,
                          'Phone Number',
                          keyboardType: TextInputType.phone,
                          validator: validatePhone,
                        ),
                        const SizedBox(height: 30),
                        if (error != null)
                          Text(
                            error!,
                            style: GoogleFonts.outfit(
                              color: Colors.red,
                              fontSize: 16,
                            ),
                          ),
                        const SizedBox(height: 30),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                checkAssistantEmail();
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: darkBlue,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: Text(
                              "CONTINUE",
                              style: GoogleFonts.outfit(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget buildStep3() {
    const darkBlue = Color(0xFF0D47A1);

    return Stack(
      children: [
        // Background image
        Image.asset(
          'assets/background.png',
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: SafeArea(
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: darkBlue),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Text(
                'Bracelet Signup\nStep 3: Patient Information',
                style: GoogleFonts.outfit(
                  color: darkBlue,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Container(
                padding: const EdgeInsets.fromLTRB(20, 40, 20, 20),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40),
                  ),
                ),
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        buildTextField(
                          patientNameController,
                          'Patient Full Name',
                          validator:
                              (val) =>
                                  val == null || val.isEmpty
                                      ? "Enter patient name"
                                      : null,
                          readOnly: existingPatient != null,
                        ),
                        const SizedBox(height: 20),
                        buildTextField(
                          ageController,
                          'Age',
                          keyboardType: TextInputType.number,
                          validator: (val) {
                            if (val == null || val.isEmpty) return "Enter age";
                            if (int.tryParse(val) == null) return "Invalid age";
                            return null;
                          },
                          readOnly: existingPatient != null,
                        ),
                        const SizedBox(height: 20),
                        buildTextField(
                          medicalNotesController,
                          'Medical Notes',
                          readOnly: existingPatient != null,
                        ),
                        const SizedBox(height: 20),
                        if (!assistantEmailExists) ...[
                          buildTextField(
                            passwordController,
                            'Password',
                            obscureText: true,
                            validator: validatePassword,
                          ),
                          const SizedBox(height: 20),
                          buildTextField(
                            confirmPasswordController,
                            'Confirm Password',
                            obscureText: true,
                            validator: validateConfirmPassword,
                          ),
                          const SizedBox(height: 20),
                        ],
                        if (error != null)
                          Text(
                            error!,
                            style: GoogleFonts.outfit(
                              color: Colors.red,
                              fontSize: 16,
                            ),
                          ),
                        const SizedBox(height: 30),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(
                              width: 150,
                              height: 50,
                              child: ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    currentStep = 2;
                                    error = null;
                                  });
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.grey,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                ),
                                child: Text(
                                  "BACK",
                                  style: GoogleFonts.outfit(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 150,
                              height: 50,
                              child: ElevatedButton(
                                onPressed: _signUp,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: darkBlue,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                ),
                                child: Text(
                                  "SUBMIT",
                                  style: GoogleFonts.outfit(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget stepContent;

    if (currentStep == 1) {
      stepContent = buildStep1();
    } else if (currentStep == 2) {
      stepContent = buildStep2();
    } else {
      stepContent = buildStep3();
    }

    return Scaffold(body: stepContent);
  }
}
