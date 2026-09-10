import 'package:currency_exchange_tracker/core/theme/app_colors.dart';
import 'package:currency_exchange_tracker/core/theme/app_text_styles.dart';
import 'package:currency_exchange_tracker/features/exchange_rates/domain/entities/currency_rate.dart';
import 'package:currency_exchange_tracker/features/exchange_rates/presentation/bloc/currency_detail/currency_detail_bloc.dart';
import 'package:currency_exchange_tracker/features/exchange_rates/presentation/bloc/currency_detail/currency_detail_event.dart';
import 'package:currency_exchange_tracker/features/exchange_rates/presentation/bloc/currency_detail/currency_detail_state.dart';
import 'package:currency_exchange_tracker/features/exchange_rates/presentation/utils/daily_change_style.dart';
import 'package:currency_exchange_tracker/features/exchange_rates/presentation/utils/rate_format.dart';
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
              Widget chartContent;
              if (state is ChartLoaded) {
                chartContent = HistoricalRateChart(points: state.points);
              } else if (state is ChartError) {
                chartContent = SizedBox(
                  height: kChartHeight,
                  child: ErrorRetryView(
                    message: state.message,
                    icon: Icons.show_chart,
                    onRetry: () => context.read<CurrencyDetailBloc>().add(
                      FetchHistoricalRates(rate.code),
                    ),
                  ),
                );
              } else {
                chartContent = const HistoricalRateChartLoading();
              }

              return Card(
                color: AppColors.white,
                shadowColor: AppColors.cardShadow,
                surfaceTintColor: Colors.transparent,
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: chartContent,
                ),
              );
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

    return Card(
      color: AppColors.white,
      shadowColor: AppColors.cardShadow,
      surfaceTintColor: Colors.transparent,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '1 ${rate.code} = ${formatRate(rate.rate)} EGP',
              style: AppTextStyles.detailRate,
            ),
            const Gap(10),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: change.color.withValues(
                      alpha: AppColors.badgeBackgroundOpacity,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(change.icon, size: 16, color: change.color),
                      const Gap(4),
                      Text(
                        '$sign${formatChangeAmount(change.amount)} EGP '
                        '($sign${change.percent.toStringAsFixed(2)}%)',
                        style: AppTextStyles.changeValue.copyWith(
                          color: change.color,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                const Gap(8),
                const Text('today', style: AppTextStyles.currencyCode),
              ],
            ),
            const Gap(12),
            Text(
              'Last updated ${DateFormat.yMMMMd().format(rate.lastUpdated)}',
              style: AppTextStyles.currencyCode,
            ),
          ],
        ),
      ),
    );
  }
}
