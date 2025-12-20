import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:formz/formz.dart';
import 'package:openai_realtime/openai_realtime.dart';

import '../../../../app/config/app_config.dart';
import '../models/inputs/api_key_input.dart';
import '../models/inputs/instructions_input.dart';
import '../models/inputs/input_audio_transcription_input.dart';
import '../models/inputs/model_input.dart';
import '../models/inputs/prompt_input.dart';
import '../models/inputs/voice_input.dart';
import '../models/log_entry.dart';
import '../models/message_entry.dart';

part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit({required AppConfig config, String defaultApiKey = ''})
    : _config = config,
      super(
        HomeState(
          apiKey: ApiKeyInput.pure(defaultApiKey.trim()),
        ),
      );

  final AppConfig _config;
  OpenAIRealtimeClient? _client;
  StreamSubscription<RealtimeServerEvent>? _serverSubscription;
  StreamSubscription<RealtimeClientEvent>? _clientSubscription;

  DateTime? _sessionCreatedAt;
  final Map<String, int> _messageIndexById = <String, int>{};
  final Set<String> _responseTextKeys = <String>{};
  String? _lastSentInstructions;

  bool get _isConnecting => state.status == HomeStatus.connecting;
  bool get _isConnected => state.status == HomeStatus.connected;
  bool get _isMicEnabled => state.micEnabled;
  bool get hasPendingInstructionChanges => _isConnected && _hasInstructionsChanged(state.instructions.value);

  void onApiKeyChanged(String value) {
    if (_isConnected) return;
    emit(state.copyWith(apiKey: ApiKeyInput.dirty(value), clearError: true));
  }

  void onModelChanged(String value) {
    if (_isConnected) return;
    emit(state.copyWith(model: ModelInput.dirty(value), clearError: true));
  }

  void onPromptChanged(String value) {
    emit(state.copyWith(prompt: PromptInput.dirty(value), clearError: true));
  }

  void onInstructionsChanged(String value) {
    emit(
      state.copyWith(
        instructions: InstructionsInput.dirty(value),
        clearError: true,
      ),
    );
  }

  void onInputAudioTranscriptionChanged(String value) {
    if (_isConnected) return;
    emit(
      state.copyWith(
        inputAudioTranscription: InputAudioTranscriptionInput.dirty(value),
        clearError: true,
      ),
    );
  }

  void onVoiceChanged(String value) {
    if (_isConnected) return;
    emit(state.copyWith(voice: VoiceInput.dirty(value), clearError: true));
  }

  void clearLogs() {
    emit(state.copyWith(logs: const []));
  }

  void toggleLogsOrder() {
    emit(state.copyWith(logsReversed: !state.logsReversed));
  }

  Future<void> connect() async {
    if (_isConnecting || _isConnected) return;

    final apiKey = ApiKeyInput.dirty(state.apiKey.value.trim());
    final model = ModelInput.dirty(state.model.value.trim());
    final inputAudioTranscription = InputAudioTranscriptionInput.dirty(
      state.inputAudioTranscription.value,
    );
    final voice = VoiceInput.dirty(state.voice.value);
    final isValid = Formz.validate([
      apiKey,
      model,
      voice,
      inputAudioTranscription,
    ]);
    if (!isValid) {
      emit(
        state.copyWith(
          apiKey: apiKey,
          model: model,
          inputAudioTranscription: inputAudioTranscription,
          voice: voice,
          lastError: 'API key, model, voice, and input transcription model are required.',
        ),
      );
      return;
    }

    _lastSentInstructions = null;
    emit(
      state.copyWith(
        status: HomeStatus.connecting,
        apiKey: apiKey,
        model: model,
        inputAudioTranscription: inputAudioTranscription,
        voice: voice,
        clearError: true,
      ),
    );

    final debugLogging = _config.flavor == Flavor.dev;
    final client = OpenAIRealtimeClient(
      accessToken: apiKey.value,
      debug: debugLogging,
    );
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
      emit(
        state.copyWith(
          status: HomeStatus.connected,
          micEnabled: false,
          clearError: true,
        ),
      );
      await _sendSessionUpdate(forceAll: true);
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
    _lastSentInstructions = null;
    emit(
      state.copyWith(
        status: HomeStatus.initial,
        micEnabled: false,
        clearError: true,
      ),
    );
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

  Future<void> saveSessionChanges() async {
    if (!_isConnected || _client == null) {
      emit(state.copyWith(lastError: 'Connect first.'));
      return;
    }
    final hasChanges = _hasInstructionsChanged(state.instructions.value);
    if (!hasChanges) return;
    await _sendSessionUpdate(instructionsChanged: true);
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
          isFinal: false,
        );
        break;
      case ConversationItemInputTranscriptionCompleted e:
        messageUpdate = _MessageUpdate.text(
          id: _inputTranscriptId(e.itemId, e.contentIndex),
          direction: LogDirection.client,
          text: e.transcript,
          isFinal: true,
        );
        break;
      case ConversationItemInputTranscriptionFailed e:
        messageUpdate = _MessageUpdate.text(
          id: _inputTranscriptId(e.itemId, e.contentIndex),
          direction: LogDirection.client,
          text: 'Transcription failed: ${e.error.message}',
          isFinal: true,
        );
        break;
      case ResponseOutputTextDeltaEvent e:
        final outputKey = _outputKey(e.itemId, e.outputIndex, e.contentIndex);
        _responseTextKeys.add(outputKey);
        messageUpdate = _MessageUpdate.delta(
          id: _outputTextId(outputKey),
          direction: LogDirection.server,
          delta: e.delta,
          isFinal: false,
        );
        break;
      case ResponseOutputTextDoneEvent e:
        final outputKey = _outputKey(e.itemId, e.outputIndex, e.contentIndex);
        _responseTextKeys.add(outputKey);
        messageUpdate = _MessageUpdate.text(
          id: _outputTextId(outputKey),
          direction: LogDirection.server,
          text: e.text,
          isFinal: true,
        );
        break;
      case ResponseOutputAudioTranscriptDeltaEvent e:
        final outputKey = _outputKey(e.itemId, e.outputIndex, e.contentIndex);
        if (_responseTextKeys.contains(outputKey)) break;
        messageUpdate = _MessageUpdate.delta(
          id: _outputAudioTranscriptId(outputKey),
          direction: LogDirection.server,
          delta: e.delta,
          isFinal: false,
        );
        break;
      case ResponseOutputAudioTranscriptDoneEvent e:
        final outputKey = _outputKey(e.itemId, e.outputIndex, e.contentIndex);
        if (_responseTextKeys.contains(outputKey)) break;
        messageUpdate = _MessageUpdate.text(
          id: _outputAudioTranscriptId(outputKey),
          direction: LogDirection.server,
          text: e.transcript,
          isFinal: true,
        );
        break;
      case ResponseOutputItemDoneEvent e:
        if (e.item.status == 'incomplete') {
          final baseKey = _outputKey(e.item.id ?? 'unknown', e.outputIndex, 0);
          _markMessageInterrupted(_outputAudioTranscriptId(baseKey));
          _markMessageInterrupted(_outputTextId(baseKey));
        }
        break;
      case ConversationItemAddedEvent e:
        final item = e.item;
        if (item.role == 'user') {
          final inputText = item.content
              .whereType<InputTextContent>()
              .map((c) => c.text.trim())
              .where((text) => text.isNotEmpty)
              .join('\n');
          messageUpdate = _MessageUpdate.text(
            id: _inputTranscriptId(item.id ?? 'unknown', 0),
            direction: LogDirection.client,
            text: inputText,
            isFinal: true,
          );
        }
        break;
      case ResponseOutputItemAddedEvent e:
        final itemId = e.item.id ?? 'output_item_${e.outputIndex}';
        final placeholderKey = _outputKey(itemId, e.outputIndex, 0);
        messageUpdate = _MessageUpdate.text(
          id: _outputAudioTranscriptId(placeholderKey),
          direction: LogDirection.server,
          text: '',
          isFinal: true,
        );
        break;
      case InputAudioBufferSpeechStartedEvent():
      case InputAudioBufferClearedEvent():
      case InputAudioBufferSpeechStoppedEvent():
      case InputAudioBufferTimeoutTriggeredEvent():
      case ServerErrorEvent():
      case SessionUpdatedEvent():
      case ConversationItemDoneEvent():
      case ConversationItemRetrievedEvent():
      case ConversationItemInputTranscriptionSegment():
      case ConversationItemTruncatedEvent():
      case ConversationItemDeletedEvent():
      case InputAudioBufferCommittedEvent():
      case InputAudioBufferDtmfEvent():
      case OutputAudioBufferStartedEvent():
      case OutputAudioBufferStoppedEvent():
      case OutputAudioBufferClearedEvent():
      case ResponseCreatedEvent():
      case ResponseDoneEvent():
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
        isFinal: messageUpdate.isFinal,
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
    switch (event) {
      case ConversationItemCreateEvent():
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
    _appendEventLog(
      direction: LogDirection.client,
      type: event.type,
      payload: event.toJson(),
      rawEvent: event,
    );
  }

  Future<void> _sendSessionUpdate({
    bool forceAll = false,
    bool instructionsChanged = false,
  }) async {
    if (!_isConnected || _client == null) return;
    final client = _client;
    if (client == null) return;

    final includeInstructions = forceAll || instructionsChanged;
    final includeVoice = forceAll;
    final includeAudioTranscription = forceAll;

    if (!includeInstructions && !includeVoice && !includeAudioTranscription) return;

    final normalizedInstructions = state.instructions.value.trim();
    final session = RealtimeSessionConfig(
      voice: includeVoice ? state.voice.value : null,
      instructions: includeInstructions ? normalizedInstructions : null,
      inputAudioTranscription:
          includeAudioTranscription ? {'model': state.inputAudioTranscription.value} : null,
    );
    if (session.voice == null && session.instructions == null && session.inputAudioTranscription == null) {
      return;
    }
    await client.sendEvent(SessionUpdateEvent(session: session));
    if (includeInstructions) {
      _lastSentInstructions = normalizedInstructions;
      emit(state.copyWith());
    }
  }

  bool _hasInstructionsChanged(String next) => _lastSentInstructions != next.trim();

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
    bool isFinal = false,
    bool interrupt = false,
  }) {
    final hasDelta = delta != null && delta.isNotEmpty;
    final hasText = text != null && text.isNotEmpty;
    final incoming = delta ?? text ?? '';
    if (!hasDelta && !hasText && !isFinal) return;

    final messages = List<MessageEntry>.from(state.messages);
    final index = _messageIndexById[id];
    final nextStreaming = isFinal ? false : hasDelta;
    if (index != null && index < messages.length) {
      final existing = messages[index];
      final nextText = hasDelta
          ? existing.text + incoming
          : incoming.isEmpty
          ? existing.text
          : incoming;
      final shouldStream = isFinal ? false : (hasDelta || existing.isStreaming);
      final shouldInterrupt = interrupt || existing.isInterrupted;
      if (nextText == existing.text && existing.isStreaming == shouldStream && existing.isInterrupted == shouldInterrupt) {
        return;
      }
      messages[index] = existing.copyWith(
        text: nextText,
        isStreaming: shouldStream,
        isInterrupted: shouldInterrupt,
      );
    } else {
      _messageIndexById[id] = messages.length;
      messages.add(
        MessageEntry(
          id: id,
          direction: direction,
          text: incoming,
          isStreaming: nextStreaming,
          isInterrupted: interrupt,
        ),
      );
    }
    emit(state.copyWith(messages: messages));
  }

  String _inputTranscriptId(String itemId, int contentIndex) => 'input_audio:$itemId:$contentIndex';

  String _outputKey(String itemId, int outputIndex, int contentIndex) => '$itemId:$outputIndex:$contentIndex';

  String _outputTextId(String key) => 'output_text:$key';

  String _outputAudioTranscriptId(String key) => 'output_audio_transcript:$key';

  void _markMessageInterrupted(String id) {
    final index = _messageIndexById[id];
    if (index == null || index >= state.messages.length) return;
    final direction = state.messages[index].direction;
    _applyMessageChange(
      id: id,
      direction: direction,
      interrupt: true,
      isFinal: true,
    );
  }

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
    required this.isFinal,
  }) : text = null;

  const _MessageUpdate.text({
    required this.id,
    required this.direction,
    required this.text,
    required this.isFinal,
  }) : delta = null;

  final String id;
  final LogDirection direction;
  final String? delta;
  final String? text;
  final bool isFinal;
}
