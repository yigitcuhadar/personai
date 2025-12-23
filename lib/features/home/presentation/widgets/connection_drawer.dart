import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:openai_realtime/openai_realtime.dart';

import '../cubit/home_cubit.dart';
import '../models/tool_option.dart';
import 'status_badge.dart';

class ConnectionDrawer extends StatelessWidget {
  const ConnectionDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return Drawer(
      width: 380,
      elevation: 14,
      child: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFF7F9FB), Color(0xFFE9F2FF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                top: -60,
                right: -20,
                child: _blurCircle(color: const Color(0x33A5BEE5), size: 160),
              ),
              Positioned(
                bottom: -50,
                left: -10,
                child: _blurCircle(color: const Color(0x33C6ECD9), size: 140),
              ),
              Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.fromLTRB(16, 12, 16, 12),
                    child: _DrawerHeader(),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.fromLTRB(
                        16,
                        0,
                        16,
                        bottomInset > 0 ? bottomInset + 20 : 24,
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: Colors.white.withAlpha(160),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha(12),
                              blurRadius: 16,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: const Padding(
                          padding: EdgeInsets.fromLTRB(16, 18, 16, 16),
                          child: _DrawerFields(),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget _blurCircle({required Color color, required double size}) {
  return Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      color: color,
      shape: BoxShape.circle,
    ),
  );
}

class _DrawerHeader extends StatelessWidget {
  const _DrawerHeader();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      buildWhen: (p, c) => p.status != c.status,
      builder: (context, state) {
        final info = StatusInfo.fromStatus(state.status);
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white.withAlpha(180)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(12),
                blurRadius: 14,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFE6F0FF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.settings_input_antenna_rounded,
                  color: Color(0xFF2563EB),
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Connection',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Configure the settings and start the session.',
                      style: TextStyle(fontSize: 12, color: Colors.black54),
                    ),
                  ],
                ),
              ),
              StatusBadge(label: info.label, color: info.color, showDot: true),
            ],
          ),
        );
      },
    );
  }
}

class _DrawerFields extends StatelessWidget {
  const _DrawerFields();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        _SectionTitle('Credentials'),
        SizedBox(height: 8),
        _ApiKeyField(),
        SizedBox(height: 16),
        _SectionTitle('Models & voice'),
        SizedBox(height: 8),
        _ModelDropdown(),
        SizedBox(height: 10),
        _InputTranscriptionDropdown(),
        SizedBox(height: 10),
        _VoiceDropdown(),
        SizedBox(height: 16),
        _SectionTitle('Instructions'),
        SizedBox(height: 8),
        _InstructionsField(),
        SizedBox(height: 20),
        _SectionTitle('Tools'),
        SizedBox(height: 4),
        _ToolToggleList(),
        SizedBox(height: 20),
        _ConnectButtons(),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
    );
  }
}

class _SubSectionTitle extends StatelessWidget {
  const _SubSectionTitle(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
    );
  }
}

class _ApiKeyField extends StatelessWidget {
  const _ApiKeyField();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      buildWhen: (p, c) =>
          p.apiKey.displayError != c.apiKey.displayError ||
          p.canFixedFieldsChange != c.canFixedFieldsChange,
      builder: (context, state) {
        final displayError = state.apiKey.displayError;
        final isEnabled = state.canFixedFieldsChange;
        return TextFormField(
          key: const ValueKey('api-key-field'),
          initialValue: state.apiKey.value,
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
    );
  }
}

class _ModelDropdown extends StatelessWidget {
  const _ModelDropdown();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      buildWhen: (p, c) =>
          p.model.displayError != c.model.displayError ||
          p.canFixedFieldsChange != c.canFixedFieldsChange ||
          p.model.value != c.model.value,
      builder: (context, state) {
        final displayError = state.model.displayError;
        final isEnabled = state.canFixedFieldsChange;
        final value = state.model.value.isNotEmpty
            ? state.model.value
            : realtimeModelNames.first;
        return DropdownButtonFormField<String>(
          isExpanded: true,
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
      buildWhen: (p, c) =>
          p.instructions != c.instructions ||
          p.canUnfixedFieldsChange != c.canUnfixedFieldsChange,
      builder: (context, state) {
        final isEnabled = state.canUnfixedFieldsChange;
        return TextFormField(
          key: const ValueKey('instructions-field'),
          autocorrect: false,
          initialValue: state.instructions.value,
          enabled: isEnabled,
          minLines: 2,
          maxLines: 4,
          onChanged: (value) =>
              context.read<HomeCubit>().onInstructionsChanged(value),
          decoration: const InputDecoration(
            labelText: 'Instructions (optional)',
            hintText: 'Assistant behavior...',
          ),
        );
      },
    );
  }
}

class _InputTranscriptionDropdown extends StatelessWidget {
  const _InputTranscriptionDropdown();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      buildWhen: (p, c) =>
          p.inputAudioTranscription != c.inputAudioTranscription ||
          p.canFixedFieldsChange != c.canFixedFieldsChange,
      builder: (context, state) {
        final isEnabled = state.canFixedFieldsChange;
        final value = state.inputAudioTranscription.value.isNotEmpty
            ? state.inputAudioTranscription.value
            : realtimeTranscriptionModelNames.first;
        return DropdownButtonFormField<String>(
          isExpanded: true,
          key: const ValueKey('input-transcription-dropdown'),
          initialValue: value,
          onChanged: isEnabled
              ? (value) =>
                    context.read<HomeCubit>().onInputAudioTranscriptionChanged(
                      value ?? realtimeTranscriptionModelNames.first,
                    )
              : null,
          decoration: const InputDecoration(
            labelText: 'Input transcription model',
          ),
          items: realtimeTranscriptionModelNames
              .map(
                (model) => DropdownMenuItem<String>(
                  value: model,
                  child: Row(
                    children: [
                      Text(model),
                      if (realtimeFavoriteTranscriptionModels.contains(
                        model,
                      )) ...[
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

class _VoiceDropdown extends StatelessWidget {
  const _VoiceDropdown();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      buildWhen: (p, c) =>
          p.voice != c.voice ||
          p.canFixedFieldsChange != c.canFixedFieldsChange,
      builder: (context, state) {
        final isEnabled = state.canFixedFieldsChange;
        final value = state.voice.value.isNotEmpty
            ? state.voice.value
            : realtimeFavoriteVoices.first;
        return DropdownButtonFormField<String>(
          isExpanded: true,
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

class _ToolToggleList extends StatelessWidget {
  const _ToolToggleList();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      buildWhen: (p, c) =>
          p.toolToggles != c.toolToggles ||
          p.canUnfixedFieldsChange != c.canUnfixedFieldsChange,
      builder: (context, state) {
        final isEnabled = state.canUnfixedFieldsChange;
        final toggles = defaultToolToggles()..addAll(state.toolToggles);
        final apiTools = kToolOptions
            .where((tool) => tool.group == ToolGroup.api)
            .toList();
        final localTools = kToolOptions
            .where((tool) => tool.group == ToolGroup.local)
            .toList();
        final familyTools = <String, List<ToolOption>>{};
        final standaloneLocalTools = <ToolOption>[];
        for (final tool in localTools) {
          final family = tool.family;
          if (family == null) {
            standaloneLocalTools.add(tool);
          } else {
            familyTools.putIfAbsent(family, () => []).add(tool);
          }
        }
        final sortedFamilies = familyTools.entries.toList()
          ..sort(
            (a, b) {
              final aLabel = kToolFamilyLabels[a.key] ?? a.key;
              final bLabel = kToolFamilyLabels[b.key] ?? b.key;
              return aLabel.compareTo(bLabel);
            },
          );

        List<Widget> buildToolTiles(
          List<ToolOption> tools, {
          bool isChild = false,
        }) => [
          for (final tool in tools) ...[
            SwitchListTile.adaptive(
              dense: isChild,
              contentPadding: EdgeInsets.only(left: isChild ? 24 : 0),
              title: Text(
                tool.label,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: isChild ? 13 : 14,
                ),
              ),
              subtitle: Text(
                tool.shortDescription,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.black.withAlpha(140),
                ),
              ),
              value: toggles[tool.name] ?? true,
              onChanged: isEnabled
                  ? (value) => context.read<HomeCubit>().onToolToggled(
                      tool.name,
                      value,
                    )
                  : null,
            ),
            const Divider(height: 1),
          ],
        ];

        List<Widget> buildFamilyTiles(String family, List<ToolOption> tools) {
          final familyKey = toolFamilyToggleKey(family);
          final familyEnabled = toggles[familyKey] ?? true;
          final label =
              kToolFamilyLabels[family] ??
              '${family[0].toUpperCase()}${family.substring(1)} tools';
          return [
            SwitchListTile.adaptive(
              dense: false,
              contentPadding: EdgeInsets.zero,
              title: Text(
                label,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                'Enable or hide all $label',
                style: const TextStyle(fontSize: 12, color: Colors.black54),
              ),
              value: familyEnabled,
              onChanged: isEnabled
                  ? (value) => context.read<HomeCubit>().onToolFamilyToggled(
                      family,
                      value,
                    )
                  : null,
            ),
            const Divider(height: 1),
            if (familyEnabled) ...buildToolTiles(tools, isChild: true),
          ];
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Align(
              alignment: Alignment.centerLeft,
              child: _SubSectionTitle('API tools'),
            ),
            ...buildToolTiles(apiTools),
            const SizedBox(height: 20),
            const Align(
              alignment: Alignment.centerLeft,
              child: _SubSectionTitle('Local tools'),
            ),
            for (final entry in sortedFamilies)
              ...buildFamilyTiles(entry.key, entry.value),
            ...buildToolTiles(standaloneLocalTools),
          ],
        );
      },
    );
  }
}

class _ConnectButtons extends StatelessWidget {
  const _ConnectButtons();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      buildWhen: (p, c) => p.status != c.status,
      builder: (context, state) {
        final showConnectButton = state.isInitial || state.isConnecting;
        return Row(
          children: [
            Expanded(
              child: showConnectButton ? _ConnectButton() : _SaveButton(),
            ),
            SizedBox(width: 10),
            const Expanded(child: _DisconnectButton()),
          ],
        );
      },
    );
  }
}

class _ConnectButton extends StatelessWidget {
  const _ConnectButton();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      buildWhen: (p, c) => p.status != c.status,
      builder: (context, state) {
        final isEnabled = state.canConnect;
        final isValid = state.isValid;
        final isConnecting = state.isConnecting;
        return OutlinedButton.icon(
          onPressed: isEnabled && isValid
              ? () => context.read<HomeCubit>().connect()
              : null,
          icon: isConnecting
              ? CircularProgressIndicator.adaptive()
              : const Icon(Icons.play_arrow),
          label: Text('Connect'),
        );
      },
    );
  }
}

class _SaveButton extends StatelessWidget {
  const _SaveButton();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      buildWhen: (p, c) => p.status != c.status,
      builder: (context, state) {
        final isEnabled = state.canSave;
        final isValid = state.isValid;
        final isSaving = state.isSaving;
        return OutlinedButton.icon(
          onPressed: isEnabled && isValid
              ? () => context.read<HomeCubit>().saveSessionChanges()
              : null,
          icon: isSaving
              ? CircularProgressIndicator.adaptive()
              : const Icon(Icons.save),
          label: Text('Save'),
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
        final isEnabled = state.canDisconnect;
        final isDisconnecting = state.isDisconnecting;
        return OutlinedButton.icon(
          onPressed: isEnabled
              ? () => context.read<HomeCubit>().disconnect()
              : null,
          icon: isDisconnecting
              ? CircularProgressIndicator.adaptive()
              : const Icon(Icons.stop),
          label: Text('Disconnect'),
        );
      },
    );
  }
}
