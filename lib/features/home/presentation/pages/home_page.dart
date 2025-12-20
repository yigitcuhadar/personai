import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/config/app_config.dart';
import '../../../../app/di/injector.dart';
import '../cubit/home_cubit.dart';
import 'home_view.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  static Page<void> page() => const MaterialPage<void>(child: HomePage());

  @override
  Widget build(BuildContext context) {
    final config = getIt<AppConfig>();
    return BlocProvider(
      create: (_) => HomeCubit(
        config: config,
        defaultApiKey: config.openaiApiKey ?? '',
      ),
      child: const HomeView(),
    );
  }
}
