import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  Future<void> _signInWithGoogle(BuildContext context) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    try {
      // Show loading SnackBar
      scaffoldMessenger.showSnackBar(
        const SnackBar(
          content: Text("Signing in with Google..."),
          duration: Duration(minutes: 1), // Will be closed manually
        ),
      );

      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        scaffoldMessenger.hideCurrentSnackBar();
        scaffoldMessenger.showSnackBar(
          const SnackBar(content: Text("Google sign in canceled.")),
        );
        return;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithCredential(credential);

      final user = userCredential.user;
      if (user != null) {
        final usersRef = FirebaseFirestore.instance.collection('Users');
        final doc = await usersRef.doc(user.uid).get();
        if (!doc.exists) {
          await usersRef.doc(user.uid).set({
            'email': user.email,
            'fullName': user.displayName ?? '',
            'createdAt': FieldValue.serverTimestamp(),
          });
        }
        scaffoldMessenger.hideCurrentSnackBar();
        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      scaffoldMessenger.hideCurrentSnackBar();
      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text("Google sign in failed: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const darkBlue = Color(0xFF0D47A1);

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/background.png', fit: BoxFit.cover),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/logo.png', width: 120, height: 120),
                const SizedBox(height: 10),
                Text(
                  "AlzMate",
                  style: GoogleFonts.outfit(
                    color: darkBlue,
                    fontSize: 22,
                    letterSpacing: 2,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 60),
                Text(
                  "Welcome Back",
                  style: GoogleFonts.outfit(
                    color: darkBlue,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 30),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 50),
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/login');
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      side: const BorderSide(color: darkBlue),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        "SIGN IN",
                        style: GoogleFonts.outfit(
                          color: darkBlue,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 50),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/signup');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: darkBlue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        "SIGN UP",
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 50),
                Text(
                  "Login with Social Media",
                  style: GoogleFonts.outfit(
                    color: darkBlue,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () => _signInWithGoogle(context),
                      child: const Icon(Icons.email, color: darkBlue, size: 30),
                    ),
                    const SizedBox(width: 30),
                    GestureDetector(
                      onTap: () {
                        // Future implementation: Apple sign-in
                      },
                      child: const Icon(Icons.apple, color: darkBlue, size: 34),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
