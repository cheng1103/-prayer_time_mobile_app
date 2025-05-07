import 'package:flutter/material.dart';

class TextEditingControllerUtil {
  final TextEditingController controller = TextEditingController();

  void dispose() {
    controller.dispose();
  }
}
