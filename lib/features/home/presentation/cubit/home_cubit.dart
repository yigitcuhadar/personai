import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:formz/formz.dart';
import 'package:openai_realtime/openai_realtime.dart';

import '../models/log_entry.dart';
import '../models/message_entry.dart';

part 'home_state.dart';

class ApiKeyInput extends FormzInput<String, String> {
  const ApiKeyInput.pure([super.value = '']) : super.pure();
  const ApiKeyInput.dirty([super.value = '']) : super.dirty();

  @override
  String? validator(String value) => value.trim().isEmpty ? 'API key is required' : null;
}

class ModelInput extends FormzInput<String, String> {
  const ModelInput.pure([super.value = 'gpt-realtime']) : super.pure();
  const ModelInput.dirty([super.value = 'gpt-realtime']) : super.dirty();

  @override
  String? validator(String value) => value.trim().isEmpty ? 'Model is required' : null;
}

class PromptInput extends FormzInput<String, String> {
  const PromptInput.pure([super.value = '']) : super.pure();
  const PromptInput.dirty([super.value = '']) : super.dirty();

  @override
  String? validator(String value) => value.trim().isEmpty ? 'Prompt is required' : null;
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
  String? validator(String value) => realtimeVoiceNames.contains(value) ? null : 'Invalid voice';
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
  StreamSubscription<MediaStreamTrack>? _remoteAudioSub;
  final StreamController<MediaStreamTrack> _remoteAudioTracks = StreamController<MediaStreamTrack>.broadcast();
  DateTime? _sessionCreatedAt;
  final Map<String, int> _messageIndexById = <String, int>{};
  final Set<String> _responseTextKeys = <String>{};
  int _messageCounter = 0;

  bool get _isConnecting => state.status == HomeStatus.connecting;
  bool get _isConnected => state.status == HomeStatus.connected;
  bool get _canChangeConfig => !_isConnecting && !_isConnected;

  Stream<MediaStreamTrack> get remoteAudioTracks => _remoteAudioTracks.stream;

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
      await _stopMicrophone(updateSession: false);
      emit(
        state.copyWith(
          status: HomeStatus.connected,
          callId: client.callId,
          micStatus: MicStatus.off,
          isUserSpeaking: false,
          clearError: true,
        ),
      );
      await _sendSessionUpdate(includeVoice: true, includeInstructions: true);
      _appendEventLog(
        direction: LogDirection.client,
        type: 'connection',
        payload: {'message': 'Connected', 'callId': client.callId},
        rawEvent: {'message': 'Connected', 'callId': client.callId},
      );
    } catch (err) {
      await _detachClientStreams();
      await client.dispose();
      emit(
        state.copyWith(
          status: HomeStatus.error,
          callId: null,
          micStatus: MicStatus.off,
          isUserSpeaking: false,
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
    await _stopMicrophone(updateSession: false);
    await client.disconnect();
    await _detachClientStreams();
    _client = null;
    _sessionCreatedAt = null;
    emit(
      state.copyWith(
        status: HomeStatus.initial,
        callId: null,
        micStatus: MicStatus.off,
        isUserSpeaking: false,
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

  Future<void> toggleMicrophone() async {
    if (state.micStatus == MicStatus.starting || state.micStatus == MicStatus.stopping) {
      return;
    }
    if (state.micStatus == MicStatus.on) {
      await disableMicrophone();
    } else {
      await enableMicrophone();
    }
  }

  Future<void> enableMicrophone() async {
    if (!_isConnected || _client == null) {
      emit(state.copyWith(lastError: 'Connect first.'));
      return;
    }
    if (state.micStatus == MicStatus.on || state.micStatus == MicStatus.starting) return;

    emit(state.copyWith(micStatus: MicStatus.starting, clearError: true));
    try {
      await _client!.enableMicrophone();
      await _sendSessionUpdate(
        includeVoice: true,
        includeInstructions: false,
        inputAudioTranscription: const {'model': 'whisper-1'},
        outputModalities: const ['audio', 'text'],
        turnDetection: const RealtimeTurnDetection(
          type: 'server_vad',
          createResponse: true,
          interruptResponse: true,
        ),
      );
      emit(state.copyWith(micStatus: MicStatus.on, clearError: true));
      _appendEventLog(
        direction: LogDirection.client,
        type: 'microphone',
        payload: {'enabled': true},
        rawEvent: {'enabled': true},
      );
    } catch (err) {
      await _stopMicrophone(updateSession: false);
      emit(
        state.copyWith(
          micStatus: MicStatus.off,
          lastError: 'Microphone error: $err',
        ),
      );
    }
  }

  Future<void> disableMicrophone() async {
    if (state.micStatus == MicStatus.off || state.micStatus == MicStatus.stopping) return;

    emit(state.copyWith(micStatus: MicStatus.stopping, isUserSpeaking: false, clearError: true));
    try {
      await _stopMicrophone(updateSession: true);
      emit(state.copyWith(micStatus: MicStatus.off, clearError: true));
      _appendEventLog(
        direction: LogDirection.client,
        type: 'microphone',
        payload: {'enabled': false},
        rawEvent: {'enabled': false},
      );
    } catch (err) {
      emit(
        state.copyWith(
          micStatus: MicStatus.off,
          lastError: 'Microphone error: $err',
        ),
      );
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
        _setUserSpeaking(true);
        break;
      case InputAudioBufferClearedEvent():
      case InputAudioBufferSpeechStoppedEvent():
      case InputAudioBufferTimeoutTriggeredEvent():
        _setUserSpeaking(false);
        break;
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
    _remoteAudioSub = client.remoteAudioTracks.listen(
      _remoteAudioTracks.add,
      onError: (err, stack) {
        _appendEventLog(
          direction: LogDirection.client,
          type: 'audio.error',
          payload: {'error': '$err'},
          rawEvent: err,
        );
      },
    );
  }

  Future<void> _detachClientStreams() async {
    await _eventSub?.cancel();
    await _clientEventSub?.cancel();
    await _remoteAudioSub?.cancel();
    _eventSub = null;
    _clientEventSub = null;
    _remoteAudioSub = null;
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

  void _setUserSpeaking(bool value) {
    if (state.isUserSpeaking == value) return;
    emit(state.copyWith(isUserSpeaking: value));
  }

  Future<void> _stopMicrophone({required bool updateSession}) async {
    try {
      await _client?.disableMicrophone();
    } catch (err) {
      _appendEventLog(
        direction: LogDirection.client,
        type: 'microphone.error',
        payload: {'error': '$err'},
        rawEvent: err,
      );
    }
    if (updateSession) {
      await _sendSessionUpdate(
        includeVoice: false,
        includeInstructions: false,
        outputModalities: const ['text'],
        turnDetection: const RealtimeTurnDetection(type: 'none'),
      );
    }
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
    await _stopMicrophone(updateSession: false);
    await _detachClientStreams();
    await _client?.dispose();
    await _remoteAudioTracks.close();
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
