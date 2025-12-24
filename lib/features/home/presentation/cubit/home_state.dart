part of 'home_cubit.dart';

class HomeState extends Equatable {
  const HomeState({
    this.status = HomeStatus.initial,
    this.logs = const [],
    this.logsReversed = false,
    this.messages = const [],
    this.lastError,
    this.micEnabled = false,
    this.apiKey = const ApiKeyInput.pure(),
    this.model = const ModelInput.pure(),
    this.inputAudioTranscription = const InputAudioTranscriptionInput.pure(),
    this.voice = const VoiceInput.pure(),
    this.instructions = const InstructionsInput.pure(),
    this.prompt = const PromptInput.pure(),
    this.toolToggles = const {},
    this.mcpServers = const [],
  });

  final HomeStatus status;
  final List<LogEntry> logs;
  final bool logsReversed;
  final List<MessageEntry> messages;
  final String? lastError;
  final bool micEnabled;
  final ApiKeyInput apiKey;
  final ModelInput model;
  final InputAudioTranscriptionInput inputAudioTranscription;
  final VoiceInput voice;
  final InstructionsInput instructions;
  final PromptInput prompt;
  final Map<String, bool> toolToggles;
  final List<McpServerConfig> mcpServers;

  bool get isValid =>
      apiKey.isValid &&
      model.isValid &&
      voice.isValid &&
      instructions.isValid &&
      inputAudioTranscription.isValid;

  bool get isInitial => status == HomeStatus.initial;
  bool get isConnecting => status == HomeStatus.connecting;
  bool get isConnected => status == HomeStatus.connected;
  bool get isDisconnecting => status == HomeStatus.disconnecting;
  bool get isSaving => status == HomeStatus.saving;

  bool get canFixedFieldsChange => isInitial;
  bool get canUnfixedFieldsChange => isInitial || isConnected;
  bool get canConnect => isInitial;
  bool get canSave => isConnected;
  bool get canDisconnect => isConnected;

  HomeState copyWith({
    HomeStatus? status,
    List<LogEntry>? logs,
    bool? logsReversed,
    List<MessageEntry>? messages,
    String? lastError,
    bool? micEnabled,
    ApiKeyInput? apiKey,
    ModelInput? model,
    PromptInput? prompt,
    InstructionsInput? instructions,
    VoiceInput? voice,
    InputAudioTranscriptionInput? inputAudioTranscription,
    Map<String, bool>? toolToggles,
    List<McpServerConfig>? mcpServers,
  }) {
    return HomeState(
      status: status ?? this.status,
      logs: logs ?? this.logs,
      logsReversed: logsReversed ?? this.logsReversed,
      messages: messages ?? this.messages,
      lastError: lastError ?? this.lastError,
      micEnabled: micEnabled ?? this.micEnabled,
      apiKey: apiKey ?? this.apiKey,
      model: model ?? this.model,
      prompt: prompt ?? this.prompt,
      instructions: instructions ?? this.instructions,
      voice: voice ?? this.voice,
      inputAudioTranscription:
          inputAudioTranscription ?? this.inputAudioTranscription,
      toolToggles: toolToggles ?? this.toolToggles,
      mcpServers: mcpServers ?? this.mcpServers,
    );
  }

  @override
  List<Object?> get props => [
    status,
    logs,
    logsReversed,
    messages,
    lastError,
    micEnabled,
    apiKey,
    model,
    prompt,
    instructions,
    voice,
    inputAudioTranscription,
    toolToggles,
    mcpServers,
  ];
}

enum HomeStatus {
  initial,
  connecting,
  connected,
  disconnecting,
  saving,
}
