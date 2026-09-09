import 'package:currency_exchange_tracker/core/error/exceptions.dart';
import 'package:currency_exchange_tracker/features/exchange_rates/domain/usecases/get_latest_rates.dart';
import 'package:currency_exchange_tracker/features/exchange_rates/presentation/bloc/exchange_rates/exchange_rates_event.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'exchange_rates_state.dart';

class ExchangeRatesBloc extends Bloc<ExchangeRatesEvent, ExchangeRatesState> {
  final GetLatestRates getLatestRates;

  ExchangeRatesBloc(this.getLatestRates) : super(ExchangeRatesInitial()) {
    on<ExchangeRatesStarted>(_onStarted);
    on<ExchangeRatesRefreshed>(_onRefreshed);
  }

  Future<void> _onStarted(ExchangeRatesStarted event,
      Emitter<ExchangeRatesState> emit,) async {
    emit(ExchangeRatesLoading());
    await _fetchRates(emit);
  }

  Future<void> _onRefreshed(ExchangeRatesRefreshed event,
      Emitter<ExchangeRatesState> emit,) async {
    await _fetchRates(emit);
  }

  Future<void> _fetchRates(Emitter<ExchangeRatesState> emit) async {
    try {
      final rates = await getLatestRates();
      if (rates.isEmpty) {
        emit(ExchangeRatesEmpty());
      } else {
        emit(ExchangeRatesLoaded(rates));
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