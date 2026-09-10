import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:currency_exchange_tracker/core/error/exceptions.dart';
import 'package:currency_exchange_tracker/core/network/network_info.dart';
import 'package:currency_exchange_tracker/features/exchange_rates/domain/entities/currency_rate.dart';
import 'package:currency_exchange_tracker/features/exchange_rates/domain/entities/daily_change.dart';
import 'package:currency_exchange_tracker/features/exchange_rates/domain/entities/exchange_rates_snapshot.dart';
import 'package:currency_exchange_tracker/features/exchange_rates/domain/usecases/get_latest_rates.dart';
import 'package:currency_exchange_tracker/features/exchange_rates/presentation/bloc/exchange_rates/exchange_rates_bloc.dart';
import 'package:currency_exchange_tracker/features/exchange_rates/presentation/bloc/exchange_rates/exchange_rates_event.dart';
import 'package:currency_exchange_tracker/features/exchange_rates/presentation/bloc/exchange_rates/exchange_rates_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockGetLatestRates extends Mock implements GetLatestRates {}

class _MockNetworkInfo extends Mock implements NetworkInfo {}

void main() {
  late _MockGetLatestRates getLatestRates;
  late _MockNetworkInfo networkInfo;
  late StreamController<bool> connectivity;

  setUp(() {
    getLatestRates = _MockGetLatestRates();
    networkInfo = _MockNetworkInfo();
    // The bloc subscribes to this in its constructor; keep it silent so the
    // auto-refresh-on-reconnect path never fires during these tests.
    when(
      () => networkInfo.onConnectivityChanged,
    ).thenAnswer((_) => const Stream<bool>.empty());
  });

  ExchangeRatesBloc buildBloc() =>
      ExchangeRatesBloc(getLatestRates, networkInfo);

  final tRates = [
    CurrencyRate(
      code: 'USD',
      name: 'US Dollar',
      rate: 50,
      dailyChange: const DailyChange(amount: 1, percent: 2),
      lastUpdated: DateTime(2026, 9, 10),
    ),
  ];
  final tLoadedSnapshot = ExchangeRatesSnapshot(
    rates: tRates,
    isFromCache: false,
  );
  const tEmptySnapshot = ExchangeRatesSnapshot(rates: [], isFromCache: false);

  group('ExchangeRatesStarted', () {
    blocTest<ExchangeRatesBloc, ExchangeRatesState>(
      'emits [Loading, Loaded] when the use case returns rates',
      setUp: () =>
          when(() => getLatestRates()).thenAnswer((_) async => tLoadedSnapshot),
      build: buildBloc,
      act: (bloc) => bloc.add(ExchangeRatesStarted()),
      expect: () => [ExchangeRatesLoading(), ExchangeRatesLoaded(tRates)],
    );

    blocTest<ExchangeRatesBloc, ExchangeRatesState>(
      'emits [Loading, Empty] when the use case returns no rates',
      setUp: () =>
          when(() => getLatestRates()).thenAnswer((_) async => tEmptySnapshot),
      build: buildBloc,
      act: (bloc) => bloc.add(ExchangeRatesStarted()),
      expect: () => [ExchangeRatesLoading(), ExchangeRatesEmpty()],
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
      'CacheException': (
        error: const CacheException('cache empty'),
        message: 'cache empty',
      ),
      'unexpected error': (
        error: Exception('boom'),
        message: 'Something went wrong. Please try again.',
      ),
    };

    errorCases.forEach((name, c) {
      blocTest<ExchangeRatesBloc, ExchangeRatesState>(
        'emits [Loading, Error] on $name',
        setUp: () => when(() => getLatestRates()).thenThrow(c.error),
        build: buildBloc,
        act: (bloc) => bloc.add(ExchangeRatesStarted()),
        expect: () => [ExchangeRatesLoading(), ExchangeRatesError(c.message)],
      );
    });
  });

  group('ExchangeRatesConnectivityChanged', () {
    blocTest<ExchangeRatesBloc, ExchangeRatesState>(
      'losing the connection flags what is on screen without refetching',
      build: buildBloc,
      seed: () => ExchangeRatesLoaded(tRates),
      act: (bloc) => bloc.add(const ExchangeRatesConnectivityChanged(false)),
      expect: () => [ExchangeRatesLoaded(tRates, isOffline: true)],
      verify: (_) => verifyNever(() => getLatestRates()),
    );

    blocTest<ExchangeRatesBloc, ExchangeRatesState>(
      'emits nothing when there are no rates on screen to flag',
      build: buildBloc,
      act: (bloc) => bloc.add(const ExchangeRatesConnectivityChanged(false)),
      expect: () => <ExchangeRatesState>[],
    );

    blocTest<ExchangeRatesBloc, ExchangeRatesState>(
      'reconnecting clears the flag and refetches',
      setUp: () => when(
        () => getLatestRates(),
      ).thenAnswer((_) async => tLoadedSnapshot),
      build: buildBloc,
      seed: () => ExchangeRatesLoaded(tRates),
      act: (bloc) => bloc
        ..add(const ExchangeRatesConnectivityChanged(false))
        ..add(const ExchangeRatesConnectivityChanged(true)),
      expect: () => [
        ExchangeRatesLoaded(tRates, isOffline: true),
        ExchangeRatesLoaded(tRates),
      ],
      verify: (_) => verify(() => getLatestRates()).called(1),
    );

    blocTest<ExchangeRatesBloc, ExchangeRatesState>(
      'a connected event while already online does not refetch',
      build: buildBloc,
      seed: () => ExchangeRatesLoaded(tRates),
      act: (bloc) => bloc.add(const ExchangeRatesConnectivityChanged(true)),
      expect: () => <ExchangeRatesState>[],
      verify: (_) => verifyNever(() => getLatestRates()),
    );

    blocTest<ExchangeRatesBloc, ExchangeRatesState>(
      'the NetworkInfo stream is what drives all of the above',
      setUp: () {
        connectivity = StreamController<bool>();
        when(
          () => networkInfo.onConnectivityChanged,
        ).thenAnswer((_) => connectivity.stream);
      },
      build: buildBloc,
      seed: () => ExchangeRatesLoaded(tRates),
      act: (_) async {
        connectivity.add(false);
        await Future<void>.delayed(Duration.zero);
      },
      tearDown: () => connectivity.close(),
      expect: () => [ExchangeRatesLoaded(tRates, isOffline: true)],
    );
  });

  group('ExchangeRatesRefreshed', () {
    blocTest<ExchangeRatesBloc, ExchangeRatesState>(
      'emits only [Loaded] — no Loading spinner on a manual refresh',
      setUp: () =>
          when(() => getLatestRates()).thenAnswer((_) async => tLoadedSnapshot),
      build: buildBloc,
      act: (bloc) => bloc.add(ExchangeRatesRefreshed()),
      expect: () => [ExchangeRatesLoaded(tRates)],
    );

    group('completer (the future RefreshIndicator waits on)', () {
      late Completer<void> completer;

      setUp(() {
        completer = Completer<void>();
        when(() => getLatestRates()).thenAnswer((_) async => tLoadedSnapshot);
      });

      blocTest<ExchangeRatesBloc, ExchangeRatesState>(
        'completes once the fetch lands',
        build: buildBloc,
        act: (bloc) => bloc.add(ExchangeRatesRefreshed(completer: completer)),
        verify: (_) => expect(completer.isCompleted, isTrue),
      );

      blocTest<ExchangeRatesBloc, ExchangeRatesState>(
        'completes even when the refresh emits no new state — rates only change '
        'once a day, so a second pull usually rebuilds an identical Loaded and '
        'Bloc suppresses it',
        build: buildBloc,
        seed: () => ExchangeRatesLoaded(tRates),
        act: (bloc) => bloc.add(ExchangeRatesRefreshed(completer: completer)),
        expect: () => <ExchangeRatesState>[],
        verify: (_) => expect(completer.isCompleted, isTrue),
      );

      blocTest<ExchangeRatesBloc, ExchangeRatesState>(
        'completes when the fetch fails, so the spinner cannot get stuck',
        setUp: () => when(
          () => getLatestRates(),
        ).thenThrow(const ServerException('boom')),
        build: buildBloc,
        act: (bloc) => bloc.add(ExchangeRatesRefreshed(completer: completer)),
        expect: () => [const ExchangeRatesError('boom')],
        verify: (_) => expect(completer.isCompleted, isTrue),
      );
    });
  });
}
