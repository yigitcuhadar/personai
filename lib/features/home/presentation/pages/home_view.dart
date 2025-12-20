import 'package:authentication_repository/authentication_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/di/injector.dart';
import '../cubit/home_cubit.dart';
import '../widgets/connection_drawer.dart';
import '../widgets/conversation_card.dart';
import '../widgets/logs_sheet.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  static const double _logMinSize = 0.12;
  static const double _logInitialSize = 0.22;
  static const double _logMaxSize = 0.7;

  @override
  Widget build(BuildContext context) {
    final keyboardInset = MediaQuery.of(context).viewInsets.bottom;
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
          drawer: const ConnectionDrawer(),
          body: SafeArea(
            bottom: false,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final basePadding = constraints.maxHeight * _logMinSize + 16;
                final bottomPadding = keyboardInset > 0 ? 16.0 : basePadding;
                return Stack(
                  children: [
                    Padding(
                      padding: EdgeInsets.fromLTRB(16, 16, 16, bottomPadding),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: const [
                          Expanded(child: ConversationCard()),
                        ],
                      ),
                    ),
                    const Align(
                      alignment: Alignment.bottomCenter,
                      child: LogsSheet(
                        minChildSize: _logMinSize,
                        initialChildSize: _logInitialSize,
                        maxChildSize: _logMaxSize,
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
