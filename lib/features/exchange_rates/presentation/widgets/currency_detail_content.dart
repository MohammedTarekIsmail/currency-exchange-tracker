import 'package:currency_exchange_tracker/core/theme/app_text_styles.dart';
import 'package:currency_exchange_tracker/features/exchange_rates/domain/entities/currency_rate.dart';
import 'package:currency_exchange_tracker/features/exchange_rates/presentation/bloc/currency_detail/currency_detail_bloc.dart';
import 'package:currency_exchange_tracker/features/exchange_rates/presentation/bloc/currency_detail/currency_detail_event.dart';
import 'package:currency_exchange_tracker/features/exchange_rates/presentation/bloc/currency_detail/currency_detail_state.dart';
import 'package:currency_exchange_tracker/features/exchange_rates/presentation/utils/daily_change_style.dart';
import 'package:currency_exchange_tracker/features/exchange_rates/presentation/widgets/chart/historical_chart_loading.dart';
import 'package:currency_exchange_tracker/features/exchange_rates/presentation/widgets/chart/historical_rate_chart.dart';
import 'package:currency_exchange_tracker/features/exchange_rates/presentation/widgets/error_retry_view.dart';
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
                return SizedBox(
                  height: kChartHeight,
                  child: ErrorRetryView(
                    message: state.message,
                    icon: Icons.show_chart,
                    onRetry: () => context
                        .read<CurrencyDetailBloc>()
                        .add(FetchHistoricalRates(rate.code)),
                  ),
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
    final sign = change.amount > 0 ? '+' : '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '1 ${rate.code} = ${rate.rate.toStringAsFixed(2)} EGP',
          style: AppTextStyles.detailRate,
        ),
        const Gap(8),
        Row(
          children: [
            Icon(change.icon, size: 18, color: change.color),
            const Gap(4),
            Text(
              '$sign${change.amount.toStringAsFixed(2)} EGP '
              '($sign${change.percent.toStringAsFixed(2)}%)',
              style: AppTextStyles.changeValue.copyWith(
                color: change.color,
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
}
