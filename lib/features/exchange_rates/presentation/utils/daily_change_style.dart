import 'package:currency_exchange_tracker/core/theme/app_colors.dart';
import 'package:currency_exchange_tracker/features/exchange_rates/domain/entities/daily_change.dart';
import 'package:flutter/material.dart';

extension DailyChangeStyle on DailyChange {
  Color get color {
    if (isEgpStrengthening) return AppColors.strengthening;
    if (isEgpWeakening) return AppColors.weakening;
    return AppColors.unchanged;
  }

  IconData get icon {
    if (isEgpStrengthening) return Icons.arrow_downward;
    if (isEgpWeakening) return Icons.arrow_upward;
    return Icons.remove;
  }
}
