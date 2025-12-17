part of 'home_cubit.dart';

class HomeState extends Equatable {
  const HomeState({
    this.status = HomeStatus.initial,
    this.debugLogging = false,
    this.logs = const [],
    this.logsReversed = false,
    this.messages = const [],
    this.callId,
    this.lastError,
    this.apiKey = const ApiKeyInput.pure(),
    this.model = const ModelInput.pure(),
    this.prompt = const PromptInput.pure(),
    this.instructions = const InstructionsInput.pure(),
    this.voice = const VoiceInput.pure(),
  });

  final HomeStatus status;
  final bool debugLogging;
  final List<LogEntry> logs;
  final bool logsReversed;
  final List<MessageEntry> messages;
  final String? callId;
  final String? lastError;
  final ApiKeyInput apiKey;
  final ModelInput model;
  final PromptInput prompt;
  final InstructionsInput instructions;
  final VoiceInput voice;

  HomeState copyWith({
    HomeStatus? status,
    bool? debugLogging,
    List<LogEntry>? logs,
    bool? logsReversed,
    List<MessageEntry>? messages,
    String? callId,
    String? lastError,
    ApiKeyInput? apiKey,
    ModelInput? model,
    PromptInput? prompt,
    InstructionsInput? instructions,
    VoiceInput? voice,
    bool clearError = false,
  }) {
    return HomeState(
      status: status ?? this.status,
      debugLogging: debugLogging ?? this.debugLogging,
      logs: logs ?? this.logs,
      logsReversed: logsReversed ?? this.logsReversed,
      messages: messages ?? this.messages,
      callId: callId ?? this.callId,
      lastError: clearError ? null : lastError ?? this.lastError,
      apiKey: apiKey ?? this.apiKey,
      model: model ?? this.model,
      prompt: prompt ?? this.prompt,
      instructions: instructions ?? this.instructions,
      voice: voice ?? this.voice,
    );
  }

  @override
  List<Object?> get props => [
    status,
    debugLogging,
    logs,
    logsReversed,
    messages,
    callId,
    lastError,
    apiKey,
    model,
    prompt,
    instructions,
    voice,
  ];
}

enum HomeStatus {
  initial,
  connecting,
  connected,
  disconnecting,
  error,
}
