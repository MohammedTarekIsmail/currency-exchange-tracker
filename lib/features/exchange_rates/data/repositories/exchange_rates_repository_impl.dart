import 'package:currency_exchange_tracker/core/constants/tracked_currencies.dart';
import 'package:currency_exchange_tracker/core/error/exceptions.dart';
import 'package:currency_exchange_tracker/core/network/api_endpoints.dart';
import 'package:currency_exchange_tracker/core/network/network_info.dart';
import 'package:currency_exchange_tracker/features/exchange_rates/data/datasources/exchange_rates_local_data_source.dart';
import 'package:currency_exchange_tracker/features/exchange_rates/data/datasources/exchange_rates_remote_data_source.dart';
import 'package:currency_exchange_tracker/features/exchange_rates/data/models/currency_rate_model.dart';
import 'package:currency_exchange_tracker/features/exchange_rates/domain/entities/currency_rate.dart';
import 'package:currency_exchange_tracker/features/exchange_rates/domain/entities/daily_change.dart';
import 'package:currency_exchange_tracker/features/exchange_rates/domain/entities/exchange_rates_snapshot.dart';
import 'package:currency_exchange_tracker/features/exchange_rates/domain/repositories/exchange_rates_repository.dart';

/// Coordinates the remote API, the local cache and connectivity into the
/// domain-facing [ExchangeRatesRepository] contract.
///
/// Offline strategy for [getLatestRates] (result carried in an
/// [ExchangeRatesSnapshot] whose `isFromCache` / `cachedAt` tell the UI where
/// the data came from):
///  * Online  -> fetch today + yesterday, compute the daily change, cache
///    today's raw response, return fresh data (`isFromCache: false`,
///    `cachedAt: null`). Only today's request is load-bearing; if yesterday's
///    fails the rates are still returned, with the daily change flat.
///  * Online but the request fails on connectivity -> serve the cache instead
///    of surfacing the error (the network dropped mid-flight).
///  * Offline -> serve the cache directly.
///  * Both cache-fallback paths report `isFromCache: true` with `cachedAt`
///    from [ExchangeRatesLocalDataSource.getLastCachedTime].
///  * Cache empty in either fallback -> the [CacheException] propagates so the
///    presentation layer can show a real error state.
///
/// Server-side failures ([ServerException]) on today's request are never
/// swallowed — only connectivity problems trigger the cache fallback. Failures
/// on yesterday's request are swallowed by design (see above): it is an
/// enrichment call, not a source of truth.
class ExchangeRatesRepositoryImpl implements ExchangeRatesRepository {
  ExchangeRatesRepositoryImpl(this._remote, this._local, this._networkInfo);

  final ExchangeRatesRemoteDataSource _remote;
  final ExchangeRatesLocalDataSource _local;
  final NetworkInfo _networkInfo;

  @override
  Future<ExchangeRatesSnapshot> getLatestRates() async {
    if (await _networkInfo.isConnected) {
      return _fetchCacheAndBuildLatest();
    }
    return _ratesFromCache();
  }

  @override
  Future<Map<String, double>> getRatesForDate(DateTime date) async {
    // No caching / offline handling here by design — the historical chart is a
    // best-effort view and errors are meant to bubble up to the caller.
    final body = await _remote.fetchRatesForDate(date);
    return _rawRates(body).map(
      (code, rawRate) => MapEntry(code, _toEgpPerUnit(rawRate)),
    );
  }

  Future<ExchangeRatesSnapshot> _fetchCacheAndBuildLatest() async {
    final now = DateTime.now();
    final yesterday = DateTime(
      now.year,
      now.month,
      now.day,
    ).subtract(const Duration(days: 1));

    // Both requests go out together, but only today's is required: yesterday's
    // exists solely to compute the daily change, and _dailyChange already
    // degrades to flat without it. Letting a failure there abort the whole
    // fetch would hide today's perfectly good rates behind an error screen.
    try {
      // Created back to back so both are in flight before the first await —
      // and inside the try, so a data source that fails synchronously still
      // reaches the cache fallback below.
      final todayRequest = _remote.fetchLatestRates();
      final yesterdayRequest = _fetchRatesForDateOrNull(yesterday);

      final todayBody = await todayRequest;
      final yesterdayBody = await yesterdayRequest;

      await _local.cacheRates(todayBody);

      return ExchangeRatesSnapshot(
        rates: _buildRates(todayBody: todayBody, yesterdayBody: yesterdayBody),
        isFromCache: false,
        cachedAt: null,
      );
    } on NetworkException {
      // We thought we were online, but the call still failed on connectivity.
      // Fall back to the last good data rather than failing outright.
      return _ratesFromCache();
    }
  }

  /// Best-effort fetch for a single date: any failure becomes `null` so the
  /// caller can carry on without the daily change rather than failing outright.
  Future<Map<String, dynamic>?> _fetchRatesForDateOrNull(DateTime date) async {
    try {
      return await _remote.fetchRatesForDate(date);
    } on Exception {
      return null;
    }
  }

  /// Builds a cache-backed snapshot. Without a cached "yesterday" response the
  /// daily change can't be recomputed offline, so it shows as flat until
  /// connectivity returns and a fresh fetch fills it in.
  Future<ExchangeRatesSnapshot> _ratesFromCache() async {
    final cachedBody = await _local.getCachedRates(); // CacheException if empty
    final List<CurrencyRate> rates;
    try {
      rates = _buildRates(todayBody: cachedBody);
    } on FormatException {
      throw const CacheException('Cached rates are corrupted.');
    }

    return ExchangeRatesSnapshot(
      rates: rates,
      isFromCache: true,
      cachedAt: await _local.getLastCachedTime(),
    );
  }

  List<CurrencyRate> _buildRates({
    required Map<String, dynamic> todayBody,
    Map<String, dynamic>? yesterdayBody,
  }) {
    final todayRates = _rawRates(todayBody);
    final yesterdayRates =
        yesterdayBody == null ? null : _rawRates(yesterdayBody);
    final lastUpdated = _reportedDate(todayBody);

    final rates = <CurrencyRate>[];
    for (final currency in TrackedCurrencies.all) {
      final rawToday = todayRates[currency.code];
      if (rawToday == null) continue; // currency absent from this response

      rates.add(
        CurrencyRateModel.fromRawRate(
          code: currency.code,
          name: currency.name,
          rawRate: rawToday,
          dailyChange: _dailyChange(
            rawToday: rawToday,
            rawYesterday: yesterdayRates?[currency.code],
          ),
          lastUpdated: lastUpdated,
        ),
      );
    }
    return rates;
  }

  /// Day-over-day movement, expressed in the displayed "EGP per 1 unit" terms
  /// so it lines up with [CurrencyRate.rate]. Falls back to flat when there's
  /// no usable yesterday value.
  DailyChange _dailyChange({
    required double rawToday,
    double? rawYesterday,
  }) {
    if (rawYesterday == null || rawYesterday <= 0) {
      return const DailyChange.zero();
    }
    final todayEgp = _toEgpPerUnit(rawToday);
    final yesterdayEgp = _toEgpPerUnit(rawYesterday);
    final amount = todayEgp - yesterdayEgp;
    return DailyChange(
      amount: amount,
      percent: (amount / yesterdayEgp) * 100,
    );
  }

  /// Pulls the `egp` object out of a raw API body and returns it as
  /// `code -> raw rate` (still in the API's "units per 1 EGP" direction),
  /// dropping any non-numeric or non-positive entries.
  Map<String, double> _rawRates(Map<String, dynamic> body) {
    final raw = body[ApiEndpoints.baseCurrency];
    if (raw is! Map) {
      throw const FormatException('Response is missing the "egp" rates object.');
    }
    final out = <String, double>{};
    raw.forEach((key, value) {
      if (value is num && value > 0) {
        out[key.toString().toLowerCase()] = value.toDouble();
      }
    });
    return out;
  }

  /// The `date` the API stamped on the payload; defaults to now if absent or
  /// unparseable.
  DateTime _reportedDate(Map<String, dynamic> body) {
    final raw = body['date'];
    if (raw is String) {
      final parsed = DateTime.tryParse(raw);
      if (parsed != null) return parsed;
    }
    return DateTime.now();
  }

  /// Invert the API rate (`1 EGP = x FOREIGN`) into the displayed direction
  /// (`1 FOREIGN = y EGP`).
  double _toEgpPerUnit(double rawRate) => 1 / rawRate;
}
