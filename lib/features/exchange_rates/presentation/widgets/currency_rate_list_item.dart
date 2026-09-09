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

    return ListTile(
      onTap: onTap,
      leading: CircleAvatar(
        backgroundColor: Colors.transparent,
        child: Text(flagFor(rate.code), style: const TextStyle(fontSize: 28)),
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
          Text(
            '$sign${change.amount.toStringAsFixed(2)} ($sign${change.percent.toStringAsFixed(2)}%)',
            style: AppTextStyles.changeValue.copyWith(color: change.color),
          ),
        ],
      ),
    );
  }
}
