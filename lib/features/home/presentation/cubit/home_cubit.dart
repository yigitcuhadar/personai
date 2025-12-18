import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:formz/formz.dart';
import 'package:openai_realtime/openai_realtime.dart';

import '../models/inputs/api_key_input.dart';
import '../models/inputs/instructions_input.dart';
import '../models/inputs/model_input.dart';
import '../models/inputs/prompt_input.dart';
import '../models/inputs/voice_input.dart';
import '../models/log_entry.dart';
import '../models/message_entry.dart';

part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit({String defaultApiKey = ''})
    : super(
        HomeState(
          apiKey: ApiKeyInput.pure(defaultApiKey.trim()),
        ),
      );

  OpenAIRealtimeClient? _client;
  StreamSubscription<RealtimeServerEvent>? _serverSubscription;
  StreamSubscription<RealtimeClientEvent>? _clientSubscription;

  DateTime? _sessionCreatedAt;
  final Map<String, int> _messageIndexById = <String, int>{};
  final Set<String> _responseTextKeys = <String>{};
  int _messageCounter = 0;

  bool get _isConnecting => state.status == HomeStatus.connecting;
  bool get _isConnected => state.status == HomeStatus.connected;
  bool get _isMicEnabled => state.micEnabled;
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
          lastError: 'API key and model are required.',
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

    final client = OpenAIRealtimeClient(
      accessToken: apiKey.value,
      debug: state.debugLogging,
    );
    if (state.debugLogging) {
      enableOpenAIRealtimeLogging();
    }
    await _attachSubscriptions(client);

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
      emit(state.copyWith(status: HomeStatus.connected, micEnabled: false, clearError: true));
      await _sendSessionUpdate(includeVoice: true, includeInstructions: true);
      _appendEventLog(
        direction: LogDirection.client,
        type: 'connection',
        payload: {'message': 'Connected', 'callId': client.callId},
        rawEvent: {'message': 'Connected', 'callId': client.callId},
      );
    } catch (err) {
      await _detachSubscriptions();
      await client.dispose();
      emit(state.copyWith(status: HomeStatus.error, lastError: '$err'));
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
    await _detachSubscriptions();
    _client = null;
    _sessionCreatedAt = null;
    emit(state.copyWith(status: HomeStatus.initial, micEnabled: false, clearError: true));
    _appendEventLog(
      direction: LogDirection.client,
      type: 'connection',
      payload: {'message': 'Disconnected'},
      rawEvent: {'message': 'Disconnected'},
    );
  }

  Future<void> sendPrompt() async {
    if (!state.prompt.isValid) return;
    final prompt = state.prompt.value.trim();

    final client = _client;
    if (client == null) {
      emit(state.copyWith(lastError: 'Connect first.'));
      return;
    }
    await client.sendText(prompt);
  }

  Future<void> toggleMic() async {
    final client = _client;
    if (client == null) {
      emit(state.copyWith(lastError: 'Connect first.'));
      return;
    }
    final enable = !_isMicEnabled;
    try {
      if (enable) {
        await client.enableMicrophone();
      } else {
        await client.disableMicrophone();
      }
      emit(state.copyWith(micEnabled: enable, clearError: true));
    } catch (err) {
      emit(state.copyWith(lastError: '$err'));
    }
  }

  void _handleServerEvent(RealtimeServerEvent event) {
    final now = DateTime.now();
    _MessageUpdate? messageUpdate;
    switch (event) {
      case SessionCreatedEvent():
        _sessionCreatedAt = now;
        break;
      case ConversationItemInputTranscriptionDelta e:
        messageUpdate = _MessageUpdate.delta(
          id: _inputTranscriptId(e.itemId, e.contentIndex),
          direction: LogDirection.client,
          delta: e.delta,
        );
        break;
      case ConversationItemInputTranscriptionCompleted e:
        messageUpdate = _MessageUpdate.text(
          id: _inputTranscriptId(e.itemId, e.contentIndex),
          direction: LogDirection.client,
          text: e.transcript,
        );
        break;
      case ResponseOutputTextDeltaEvent e:
        final outputKey = _outputKey(e.itemId, e.outputIndex, e.contentIndex);
        _responseTextKeys.add(outputKey);
        messageUpdate = _MessageUpdate.delta(
          id: _outputTextId(outputKey),
          direction: LogDirection.server,
          delta: e.delta,
        );
        break;
      case ResponseOutputTextDoneEvent e:
        final outputKey = _outputKey(e.itemId, e.outputIndex, e.contentIndex);
        _responseTextKeys.add(outputKey);
        messageUpdate = _MessageUpdate.text(
          id: _outputTextId(outputKey),
          direction: LogDirection.server,
          text: e.text,
        );
        break;
      case ResponseOutputAudioTranscriptDeltaEvent e:
        final outputKey = _outputKey(e.itemId, e.outputIndex, e.contentIndex);
        if (_responseTextKeys.contains(outputKey)) break;
        messageUpdate = _MessageUpdate.delta(
          id: _outputAudioTranscriptId(outputKey),
          direction: LogDirection.server,
          delta: e.delta,
        );
        break;
      case ResponseOutputAudioTranscriptDoneEvent e:
        final outputKey = _outputKey(e.itemId, e.outputIndex, e.contentIndex);
        if (_responseTextKeys.contains(outputKey)) break;
        messageUpdate = _MessageUpdate.text(
          id: _outputAudioTranscriptId(outputKey),
          direction: LogDirection.server,
          text: e.transcript,
        );
        break;
      case InputAudioBufferSpeechStartedEvent():
      case InputAudioBufferClearedEvent():
      case InputAudioBufferSpeechStoppedEvent():
      case InputAudioBufferTimeoutTriggeredEvent():
      case ServerErrorEvent():
      case SessionUpdatedEvent():
      case ConversationItemAddedEvent():
      case ConversationItemDoneEvent():
      case ConversationItemRetrievedEvent():
      case ConversationItemInputTranscriptionSegment():
      case ConversationItemInputTranscriptionFailed():
      case ConversationItemTruncatedEvent():
      case ConversationItemDeletedEvent():
      case InputAudioBufferCommittedEvent():
      case InputAudioBufferDtmfEvent():
      case OutputAudioBufferStartedEvent():
      case OutputAudioBufferStoppedEvent():
      case OutputAudioBufferClearedEvent():
      case ResponseCreatedEvent():
      case ResponseDoneEvent():
      case ResponseOutputItemAddedEvent():
      case ResponseOutputItemDoneEvent():
      case ResponseContentPartAddedEvent():
      case ResponseContentPartDoneEvent():
      case ResponseOutputAudioDeltaEvent():
      case ResponseOutputAudioDoneEvent():
      case ResponseFunctionCallArgumentsDeltaEvent():
      case ResponseFunctionCallArgumentsDoneEvent():
      case ResponseMcpCallArgumentsDeltaEvent():
      case ResponseMcpCallArgumentsDoneEvent():
      case ResponseMcpCallInProgressEvent():
      case ResponseMcpCallCompletedEvent():
      case ResponseMcpCallFailedEvent():
      case McpListToolsInProgressEvent():
      case McpListToolsCompletedEvent():
      case McpListToolsFailedEvent():
      case RateLimitsUpdatedEvent():
      case UnknownServerEvent():
        break;
    }
    if (messageUpdate != null) {
      _applyMessageChange(
        id: messageUpdate.id,
        direction: messageUpdate.direction,
        delta: messageUpdate.delta,
        text: messageUpdate.text,
      );
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
    String? inputText;
    switch (event) {
      case ConversationItemCreateEvent e:
        inputText = _extractInputText(e.item);
        break;
      case SessionUpdateEvent():
      case InputAudioBufferAppendEvent():
      case InputAudioBufferCommitEvent():
      case InputAudioBufferClearEvent():
      case ConversationItemRetrieveEvent():
      case ConversationItemTruncateEvent():
      case ConversationItemDeleteEvent():
      case ResponseCreateEvent():
      case ResponseCancelEvent():
      case OutputAudioBufferClearEvent():
        break;
    }
    if (inputText != null) {
      _applyMessageChange(
        id: _nextClientMessageId(),
        direction: LogDirection.client,
        text: inputText,
      );
    }
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
    JsonMap? inputAudioTranscription,
    List<String>? outputModalities,
    RealtimeTurnDetection? turnDetection,
  }) async {
    if (!_isConnected || _client == null) return;
    final session = RealtimeSessionConfig(
      voice: includeVoice ? state.voice.value.trim() : null,
      inputAudioTranscription: inputAudioTranscription,
      outputModalities: outputModalities,
      turnDetection: turnDetection,
      instructions: includeInstructions
          ? state.instructions.value.trim().isEmpty
                ? null
                : state.instructions.value.trim()
          : null,
    );
    if (session.voice == null &&
        session.instructions == null &&
        session.inputAudioTranscription == null &&
        session.outputModalities == null &&
        session.turnDetection == null) {
      return;
    }
    await _client!.sendEvent(SessionUpdateEvent(session: session));
  }

  Future<void> _attachSubscriptions(OpenAIRealtimeClient client) async {
    await _detachSubscriptions();
    _sessionCreatedAt = null;
    _serverSubscription = client.serverEvents.listen(
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
    _clientSubscription = client.clientEvents.listen(
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

  Future<void> _detachSubscriptions() async {
    await _serverSubscription?.cancel();
    await _clientSubscription?.cancel();
    _serverSubscription = null;
    _clientSubscription = null;
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

  void _applyMessageChange({
    required String id,
    required LogDirection direction,
    String? delta,
    String? text,
  }) {
    final hasDelta = delta != null && delta.isNotEmpty;
    final hasText = text != null && text.isNotEmpty;
    if (!hasDelta && !hasText) return;

    final incoming = hasDelta ? delta : text!;
    final messages = List<MessageEntry>.from(state.messages);
    final index = _messageIndexById[id];
    if (index != null && index < messages.length) {
      final existing = messages[index];
      final nextText = hasDelta ? existing.text + incoming : incoming;
      if (nextText == existing.text) return;
      messages[index] = existing.copyWith(text: nextText);
    } else {
      _messageIndexById[id] = messages.length;
      messages.add(
        MessageEntry(
          id: id,
          direction: direction,
          text: incoming,
        ),
      );
    }
    emit(state.copyWith(messages: messages));
  }

  String _nextClientMessageId() => 'client_${_messageCounter++}';

  String? _extractInputText(RealtimeItem item) {
    for (final content in item.content) {
      if (content is InputTextContent) {
        final text = content.text.trim();
        if (text.isNotEmpty) return text;
      }
    }
    return null;
  }

  String _inputTranscriptId(String itemId, int contentIndex) => 'input_audio:$itemId:$contentIndex';

  String _outputKey(String itemId, int outputIndex, int contentIndex) => '$itemId:$outputIndex:$contentIndex';

  String _outputTextId(String key) => 'output_text:$key';

  String _outputAudioTranscriptId(String key) => 'output_audio_transcript:$key';

  @override
  Future<void> close() async {
    await _detachSubscriptions();
    await _client?.dispose();
    return super.close();
  }
}

class _MessageUpdate {
  const _MessageUpdate.delta({
    required this.id,
    required this.direction,
    required this.delta,
  }) : text = null;

  const _MessageUpdate.text({
    required this.id,
    required this.direction,
    required this.text,
  }) : delta = null;

  final String id;
  final LogDirection direction;
  final String? delta;
  final String? text;
}
