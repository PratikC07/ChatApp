import 'package:flutter/material.dart';

extension ContextExtension on BuildContext {
  showSnackbar(String message) {
    ScaffoldMessenger.of(this).showSnackBar(SnackBar(content: Text(message)));
  }
}
