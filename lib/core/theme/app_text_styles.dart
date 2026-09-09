import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  static const TextStyle screenTitle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
  );

  /// Hero rate line on the currency detail screen ("1 USD = 52.01 EGP").
  static const TextStyle detailRate = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
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

  static const TextStyle chartAxisLabel = TextStyle(
    fontSize: 10,
    color: AppColors.textSecondary,
  );
}
