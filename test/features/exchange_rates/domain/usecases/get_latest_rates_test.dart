import 'package:currency_exchange_tracker/core/error/exceptions.dart';
import 'package:currency_exchange_tracker/features/exchange_rates/domain/entities/currency_rate.dart';
import 'package:currency_exchange_tracker/features/exchange_rates/domain/entities/daily_change.dart';
import 'package:currency_exchange_tracker/features/exchange_rates/domain/entities/exchange_rates_snapshot.dart';
import 'package:currency_exchange_tracker/features/exchange_rates/domain/repositories/exchange_rates_repository.dart';
import 'package:currency_exchange_tracker/features/exchange_rates/domain/usecases/get_latest_rates.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockExchangeRatesRepository extends Mock
    implements ExchangeRatesRepository {}

void main() {
  late _MockExchangeRatesRepository repository;
  late GetLatestRates useCase;

  setUp(() {
    repository = _MockExchangeRatesRepository();
    useCase = GetLatestRates(repository);
  });

  final tSnapshot = ExchangeRatesSnapshot(
    rates: [
      CurrencyRate(
        code: 'USD',
        name: 'US Dollar',
        rate: 52.01,
        dailyChange: const DailyChange(amount: -0.12, percent: -0.23),
        lastUpdated: DateTime(2026, 9, 10),
      ),
    ],
    isFromCache: true,
    cachedAt: DateTime(2026, 9, 10, 8, 30),
  );

  test(
    'delegates to the repository once and returns its snapshot unchanged',
    () async {
      when(
        () => repository.getLatestRates(),
      ).thenAnswer((_) async => tSnapshot);

      final result = await useCase();

      expect(result, tSnapshot);
      verify(() => repository.getLatestRates()).called(1);
      verifyNoMoreInteractions(repository);
    },
  );

  group('propagates exceptions from the repository', () {
    for (final exception in <Exception>[
      const NetworkException(),
      const ServerException(),
      const CacheException(),
    ]) {
      test('rethrows ${exception.runtimeType}', () {
        when(() => repository.getLatestRates()).thenThrow(exception);

        expect(() => useCase(), throwsA(same(exception)));
      });
    }
  });
}
