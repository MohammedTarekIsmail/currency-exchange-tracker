import 'package:currency_exchange_tracker/features/exchange_rates/domain/entities/currency_rate.dart';

/// Contract the domain depends on for exchange-rate data. The data layer
/// decides where the values come from (network, cache) and is responsible for
/// inverting the raw API rates into the "EGP per 1 unit" convention used here.
abstract class ExchangeRatesRepository {
  /// The 5 tracked pairs for today, each already carrying its [DailyChange]
  /// (which the implementation computes from today's and yesterday's rates).
  ///
  /// Throws on failure; may serve cached data when offline.
  Future<List<CurrencyRate>> getLatestRates();

  /// Every tracked currency's rate for a single [date], keyed by lower-case
  /// currency code (`usd`, `eur`, ...) — one API response holds them all.
  ///
  /// Values follow the "EGP per 1 unit" convention. Throws on failure.
  Future<Map<String, double>> getRatesForDate(DateTime date);
}
