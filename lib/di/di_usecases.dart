import 'package:get_it/get_it.dart';
import 'package:currency_exchange_tracker/features/exchange_rates/domain/usecases/get_latest_rates.dart';
import 'package:currency_exchange_tracker/features/exchange_rates/domain/usecases/get_historical_rates.dart';

void initUsecaseDependencies(GetIt sl) {
  sl.registerLazySingleton(() => GetLatestRates(sl()));
  sl.registerLazySingleton(() => GetHistoricalRates(sl()));
}
