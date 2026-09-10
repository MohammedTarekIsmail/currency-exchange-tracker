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
      shadowColor: AppColors.cardShadow,
      surfaceTintColor: Colors.transparent,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(flagFor(rate.code), style: const TextStyle(fontSize: 24)),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(rate.name, style: AppTextStyles.currencyName),
                    const SizedBox(height: 2),
                    Text(rate.code, style: AppTextStyles.currencyCode),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${rate.rate.toStringAsFixed(2)} EGP',
                    style: AppTextStyles.rateValue,
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: change.color.withValues(alpha: AppColors.badgeBackgroundOpacity),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '$sign${change.amount.toStringAsFixed(2)} ($sign${change.percent.toStringAsFixed(2)}%)',
                      style: AppTextStyles.changeValue.copyWith(color: change.color),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}