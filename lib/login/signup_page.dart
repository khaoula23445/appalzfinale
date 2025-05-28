import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  String? validatePhone(String? value) {
    if (value == null || value.isEmpty) return 'Please enter phone number';
    if (!RegExp(r'^(05|06|07)\d{8}$').hasMatch(value))
      return 'Enter valid Algerian number';
    return null;
  }

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Please enter email';
    if (!value.endsWith('@gmail.com')) return 'Email must be @gmail.com';
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Enter password';
    if (value.length < 8) return 'At least 8 characters';
    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value))
      return 'Include special character';
    return null;
  }

  String? validateConfirmPassword(String? value) {
    if (value != _passwordController.text) return 'Passwords don’t match';
    return null;
  }

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) return;

    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();
    final password = _passwordController.text;

    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      await FirebaseFirestore.instance.collection('Users').doc(userCredential.user!.uid).set({
        'name': name,
        'email': email,
        'phone': phone,
        'uid': userCredential.user!.uid,
        'createdAt': FieldValue.serverTimestamp(),
      });

      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Sign up failed: $e"), backgroundColor: Colors.red),
      );
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
                    Navigator.pop(context);
                  },
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Create Your\nAccount',
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
                  borderRadius:
                      BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
                ),
                child: Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            labelText: 'Full Name',
                            suffixIcon: Icon(Icons.person),
                          ),
                          validator: (val) =>
                              val == null || val.isEmpty ? 'Enter name' : null,
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: _phoneController,
                          decoration: const InputDecoration(
                            labelText: 'Phone',
                            suffixIcon: Icon(Icons.phone),
                          ),
                          keyboardType: TextInputType.phone,
                          validator: validatePhone,
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: _emailController,
                          decoration: const InputDecoration(
                            labelText: 'Gmail',
                            suffixIcon: Icon(Icons.email),
                          ),
                          keyboardType: TextInputType.emailAddress,
                          validator: validateEmail,
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: true,
                          decoration: const InputDecoration(
                            labelText: 'Password',
                            suffixIcon: Icon(Icons.lock),
                          ),
                          validator: validatePassword,
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: _confirmPasswordController,
                          obscureText: true,
                          decoration: const InputDecoration(
                            labelText: 'Confirm Password',
                            suffixIcon: Icon(Icons.lock),
                          ),
                          validator: validateConfirmPassword,
                        ),
                        const SizedBox(height: 40),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _signUp,
                            child: const Text("SIGN UP"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF1E3A8A),
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
