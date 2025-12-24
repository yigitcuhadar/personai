import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:openai_realtime/openai_realtime.dart';
import 'package:url_launcher/url_launcher.dart';

import '../cubit/home_cubit.dart';
import '../models/tool_option.dart';
import '../models/mcp_server_config.dart';
import 'status_badge.dart';

final Uri _gmailOauthPlaygroundUri = Uri.parse(
  'https://developers.google.com/oauthplayground/?scope=https://mail.google.com/',
);

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
      children: [
        const _SectionTitle('Credentials'),
        const SizedBox(height: 8),
        const _ApiKeyField(),
        const SizedBox(height: 16),
        const _SectionTitle('Models & voice'),
        const SizedBox(height: 8),
        const _ModelDropdown(),
        const SizedBox(height: 10),
        const _InputTranscriptionDropdown(),
        const SizedBox(height: 10),
        const _VoiceDropdown(),
        const SizedBox(height: 16),
        const _SectionTitle('Instructions'),
        const SizedBox(height: 8),
        const _InstructionsField(),
        const SizedBox(height: 20),
        const _SectionTitle('Tools'),
        const SizedBox(height: 4),
        const _ToolToggleList(),
        const SizedBox(height: 20),
        const _SectionTitle('MCP Servers'),
        const SizedBox(height: 6),
        const _McpServersSection(),
        const SizedBox(height: 20),
        const _ConnectButtons(),
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
      buildWhen: (p, c) => p.apiKey.displayError != c.apiKey.displayError || p.canFixedFieldsChange != c.canFixedFieldsChange,
      builder: (context, state) {
        final displayError = state.apiKey.displayError;
        final isEnabled = state.canFixedFieldsChange;
        return TextFormField(
          key: const ValueKey('api-key-field'),
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
      buildWhen: (p, c) =>
          p.model.displayError != c.model.displayError ||
          p.canFixedFieldsChange != c.canFixedFieldsChange ||
          p.model.value != c.model.value,
      builder: (context, state) {
        final displayError = state.model.displayError;
        final isEnabled = state.canFixedFieldsChange;
        final value = state.model.value.isNotEmpty ? state.model.value : realtimeModelNames.first;
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
      buildWhen: (p, c) => p.instructions != c.instructions || p.canUnfixedFieldsChange != c.canUnfixedFieldsChange,
      builder: (context, state) {
        final isEnabled = state.canUnfixedFieldsChange;
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

class _InputTranscriptionDropdown extends StatelessWidget {
  const _InputTranscriptionDropdown();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      buildWhen: (p, c) =>
          p.inputAudioTranscription != c.inputAudioTranscription || p.canFixedFieldsChange != c.canFixedFieldsChange,
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
              ? (value) => context.read<HomeCubit>().onInputAudioTranscriptionChanged(
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
      buildWhen: (p, c) => p.voice != c.voice || p.canFixedFieldsChange != c.canFixedFieldsChange,
      builder: (context, state) {
        final isEnabled = state.canFixedFieldsChange;
        final value = state.voice.value.isNotEmpty ? state.voice.value : realtimeFavoriteVoices.first;
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
      buildWhen: (p, c) => p.toolToggles != c.toolToggles || p.canUnfixedFieldsChange != c.canUnfixedFieldsChange,
      builder: (context, state) {
        final isEnabled = state.canUnfixedFieldsChange;
        final toggles = defaultToolToggles()..addAll(state.toolToggles);
        final apiTools = kToolOptions.where((tool) => tool.group == ToolGroup.api).toList();
        final localTools = kToolOptions.where((tool) => tool.group == ToolGroup.local).toList();
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
          final label = kToolFamilyLabels[family] ?? '${family[0].toUpperCase()}${family.substring(1)} tools';
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
            for (final entry in sortedFamilies) ...buildFamilyTiles(entry.key, entry.value),
            ...buildToolTiles(standaloneLocalTools),
          ],
        );
      },
    );
  }
}

class _McpServersSection extends StatelessWidget {
  const _McpServersSection();

  McpServerConfig? _gmailConfig(List<McpServerConfig> servers) {
    for (final server in servers) {
      if (server.connectorId == kGmailMcpConnectorId || server.serverLabel == kGmailMcpServerLabel) {
        return server;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      buildWhen: (p, c) => p.mcpServers != c.mcpServers || p.status != c.status,
      builder: (context, state) {
        final canEdit = state.canUnfixedFieldsChange;
        final gmailConfig = _gmailConfig(state.mcpServers);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF4F6FB),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE0E7FF)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Row(
                children: const [
                  Icon(Icons.cable_rounded, color: Color(0xFF2563EB)),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Bridge Gmail via MCP connectors. Configure credentials and tools, then apply with Connect or Save.',
                      style: TextStyle(fontSize: 12.5),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            _GmailServerTile(
              config: gmailConfig,
              canEdit: canEdit,
            ),
          ],
        );
      },
    );
  }
}

class _GmailServerTile extends StatelessWidget {
  const _GmailServerTile({
    required this.config,
    required this.canEdit,
  });

  final McpServerConfig? config;
  final bool canEdit;

  @override
  Widget build(BuildContext context) {
    final enabledTools =
        config?.enabledTools(
          defaultMcpToolToggles(kGmailMcpConnectorId),
        ) ??
        [];
    final added = config?.hasCredentials == true;
    final subtitle = added
        ? 'Ready with ${enabledTools.length} tool${enabledTools.length == 1 ? '' : 's'}'
        : 'Add an optional description, access token, then choose tools.';
    final badgeColor = added ? Colors.green.shade600 : Colors.orange.shade600;

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: canEdit
          ? () => _showGmailSheet(
              context,
              existing: config,
              canEdit: canEdit,
            )
          : null,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE0E0E0)),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(8),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF3F3),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFFFE0E0)),
              ),
              child: const Icon(
                Icons.mark_email_unread_rounded,
                color: Color(0xFFDB3C30),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Gmail connector',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.black.withAlpha(150),
                      fontSize: 12.5,
                    ),
                  ),
                  if (enabledTools.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: enabledTools
                          .take(3)
                          .map(
                            (name) => _Pill(
                              label: name.replaceAll('_', ' '),
                            ),
                          )
                          .toList(),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: badgeColor.withAlpha(26),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                added ? 'Added' : 'Tap to add',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: badgeColor,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(width: 6),
            Icon(
              Icons.chevron_right,
              color: canEdit ? Colors.black54 : Colors.black26,
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> _showGmailSheet(
  BuildContext context, {
  McpServerConfig? existing,
  required bool canEdit,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) {
      final bottomInset = MediaQuery.of(sheetContext).viewInsets.bottom;
      final homeCubit = context.read<HomeCubit>();
      return Padding(
        padding: EdgeInsets.only(bottom: bottomInset),
        child: BlocProvider.value(
          value: homeCubit,
          child: _GmailMcpSheet(
            existing: existing,
            canEdit: canEdit,
          ),
        ),
      );
    },
  );
}

class _GmailMcpSheet extends StatefulWidget {
  const _GmailMcpSheet({
    this.existing,
    required this.canEdit,
  });

  final McpServerConfig? existing;
  final bool canEdit;

  @override
  State<_GmailMcpSheet> createState() => _GmailMcpSheetState();
}

class _GmailMcpSheetState extends State<_GmailMcpSheet> {
  late final TextEditingController _descriptionController;
  late final TextEditingController _accessTokenController;
  late Map<String, bool> _toolToggles;
  bool _showErrors = false;

  @override
  void initState() {
    super.initState();
    _descriptionController = TextEditingController(
      text: widget.existing?.description ?? '',
    );
    _accessTokenController = TextEditingController(
      text: widget.existing?.accessToken ?? '',
    );
    _toolToggles = defaultMcpToolToggles(kGmailMcpConnectorId);
    final existingToggles = widget.existing?.toolToggles ?? {};
    _toolToggles.addAll(existingToggles);
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _accessTokenController.dispose();
    super.dispose();
  }

  void _onToggle(String name, bool value) {
    setState(() {
      _toolToggles[name] = value;
    });
  }

  Future<void> _openAccessTokenLink() async {
    try {
      final opened = await launchUrl(
        _gmailOauthPlaygroundUri,
        mode: LaunchMode.externalApplication,
      );
      if (!opened && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open OAuth Playground')),
        );
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open OAuth Playground')),
      );
    }
  }

  void _submit() {
    final description = _descriptionController.text.trim();
    final token = _accessTokenController.text.trim();
    final isValid = token.isNotEmpty;
    if (!isValid) {
      setState(() {
        _showErrors = true;
      });
      return;
    }
    final config = McpServerConfig(
      serverLabel: kGmailMcpServerLabel,
      description: description,
      accessToken: token,
      connectorId: kGmailMcpConnectorId,
      toolToggles: Map<String, bool>.from(_toolToggles),
    );
    context.read<HomeCubit>().upsertMcpServer(config);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final canEdit = widget.canEdit;
    final title = widget.existing == null ? 'Add Gmail (MCP)' : 'Update Gmail (MCP)';
    final actionLabel = widget.existing == null ? 'Add' : 'Update';
    final actionIcon = widget.existing == null ? Icons.add : Icons.save_outlined;

    return FractionallySizedBox(
      heightFactor: 0.9,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(20),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.black.withAlpha(70),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF0F0),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.mark_email_read_rounded,
                      color: Color(0xFFDB3C30),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Keep scopes minimal and disable tools and connectors you do not need.',
                          style: TextStyle(
                            fontSize: 12.5,
                            color: Colors.black.withAlpha(150),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Close',
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Describe the connection',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _descriptionController,
                      enabled: canEdit,
                      decoration: InputDecoration(
                        labelText: 'Description (optional)',
                        hintText: 'e.g. Personal inbox, work updates only',
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        const Text(
                          'Access token (OAuth)',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: canEdit ? _openAccessTokenLink : null,
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: const Size(0, 0),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: const Text(
                            'Get access token',
                            style: TextStyle(fontSize: 12.5),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _accessTokenController,
                      enabled: canEdit,
                      minLines: 1,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: 'Access token',
                        hintText: 'ya29....',
                        errorText: _showErrors && _accessTokenController.text.trim().isEmpty ? 'Access token is required' : null,
                        helperText: 'Should include scopes: userinfo.email, userinfo.profile, gmail.modify',
                      ),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        const Text(
                          'Tool access',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 8),
                        _Pill(
                          label: 'Toggles reflect allowed_tools',
                          tone: const Color(0xFF2563EB),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          for (final tool in kGmailMcpTools) ...[
                            SwitchListTile.adaptive(
                              dense: true,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                              title: Text(
                                tool.title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13.5,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    tool.description,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.black.withAlpha(150),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Scopes: ${tool.scopes}',
                                    style: TextStyle(
                                      fontSize: 11.5,
                                      color: Colors.black.withAlpha(120),
                                    ),
                                  ),
                                ],
                              ),
                              value: _toolToggles[tool.name] ?? true,
                              onChanged: canEdit ? (value) => _onToggle(tool.name, value) : null,
                            ),
                            if (tool != kGmailMcpTools.last) const Divider(height: 1, indent: 12, endIndent: 12),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    FilledButton.icon(
                      icon: Icon(actionIcon),
                      onPressed: canEdit ? _submit : null,
                      label: Text('$actionLabel connector'),
                    ),
                    if (widget.existing != null) ...[
                      const SizedBox(height: 6),
                      OutlinedButton.icon(
                        icon: const Icon(Icons.delete_outline, color: Colors.red),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.red),
                        ),
                        onPressed: canEdit
                            ? () {
                                final cubit = context.read<HomeCubit>();
                                cubit.removeMcpServer(kGmailMcpServerLabel);
                                if (cubit.state.canSave) {
                                  cubit.saveSessionChanges();
                                }
                                Navigator.of(context).pop();
                              }
                            : null,
                        label: const Text(
                          'Remove connector',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({
    required this.label,
    this.tone = const Color(0xFF2563EB),
  });

  final String label;
  final Color tone;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: tone.withAlpha(16),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: tone,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
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
          onPressed: isEnabled && isValid ? () => context.read<HomeCubit>().connect() : null,
          icon: isConnecting ? CircularProgressIndicator.adaptive() : const Icon(Icons.play_arrow),
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
          onPressed: isEnabled && isValid ? () => context.read<HomeCubit>().saveSessionChanges() : null,
          icon: isSaving ? CircularProgressIndicator.adaptive() : const Icon(Icons.save),
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
          onPressed: isEnabled ? () => context.read<HomeCubit>().disconnect() : null,
          icon: isDisconnecting ? CircularProgressIndicator.adaptive() : const Icon(Icons.stop),
          label: Text('Disconnect'),
        );
      },
    );
  }
}
