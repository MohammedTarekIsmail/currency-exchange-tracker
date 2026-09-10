import 'package:currency_exchange_tracker/core/error/exceptions.dart';
import 'package:currency_exchange_tracker/features/exchange_rates/domain/entities/historical_rate_point.dart';
import 'package:currency_exchange_tracker/features/exchange_rates/domain/repositories/exchange_rates_repository.dart';
import 'package:currency_exchange_tracker/features/exchange_rates/domain/usecases/get_historical_rates.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockExchangeRatesRepository extends Mock
    implements ExchangeRatesRepository {}

void main() {
  late _MockExchangeRatesRepository repository;
  late GetHistoricalRates useCase;

  setUpAll(() => registerFallbackValue(DateTime(2020)));

  setUp(() {
    repository = _MockExchangeRatesRepository();
    useCase = GetHistoricalRates(repository);
  });

  /// Midnight, [n] days before today — the same value the use case derives
  /// internally for the n-th day it requests.
  DateTime dayAgo(int n) {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day).subtract(Duration(days: n));
  }

  group('number of repository calls', () {
    test('calls getRatesForDate once per day in the window', () async {
      when(
        () => repository.getRatesForDate(any()),
      ).thenAnswer((_) async => {'usd': 50.0});

      await useCase('usd', days: 5);

      verify(() => repository.getRatesForDate(any())).called(5);
    });

    test('defaults to a 7-day window', () async {
      when(
        () => repository.getRatesForDate(any()),
      ).thenAnswer((_) async => {'usd': 50.0});

      await useCase('usd');

      verify(() => repository.getRatesForDate(any())).called(7);
    });
  });

  test('extracts only the requested currency, case-insensitively', () async {
    when(
      () => repository.getRatesForDate(dayAgo(0)),
    ).thenAnswer((_) async => {'usd': 50.0, 'eur': 60.0, 'gbp': 70.0});

    final result = await useCase('USD', days: 1);

    expect(result, [HistoricalRatePoint(date: dayAgo(0), rate: 50.0)]);
  });

  test('returns points sorted oldest-first', () async {
    // Repository is queried today-first; the use case must reverse that.
    when(
      () => repository.getRatesForDate(dayAgo(0)),
    ).thenAnswer((_) async => {'usd': 50.0});
    when(
      () => repository.getRatesForDate(dayAgo(1)),
    ).thenAnswer((_) async => {'usd': 51.0});
    when(
      () => repository.getRatesForDate(dayAgo(2)),
    ).thenAnswer((_) async => {'usd': 52.0});

    final result = await useCase('usd', days: 3);

    expect(result, [
      HistoricalRatePoint(date: dayAgo(2), rate: 52.0),
      HistoricalRatePoint(date: dayAgo(1), rate: 51.0),
      HistoricalRatePoint(date: dayAgo(0), rate: 50.0),
    ]);
  });

  test(
    'skips a day whose response is missing the requested currency',
    () async {
      when(
        () => repository.getRatesForDate(dayAgo(0)),
      ).thenAnswer((_) async => {'usd': 50.0});
      when(
        () => repository.getRatesForDate(dayAgo(1)),
      ).thenAnswer((_) async => {'eur': 61.0}); // no usd for this day
      when(
        () => repository.getRatesForDate(dayAgo(2)),
      ).thenAnswer((_) async => {'usd': 52.0});

      final result = await useCase('usd', days: 3);

      expect(result, [
        HistoricalRatePoint(date: dayAgo(2), rate: 52.0),
        HistoricalRatePoint(date: dayAgo(0), rate: 50.0),
      ]);
    },
  );

  group('propagates exceptions from the repository', () {
    for (final exception in <Exception>[
      const NetworkException(),
      const ServerException(),
    ]) {
      test('rethrows ${exception.runtimeType}', () {
        when(() => repository.getRatesForDate(any())).thenThrow(exception);

        expect(() => useCase('usd'), throwsA(same(exception)));
      });
    }
  });
}
