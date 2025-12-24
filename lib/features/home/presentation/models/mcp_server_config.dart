import 'package:equatable/equatable.dart';
import 'package:openai_realtime/openai_realtime.dart';

const String kGmailMcpConnectorId = 'connector_gmail';
const String kGmailMcpServerLabel = 'gmail';

class McpToolInfo {
  const McpToolInfo({
    required this.name,
    required this.title,
    required this.description,
    required this.scopes,
  });

  final String name;
  final String title;
  final String description;
  final String scopes;
}

const List<McpToolInfo> kGmailMcpTools = [
  McpToolInfo(
    name: 'batch_read_email',
    title: 'Batch read email',
    description: 'Read multiple Gmail messages in one call.',
    scopes: 'gmail.modify',
  ),
  McpToolInfo(
    name: 'get_profile',
    title: 'Profile',
    description: 'Return the current Gmail user profile.',
    scopes: 'userinfo.email, userinfo.profile',
  ),
  McpToolInfo(
    name: 'get_recent_emails',
    title: 'Recent emails',
    description: 'Return the most recently received Gmail messages.',
    scopes: 'gmail.modify',
  ),
  McpToolInfo(
    name: 'read_email',
    title: 'Read email',
    description: 'Fetch a single Gmail message including its body.',
    scopes: 'gmail.modify',
  ),
  McpToolInfo(
    name: 'search_email_ids',
    title: 'Search ids',
    description: 'Retrieve Gmail message IDs matching a search.',
    scopes: 'gmail.modify',
  ),
  McpToolInfo(
    name: 'search_emails',
    title: 'Search emails',
    description: 'Search Gmail for emails matching a query or label.',
    scopes: 'gmail.modify',
  ),
];

Map<String, bool> gmailDefaultToolToggles() => {
  for (final tool in kGmailMcpTools) tool.name: true,
};

Map<String, bool> defaultMcpToolToggles(String connectorId) {
  switch (connectorId) {
    case kGmailMcpConnectorId:
      return gmailDefaultToolToggles();
    default:
      return const {};
  }
}

class McpServerConfig extends Equatable {
  const McpServerConfig({
    required this.serverLabel,
    required this.description,
    required this.accessToken,
    required this.apiKey,
    required this.connectorId,
    required this.toolToggles,
  });

  final String serverLabel;
  final String description;
  final String accessToken;
  final String apiKey;
  final String connectorId;
  final Map<String, bool> toolToggles;

  Map<String, bool> _normalizedToolToggles(Map<String, bool> defaults) {
    final merged = Map<String, bool>.from(defaults);
    merged.addAll(toolToggles);
    return merged;
  }

  List<String> enabledTools(Map<String, bool> defaults) {
    final toggles = _normalizedToolToggles(defaults);
    return toggles.entries
        .where((entry) => entry.value)
        .map((entry) => entry.key)
        .toList();
  }

  bool get hasCredentials =>
      accessToken.trim().isNotEmpty && apiKey.trim().isNotEmpty;

  McpServerConfig copyWith({
    String? serverLabel,
    String? description,
    String? accessToken,
    String? apiKey,
    String? connectorId,
    Map<String, bool>? toolToggles,
  }) {
    return McpServerConfig(
      serverLabel: serverLabel ?? this.serverLabel,
      description: description ?? this.description,
      accessToken: accessToken ?? this.accessToken,
      apiKey: apiKey ?? this.apiKey,
      connectorId: connectorId ?? this.connectorId,
      toolToggles: toolToggles ?? this.toolToggles,
    );
  }

  RealtimeTool toRealtimeTool({
    required Map<String, bool> defaultToolToggles,
  }) {
    final allowedTools = enabledTools(defaultToolToggles);
    final trimmedToken = accessToken.trim();
    final trimmedApiKey = apiKey.trim();
    final headers = <String, String>{};
    if (trimmedApiKey.isNotEmpty) headers['x-goog-api-key'] = trimmedApiKey;

    final extra = <String, dynamic>{
      'server_label': serverLabel,
      'connector_id': connectorId,
      if (trimmedToken.isNotEmpty) 'authorization': trimmedToken,
      if (allowedTools.isNotEmpty) 'allowed_tools': allowedTools,
      if (headers.isNotEmpty) 'headers': headers,
    };

    return RealtimeTool(type: 'mcp', extra: extra);
  }

  List<String> get _toggleSnapshot {
    final entries = toolToggles.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    return entries.map((entry) => '${entry.key}:${entry.value}').toList();
  }

  @override
  List<Object?> get props => [
    serverLabel,
    description,
    accessToken,
    apiKey,
    connectorId,
    _toggleSnapshot,
  ];
}
