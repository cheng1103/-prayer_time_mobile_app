import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:prayer_time_mobile_app/app/controller/usernamectl.dart';
import 'package:prayer_time_mobile_app/app/controller/emailctl.dart';
import 'package:prayer_time_mobile_app/app/controller/passwordctl.dart';
import 'package:prayer_time_mobile_app/app/controller/confirmpasswordctl.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final _usernameController = UsernameController();
  final _emailController = EmailController();
  final _passwordController = PasswordController();
  final _confirmPasswordController = ConfirmPasswordController();

  Future<void> _register() async {
    final username = _usernameController.controller.text.trim();
    final email = _emailController.controller.text.trim();
    final password = _passwordController.controller.text.trim();
    final confirmPassword = _confirmPasswordController.controller.text.trim();

    // Check if any field is empty
    if (username.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      _showWarningDialog('All fields are required');
      return;
    }

    // Validate password requirements
    final passwordRegExp =
        RegExp(r'^(?=.*[A-Z])(?=.*[a-z])(?=.*\d)(?=.*[!@#%.]).{8,}$');
    if (!passwordRegExp.hasMatch(password)) {
      _showWarningDialog(
          'Password must contain at least 8 characters, including an uppercase letter, a lowercase letter, a number, and a special character (!, @, #, %, .)');
      return;
    }

    if (password != confirmPassword) {
      _showWarningDialog('Passwords do not match');
      return;
    }

    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = userCredential.user;

      if (user != null) {
        await user.updateDisplayName(username);
        await _firestore.collection('users')
            .doc(user.uid)
            .set({
          'email': user.email,
          'displayName': user.displayName,
          'createdAt': DateTime.now()
        });
      }

      // Show success dialog
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle, color: Colors.green, size: 60),
                const SizedBox(height: 16),
                const Text('Success', style: TextStyle(fontSize: 20)),
                const SizedBox(height: 8),
                const Text('Registration successful.'),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // Close dialog
                    Navigator.pop(context); // Navigate back to login screen
                  },
                  child: const Text('Ok'),
                ),
              ],
            ),
          );
        },
      );
    } catch (e) {
      // Handle error
      _showWarningDialog(e.toString());
    }
  }

  void _showWarningDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text('Warning'),
          content: Text(message),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Ok'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _usernameController.controller,
              decoration: const InputDecoration(labelText: 'Username'),
            ),
            TextField(
              controller: _emailController.controller,
              decoration: const InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
            ),
            TextField(
              controller: _passwordController.controller,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            TextField(
              controller: _confirmPasswordController.controller,
              decoration: const InputDecoration(labelText: 'Confirm Password'),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _register,
              child: const Text('Register'),
            ),
          ],
        ),
      ),
    );
  }
}
