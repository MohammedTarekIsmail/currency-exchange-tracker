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

  /// Whether [rates] were served from the offline cache rather than the live
  /// API, and — when they were — the time they were cached.
  final bool isFromCache;
  final DateTime? cachedAt;
  final bool isOffline;

  const ExchangeRatesLoaded(
    this.rates, {
    this.isFromCache = false,
    this.cachedAt,
    this.isOffline = false,
  });

  ExchangeRatesLoaded copyWith({bool? isOffline}) => ExchangeRatesLoaded(
    rates,
    isFromCache: isFromCache,
    cachedAt: cachedAt,
    isOffline: isOffline ?? this.isOffline,
  );

  @override
  List<Object?> get props => [rates, isFromCache, cachedAt, isOffline];
}

class ExchangeRatesError extends ExchangeRatesState {
  final String message;

  const ExchangeRatesError(this.message);

  @override
  List<Object?> get props => [message];
}

class ExchangeRatesEmpty extends ExchangeRatesState {}
