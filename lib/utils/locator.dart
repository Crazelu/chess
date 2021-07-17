import 'package:chess/handlers/handlers.dart';
import 'package:get_it/get_it.dart';

GetIt locator = GetIt.instance;

void registerDependencies() {
  locator.registerLazySingleton<NavigationHandler>(
    () => NavigationHandlerImpl(),
  );
}
