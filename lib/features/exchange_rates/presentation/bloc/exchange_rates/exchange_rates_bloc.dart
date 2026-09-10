import 'dart:async';

import 'package:currency_exchange_tracker/core/error/exceptions.dart';
import 'package:currency_exchange_tracker/core/network/network_info.dart';
import 'package:currency_exchange_tracker/features/exchange_rates/domain/usecases/get_latest_rates.dart';
import 'package:currency_exchange_tracker/features/exchange_rates/presentation/bloc/exchange_rates/exchange_rates_event.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'exchange_rates_state.dart';

class ExchangeRatesBloc extends Bloc<ExchangeRatesEvent, ExchangeRatesState> {
  final GetLatestRates getLatestRates;
  final NetworkInfo networkInfo;

  StreamSubscription<bool>? _connectivitySubscription;
  bool _wasOffline = false;

  ExchangeRatesBloc(this.getLatestRates, this.networkInfo)
    : super(ExchangeRatesInitial()) {
    on<ExchangeRatesStarted>(_onStarted);
    on<ExchangeRatesRefreshed>(_onRefreshed);
    on<ExchangeRatesConnectivityChanged>(_onConnectivityChanged);

    _connectivitySubscription = networkInfo.onConnectivityChanged.listen(
      (isConnected) => add(ExchangeRatesConnectivityChanged(isConnected)),
    );
  }

  @override
  Future<void> close() {
    _connectivitySubscription?.cancel();
    return super.close();
  }

  Future<void> _onStarted(
    ExchangeRatesStarted event,
    Emitter<ExchangeRatesState> emit,
  ) async {
    emit(ExchangeRatesLoading());
    await _fetchRates(emit);
  }

  Future<void> _onRefreshed(
    ExchangeRatesRefreshed event,
    Emitter<ExchangeRatesState> emit,
  ) async {
    try {
      await _fetchRates(emit);
    } finally {
      event.completer?.complete();
    }
  }

  Future<void> _onConnectivityChanged(
    ExchangeRatesConnectivityChanged event,
    Emitter<ExchangeRatesState> emit,
  ) async {
    final reconnected = event.isConnected && _wasOffline;
    _wasOffline = !event.isConnected;

    final current = state;
    if (current is ExchangeRatesLoaded) {
      emit(current.copyWith(isOffline: _wasOffline));
    }

    if (reconnected) {
      await _fetchRates(emit);
    }
  }

  Future<void> _fetchRates(Emitter<ExchangeRatesState> emit) async {
    try {
      final snapshot = await getLatestRates();
      if (snapshot.rates.isEmpty) {
        emit(ExchangeRatesEmpty());
      } else {
        emit(
          ExchangeRatesLoaded(
            snapshot.rates,
            isFromCache: snapshot.isFromCache,
            cachedAt: snapshot.cachedAt,
            isOffline: _wasOffline,
          ),
        );
      }
    } on NetworkException catch (e) {
      emit(ExchangeRatesError(e.message));
    } on ServerException catch (e) {
      emit(ExchangeRatesError(e.message));
    } on CacheException catch (e) {
      emit(ExchangeRatesError(e.message));
    } catch (e) {
      emit(ExchangeRatesError('Something went wrong. Please try again.'));
    }
  }
}
