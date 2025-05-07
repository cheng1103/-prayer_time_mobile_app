import 'package:flutter/material.dart';

class UsernameController {
  final TextEditingController controller = TextEditingController();

  String? validate(String? value) {
    if (value == null || value.isEmpty) {
      return 'Username is required';
    }
    return null;
  }

  void dispose() {
    controller.dispose();
  }
}
