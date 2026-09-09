import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  static const TextStyle screenTitle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle currencyName = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
  );

  static const TextStyle currencyCode = TextStyle(
    fontSize: 13,
    color: AppColors.textSecondary,
  );

  static const TextStyle rateValue = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle changeValue = TextStyle(fontSize: 12);

  static const TextStyle errorMessage = TextStyle(fontSize: 14);
}
