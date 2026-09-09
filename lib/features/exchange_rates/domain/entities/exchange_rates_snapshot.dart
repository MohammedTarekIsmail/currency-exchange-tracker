import 'package:equatable/equatable.dart';
import 'currency_rate.dart';

class ExchangeRatesSnapshot extends Equatable {
  final List<CurrencyRate> rates;
  final bool isFromCache;
  final DateTime? cachedAt;

  const ExchangeRatesSnapshot({
    required this.rates,
    required this.isFromCache,
    this.cachedAt,
  });

  @override
  List<Object?> get props => [rates, isFromCache, cachedAt];
}
