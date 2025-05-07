import 'package:flutter/material.dart';

class ConfirmPasswordController {
  final TextEditingController controller = TextEditingController();

  String? validate(String? value) {
    if (value == null || value.isEmpty) {
      return 'Confirm Password is required';
    }
    return null;
  }

  void dispose() {
    controller.dispose();
  }
}
