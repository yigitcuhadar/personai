import 'dart:async';

import 'package:authentication_repository/authentication_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:firebase_core/firebase_core.dart';

import '../features/authentication/presentation/cubit/authentication_bloc.dart';
import '../features/authentication/presentation/pages/login/login_page.dart';
import '../features/home/presentation/pages/home_page.dart';
import '../firebase_options.dart';
import 'config/app_config.dart';
import 'di/injector.dart';

class PersonAIApp {
  final AppConfig config;
  const PersonAIApp({required this.config});

  static Future<void> bootstrap(AppConfig config) async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    final tmpDir = await getTemporaryDirectory();
    final storage = await HydratedStorage.build(storageDirectory: HydratedStorageDirectory(tmpDir.path));
    HydratedBloc.storage = storage;
    await setupDependencies(config);
    final firstUser = await getIt<AuthenticationRepository>().user.first;
    runApp(
      MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => AuthenticationBloc(repository: getIt(), firstUser: firstUser),
          ),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: config.flavor == Flavor.dev,
          home: const AppHome(),
        ),
      ),
    );
  }
}

class AppHome extends StatelessWidget {
  const AppHome({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthenticationBloc, AuthenticationState>(
      buildWhen: (p, c) => p.runtimeType != c.runtimeType,
      builder: (context, state) {
        if (state is AuthenticatedState) {
          return const HomePage();
        } else {
          return const LoginPage();
        }
      },
    );
  }
}
