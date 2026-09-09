import 'package:currency_exchange_tracker/features/exchange_rates/domain/entities/exchange_rates_snapshot.dart';
import 'package:currency_exchange_tracker/features/exchange_rates/domain/repositories/exchange_rates_repository.dart';

/// Fetches the latest rates for the 5 tracked pairs. Takes no parameters — the
/// set of currencies and the base (EGP) are fixed for this app.
class GetLatestRates {
  const GetLatestRates(this._repository);

  final ExchangeRatesRepository _repository;

  Future<ExchangeRatesSnapshot> call() => _repository.getLatestRates();
}
