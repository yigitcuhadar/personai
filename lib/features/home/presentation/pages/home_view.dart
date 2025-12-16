import 'package:authentication_repository/authentication_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/di/injector.dart';
import '../cubit/home_cubit.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<HomeCubit, HomeState>(
      listenWhen: (p, c) => p.status != c.status,
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
                children: [
                  const _ConnectionCard(),
                  const SizedBox(height: 12),
                  const _PromptCard(),
                  const SizedBox(height: 12),
                  const _LogPane(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ConnectionCard extends StatelessWidget {
  const _ConnectionCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            BlocBuilder<HomeCubit, HomeState>(
              buildWhen: (p, c) => p.apiKey.displayError != c.apiKey.displayError || p.status != c.status,
              builder: (context, state) {
                final displayError = state.apiKey.displayError;
                final isEnabled = state.status == HomeStatus.initial || state.status == HomeStatus.error;
                return TextFormField(
                  enabled: isEnabled,
                  autocorrect: false,
                  onChanged: (value) => context.read<HomeCubit>().onApiKeyChanged(value),
                  decoration: InputDecoration(
                    labelText: 'OpenAI API Key',
                    hintText: 'sk-...',
                    errorText: displayError,
                  ),
                  obscureText: true,
                  autofillHints: const [AutofillHints.password],
                );
              },
            ),
            const SizedBox(height: 8),
            BlocBuilder<HomeCubit, HomeState>(
              buildWhen: (p, c) => p.model.displayError != p.model.displayError || p.status != c.status,
              builder: (context, state) {
                final displayError = state.model.displayError;
                final isEnabled = state.status == HomeStatus.initial || state.status == HomeStatus.error;
                return TextFormField(
                  enabled: isEnabled,
                  autocorrect: false,
                  onChanged: (value) => context.read<HomeCubit>().onModelChanged(value),
                  initialValue: 'gpt-realtime',
                  decoration: InputDecoration(
                    labelText: 'Model',
                    hintText: 'gpt-realtime',
                    errorText: displayError,
                  ),
                );
              },
            ),
            BlocBuilder<HomeCubit, HomeState>(
              buildWhen: (p, c) => p.debugLogging != c.debugLogging || p.status != c.status,
              builder: (context, state) {
                final debugLogging = state.debugLogging;
                final status = state.status;
                final isEnabled = status == HomeStatus.initial || status == HomeStatus.error;
                return SwitchListTile(
                  value: debugLogging,
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Verbose logging'),
                  subtitle: const Text('SDK, HTTP ve event trafiğini yazdır'),
                  onChanged: isEnabled ? (value) => context.read<HomeCubit>().setDebugLogging(value) : null,
                );
              },
            ),
            Row(
              children: [
                Expanded(
                  child: BlocBuilder<HomeCubit, HomeState>(
                    buildWhen: (p, c) => p.status != c.status || p.apiKey != c.apiKey || p.model != c.model,
                    builder: (context, state) {
                      final status = state.status;
                      final isEnabled = status == HomeStatus.initial || status == HomeStatus.error;
                      final isValid = state.apiKey.isValid && state.model.isValid;
                      return ElevatedButton.icon(
                        onPressed: isEnabled && isValid ? () => context.read<HomeCubit>().connect() : null,
                        icon: const Icon(Icons.play_arrow),
                        label: Text(status == HomeStatus.connecting ? 'Connecting...' : 'Connect'),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: BlocBuilder<HomeCubit, HomeState>(
                    buildWhen: (p, c) => p.status != c.status,
                    builder: (context, state) {
                      final status = state.status;
                      final isEnabled = status == HomeStatus.connected;
                      final isDisconnecting = status == HomeStatus.disconnecting;
                      return OutlinedButton.icon(
                        onPressed: isEnabled ? () => context.read<HomeCubit>().disconnect() : null,
                        icon: const Icon(Icons.stop),
                        label: Text(isDisconnecting ? 'Disconnecting...' : 'Disconnect'),
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PromptCard extends StatelessWidget {
  const _PromptCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            BlocBuilder<HomeCubit, HomeState>(
              buildWhen: (p, c) => p.prompt.displayError != c.prompt.displayError || p.status != c.status,
              builder: (context, state) {
                final displayError = state.prompt.displayError;
                final isConnected = state.status == HomeStatus.connected;
                return TextFormField(
                  autocorrect: false,
                  onChanged: (value) => context.read<HomeCubit>().onPromptChanged(value),
                  minLines: 2,
                  maxLines: 6,
                  decoration: InputDecoration(
                    labelText: 'Prompt',
                    hintText: 'Bugün hava nasıl?',
                    errorText: displayError,
                  ),
                  onFieldSubmitted: isConnected
                      ? (_) {
                          context.read<HomeCubit>().sendPrompt();
                          FocusScope.of(context).unfocus();
                        }
                      : null,
                );
              },
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: BlocBuilder<HomeCubit, HomeState>(
                buildWhen: (p, c) => p.prompt.isValid != c.prompt.isValid || p.status != c.status,
                builder: (context, state) {
                  final isPromptValid = state.prompt.isValid;
                  final isConnected = state.status == HomeStatus.connected;
                  final isBusy = state.status == HomeStatus.connecting || state.status == HomeStatus.disconnecting;
                  return ElevatedButton.icon(
                    onPressed: isPromptValid && isConnected && !isBusy
                        ? () {
                            context.read<HomeCubit>().sendPrompt();
                            FocusScope.of(context).unfocus();
                          }
                        : null,
                    icon: const Icon(Icons.send),
                    label: const Text('Send'),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LogPane extends StatelessWidget {
  const _LogPane();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      buildWhen: (p, c) => p.logs != c.logs,
      builder: (context, state) {
        final logs = state.logs;
        return Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: logs.isEmpty
                ? const Center(child: Text('Henüz etkinlik yok.'))
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: logs.length,
                    itemBuilder: (context, index) {
                      final entry = logs[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Text(entry),
                      );
                    },
                  ),
          ),
        );
      },
    );
  }
}
