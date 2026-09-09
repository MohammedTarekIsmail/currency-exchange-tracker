import 'package:currency_exchange_tracker/core/theme/app_colors.dart';
import 'package:currency_exchange_tracker/core/theme/app_text_styles.dart';
import 'package:currency_exchange_tracker/features/exchange_rates/domain/entities/currency_rate.dart';
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
    final color = change.isEgpStrengthening
        ? AppColors.strengthening
        : change.isEgpWeakening
        ? AppColors.weakening
        : AppColors.unchanged;

    final sign = change.amount > 0 ? '+' : '';

    return ListTile(
      onTap: onTap,
      leading: CircleAvatar(child: Text(rate.code.substring(0, 1))),
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
          Text(
            '$sign${change.amount.toStringAsFixed(2)} ($sign${change.percent.toStringAsFixed(2)}%)',
            style: AppTextStyles.changeValue.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}
