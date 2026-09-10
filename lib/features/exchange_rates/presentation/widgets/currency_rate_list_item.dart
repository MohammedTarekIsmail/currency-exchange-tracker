import 'package:currency_exchange_tracker/core/theme/app_colors.dart';
import 'package:currency_exchange_tracker/core/theme/app_text_styles.dart';
import 'package:currency_exchange_tracker/features/exchange_rates/domain/entities/currency_rate.dart';
import 'package:currency_exchange_tracker/features/exchange_rates/presentation/utils/currency_flags.dart';
import 'package:currency_exchange_tracker/features/exchange_rates/presentation/utils/rate_format.dart';
import 'package:currency_exchange_tracker/features/exchange_rates/presentation/widgets/daily_change_badge.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

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
                    '${formatRate(rate.rate)} EGP',
                    style: AppTextStyles.rateValue,
                  ),
                  const Gap(6),
                  DailyChangeBadge(change: rate.dailyChange, dense: true),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}