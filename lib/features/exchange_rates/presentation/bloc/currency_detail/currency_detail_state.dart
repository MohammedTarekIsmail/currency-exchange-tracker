import 'package:currency_exchange_tracker/features/exchange_rates/domain/entities/historical_rate_point.dart';
import 'package:equatable/equatable.dart';

abstract class CurrencyDetailState extends Equatable {
  const CurrencyDetailState();

  @override
  List<Object?> get props => [];
}

class CurrencyDetailInitial extends CurrencyDetailState {}

class ChartLoading extends CurrencyDetailState {}

class ChartLoaded extends CurrencyDetailState {
  final List<HistoricalRatePoint> points;

  const ChartLoaded(this.points);

  @override
  List<Object?> get props => [points];
}

class ChartError extends CurrencyDetailState {
  final String message;

  const ChartError(this.message);

  @override
  List<Object?> get props => [message];
}
