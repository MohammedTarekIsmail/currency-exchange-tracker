import 'package:equatable/equatable.dart';

abstract class CurrencyDetailEvent extends Equatable {
  const CurrencyDetailEvent();

  @override
  List<Object?> get props => [];
}

class FetchHistoricalRates extends CurrencyDetailEvent {
  final String currencyCode;

  const FetchHistoricalRates(this.currencyCode);

  @override
  List<Object?> get props => [currencyCode];
}
