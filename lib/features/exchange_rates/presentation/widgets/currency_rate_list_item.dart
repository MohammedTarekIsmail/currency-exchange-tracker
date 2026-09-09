import 'package:currency_exchange_tracker/core/theme/app_colors.dart';
import 'package:currency_exchange_tracker/core/theme/app_text_styles.dart';
import 'package:currency_exchange_tracker/features/exchange_rates/domain/entities/currency_rate.dart';
import 'package:currency_exchange_tracker/features/exchange_rates/presentation/utils/currency_flags.dart';
import 'package:currency_exchange_tracker/features/exchange_rates/presentation/utils/daily_change_style.dart';
import 'package:flutter/material.dart';

class CurrencyRateListItem extends StatelessWidget {
  final CurrencyRate rate;
  final VoidCallback onTap;

  const CurrencyRateListItem({
    super.key,
    required this.rate,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final change = rate.dailyChange;
    final sign = change.amount > 0 ? '+' : '';

    return Card(
      color: AppColors.white,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        onTap: onTap,
        leading: SizedBox(
          width: 40,
          height: 40,
          child: Center(
            child: Text(
              flagFor(rate.code),
              style: const TextStyle(fontSize: 30),
            ),
          ),
        ),
        title: Text(rate.name),
        subtitle: Text(rate.code),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${rate.rate.toStringAsFixed(2)} EGP',
              style: AppTextStyles.rateValue,
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: change.color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                '$sign${change.amount.toStringAsFixed(2)} ($sign${change.percent.toStringAsFixed(2)}%)',
                style: AppTextStyles.changeValue.copyWith(color: change.color),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
