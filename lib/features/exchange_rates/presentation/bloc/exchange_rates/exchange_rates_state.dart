import 'package:currency_exchange_tracker/features/exchange_rates/domain/entities/currency_rate.dart';
import 'package:equatable/equatable.dart';

abstract class ExchangeRatesState extends Equatable {
  const ExchangeRatesState();

  @override
  List<Object?> get props => [];
}

class ExchangeRatesInitial extends ExchangeRatesState {}

class ExchangeRatesLoading extends ExchangeRatesState {}

class ExchangeRatesLoaded extends ExchangeRatesState {
  final List<CurrencyRate> rates;

  const ExchangeRatesLoaded(this.rates);

  @override
  List<Object?> get props => [rates];
}

class ExchangeRatesError extends ExchangeRatesState {
  final String message;

  const ExchangeRatesError(this.message);

  @override
  List<Object?> get props => [message];
}

class ExchangeRatesEmpty extends ExchangeRatesState {}
