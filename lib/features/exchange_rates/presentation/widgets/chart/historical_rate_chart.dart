import 'dart:math' as math;
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:currency_exchange_tracker/core/theme/app_colors.dart';
import 'package:currency_exchange_tracker/core/theme/app_text_styles.dart';
import 'package:currency_exchange_tracker/features/exchange_rates/domain/entities/historical_rate_point.dart';
import 'chart_bottom_titles.dart';
import 'chart_left_titles.dart';
import 'historical_chart_loading.dart';

class HistoricalRateChart extends StatelessWidget {
  const HistoricalRateChart({super.key, required this.points});

  final List<HistoricalRatePoint> points;

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty) {
      return SizedBox(
        height: kChartHeight,
        child: Center(
          child: Text('No chart data to display.', style: AppTextStyles.chartAxisLabel),
        ),
      );
    }

    final data = [...points]..sort((a, b) => a.date.compareTo(b.date));
    final spots = <FlSpot>[
      for (var i = 0; i < data.length; i++) FlSpot(i.toDouble(), data[i].rate),
    ];

    final maxX = data.length > 1 ? (data.length - 1).toDouble() : 1.0;

    final rates = data.map((p) => p.rate);
    final minRate = rates.reduce(math.min);
    final maxRate = rates.reduce(math.max);
    final span = maxRate - minRate;
    final padding = span > 0 ? span * 0.15 : math.max(maxRate.abs() * 0.05, 0.01);
    final minY = math.max(minRate - padding, 0.0);
    final maxY = maxRate + padding;
    final yInterval = (maxY - minY) / 4;
    final safeYInterval = yInterval > 0 ? yInterval : 1.0;

    return SizedBox(
      height: kChartHeight,
      child: Padding(
        padding: const EdgeInsets.only(top: 16, right: 16),
        child: LineChart(
          LineChartData(
            minX: 0,
            maxX: maxX,
            minY: minY,
            maxY: maxY,
            clipData: const FlClipData.all(),
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              horizontalInterval: safeYInterval,
              getDrawingHorizontalLine: (_) =>
              const FlLine(color: AppColors.chartGridLine, strokeWidth: 1),
            ),
            borderData: FlBorderData(show: false),
            titlesData: FlTitlesData(
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              bottomTitles: AxisTitles(
                axisNameWidget: Text('Date', style: AppTextStyles.chartAxisLabel),
                axisNameSize: 18,
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: 1,
                  reservedSize: 28,
                  getTitlesWidget: (value, meta) => ChartBottomTitles.build(value, meta, data),
                ),
              ),
              leftTitles: AxisTitles(
                axisNameWidget: Text('Rate (EGP)', style: AppTextStyles.chartAxisLabel),
                axisNameSize: 18,
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: safeYInterval,
                  reservedSize: 46,
                  getTitlesWidget: ChartLeftTitles.build,
                ),
              ),
            ),
            lineTouchData: LineTouchData(
              touchTooltipData: LineTouchTooltipData(
                tooltipBorderRadius: BorderRadius.circular(8),
                getTooltipColor: (_) => AppColors.chartTooltipBackground,
                getTooltipItems: (touchedSpots) => [
                  for (final spot in touchedSpots)
                    LineTooltipItem(
                      '${DateFormat('MMM d').format(data[spot.x.round().clamp(0, data.length - 1)].date)}\n'
                          '${ChartLeftTitles.formatRate(spot.y)} EGP',
                      TextStyle(
                        color: AppColors.chartTooltipText,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                ],
              ),
            ),
            lineBarsData: [
              LineChartBarData(
                spots: spots,
                isCurved: true,
                preventCurveOverShooting: true,
                color: AppColors.primary,
                barWidth: 3,
                dotData: FlDotData(show: data.length <= 14),
                belowBarData: BarAreaData(
                  show: true,
                  color: AppColors.primary.withValues(alpha: 0.12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}