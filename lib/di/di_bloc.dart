import 'package:get_it/get_it.dart';
import 'package:currency_exchange_tracker/features/exchange_rates/presentation/bloc/exchange_rates_bloc.dart';

void initBlocDependencies(GetIt sl) {
  sl.registerFactory(() => ExchangeRatesBloc(sl()));
}
