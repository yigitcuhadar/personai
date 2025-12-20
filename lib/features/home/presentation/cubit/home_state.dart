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
    this.prompt = const PromptInput.pure(),
    this.instructions = const InstructionsInput.pure(),
    this.voice = const VoiceInput.pure(),
    this.inputAudioTranscription = const InputAudioTranscriptionInput.pure(),
  });

  final HomeStatus status;
  final List<LogEntry> logs;
  final bool logsReversed;
  final List<MessageEntry> messages;
  final String? lastError;
  final bool micEnabled;
  final ApiKeyInput apiKey;
  final ModelInput model;
  final PromptInput prompt;
  final InstructionsInput instructions;
  final VoiceInput voice;
  final InputAudioTranscriptionInput inputAudioTranscription;

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
    bool clearError = false,
  }) {
    return HomeState(
      status: status ?? this.status,
      logs: logs ?? this.logs,
      logsReversed: logsReversed ?? this.logsReversed,
      messages: messages ?? this.messages,
      lastError: clearError ? null : lastError ?? this.lastError,
      micEnabled: micEnabled ?? this.micEnabled,
      apiKey: apiKey ?? this.apiKey,
      model: model ?? this.model,
      prompt: prompt ?? this.prompt,
      instructions: instructions ?? this.instructions,
      voice: voice ?? this.voice,
      inputAudioTranscription:
          inputAudioTranscription ?? this.inputAudioTranscription,
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
  ];
}

enum HomeStatus {
  initial,
  connecting,
  connected,
  disconnecting,
  error,
}
