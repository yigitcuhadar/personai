import 'package:authentication_repository/authentication_repository.dart';
import 'package:get_it/get_it.dart';

import '../config/app_config.dart';

final GetIt getIt = GetIt.instance;

Future<void> setupDependencies(AppConfig config) async {
  // Config
  getIt.registerSingleton<AppConfig>(config);

  // Repositories
  getIt.registerLazySingleton<AuthenticationRepository>(() => FirebaseAuthenticationRepository());
}
