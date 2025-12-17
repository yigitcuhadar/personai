import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:openai_realtime/openai_realtime.dart';

import '../cubit/home_cubit.dart';
import 'home_card_styles.dart';
import 'status_badge.dart';

class ConnectionCard extends StatelessWidget {
  const ConnectionCard({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      buildWhen: (p, c) => p.status != c.status,
      builder: (context, state) {
        final isCollapsed = state.status == HomeStatus.connected || state.status == HomeStatus.disconnecting;
        return Material(
          elevation: 3,
          borderRadius: BorderRadius.circular(kHomeCardRadius),
          clipBehavior: Clip.antiAlias,
          child: AnimatedSize(
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
            alignment: Alignment.topCenter,
            child: Container(
              padding: EdgeInsets.all(kHomeCardPadding),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFF6F7FB), Color(0xFFF2F8F2)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: isCollapsed ? const _CollapsedConnectionContent() : const _ExpandedConnectionContent(),
            ),
          ),
        );
      },
    );
  }
}

class _ExpandedConnectionContent extends StatelessWidget {
  const _ExpandedConnectionContent();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: const [
        _ConnectionHeader(),
        SizedBox(height: 10),
        _ApiKeyField(),
        SizedBox(height: 8),
        _ModelDropdown(),
        SizedBox(height: 8),
        _InstructionsField(),
        SizedBox(height: 8),
        _VoiceDropdown(),
        SizedBox(height: 8),
        _VerboseLoggingSwitch(),
        SizedBox(height: 8),
        _ConnectButtons(),
      ],
    );
  }
}

class _CollapsedConnectionContent extends StatelessWidget {
  const _CollapsedConnectionContent();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _ConnectionHeader(),
        SizedBox(height: 8),
        _ConnectButtons(),
      ],
    );
  }
}

class _ConnectionHeader extends StatelessWidget {
  const _ConnectionHeader();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      buildWhen: (p, c) => p.status != c.status,
      builder: (context, state) {
        final info = _connectionStatusInfo(state.status);
        return Row(
          children: [
            const Expanded(
              child: Text(
                'Connection setup',
                style: kHomeCardTitleTextStyle,
              ),
            ),
            StatusBadge(
              label: info.label,
              color: info.color,
              showDot: true,
            ),
          ],
        );
      },
    );
  }
}

class _ConnectionStatusInfo {
  const _ConnectionStatusInfo(this.label, this.color);

  final String label;
  final Color color;
}

_ConnectionStatusInfo _connectionStatusInfo(HomeStatus status) {
  switch (status) {
    case HomeStatus.connected:
      return const _ConnectionStatusInfo('Connected', Colors.green);
    case HomeStatus.connecting:
      return const _ConnectionStatusInfo('Connecting', Colors.orange);
    case HomeStatus.disconnecting:
      return const _ConnectionStatusInfo('Disconnecting', Colors.orange);
    case HomeStatus.error:
      return const _ConnectionStatusInfo('Error', Colors.red);
    case HomeStatus.initial:
      return const _ConnectionStatusInfo('Ready', Colors.blueGrey);
  }
}

class _ApiKeyField extends StatelessWidget {
  const _ApiKeyField();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      buildWhen: (p, c) => p.apiKey.displayError != c.apiKey.displayError || p.status != c.status,
      builder: (context, state) {
        final displayError = state.apiKey.displayError;
        final isEnabled = state.status == HomeStatus.initial || state.status == HomeStatus.error;
        return TextFormField(
          key: ValueKey('api-key-field'),
          initialValue: state.apiKey.value,
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
    );
  }
}

class _ModelDropdown extends StatelessWidget {
  const _ModelDropdown();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      buildWhen: (p, c) => p.model.displayError != c.model.displayError || p.status != c.status || p.model.value != c.model.value,
      builder: (context, state) {
        final displayError = state.model.displayError;
        final isEnabled = state.status == HomeStatus.initial || state.status == HomeStatus.error;
        final value = state.model.value.isNotEmpty ? state.model.value : realtimeModelNames.first;
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
    );
  }
}

class _InstructionsField extends StatelessWidget {
  const _InstructionsField();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      buildWhen: (p, c) => p.instructions != c.instructions || p.status != c.status,
      builder: (context, state) {
        final isEnabled = state.status == HomeStatus.initial || state.status == HomeStatus.error;
        return TextFormField(
          key: const ValueKey('instructions-field'),
          autocorrect: false,
          initialValue: state.instructions.value,
          enabled: isEnabled,
          minLines: 2,
          maxLines: 4,
          onChanged: (value) => context.read<HomeCubit>().onInstructionsChanged(value),
          decoration: const InputDecoration(
            labelText: 'Instructions (optional)',
            hintText: 'Assistant behavior...',
          ),
        );
      },
    );
  }
}

class _VoiceDropdown extends StatelessWidget {
  const _VoiceDropdown();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      buildWhen: (p, c) => p.voice != c.voice || p.status != c.status,
      builder: (context, state) {
        final isEnabled = state.status == HomeStatus.initial || state.status == HomeStatus.error;
        final value = state.voice.value.isNotEmpty ? state.voice.value : realtimeFavoriteVoices.first;
        return DropdownButtonFormField<String>(
          key: const ValueKey('voice-dropdown'),
          initialValue: value,
          onChanged: isEnabled
              ? (value) => context.read<HomeCubit>().onVoiceChanged(
                  value ?? realtimeFavoriteVoices.first,
                )
              : null,
          decoration: const InputDecoration(labelText: 'Voice'),
          items: realtimeVoiceNames
              .map(
                (voice) => DropdownMenuItem<String>(
                  value: voice,
                  child: Row(
                    children: [
                      Text(voice),
                      if (realtimeFavoriteVoices.contains(voice)) ...[
                        const SizedBox(width: 6),
                        const Icon(Icons.star, size: 14, color: Colors.amber),
                      ],
                    ],
                  ),
                ),
              )
              .toList(),
        );
      },
    );
  }
}

class _VerboseLoggingSwitch extends StatelessWidget {
  const _VerboseLoggingSwitch();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      buildWhen: (p, c) => p.debugLogging != c.debugLogging || p.status != c.status,
      builder: (context, state) {
        final debugLogging = state.debugLogging;
        final status = state.status;
        final isEnabled = status == HomeStatus.initial || status == HomeStatus.error;
        return SwitchListTile(
          value: debugLogging,
          contentPadding: EdgeInsets.zero,
          title: const Text('Verbose logging'),
          subtitle: const Text('Print SDK, HTTP, and event traffic'),
          onChanged: isEnabled ? (value) => context.read<HomeCubit>().setDebugLogging(value) : null,
        );
      },
    );
  }
}

class _ConnectButtons extends StatelessWidget {
  const _ConnectButtons();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        Expanded(child: _ConnectButton()),
        SizedBox(width: 8),
        Expanded(child: _DisconnectButton()),
      ],
    );
  }
}

class _ConnectButton extends StatelessWidget {
  const _ConnectButton();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      buildWhen: (p, c) => p.status != c.status || p.apiKey != c.apiKey || p.model != c.model,
      builder: (context, state) {
        final status = state.status;
        final isEnabled = status == HomeStatus.initial || status == HomeStatus.error;
        final isValid = state.apiKey.isValid && state.model.isValid;
        final isConnecting = status == HomeStatus.connecting;
        return ElevatedButton.icon(
          onPressed: isEnabled && isValid ? () => context.read<HomeCubit>().connect() : null,
          icon: const Icon(Icons.play_arrow),
          label: Text(
            isConnecting ? 'Connecting...' : 'Connect',
          ),
        );
      },
    );
  }
}

class _DisconnectButton extends StatelessWidget {
  const _DisconnectButton();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
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
    );
  }
}
