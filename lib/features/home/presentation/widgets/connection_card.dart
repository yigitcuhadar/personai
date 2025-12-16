import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:openai_realtime/openai_realtime.dart';

import '../cubit/home_cubit.dart';

class ConnectionCard extends StatelessWidget {
  const ConnectionCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: const [
            _ApiKeyField(),
            SizedBox(height: 8),
            _ModelDropdown(),
            _VerboseLoggingSwitch(),
            _ConnectButtons(),
          ],
        ),
      ),
    );
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
          subtitle: const Text('SDK, HTTP ve event trafiğini yazdır'),
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
