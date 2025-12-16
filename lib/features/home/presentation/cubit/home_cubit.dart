import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:formz/formz.dart';
import 'package:openai_realtime/openai_realtime.dart';

import '../models/log_entry.dart';

part 'home_state.dart';

class ApiKeyInput extends FormzInput<String, String> {
  const ApiKeyInput.pure([super.value = '']) : super.pure();
  const ApiKeyInput.dirty([super.value = '']) : super.dirty();

  @override
  String? validator(String value) => value.trim().isEmpty ? 'API anahtarı gerekli' : null;
}

class ModelInput extends FormzInput<String, String> {
  const ModelInput.pure([super.value = 'gpt-realtime']) : super.pure();
  const ModelInput.dirty([super.value = 'gpt-realtime']) : super.dirty();

  @override
  String? validator(String value) => value.trim().isEmpty ? 'Model gerekli' : null;
}

class PromptInput extends FormzInput<String, String> {
  const PromptInput.pure([super.value = '']) : super.pure();
  const PromptInput.dirty([super.value = '']) : super.dirty();

  @override
  String? validator(String value) => value.trim().isEmpty ? 'Prompt gerekli' : null;
}

class InstructionsInput extends FormzInput<String, String> {
  const InstructionsInput.pure([super.value = '']) : super.pure();
  const InstructionsInput.dirty([super.value = '']) : super.dirty();

  @override
  String? validator(String value) => null; // optional
}

class VoiceInput extends FormzInput<String, String> {
  const VoiceInput.pure([super.value = 'marin']) : super.pure();
  const VoiceInput.dirty([super.value = 'marin']) : super.dirty();

  @override
  String? validator(String value) => realtimeVoiceNames.contains(value) ? null : 'Geçersiz ses';
}

class HomeCubit extends Cubit<HomeState> {
  HomeCubit({String defaultApiKey = ''})
    : super(
        HomeState(
          apiKey: ApiKeyInput.pure(defaultApiKey.trim()),
        ),
      );

  OpenAIRealtimeClient? _client;
  StreamSubscription<RealtimeServerEvent>? _eventSub;
  StreamSubscription<RealtimeClientEvent>? _clientEventSub;
  DateTime? _sessionCreatedAt;

  bool get _isConnecting => state.status == HomeStatus.connecting;
  bool get _isConnected => state.status == HomeStatus.connected;
  bool get _canChangeConfig => !_isConnecting && !_isConnected;

  void onApiKeyChanged(String value) {
    emit(state.copyWith(apiKey: ApiKeyInput.dirty(value), clearError: true));
  }

  void onModelChanged(String value) {
    emit(state.copyWith(model: ModelInput.dirty(value), clearError: true));
  }

  void onPromptChanged(String value) {
    emit(state.copyWith(prompt: PromptInput.dirty(value), clearError: true));
  }

  void onInstructionsChanged(String value) {
    emit(state.copyWith(instructions: InstructionsInput.dirty(value), clearError: true));
  }

  void onVoiceChanged(String value) {
    emit(state.copyWith(voice: VoiceInput.dirty(value), clearError: true));
  }

  void clearLogs() {
    emit(state.copyWith(logs: const []));
  }

  void toggleLogsOrder() {
    emit(state.copyWith(logsReversed: !state.logsReversed));
  }

  void setDebugLogging(bool value) {
    if (!_canChangeConfig) return;
    emit(state.copyWith(debugLogging: value, clearError: true));
  }

  Future<void> connect() async {
    if (_isConnecting || _isConnected) return;

    final apiKey = ApiKeyInput.dirty(state.apiKey.value.trim());
    final model = ModelInput.dirty(state.model.value.trim());
    final voice = VoiceInput.dirty(state.voice.value);
    final isValid = Formz.validate([apiKey, model, voice]);
    if (!isValid) {
      emit(
        state.copyWith(
          apiKey: apiKey,
          model: model,
          voice: voice,
          lastError: 'API anahtarı ve model gerekli.',
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        status: HomeStatus.connecting,
        apiKey: apiKey,
        model: model,
        clearError: true,
      ),
    );

    final client = _createClient(apiKey.value);
    await _attachClientStreams(client);

    try {
      final session = RealtimeSessionConfig(
        type: 'realtime',
        model: model.value,
      );
      await client.connect(
        model: model.value,
        session: session,
      );
      _client = client;
      emit(
        state.copyWith(
          status: HomeStatus.connected,
          callId: client.callId,
          clearError: true,
        ),
      );
      await _sendSessionUpdate(includeVoice: true, includeInstructions: true);
      _appendEventLog(
        direction: LogDirection.client,
        type: 'connection',
        payload: {'message': 'Bağlanıldı', 'callId': client.callId},
        rawEvent: {'message': 'Bağlanıldı', 'callId': client.callId},
      );
    } catch (err) {
      await _detachClientStreams();
      await client.dispose();
      emit(
        state.copyWith(
          status: HomeStatus.error,
          callId: null,
          lastError: '$err',
        ),
      );
      _appendEventLog(
        direction: LogDirection.client,
        type: 'connection.error',
        payload: {'error': '$err'},
        rawEvent: err,
      );
    }
  }

  Future<void> disconnect() async {
    final client = _client;
    if (client == null) return;
    emit(state.copyWith(status: HomeStatus.disconnecting, clearError: true));
    await client.disconnect();
    await _detachClientStreams();
    _client = null;
    _sessionCreatedAt = null;
    emit(
      state.copyWith(
        status: HomeStatus.initial,
        callId: null,
        clearError: true,
      ),
    );
    _appendEventLog(
      direction: LogDirection.client,
      type: 'connection',
      payload: {'message': 'Bağlantı kapatıldı'},
      rawEvent: {'message': 'Bağlantı kapatıldı'},
    );
  }

  Future<void> sendPrompt() async {
    if (!state.prompt.isValid) return;
    final prompt = state.prompt.value.trim();

    final client = _client;
    if (client == null) {
      emit(state.copyWith(lastError: 'Önce bağlanın.'));
      return;
    }
    await client.sendText(prompt);
  }

  void _handleServerEvent(RealtimeServerEvent event) {
    final now = DateTime.now();
    if (event is SessionCreatedEvent) {
      _sessionCreatedAt = now;
    }
    _appendEventLog(
      direction: LogDirection.server,
      type: event.type,
      payload: event.toJson(),
      timestamp: now,
      rawEvent: event,
    );
  }

  void _handleClientEvent(RealtimeClientEvent event) {
    _appendEventLog(
      direction: LogDirection.client,
      type: event.type,
      payload: event.toJson(),
      rawEvent: event,
    );
  }

  Future<void> _sendSessionUpdate({
    required bool includeVoice,
    required bool includeInstructions,
  }) async {
    if (!_isConnected || _client == null) return;
    final session = RealtimeSessionConfig(
      audio: includeVoice ? RealtimeAudioConfig(output: RealtimeAudioOutputConfig(voice: state.voice.value)) : null,
      instructions: includeInstructions
          ? state.instructions.value.trim().isEmpty
                ? null
                : state.instructions.value.trim()
          : null,
    );
    if (session.audio == null && session.instructions == null) return;
    await _client!.sendEvent(SessionUpdateEvent(session: session));
  }

  OpenAIRealtimeClient _createClient(String token) {
    final client = OpenAIRealtimeClient(
      accessToken: token,
      debug: state.debugLogging,
    );
    if (state.debugLogging) {
      enableOpenAIRealtimeLogging();
    }
    return client;
  }

  Future<void> _attachClientStreams(OpenAIRealtimeClient client) async {
    await _detachClientStreams();
    _sessionCreatedAt = null;
    _eventSub = client.serverEvents.listen(
      _handleServerEvent,
      onError: (err, stack) {
        _appendEventLog(
          direction: LogDirection.server,
          type: 'server.error',
          payload: {'error': '$err'},
          rawEvent: err,
        );
      },
    );
    _clientEventSub = client.clientEvents.listen(
      _handleClientEvent,
      onError: (err, stack) {
        _appendEventLog(
          direction: LogDirection.client,
          type: 'client.error',
          payload: {'error': '$err'},
          rawEvent: err,
        );
      },
    );
  }

  Future<void> _detachClientStreams() async {
    await _eventSub?.cancel();
    await _clientEventSub?.cancel();
    _eventSub = null;
    _clientEventSub = null;
  }

  void _appendEventLog({
    required LogDirection direction,
    required String type,
    required Map<String, dynamic> payload,
    DateTime? timestamp,
    Object? rawEvent,
  }) {
    final now = timestamp ?? DateTime.now();
    final normalizedPayload = Map<String, dynamic>.from(payload)..putIfAbsent('type', () => type);
    final elapsed = _sessionCreatedAt != null ? now.difference(_sessionCreatedAt!) : null;
    final detail = LogEventDetail(
      payload: normalizedPayload,
      timestamp: now,
      elapsedSinceSession: elapsed,
      event: rawEvent,
    );

    final logs = List<LogEntry>.from(state.logs);
    if (logs.isNotEmpty) {
      final last = logs.last;
      if (last.type == type && last.direction == direction) {
        final updatedDetails = List<LogEventDetail>.from(last.details)..add(detail);
        logs[logs.length - 1] = last.copyWith(details: updatedDetails);
        emit(state.copyWith(logs: logs));
        return;
      }
    }

    logs.add(
      LogEntry(
        type: type,
        direction: direction,
        details: [detail],
      ),
    );
    emit(state.copyWith(logs: logs));
  }

  @override
  Future<void> close() async {
    await _detachClientStreams();
    await _client?.dispose();
    return super.close();
  }
}
