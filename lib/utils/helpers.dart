import 'package:flutter/material.dart';

class Helpers {
  static String formatCurrency(double value) {
    return '₹${value.toStringAsFixed(2)}';
  }

  static void showSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }
}
