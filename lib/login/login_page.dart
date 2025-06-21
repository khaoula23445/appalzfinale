import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'patientSelectionPage.dart';

class LoginPage extends StatelessWidget {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isValidGmail(String email) {
    return email.toLowerCase().endsWith('@gmail.com');
  }

  void _showMessage(
    BuildContext context,
    String message, {
    Color color = Colors.red,
  }) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message), backgroundColor: color));
  }

  void _signIn(BuildContext context) async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty && password.isEmpty) {
      _showMessage(context, "Please enter Gmail and Password");
      return;
    } else if (email.isEmpty) {
      _showMessage(context, "Please enter your Gmail");
      return;
    } else if (password.isEmpty) {
      _showMessage(context, "Please enter your Password");
      return;
    } else if (!_isValidGmail(email)) {
      _showMessage(context, "Please enter a valid @gmail.com address");
      return;
    }

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final userSnapshot =
          await FirebaseFirestore.instance
              .collection('Users')
              .where('email', isEqualTo: email)
              .limit(1)
              .get();

      if (userSnapshot.docs.isNotEmpty) {
        final userData = userSnapshot.docs.first.data();
        final List<dynamic> patientIds = userData['patients'] ?? [];

        if (patientIds.isEmpty) {
          _showMessage(
            context,
            "No patients linked to this account.",
            color: Colors.orange,
          );
          return;
        }

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => PatientSelectionPage(patientIds: patientIds),
          ),
        );
      } else {
        _showMessage(
          context,
          "User does not exist, try again with the right credentials.",
          color: Colors.orange,
        );
      }
    } catch (e) {
      _showMessage(context, "Login failed: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    const darkBlue = Color(0xFF0D47A1);

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/background.png', // Same background as WelcomePage
            fit: BoxFit.cover,
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
                      Navigator.pushReplacementNamed(context, '/');
                    },
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Hello\nSign in!',
                  style: GoogleFonts.outfit(
                    color: darkBlue,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 40),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: 'Gmail',
                          labelStyle: GoogleFonts.outfit(
                            color: darkBlue,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          suffixIcon: const Icon(Icons.email),
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          labelStyle: GoogleFonts.outfit(
                            color: darkBlue,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          suffixIcon: const Icon(Icons.lock),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/forgot-password');
                          },
                          child: Text(
                            "Forgot Password?",
                            style: GoogleFonts.outfit(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => _signIn(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: darkBlue,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: Text(
                            "SIGN IN",
                            style: GoogleFonts.outfit(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const Spacer(),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              "Don't have an account?",
                              style: GoogleFonts.outfit(
                                color: Colors.grey,
                                fontSize: 16,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                            TextButton(
                              onPressed:
                                  () => Navigator.pushNamed(context, '/signup'),
                              child: Text(
                                "Sign Up",
                                style: GoogleFonts.outfit(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                  fontSize: 18,
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
            ],
          ),
        ],
      ),
    );
  }
}
