import 'package:equatable/equatable.dart';

/// One plotted point on the detail screen's 7-day line chart: the rate for a
/// single currency pair on a single day.
///
/// [rate] uses the same "EGP per 1 unit" convention as [CurrencyRate.rate].
/// [date] is date-only (midnight, local); the API publishes one value per day.
class HistoricalRatePoint extends Equatable {
  const HistoricalRatePoint({required this.date, required this.rate});

  final DateTime date;
  final double rate;

  @override
  List<Object?> get props => [date, rate];
}
