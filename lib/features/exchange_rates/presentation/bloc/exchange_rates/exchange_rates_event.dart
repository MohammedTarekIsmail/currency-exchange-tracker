import 'package:equatable/equatable.dart';

abstract class ExchangeRatesEvent extends Equatable {
  const ExchangeRatesEvent();

  @override
  List<Object?> get props => [];
}

class ExchangeRatesStarted extends ExchangeRatesEvent {}

class ExchangeRatesRefreshed extends ExchangeRatesEvent {}
