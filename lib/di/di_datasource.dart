import 'package:get_it/get_it.dart';
import 'package:currency_exchange_tracker/features/exchange_rates/data/datasources/exchange_rates_local_data_source.dart';
import 'package:currency_exchange_tracker/features/exchange_rates/data/datasources/exchange_rates_remote_data_source.dart';

void initDataSourceDependencies(GetIt sl) {
  sl.registerLazySingleton<ExchangeRatesRemoteDataSource>(
    () => ExchangeRatesRemoteDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<ExchangeRatesLocalDataSource>(
    () => ExchangeRatesLocalDataSourceImpl(sl()),
  );
}
