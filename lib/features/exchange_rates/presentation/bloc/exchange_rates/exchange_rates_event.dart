import 'dart:async';

import 'package:equatable/equatable.dart';

abstract class ExchangeRatesEvent extends Equatable {
  const ExchangeRatesEvent();

  @override
  List<Object?> get props => [];
}

class ExchangeRatesStarted extends ExchangeRatesEvent {}

/// Re-fetches without passing through [ExchangeRatesLoading], so the list stays
/// on screen while it refreshes.
class ExchangeRatesRefreshed extends ExchangeRatesEvent {
  const ExchangeRatesRefreshed({this.completer});

  final Completer<void>? completer;

  @override
  List<Object?> get props => [completer];
}

class ExchangeRatesConnectivityChanged extends ExchangeRatesEvent {
  const ExchangeRatesConnectivityChanged(this.isConnected);

  final bool isConnected;

  @override
  List<Object?> get props => [isConnected];
}
