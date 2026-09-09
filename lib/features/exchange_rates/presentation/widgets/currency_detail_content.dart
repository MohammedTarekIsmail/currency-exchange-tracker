import 'package:currency_exchange_tracker/core/theme/app_colors.dart';
import 'package:currency_exchange_tracker/core/theme/app_text_styles.dart';
import 'package:currency_exchange_tracker/features/exchange_rates/domain/entities/currency_rate.dart';
import 'package:currency_exchange_tracker/features/exchange_rates/domain/entities/daily_change.dart';
import 'package:currency_exchange_tracker/features/exchange_rates/presentation/bloc/currency_detail/currency_detail_bloc.dart';
import 'package:currency_exchange_tracker/features/exchange_rates/presentation/bloc/currency_detail/currency_detail_event.dart';
import 'package:currency_exchange_tracker/features/exchange_rates/presentation/bloc/currency_detail/currency_detail_state.dart';
import 'package:currency_exchange_tracker/features/exchange_rates/presentation/widgets/chart/historical_chart_loading.dart';
import 'package:currency_exchange_tracker/features/exchange_rates/presentation/widgets/chart/historical_rate_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';

class CurrencyDetailContent extends StatelessWidget {
  final CurrencyRate rate;

  const CurrencyDetailContent({super.key, required this.rate});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _RateSummary(rate: rate),
          const Gap(28),
          const Text('Last 7 days', style: AppTextStyles.screenTitle),
          const Gap(12),
          BlocBuilder<CurrencyDetailBloc, CurrencyDetailState>(
            builder: (context, state) {
              if (state is ChartLoaded) {
                return HistoricalRateChart(points: state.points);
              }
              if (state is ChartError) {
                return _ChartErrorView(
                  message: state.message,
                  onRetry: () => context
                      .read<CurrencyDetailBloc>()
                      .add(FetchHistoricalRates(rate.code)),
                );
              }
              // CurrencyDetailInitial / ChartLoading
              return const HistoricalRateChartLoading();
            },
          ),
        ],
      ),
    );
  }
}

/// Current rate, daily change and last-update date for the selected pair.
class _RateSummary extends StatelessWidget {
  final CurrencyRate rate;

  const _RateSummary({required this.rate});

  @override
  Widget build(BuildContext context) {
    final change = rate.dailyChange;
    final color = _changeColor(change);
    final sign = change.amount > 0 ? '+' : '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '1 ${rate.code} = ${rate.rate.toStringAsFixed(2)} EGP',
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const Gap(8),
        Row(
          children: [
            Icon(_changeIcon(change), size: 18, color: color),
            const Gap(4),
            Text(
              '$sign${change.amount.toStringAsFixed(2)} EGP '
              '($sign${change.percent.toStringAsFixed(2)}%)',
              style: AppTextStyles.changeValue.copyWith(
                color: color,
                fontSize: 14,
              ),
            ),
            const Gap(6),
            const Text('today', style: AppTextStyles.currencyCode),
          ],
        ),
        const Gap(10),
        Text(
          'Last updated ${DateFormat.yMMMMd().format(rate.lastUpdated)}',
          style: AppTextStyles.currencyCode,
        ),
      ],
    );
  }

  Color _changeColor(DailyChange change) {
    if (change.isEgpStrengthening) return AppColors.strengthening;
    if (change.isEgpWeakening) return AppColors.weakening;
    return AppColors.unchanged;
  }

  IconData _changeIcon(DailyChange change) {
    if (change.isEgpStrengthening) return Icons.arrow_downward;
    if (change.isEgpWeakening) return Icons.arrow_upward;
    return Icons.remove;
  }
}

/// User-friendly failure state for the chart area, with a retry action.
class _ChartErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ChartErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 220,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.show_chart,
              size: 40,
              color: AppColors.textSecondary,
            ),
            const Gap(10),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyles.errorMessage,
            ),
            const Gap(12),
            OutlinedButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}
