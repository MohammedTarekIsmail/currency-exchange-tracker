import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'chart_axis_label.dart';

class ChartLeftTitles {
  const ChartLeftTitles._();

  static String formatRate(double value) {
    if (value >= 100) return value.toStringAsFixed(0);
    if (value >= 10) return value.toStringAsFixed(1);
    if (value >= 1) return value.toStringAsFixed(2);
    return value.toStringAsFixed(3);
  }

  static Widget build(double value, TitleMeta meta) {
    if (value <= meta.min || value >= meta.max) {
      return const SizedBox.shrink();
    }
    return ChartAxisLabel(text: formatRate(value), meta: meta);
  }
}
