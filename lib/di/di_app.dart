import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:currency_exchange_tracker/core/network/network_info.dart';

Future<void> initAppDependencies(GetIt sl) async {
  sl.registerLazySingleton(() => Dio());
  sl.registerLazySingleton(() => Connectivity());

  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);

  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl()));
}
