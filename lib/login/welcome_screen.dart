// welcome_screen.dart
import 'package:flutter/material.dart';

class WelcomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
<<<<<<< HEAD
            colors: [Color(0xFFE6F0FA), Color(0xFF1E3A8A)],
=======
            colors: [Colors.redAccent, Colors.deepPurple],
>>>>>>> d8e37fec08c59069d54675d516c51c995811f073
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.watch, size: 60, color: Colors.white),
<<<<<<< HEAD
              SizedBox(height: 0),
=======
              SizedBox(height: 10),
>>>>>>> d8e37fec08c59069d54675d516c51c995811f073
              Text(
                "Safe Bracelet",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  letterSpacing: 2,
                  fontWeight: FontWeight.bold,
                ),
              ),
<<<<<<< HEAD
              SizedBox(height: 80),
=======
              SizedBox(height: 60),
>>>>>>> d8e37fec08c59069d54675d516c51c995811f073
              Text(
                "Welcome Back",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 30),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 50),
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/login');
                  },
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 15),
                    side: BorderSide(color: Colors.white),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      "SIGN IN",
<<<<<<< HEAD
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
=======
                      style: TextStyle(color: Colors.white, fontSize: 16),
>>>>>>> d8e37fec08c59069d54675d516c51c995811f073
                    ),
                  ),
                ),
              ),
              SizedBox(height: 15),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 50),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/signup');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    padding: EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      "SIGN UP",
<<<<<<< HEAD
                      style: TextStyle(fontWeight: FontWeight.bold),
=======
                      style: TextStyle(fontSize: 16),
>>>>>>> d8e37fec08c59069d54675d516c51c995811f073
                    ),
                  ),
                ),
              ),
<<<<<<< HEAD
              SizedBox(height: 150),
=======
              SizedBox(height: 50),
>>>>>>> d8e37fec08c59069d54675d516c51c995811f073
              Text(
                "Login with Social Media",
                style: TextStyle(color: Colors.white70),
              ),
              SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.camera_alt, color: Colors.white),
                  SizedBox(width: 20),
                  Icon(Icons.facebook, color: Colors.white),
                  SizedBox(width: 20),
                  Icon(Icons.email, color: Colors.white),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}