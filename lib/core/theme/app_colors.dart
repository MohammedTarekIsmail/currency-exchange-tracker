import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Brand
  static const Color primary = Color(
    0xFF5B3FD9,
  ); // richer, more saturated purple
  static const Color primaryDark = Color(0xFF4229B8);
  static const Color background = Color(0xFFF6F4FB);

  // Currency movement
  static const Color strengthening = Color(0xFF1B9E5A);
  static const Color weakening = Color(0xFFE0483E);
  static const Color unchanged = Colors.grey;

  // Text
  static const Color textPrimary = Color(0xFF1A1533);
  static const Color textSecondary = Color(0xFF6E6785);

  // Status
  static const Color error = Color(0xFFE0483E);

  // Chart
  static const Color chartGridLine = Color(0xFFEDEAF6);
  static const Color chartTooltipBackground = Color(0xFF1A1533);
  static const Color chartTooltipText = Colors.white;

  // Shimmer
  static const Color shimmerBase = Color(0xFFE7E3F3);
  static const Color shimmerHighlight = Color(0xFFF6F4FB);

  static const Color white = Colors.white;
  static const Color cardShadow = Color(0x1F5B3FD9);
  static const double badgeBackgroundOpacity = 0.12;
}
