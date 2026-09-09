import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color primary = Colors.deepPurple;
  static const Color background = Color(0xFFFDF7FF);

  // Currency movement colors
  static const Color strengthening = Colors.green;
  static const Color weakening = Colors.red;
  static const Color unchanged = Colors.grey;

  // Text
  static const Color textPrimary = Colors.black87;
  static const Color textSecondary = Colors.black54;

  // Error/status
  static const Color error = Colors.red;

  // Chart-specific
  static const Color chartGridLine = Colors.black12;
  static const Color chartTooltipBackground = Colors.black87;
  static const Color chartTooltipText = Colors.white;
  static const Color shimmerBase = Color(0xFFE0E0E0);
  static const Color shimmerHighlight = Color(0xFFF5F5F5);
  static const Color chartPlaceholderFill = Colors.white;
}
