import 'package:authentication_repository/authentication_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/di/injector.dart';
import '../cubit/home_cubit.dart';
import '../widgets/connection_card.dart';
import '../widgets/log_pane.dart';
import '../widgets/message_pane.dart';
import '../widgets/prompt_card.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<HomeCubit, HomeState>(
      listenWhen: (p, c) => p.status != c.status || p.lastError != c.lastError,
      listener: (context, state) {
        final status = state.status;
        final lastError = state.lastError;
        if (status == HomeStatus.error) {
          if (lastError != null && lastError.isNotEmpty) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(SnackBar(content: Text(lastError)));
          }
        }
      },
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        behavior: HitTestBehavior.translucent,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Realtime Playground'),
            actions: [
              TextButton(
                onPressed: () => getIt<AuthenticationRepository>().logOut(),
                child: const Text('Logout'),
              ),
            ],
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: const [
                  ConnectionCard(),
                  SizedBox(height: 12),
                  PromptCard(),
                  SizedBox(height: 12),
                  MessagePane(),
                  SizedBox(height: 12),
                  LogPane(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
