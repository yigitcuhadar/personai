import 'package:authentication_repository/authentication_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/di/injector.dart';
import '../cubit/home_cubit.dart';
import '../widgets/connection_card.dart';
import '../widgets/conversation_pane.dart';
import '../widgets/log_pane.dart';

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
            bottom: false,
            child: LayoutBuilder(
              builder: (context, constraints) {
                const logMinSize = 0.12;
                final bottomPadding =
                    constraints.maxHeight * logMinSize + 16;
                return Stack(
                  children: [
                    Padding(
                      padding: EdgeInsets.fromLTRB(16, 16, 16, bottomPadding),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: const [
                          ConnectionCard(),
                          SizedBox(height: 12),
                          Expanded(child: ConversationPane()),
                        ],
                      ),
                    ),
                    const Align(
                      alignment: Alignment.bottomCenter,
                      child: LogSheet(
                        minChildSize: logMinSize,
                        initialChildSize: 0.22,
                        maxChildSize: 0.7,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
