import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'patientSelectionPage.dart';

class LoginPage extends StatelessWidget {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isValidGmail(String email) {
    return email.toLowerCase().endsWith('@gmail.com');
  }

  void _showMessage(BuildContext context, String message, {Color color = Colors.red}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color),
    );
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

      final userSnapshot = await FirebaseFirestore.instance
          .collection('Users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (userSnapshot.docs.isNotEmpty) {
        final userData = userSnapshot.docs.first.data();
        final List<dynamic> patientIds = userData['patients'] ?? [];

        if (patientIds.isEmpty) {
          _showMessage(context, "No patients linked to this account.", color: Colors.orange);
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
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE6F0FA), Color(0xFF1E3A8A)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: SafeArea(
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/');
                  },
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Hello\nSign in!',
                style: TextStyle(
                  color: Colors.white,
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
                      decoration: const InputDecoration(
                        labelText: 'Gmail',
                        labelStyle: TextStyle(
                          color: Color(0xFF1E3A8A),
                          fontSize: 16,
                        ),
                        suffixIcon: Icon(Icons.email),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Password',
                        labelStyle: TextStyle(
                          color: Color(0xFF1E3A8A),
                          fontSize: 16,
                        ),
                        suffixIcon: Icon(Icons.lock),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/forgot-password');
                        },
                        child: const Text(
                          "Forgot Password?",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 18,
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
                        child: const Text(
                          "SIGN IN",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF1E3A8A),
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
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
                          const Text(
                            "Don't have an account?",
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 18,
                            ),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pushNamed(context, '/signup'),
                            child: const Text(
                              "Sign Up",
                              style: TextStyle(
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
      ),
    );
  }
}
