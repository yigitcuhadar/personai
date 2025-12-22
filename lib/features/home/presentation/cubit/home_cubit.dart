import 'dart:async';
import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
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
import 'package:http/http.dart' as http;

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

  void onApiKeyChanged(String value) {
    if (state.canFixedFieldsChange) emit(state.copyWith(apiKey: ApiKeyInput.dirty(value)));
  }

  void onModelChanged(String value) {
    if (state.canFixedFieldsChange) emit(state.copyWith(model: ModelInput.dirty(value)));
  }

  void onInputAudioTranscriptionChanged(String value) {
    if (state.canFixedFieldsChange)
      emit(
        state.copyWith(
          inputAudioTranscription: InputAudioTranscriptionInput.dirty(value),
        ),
      );
  }

  void onVoiceChanged(String value) {
    if (state.canFixedFieldsChange) emit(state.copyWith(voice: VoiceInput.dirty(value)));
  }

  void onInstructionsChanged(String value) {
    if (state.canUnfixedFieldsChange) emit(state.copyWith(instructions: InstructionsInput.dirty(value)));
  }

  void onPromptChanged(String value) {
    if (state.isConnected) emit(state.copyWith(prompt: PromptInput.dirty(value)));
  }

  void clearLogs() {
    emit(state.copyWith(logs: const []));
  }

  void toggleLogsOrder() {
    emit(state.copyWith(logsReversed: !state.logsReversed));
  }

  Future<void> connect() async {
    if (!state.canConnect && !state.isValid) return;

    emit(state.copyWith(status: HomeStatus.connecting));

    final debugLogging = _config.flavor == Flavor.dev;
    _client = OpenAIRealtimeClient(
      accessToken: state.apiKey.value,
      debug: debugLogging,
    );
    await _attachSubscriptions();

    try {
      final session = RealtimeSessionConfig(
        type: 'realtime',
        model: state.model.value,
      );
      await _client!.connect(
        session: session,
      );
      emit(
        state.copyWith(
          status: HomeStatus.connected,
          micEnabled: false,
        ),
      );
      await _sendSessionUpdate(forceAll: true);
      _appendEventLog(
        direction: LogDirection.client,
        type: 'connection',
        payload: {'message': 'Connected', 'callId': _client!.callId},
        rawEvent: {'message': 'Connected', 'callId': _client!.callId},
      );
    } catch (err) {
      await _detachSubscriptions();
      await _client!.dispose();
      emit(state.copyWith(lastError: '$err'));
      _appendEventLog(
        direction: LogDirection.client,
        type: 'connection.error',
        payload: {'error': '$err'},
        rawEvent: err,
      );
    }
  }

  Future<void> disconnect() async {
    if (_client == null || !state.isConnected) return;
    emit(state.copyWith(status: HomeStatus.disconnecting));
    await _client!.disconnect();
    await _detachSubscriptions();
    _client = null;
    _sessionCreatedAt = null;
    emit(
      state.copyWith(
        status: HomeStatus.initial,
        micEnabled: false,
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
    if (!state.prompt.isValid || _client == null) return;
    final prompt = state.prompt.value.trim();
    await _client!.sendText(prompt);
  }

  Future<void> toggleMic() async {
    if (_client == null) return;
    try {
      if (!state.micEnabled) {
        await _client!.enableMicrophone();
      } else {
        await _client!.disableMicrophone();
      }
      emit(state.copyWith(micEnabled: !state.micEnabled));
    } catch (err) {
      emit(state.copyWith(lastError: '$err'));
    }
  }

  Future<bool> saveSessionChanges() async {
    if (!state.isConnected || _client == null) return false;
    emit(state.copyWith(status: HomeStatus.saving));
    try {
      await _sendSessionUpdate(instructionsChanged: true);
      emit(state.copyWith(status: HomeStatus.connected));
      return true;
    } catch (err) {
      emit(state.copyWith(status: HomeStatus.connected, lastError: '$err'));
      return false;
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
        final item = e.item;
        if (item.type == 'message') {
          final itemId = item.id ?? 'output_item_${e.outputIndex}';
          final outputKey = _outputKey(itemId, e.outputIndex, 0);
          final initialText = item.content
              .whereType<OutputTextContent>()
              .map((c) => c.text.trim())
              .where((text) => text.isNotEmpty)
              .join('\n');
          final initialTranscript = item.content
              .whereType<OutputAudioContent>()
              .map((c) => c.transcript?.trim() ?? '')
              .where((text) => text.isNotEmpty)
              .join('\n');

          final seedText = initialText.isNotEmpty ? initialText : initialTranscript;
          if (seedText.isEmpty) break;

          final useTextId = initialText.isNotEmpty;
          if (useTextId) _responseTextKeys.add(outputKey);
          messageUpdate = _MessageUpdate.text(
            id: useTextId ? _outputTextId(outputKey) : _outputAudioTranscriptId(outputKey),
            direction: LogDirection.server,
            text: seedText,
            isFinal: item.status == 'completed',
          );
        }
        break;
      case ResponseFunctionCallArgumentsDoneEvent e:
        _handleToolCall(e);
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

  Future<void> _handleToolCall(
    ResponseFunctionCallArgumentsDoneEvent event,
  ) async {
    try {
      final params = event.arguments;
      final args = jsonDecode(params) as Map<String, dynamic>;
      if (true) {
        final location = (args['location'] as String);
        await _client?.sendEvent(
          ConversationItemCreateEvent(
            item: RealtimeItem(
              type: 'function_call_output',
              output: jsonEncode(await getWeatherOpenMeteo(location)),
              callId: event.callId,
            ),
          ),
        );
        await _client?.sendEvent(ResponseCreateEvent());
      }
    } catch (_) {}

    return;
  }

  Future<Map<String, dynamic>> getWeatherOpenMeteo(String city) async {
    // 1) Geocoding
    final geoUri = Uri.parse(
      'https://geocoding-api.open-meteo.com/v1/search'
      '?name=${Uri.encodeComponent(city)}&count=1&language=en&format=json',
    );
    final geoRes = await http.get(geoUri);
    if (geoRes.statusCode != 200) throw Exception('Geocoding failed');
    final geoJson = jsonDecode(geoRes.body) as Map<String, dynamic>;
    final results = (geoJson['results'] as List?) ?? [];
    if (results.isEmpty) throw Exception('City not found');

    final first = results.first as Map<String, dynamic>;
    final lat = first['latitude'];
    final lon = first['longitude'];

    // 2) Forecast / current
    final wxUri = Uri.parse(
      'https://api.open-meteo.com/v1/forecast'
      '?latitude=$lat&longitude=$lon'
      '&current=temperature_2m,relative_humidity_2m,weather_code,wind_speed_10m'
      '&timezone=auto',
    );
    final wxRes = await http.get(wxUri);
    if (wxRes.statusCode != 200) throw Exception('Weather fetch failed');
    final wxJson = jsonDecode(wxRes.body) as Map<String, dynamic>;

    // Realtime tool output olarak döneceğin “sade” payload
    final current = (wxJson['current'] as Map<String, dynamic>?) ?? {};
    return {
      'location': {'name': first['name'], 'country': first['country']},
      'temp_c': current['temperature_2m'],
      'humidity': current['relative_humidity_2m'],
      'weather_code': current['weather_code'],
      'wind_kmh': current['wind_speed_10m'],
    };
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
    if (_client == null) return;

    final includeInstructions = forceAll || instructionsChanged;
    final includeVoice = forceAll;
    final includeAudioTranscription = forceAll;

    final session = RealtimeSessionConfig(
      voice: includeVoice ? state.voice.value : null,
      instructions: includeInstructions ? state.instructions.value.trim() : null,
      inputAudioTranscription: includeAudioTranscription ? {'model': state.inputAudioTranscription.value} : null,
      tools: [
        RealtimeTool(
          type: 'function',
          name: 'get_weather',
          description: 'Determine weather in my location',
          parameters: {
            "type": "object",
            "properties": {
              "location": {
                "type": "string",
                "description": "The city and state e.g. San Francisco, CA",
              },
              "unit": {
                "type": "string",
                "enum": ["c", "f"],
              },
            },
            "additionalProperties": false,
            "required": ["location", "unit"],
          },
        ),
        RealtimeTool(
          type: 'function',
          name: 'get_stock_price',
          description: 'Get the current stock price',
          parameters: {
            "type": "object",
            "properties": {
              "symbol": {"type": "string", "description": "The stock symbol"},
            },
            "additionalProperties": false,
            "required": ["symbol"],
          },
        ),
      ],
    );
    if (session.voice == null && session.instructions == null && session.inputAudioTranscription == null) {
      return;
    }
    await _client!.sendEvent(SessionUpdateEvent(session: session));
  }

  Future<void> _attachSubscriptions() async {
    await _detachSubscriptions();
    _sessionCreatedAt = null;
    _serverSubscription = _client!.serverEvents.listen(
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
    _clientSubscription = _client!.clientEvents.listen(
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
