import 'package:bloc_test/bloc_test.dart';
import 'package:currency_exchange_tracker/core/error/exceptions.dart';
import 'package:currency_exchange_tracker/features/exchange_rates/domain/entities/historical_rate_point.dart';
import 'package:currency_exchange_tracker/features/exchange_rates/domain/usecases/get_historical_rates.dart';
import 'package:currency_exchange_tracker/features/exchange_rates/presentation/bloc/currency_detail/currency_detail_bloc.dart';
import 'package:currency_exchange_tracker/features/exchange_rates/presentation/bloc/currency_detail/currency_detail_event.dart';
import 'package:currency_exchange_tracker/features/exchange_rates/presentation/bloc/currency_detail/currency_detail_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockGetHistoricalRates extends Mock implements GetHistoricalRates {}

void main() {
  late _MockGetHistoricalRates getHistoricalRates;

  setUp(() => getHistoricalRates = _MockGetHistoricalRates());

  CurrencyDetailBloc buildBloc() => CurrencyDetailBloc(getHistoricalRates);

  final tPoints = [
    HistoricalRatePoint(date: DateTime(2026, 9, 8), rate: 49.5),
    HistoricalRatePoint(date: DateTime(2026, 9, 9), rate: 50.1),
  ];

  blocTest<CurrencyDetailBloc, CurrencyDetailState>(
    'emits [ChartLoading, ChartLoaded] when the use case returns points',
    setUp: () => when(
      () => getHistoricalRates(any()),
    ).thenAnswer((_) async => tPoints),
    build: buildBloc,
    act: (bloc) => bloc.add(const FetchHistoricalRates('usd')),
    expect: () => [ChartLoading(), ChartLoaded(tPoints)],
  );

  blocTest<CurrencyDetailBloc, CurrencyDetailState>(
    'emits [ChartLoading, ChartError] when the use case returns an empty list',
    setUp: () => when(
      () => getHistoricalRates(any()),
    ).thenAnswer((_) async => []),
    build: buildBloc,
    act: (bloc) => bloc.add(const FetchHistoricalRates('usd')),
    expect: () => [
      ChartLoading(),
      const ChartError('No historical data available for this currency.'),
    ],
  );

  final errorCases = <String, ({Object error, String message})>{
    'NetworkException': (
      error: const NetworkException('no internet'),
      message: 'no internet',
    ),
    'ServerException': (
      error: const ServerException('server exploded'),
      message: 'server exploded',
    ),
    'unexpected error': (
      error: Exception('boom'),
      message: 'Could not load chart data. Please try again.',
    ),
  };

  errorCases.forEach((name, c) {
    blocTest<CurrencyDetailBloc, CurrencyDetailState>(
      'emits [ChartLoading, ChartError] on $name',
      setUp: () => when(() => getHistoricalRates(any())).thenThrow(c.error),
      build: buildBloc,
      act: (bloc) => bloc.add(const FetchHistoricalRates('usd')),
      expect: () => [ChartLoading(), ChartError(c.message)],
    );
  });
}
