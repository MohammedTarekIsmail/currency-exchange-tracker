import 'package:currency_exchange_tracker/features/exchange_rates/domain/entities/historical_rate_point.dart';
import 'package:currency_exchange_tracker/features/exchange_rates/domain/repositories/exchange_rates_repository.dart';

/// Builds the series for the detail screen's line chart: the last [days] daily
/// rates for one currency pair.
///
/// The API returns every currency for a given date, so this fetches one date
/// per day in the window (in parallel), pulls the requested currency out of
/// each response, and returns the points oldest-first.
///
/// A day is omitted rather than failing the whole series when its response has
/// no value for the currency *or* when its request fails outright — one 404 in
/// a 7-day window should cost one point, not the chart. If every day fails
/// there is nothing to draw, so the first failure is rethrown and the caller
/// gets the real reason ("No internet connection") instead of an empty list.
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

    Exception? failure;
    final responses = await Future.wait(
      dates.map((date) async {
        try {
          return await _repository.getRatesForDate(date);
        } on Exception catch (e) {
          failure ??= e;
          return null;
        }
      }),
    );

    final points = <HistoricalRatePoint>[];
    for (var i = 0; i < dates.length; i++) {
      final rate = responses[i]?[key];
      if (rate == null) continue;
      points.add(HistoricalRatePoint(date: dates[i], rate: rate));
    }

    // Nothing survived and we know why — surface that rather than an empty
    // series the caller would have to guess at.
    if (points.isEmpty && failure != null) throw failure!;

    points.sort((a, b) => a.date.compareTo(b.date));
    return points;
  }
}
