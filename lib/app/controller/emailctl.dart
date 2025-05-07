import 'package:flutter/material.dart';

class EmailController {
  final TextEditingController controller = TextEditingController();

  String? validate(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
      return 'Enter a valid email';
    }
    return null;
  }

  void dispose() {
    controller.dispose();
  }
}
