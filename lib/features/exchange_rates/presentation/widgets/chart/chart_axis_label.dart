import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:currency_exchange_tracker/core/theme/app_text_styles.dart';

class ChartAxisLabel extends StatelessWidget {
  const ChartAxisLabel({super.key, required this.text, required this.meta});

  final String text;
  final TitleMeta meta;

  @override
  Widget build(BuildContext context) {
    return SideTitleWidget(
      meta: meta,
      space: 6,
      child: Text(text, style: AppTextStyles.chartAxisLabel),
    );
  }
}
