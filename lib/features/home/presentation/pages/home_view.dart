import 'package:authentication_repository/authentication_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/di/injector.dart';
import 'package:openai_realtime/openai_realtime.dart';
import '../cubit/home_cubit.dart';
import '../models/log_entry.dart';

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
              buildWhen: (p, c) =>
                  p.apiKey.displayError != c.apiKey.displayError ||
                  p.status != c.status,
              builder: (context, state) {
                final displayError = state.apiKey.displayError;
                final isEnabled =
                    state.status == HomeStatus.initial ||
                    state.status == HomeStatus.error;
                return TextFormField(
                  enabled: isEnabled,
                  autocorrect: false,
                  onChanged: (value) =>
                      context.read<HomeCubit>().onApiKeyChanged(value),
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
              buildWhen: (p, c) =>
                  p.model.displayError != c.model.displayError ||
                  p.status != c.status ||
                  p.model.value != c.model.value,
              builder: (context, state) {
                final displayError = state.model.displayError;
                final isEnabled =
                    state.status == HomeStatus.initial ||
                    state.status == HomeStatus.error;
                final value = state.model.value.isNotEmpty
                    ? state.model.value
                    : realtimeModelNames.first;
                return DropdownButtonFormField<String>(
                  key: const ValueKey('model-dropdown'),
                  initialValue: value,
                  items: realtimeModelNames
                      .map(
                        (model) => DropdownMenuItem<String>(
                          value: model,
                          child: Text(model),
                        ),
                      )
                      .toList(),
                  onChanged: isEnabled
                      ? (value) => context.read<HomeCubit>().onModelChanged(
                          value ?? realtimeModelNames.first,
                        )
                      : null,
                  decoration: InputDecoration(
                    labelText: 'Model',
                    errorText: displayError,
                  ),
                );
              },
            ),
            BlocBuilder<HomeCubit, HomeState>(
              buildWhen: (p, c) =>
                  p.debugLogging != c.debugLogging || p.status != c.status,
              builder: (context, state) {
                final debugLogging = state.debugLogging;
                final status = state.status;
                final isEnabled =
                    status == HomeStatus.initial || status == HomeStatus.error;
                return SwitchListTile(
                  value: debugLogging,
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Verbose logging'),
                  subtitle: const Text('SDK, HTTP ve event trafiğini yazdır'),
                  onChanged: isEnabled
                      ? (value) =>
                            context.read<HomeCubit>().setDebugLogging(value)
                      : null,
                );
              },
            ),
            Row(
              children: [
                Expanded(
                  child: BlocBuilder<HomeCubit, HomeState>(
                    buildWhen: (p, c) =>
                        p.status != c.status ||
                        p.apiKey != c.apiKey ||
                        p.model != c.model,
                    builder: (context, state) {
                      final status = state.status;
                      final isEnabled =
                          status == HomeStatus.initial ||
                          status == HomeStatus.error;
                      final isValid =
                          state.apiKey.isValid && state.model.isValid;
                      return ElevatedButton.icon(
                        onPressed: isEnabled && isValid
                            ? () => context.read<HomeCubit>().connect()
                            : null,
                        icon: const Icon(Icons.play_arrow),
                        label: Text(
                          status == HomeStatus.connecting
                              ? 'Connecting...'
                              : 'Connect',
                        ),
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
                      final isDisconnecting =
                          status == HomeStatus.disconnecting;
                      return OutlinedButton.icon(
                        onPressed: isEnabled
                            ? () => context.read<HomeCubit>().disconnect()
                            : null,
                        icon: const Icon(Icons.stop),
                        label: Text(
                          isDisconnecting ? 'Disconnecting...' : 'Disconnect',
                        ),
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
              buildWhen: (p, c) =>
                  p.prompt.displayError != c.prompt.displayError ||
                  p.status != c.status,
              builder: (context, state) {
                final displayError = state.prompt.displayError;
                final isConnected = state.status == HomeStatus.connected;
                return TextFormField(
                  autocorrect: false,
                  onChanged: (value) =>
                      context.read<HomeCubit>().onPromptChanged(value),
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
                buildWhen: (p, c) =>
                    p.prompt.isValid != c.prompt.isValid ||
                    p.status != c.status,
                builder: (context, state) {
                  final isPromptValid = state.prompt.isValid;
                  final isConnected = state.status == HomeStatus.connected;
                  final isBusy =
                      state.status == HomeStatus.connecting ||
                      state.status == HomeStatus.disconnecting;
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
      buildWhen: (p, c) => p.logs != c.logs || p.logsReversed != c.logsReversed,
      builder: (context, state) {
        final logs = state.logsReversed
            ? state.logs.reversed.toList()
            : state.logs;
        return Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Loglar',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Sırayı ters çevir',
                      icon: Icon(
                        state.logsReversed
                            ? Icons.arrow_downward
                            : Icons.arrow_upward,
                      ),
                      onPressed: () =>
                          context.read<HomeCubit>().toggleLogsOrder(),
                    ),
                    IconButton(
                      tooltip: 'Temizle',
                      icon: const Icon(Icons.delete_outline),
                      onPressed: logs.isEmpty
                          ? null
                          : () => context.read<HomeCubit>().clearLogs(),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (logs.isEmpty)
                  const Center(child: Text('Henüz etkinlik yok.'))
                else
                  ListView.separated(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: logs.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final entry = logs[index];
                      return _LogEntryTile(entry: entry);
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _LogEntryTile extends StatelessWidget {
  const _LogEntryTile({required this.entry});

  final LogEntry entry;

  @override
  Widget build(BuildContext context) {
    final isServer = entry.direction == LogDirection.server;
    final alignment = isServer ? Alignment.centerLeft : Alignment.centerRight;
    final color = isServer ? Colors.blue.shade50 : Colors.green.shade50;
    final borderColor = Colors.grey.shade300;

    return Align(
      alignment: alignment,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: borderColor),
          ),
          child: Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              tilePadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              title: _LogEntryHeader(entry: entry),
              trailing: Icon(Icons.expand_more, color: Colors.grey.shade700),
              children: _buildDetails(),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildDetails() {
    final items = <Widget>[];
    for (var i = 0; i < entry.details.length; i++) {
      final detail = entry.details[i];
      if (entry.count > 1) {
        items.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 6, top: 8),
            child: Text(
              'Event ${i + 1} • ${formatElapsed(detail.elapsedSinceSession)}',
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
            ),
          ),
        );
      }
      items.add(
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: SelectableText(
            prettyPrintJson(detail.payload),
            style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
          ),
        ),
      );
      if (i != entry.details.length - 1) {
        items.add(const SizedBox(height: 12));
      }
    }
    return items;
  }
}

class _LogEntryHeader extends StatelessWidget {
  const _LogEntryHeader({required this.entry});

  final LogEntry entry;

  @override
  Widget build(BuildContext context) {
    final label = entry.count > 1
        ? '${entry.type} (${entry.count})'
        : entry.type;
    final elapsed = formatElapsed(entry.latest.elapsedSinceSession);
    String directionLabel;
    Color directionColor;
    switch (entry.direction) {
      case LogDirection.server:
        directionLabel = 'Server';
        directionColor = Colors.blue;
        break;
      case LogDirection.client:
        directionLabel = 'Client';
        directionColor = Colors.green;
        break;
    }

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          decoration: BoxDecoration(
            color: directionColor.withAlpha(30),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            directionLabel,
            style: TextStyle(
              color: directionColor,
              fontWeight: FontWeight.w600,
              fontSize: 10,
            ),
          ),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 10),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          elapsed,
          style: TextStyle(fontSize: 10, color: Colors.grey.shade700),
        ),
      ],
    );
  }
}
