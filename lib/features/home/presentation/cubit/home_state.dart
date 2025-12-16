part of 'home_cubit.dart';

class HomeState extends Equatable {
  const HomeState({
    this.status = HomeStatus.initial,
    this.debugLogging = false,
    this.logs = const [],
    this.callId,
    this.lastError,
    this.apiKey = const ApiKeyInput.pure(),
    this.model = const ModelInput.pure(),
    this.prompt = const PromptInput.pure(),
  });

  final HomeStatus status;
  final bool debugLogging;
  final List<String> logs;
  final String? callId;
  final String? lastError;
  final ApiKeyInput apiKey;
  final ModelInput model;
  final PromptInput prompt;

  HomeState copyWith({
    HomeStatus? status,
    bool? debugLogging,
    List<String>? logs,
    String? callId,
    String? lastError,
    ApiKeyInput? apiKey,
    ModelInput? model,
    PromptInput? prompt,
    bool clearError = false,
  }) {
    return HomeState(
      status: status ?? this.status,
      debugLogging: debugLogging ?? this.debugLogging,
      logs: logs ?? this.logs,
      callId: callId ?? this.callId,
      lastError: clearError ? null : lastError ?? this.lastError,
      apiKey: apiKey ?? this.apiKey,
      model: model ?? this.model,
      prompt: prompt ?? this.prompt,
    );
  }

  @override
  List<Object?> get props => [status, debugLogging, logs, callId, lastError, apiKey, model, prompt];
}

enum HomeStatus {
  initial,
  connecting,
  connected,
  disconnecting,
  error,
}
