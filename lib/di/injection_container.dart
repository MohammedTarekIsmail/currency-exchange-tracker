import 'package:get_it/get_it.dart';
import 'di_app.dart';
import 'di_bloc.dart';
import 'di_datasource.dart';
import 'di_repository.dart';
import 'di_usecases.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  await initAppDependencies(sl);
  initDataSourceDependencies(sl);
  initRepositoryDependencies(sl);
  initUsecaseDependencies(sl);
  initBlocDependencies(sl);
}
