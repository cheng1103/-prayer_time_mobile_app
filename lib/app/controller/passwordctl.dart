import 'package:flutter/material.dart';

class PasswordController {
  final TextEditingController controller = TextEditingController();

  String? validate(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  void dispose() {
    controller.dispose();
  }
}
