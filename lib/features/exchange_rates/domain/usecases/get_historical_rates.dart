import 'package:currency_exchange_tracker/features/exchange_rates/domain/entities/historical_rate_point.dart';
import 'package:currency_exchange_tracker/features/exchange_rates/domain/repositories/exchange_rates_repository.dart';

/// Builds the series for the detail screen's line chart: the last [days] daily
/// rates for one currency pair.
///
/// The API returns every currency for a given date, so this fetches one date
/// per day in the window (in parallel), pulls the requested currency out of
/// each response, and returns the points oldest-first. Days the API has no
/// value for are simply omitted rather than failing the whole series.
class GetHistoricalRates {
  const GetHistoricalRates(this._repository);

  final ExchangeRatesRepository _repository;

  Future<List<HistoricalRatePoint>> call(
    String currencyCode, {
    int days = 7,
  }) async {
    assert(days > 0, 'days must be positive');

    final key = currencyCode.toLowerCase();
    final today = DateTime.now();
    final startOfToday = DateTime(today.year, today.month, today.day);

    final dates = List.generate(
      days,
      (i) => startOfToday.subtract(Duration(days: i)),
    );

    final responses = await Future.wait(dates.map(_repository.getRatesForDate));

    final points = <HistoricalRatePoint>[];
    for (var i = 0; i < dates.length; i++) {
      final rate = responses[i][key];
      if (rate == null) continue;
      points.add(HistoricalRatePoint(date: dates[i], rate: rate));
    }

    points.sort((a, b) => a.date.compareTo(b.date));
    return points;
  }
}
