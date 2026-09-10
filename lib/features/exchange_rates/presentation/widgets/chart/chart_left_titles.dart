import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:currency_exchange_tracker/features/exchange_rates/presentation/utils/rate_format.dart';
import 'chart_axis_label.dart';

class ChartLeftTitles {
  const ChartLeftTitles._();

  static Widget build(double value, TitleMeta meta) {
    if (value <= meta.min || value >= meta.max) {
      return const SizedBox.shrink();
    }
    return ChartAxisLabel(text: formatAxisRate(value), meta: meta);
  }
}
