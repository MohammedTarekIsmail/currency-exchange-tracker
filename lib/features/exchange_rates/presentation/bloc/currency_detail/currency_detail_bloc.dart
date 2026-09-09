import 'package:currency_exchange_tracker/core/error/exceptions.dart';
import 'package:currency_exchange_tracker/features/exchange_rates/domain/usecases/get_historical_rates.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'currency_detail_event.dart';
import 'currency_detail_state.dart';

class CurrencyDetailBloc
    extends Bloc<CurrencyDetailEvent, CurrencyDetailState> {
  final GetHistoricalRates getHistoricalRates;

  CurrencyDetailBloc(this.getHistoricalRates) : super(CurrencyDetailInitial()) {
    on<FetchHistoricalRates>(_onFetchHistoricalRates);
  }

  Future<void> _onFetchHistoricalRates(
    FetchHistoricalRates event,
    Emitter<CurrencyDetailState> emit,
  ) async {
    emit(ChartLoading());
    try {
      final points = await getHistoricalRates(event.currencyCode);
      if (points.isEmpty) {
        emit(
          const ChartError('No historical data available for this currency.'),
        );
      } else {
        emit(ChartLoaded(points));
      }
    } on NetworkException catch (e) {
      emit(ChartError(e.message));
    } on ServerException catch (e) {
      emit(ChartError(e.message));
    } catch (e) {
      emit(const ChartError('Could not load chart data. Please try again.'));
    }
  }
}
