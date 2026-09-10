import 'package:currency_exchange_tracker/core/theme/app_palette.dart';
import 'package:currency_exchange_tracker/features/exchange_rates/domain/entities/daily_change.dart';
import 'package:flutter/material.dart';

extension DailyChangeStyle on DailyChange {
  Color colorIn(AppPalette palette) {
    if (isEgpStrengthening) return palette.strengthening;
    if (isEgpWeakening) return palette.weakening;
    return palette.unchanged;
  }

  IconData get icon {
    if (isEgpStrengthening) return Icons.arrow_downward;
    if (isEgpWeakening) return Icons.arrow_upward;
    return Icons.remove;
  }
}
