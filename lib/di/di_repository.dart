import 'package:get_it/get_it.dart';
import 'package:currency_exchange_tracker/features/exchange_rates/data/repositories/exchange_rates_repository_impl.dart';
import 'package:currency_exchange_tracker/features/exchange_rates/domain/repositories/exchange_rates_repository.dart';

void initRepositoryDependencies(GetIt sl) {
  sl.registerLazySingleton<ExchangeRatesRepository>(
    () => ExchangeRatesRepositoryImpl(sl(), sl(), sl()),
  );
}
