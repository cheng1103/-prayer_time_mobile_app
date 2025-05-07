import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:prayer_time_mobile_app/app/controller/emailctl.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  _ResetPasswordScreenState createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _auth = FirebaseAuth.instance;
  final _emailController = EmailController();
  bool _isEmailSent = false;

  Future<void> _sendPasswordResetEmail() async {
    try {
      await _auth.sendPasswordResetEmail(
        email: _emailController.controller.text.trim(),
      );
      setState(() {
        _isEmailSent = true;
      });
    } catch (e) {
      print(e);
      _showWarningDialog(
          'Failed to send verification email. Please try again.');
    }
  }

  Future<void> _confirmPasswordChange() async {
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
              const Text('Password reset successful.'),
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reset Password')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (!_isEmailSent) ...[
              TextField(
                controller: _emailController.controller,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _sendPasswordResetEmail,
                child: const Text('Send Verification Email'),
              ),
            ] else ...[
              const Text(
                  'A verification link has been sent to your email. Please use the link to reset your password.'),
              const SizedBox(height: 10),
              const Text(
                  'Password must contain at least 8 characters, including an uppercase letter, a lowercase letter, a number, and a special character (!, @, #, %, .).'),
              const SizedBox(height: 10),
              const Text(
                  'After successfully changing your password, please click the button below to log in to your account.'),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _confirmPasswordChange,
                child: const Text('I have changed password'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }
}
