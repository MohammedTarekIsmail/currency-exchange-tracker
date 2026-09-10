import 'package:currency_exchange_tracker/core/error/exceptions.dart';
import 'package:currency_exchange_tracker/core/network/network_info.dart';
import 'package:currency_exchange_tracker/features/exchange_rates/data/datasources/exchange_rates_local_data_source.dart';
import 'package:currency_exchange_tracker/features/exchange_rates/data/datasources/exchange_rates_remote_data_source.dart';
import 'package:currency_exchange_tracker/features/exchange_rates/data/repositories/exchange_rates_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockRemote extends Mock implements ExchangeRatesRemoteDataSource {}

class _MockLocal extends Mock implements ExchangeRatesLocalDataSource {}

class _MockNetworkInfo extends Mock implements NetworkInfo {}

void main() {
  late _MockRemote remote;
  late _MockLocal local;
  late _MockNetworkInfo networkInfo;
  late ExchangeRatesRepositoryImpl repository;

  setUpAll(() {
    registerFallbackValue(DateTime(2020));
    registerFallbackValue(<String, dynamic>{});
  });

  setUp(() {
    remote = _MockRemote();
    local = _MockLocal();
    networkInfo = _MockNetworkInfo();
    repository = ExchangeRatesRepositoryImpl(remote, local, networkInfo);
  });

  // Raw API bodies: values are "foreign units per 1 EGP", so the repository
  // inverts them. usd 0.02 -> 50 EGP today, 0.025 -> 40 EGP yesterday.
  final todayBody = <String, dynamic>{
    'date': '2026-09-10',
    'egp': {'usd': 0.02, 'eur': 0.017, 'gbp': 0.015, 'sar': 0.075, 'jpy': 3.0},
  };
  final yesterdayBody = <String, dynamic>{
    'date': '2026-09-09',
    'egp': {'usd': 0.025, 'eur': 0.017, 'gbp': 0.015, 'sar': 0.075, 'jpy': 3.0},
  };
  final cachedBody = <String, dynamic>{
    'date': '2026-09-08',
    'egp': {'usd': 0.02, 'eur': 0.017, 'gbp': 0.015, 'sar': 0.075, 'jpy': 3.0},
  };
  final tCachedAt = DateTime(2026, 9, 10, 8, 30);

  group('getLatestRates — online', () {
    setUp(() {
      when(() => networkInfo.isConnected).thenAnswer((_) async => true);
      when(() => remote.fetchLatestRates()).thenAnswer((_) async => todayBody);
      when(
        () => remote.fetchRatesForDate(any()),
      ).thenAnswer((_) async => yesterdayBody);
      when(() => local.cacheRates(any())).thenAnswer((_) async {});
    });

    test(
      'fetches today + yesterday, computes the daily change, caches today, '
      'and reports isFromCache: false',
      () async {
        final snapshot = await repository.getLatestRates();

        // Yesterday is requested for the calendar day before today.
        final now = DateTime.now();
        final expectedYesterday = DateTime(
          now.year,
          now.month,
          now.day,
        ).subtract(const Duration(days: 1));
        final requestedDate = verify(
          () => remote.fetchRatesForDate(captureAny()),
        ).captured.single as DateTime;
        expect(requestedDate, expectedYesterday);

        // Raw today response is cached verbatim.
        verify(() => local.cacheRates(todayBody)).called(1);

        expect(snapshot.isFromCache, isFalse);
        expect(snapshot.cachedAt, isNull);
        expect(snapshot.rates, hasLength(5));

        // USD: 1/0.02 = 50 today, 1/0.025 = 40 yesterday -> +10 EGP / +25%.
        final usd = snapshot.rates.firstWhere((r) => r.code == 'USD');
        expect(usd.rate, closeTo(50, 1e-9));
        expect(usd.dailyChange.amount, closeTo(10, 1e-9));
        expect(usd.dailyChange.percent, closeTo(25, 1e-9));

        // EUR unchanged day over day.
        final eur = snapshot.rates.firstWhere((r) => r.code == 'EUR');
        expect(eur.dailyChange.amount, closeTo(0, 1e-9));
        expect(eur.dailyChange.percent, closeTo(0, 1e-9));
      },
    );
  });

  group('getLatestRates — offline', () {
    setUp(() {
      when(() => networkInfo.isConnected).thenAnswer((_) async => false);
      when(() => local.getCachedRates()).thenAnswer((_) async => cachedBody);
      when(() => local.getLastCachedTime()).thenAnswer((_) async => tCachedAt);
    });

    test('serves cached data with isFromCache: true and never hits the network',
        () async {
      final snapshot = await repository.getLatestRates();

      expect(snapshot.isFromCache, isTrue);
      expect(snapshot.cachedAt, tCachedAt);
      expect(snapshot.rates, hasLength(5));
      // No cached "yesterday" to diff against -> every change is flat.
      expect(
        snapshot.rates.every(
          (r) => r.dailyChange.amount == 0 && r.dailyChange.percent == 0,
        ),
        isTrue,
      );

      verifyNever(() => remote.fetchLatestRates());
      verifyNever(() => remote.fetchRatesForDate(any()));
      verifyNever(() => local.cacheRates(any()));
    });
  });

  group('getLatestRates — remote failure while online', () {
    setUp(() {
      when(() => networkInfo.isConnected).thenAnswer((_) async => true);
      when(() => local.getCachedRates()).thenAnswer((_) async => cachedBody);
      when(() => local.getLastCachedTime()).thenAnswer((_) async => tCachedAt);
    });

    test('NetworkException falls back to the cache instead of throwing',
        () async {
      when(
        () => remote.fetchLatestRates(),
      ).thenThrow(const NetworkException());
      when(
        () => remote.fetchRatesForDate(any()),
      ).thenAnswer((_) async => yesterdayBody);

      final snapshot = await repository.getLatestRates();

      expect(snapshot.isFromCache, isTrue);
      expect(snapshot.cachedAt, tCachedAt);
      verify(() => local.getCachedRates()).called(1);
      verifyNever(() => local.cacheRates(any()));
    });

    test(
      "yesterday's failure still returns today's rates, with a flat change",
      () async {
        when(
          () => remote.fetchLatestRates(),
        ).thenAnswer((_) async => todayBody);
        when(
          () => remote.fetchRatesForDate(any()),
        ).thenThrow(const ServerException('historical endpoint is down'));
        when(() => local.cacheRates(any())).thenAnswer((_) async {});

        final snapshot = await repository.getLatestRates();

        // Live data, not the cache fallback.
        expect(snapshot.isFromCache, isFalse);
        expect(snapshot.rates, hasLength(5));
        verifyNever(() => local.getCachedRates());
        verify(() => local.cacheRates(todayBody)).called(1);

        // Rates are real; only the day-over-day comparison is missing.
        final usd = snapshot.rates.firstWhere((r) => r.code == 'USD');
        expect(usd.rate, closeTo(50, 1e-9));
        expect(usd.dailyChange.amount, 0);
        expect(usd.dailyChange.percent, 0);
      },
    );

    test('ServerException is rethrown and the cache is not touched', () async {
      when(
        () => remote.fetchLatestRates(),
      ).thenThrow(const ServerException());
      when(
        () => remote.fetchRatesForDate(any()),
      ).thenAnswer((_) async => yesterdayBody);

      await expectLater(
        repository.getLatestRates(),
        throwsA(isA<ServerException>()),
      );
      verifyNever(() => local.getCachedRates());
      verifyNever(() => local.cacheRates(any()));
    });
  });

  group('getLatestRates — empty cache', () {
    test('offline + empty cache throws CacheException', () async {
      when(() => networkInfo.isConnected).thenAnswer((_) async => false);
      when(
        () => local.getCachedRates(),
      ).thenThrow(const CacheException('No cached rates available'));

      await expectLater(
        repository.getLatestRates(),
        throwsA(isA<CacheException>()),
      );
    });

    test('online + NetworkException + empty cache throws CacheException',
        () async {
      when(() => networkInfo.isConnected).thenAnswer((_) async => true);
      when(
        () => remote.fetchLatestRates(),
      ).thenThrow(const NetworkException());
      when(
        () => remote.fetchRatesForDate(any()),
      ).thenAnswer((_) async => yesterdayBody);
      when(
        () => local.getCachedRates(),
      ).thenThrow(const CacheException('No cached rates available'));

      await expectLater(
        repository.getLatestRates(),
        throwsA(isA<CacheException>()),
      );
    });
  });

  group('getRatesForDate', () {
    test('calls the remote directly, inverts rates, and does not cache',
        () async {
      final date = DateTime(2026, 9, 1);
      when(() => remote.fetchRatesForDate(date)).thenAnswer(
        (_) async => <String, dynamic>{
          'date': '2026-09-01',
          'egp': {'usd': 0.02, 'eur': 0.04},
        },
      );

      final result = await repository.getRatesForDate(date);

      expect(result.keys, containsAll(<String>['usd', 'eur']));
      expect(result['usd'], closeTo(50, 1e-9));
      expect(result['eur'], closeTo(25, 1e-9));

      verify(() => remote.fetchRatesForDate(date)).called(1);
      verifyNever(() => networkInfo.isConnected);
      verifyNever(() => local.getCachedRates());
      verifyNever(() => local.cacheRates(any()));
    });
  });
}
