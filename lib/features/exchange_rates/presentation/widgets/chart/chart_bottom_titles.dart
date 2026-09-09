import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:currency_exchange_tracker/features/exchange_rates/domain/entities/historical_rate_point.dart';
import 'chart_axis_label.dart';

class ChartBottomTitles {
  const ChartBottomTitles._();

  static Widget build(
    double value,
    TitleMeta meta,
    List<HistoricalRatePoint> data,
  ) {
    final index = value.round();
    if ((value - index).abs() > 0.01 || index < 0 || index >= data.length) {
      return const SizedBox.shrink();
    }
    return ChartAxisLabel(
      text: DateFormat('MMM d').format(data[index].date),
      meta: meta,
    );
  }
}
