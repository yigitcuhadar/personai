part of 'realtime_models.dart';

/// Base class for server-originated events.
sealed class RealtimeServerEvent {
  String get type;
  String? get eventId;

  JsonMap toJson();

  static RealtimeServerEvent fromJson(JsonMap json) {
    final type = json['type'] as String?;
    if (type == null) {
      throw ArgumentError('Server event missing "type" field.');
    }
    switch (type) {
      case ServerErrorEvent.eventType:
        return ServerErrorEvent.fromJson(json);
      case SessionCreatedEvent.eventType:
        return SessionCreatedEvent.fromJson(json);
      case SessionUpdatedEvent.eventType:
        return SessionUpdatedEvent.fromJson(json);
      case ConversationItemAddedEvent.eventType:
        return ConversationItemAddedEvent.fromJson(json);
      case ConversationItemDoneEvent.eventType:
        return ConversationItemDoneEvent.fromJson(json);
      case ConversationItemRetrievedEvent.eventType:
        return ConversationItemRetrievedEvent.fromJson(json);
      case ConversationItemInputTranscriptionCompleted.eventType:
        return ConversationItemInputTranscriptionCompleted.fromJson(json);
      case ConversationItemInputTranscriptionDelta.eventType:
        return ConversationItemInputTranscriptionDelta.fromJson(json);
      case ConversationItemInputTranscriptionSegment.eventType:
        return ConversationItemInputTranscriptionSegment.fromJson(json);
      case ConversationItemInputTranscriptionFailed.eventType:
        return ConversationItemInputTranscriptionFailed.fromJson(json);
      case ConversationItemTruncatedEvent.eventType:
        return ConversationItemTruncatedEvent.fromJson(json);
      case ConversationItemDeletedEvent.eventType:
        return ConversationItemDeletedEvent.fromJson(json);
      case InputAudioBufferCommittedEvent.eventType:
        return InputAudioBufferCommittedEvent.fromJson(json);
      case InputAudioBufferDtmfEvent.eventType:
        return InputAudioBufferDtmfEvent.fromJson(json);
      case InputAudioBufferClearedEvent.eventType:
        return InputAudioBufferClearedEvent.fromJson(json);
      case InputAudioBufferSpeechStartedEvent.eventType:
        return InputAudioBufferSpeechStartedEvent.fromJson(json);
      case InputAudioBufferSpeechStoppedEvent.eventType:
        return InputAudioBufferSpeechStoppedEvent.fromJson(json);
      case InputAudioBufferTimeoutTriggeredEvent.eventType:
        return InputAudioBufferTimeoutTriggeredEvent.fromJson(json);
      case OutputAudioBufferStartedEvent.eventType:
        return OutputAudioBufferStartedEvent.fromJson(json);
      case OutputAudioBufferStoppedEvent.eventType:
        return OutputAudioBufferStoppedEvent.fromJson(json);
      case OutputAudioBufferClearedEvent.eventType:
        return OutputAudioBufferClearedEvent.fromJson(json);
      case ResponseCreatedEvent.eventType:
        return ResponseCreatedEvent.fromJson(json);
      case ResponseDoneEvent.eventType:
        return ResponseDoneEvent.fromJson(json);
      case ResponseOutputItemAddedEvent.eventType:
        return ResponseOutputItemAddedEvent.fromJson(json);
      case ResponseOutputItemDoneEvent.eventType:
        return ResponseOutputItemDoneEvent.fromJson(json);
      case ResponseContentPartAddedEvent.eventType:
        return ResponseContentPartAddedEvent.fromJson(json);
      case ResponseContentPartDoneEvent.eventType:
        return ResponseContentPartDoneEvent.fromJson(json);
      case ResponseOutputTextDeltaEvent.eventType:
        return ResponseOutputTextDeltaEvent.fromJson(json);
      case ResponseOutputTextDoneEvent.eventType:
        return ResponseOutputTextDoneEvent.fromJson(json);
      case ResponseOutputAudioTranscriptDeltaEvent.eventType:
        return ResponseOutputAudioTranscriptDeltaEvent.fromJson(json);
      case ResponseOutputAudioTranscriptDoneEvent.eventType:
        return ResponseOutputAudioTranscriptDoneEvent.fromJson(json);
      case ResponseOutputAudioDeltaEvent.eventType:
        return ResponseOutputAudioDeltaEvent.fromJson(json);
      case ResponseOutputAudioDoneEvent.eventType:
        return ResponseOutputAudioDoneEvent.fromJson(json);
      case ResponseFunctionCallArgumentsDeltaEvent.eventType:
        return ResponseFunctionCallArgumentsDeltaEvent.fromJson(json);
      case ResponseFunctionCallArgumentsDoneEvent.eventType:
        return ResponseFunctionCallArgumentsDoneEvent.fromJson(json);
      case ResponseMcpCallArgumentsDeltaEvent.eventType:
        return ResponseMcpCallArgumentsDeltaEvent.fromJson(json);
      case ResponseMcpCallArgumentsDoneEvent.eventType:
        return ResponseMcpCallArgumentsDoneEvent.fromJson(json);
      case ResponseMcpCallInProgressEvent.eventType:
        return ResponseMcpCallInProgressEvent.fromJson(json);
      case ResponseMcpCallCompletedEvent.eventType:
        return ResponseMcpCallCompletedEvent.fromJson(json);
      case ResponseMcpCallFailedEvent.eventType:
        return ResponseMcpCallFailedEvent.fromJson(json);
      case McpListToolsInProgressEvent.eventType:
        return McpListToolsInProgressEvent.fromJson(json);
      case McpListToolsCompletedEvent.eventType:
        return McpListToolsCompletedEvent.fromJson(json);
      case McpListToolsFailedEvent.eventType:
        return McpListToolsFailedEvent.fromJson(json);
      case RateLimitsUpdatedEvent.eventType:
        return RateLimitsUpdatedEvent.fromJson(json);
      default:
        return UnknownServerEvent(type: type, raw: json);
    }
  }
}

/// Error response from the server.
@JsonSerializable(explicitToJson: true, includeIfNull: false)
class ServerErrorEvent implements RealtimeServerEvent {
  const ServerErrorEvent({
    @JsonKey(name: 'event_id') this.eventId,
    required this.error,
  });

  factory ServerErrorEvent.fromJson(JsonMap json) =>
      _$ServerErrorEventFromJson(json);

  static const String eventType = 'error';

  @override
  @JsonKey(name: 'event_id')
  final String? eventId;

  final RealtimeApiError error;

  @override
  String get type => eventType;

  @override
  JsonMap toJson() => _$ServerErrorEventToJson(this)..['type'] = type;
}

/// Session created event.
@JsonSerializable(explicitToJson: true, includeIfNull: false)
class SessionCreatedEvent implements RealtimeServerEvent {
  const SessionCreatedEvent({
    @JsonKey(name: 'event_id') this.eventId,
    required this.session,
  });

  factory SessionCreatedEvent.fromJson(JsonMap json) =>
      _$SessionCreatedEventFromJson(json);

  static const String eventType = 'session.created';

  @override
  @JsonKey(name: 'event_id')
  final String? eventId;

  final RealtimeSessionConfig session;

  @override
  String get type => eventType;

  @override
  JsonMap toJson() => _$SessionCreatedEventToJson(this)..['type'] = type;
}

/// Session updated event.
@JsonSerializable(explicitToJson: true, includeIfNull: false)
class SessionUpdatedEvent implements RealtimeServerEvent {
  const SessionUpdatedEvent({
    @JsonKey(name: 'event_id') this.eventId,
    required this.session,
  });

  factory SessionUpdatedEvent.fromJson(JsonMap json) =>
      _$SessionUpdatedEventFromJson(json);

  static const String eventType = 'session.updated';

  @override
  @JsonKey(name: 'event_id')
  final String? eventId;

  final RealtimeSessionConfig session;

  @override
  String get type => eventType;

  @override
  JsonMap toJson() => _$SessionUpdatedEventToJson(this)..['type'] = type;
}

/// Item added to the conversation.
@JsonSerializable(explicitToJson: true, includeIfNull: false)
class ConversationItemAddedEvent implements RealtimeServerEvent {
  const ConversationItemAddedEvent({
    @JsonKey(name: 'event_id') this.eventId,
    required this.item,
    @JsonKey(name: 'previous_item_id') this.previousItemId,
  });

  factory ConversationItemAddedEvent.fromJson(JsonMap json) =>
      _$ConversationItemAddedEventFromJson(json);

  static const String eventType = 'conversation.item.added';

  @override
  @JsonKey(name: 'event_id')
  final String? eventId;

  final RealtimeItem item;

  @JsonKey(name: 'previous_item_id')
  final String? previousItemId;

  @override
  String get type => eventType;

  @override
  JsonMap toJson() => _$ConversationItemAddedEventToJson(this)..['type'] = type;
}

/// Item completed.
@JsonSerializable(explicitToJson: true, includeIfNull: false)
class ConversationItemDoneEvent implements RealtimeServerEvent {
  const ConversationItemDoneEvent({
    @JsonKey(name: 'event_id') this.eventId,
    required this.item,
    @JsonKey(name: 'previous_item_id') this.previousItemId,
  });

  factory ConversationItemDoneEvent.fromJson(JsonMap json) =>
      _$ConversationItemDoneEventFromJson(json);

  static const String eventType = 'conversation.item.done';

  @override
  @JsonKey(name: 'event_id')
  final String? eventId;

  final RealtimeItem item;

  @JsonKey(name: 'previous_item_id')
  final String? previousItemId;

  @override
  String get type => eventType;

  @override
  JsonMap toJson() => _$ConversationItemDoneEventToJson(this)..['type'] = type;
}

/// Item retrieved.
@JsonSerializable(explicitToJson: true, includeIfNull: false)
class ConversationItemRetrievedEvent implements RealtimeServerEvent {
  const ConversationItemRetrievedEvent({
    @JsonKey(name: 'event_id') this.eventId,
    required this.item,
  });

  factory ConversationItemRetrievedEvent.fromJson(JsonMap json) =>
      _$ConversationItemRetrievedEventFromJson(json);

  static const String eventType = 'conversation.item.retrieved';

  @override
  @JsonKey(name: 'event_id')
  final String? eventId;

  final RealtimeItem item;

  @override
  String get type => eventType;

  @override
  JsonMap toJson() =>
      _$ConversationItemRetrievedEventToJson(this)..['type'] = type;
}

/// Input audio transcription completed.
@JsonSerializable(explicitToJson: true, includeIfNull: false)
class ConversationItemInputTranscriptionCompleted
    implements RealtimeServerEvent {
  const ConversationItemInputTranscriptionCompleted({
    @JsonKey(name: 'event_id') this.eventId,
    @JsonKey(name: 'item_id') required this.itemId,
    @JsonKey(name: 'content_index') required this.contentIndex,
    required this.transcript,
    this.usage,
    this.logprobs,
  });

  factory ConversationItemInputTranscriptionCompleted.fromJson(JsonMap json) =>
      _$ConversationItemInputTranscriptionCompletedFromJson(json);

  static const String eventType =
      'conversation.item.input_audio_transcription.completed';

  @override
  @JsonKey(name: 'event_id')
  final String? eventId;

  @JsonKey(name: 'item_id')
  final String itemId;

  @JsonKey(name: 'content_index')
  final int contentIndex;

  final String transcript;
  final RealtimeUsage? usage;
  final List<dynamic>? logprobs;

  @override
  String get type => eventType;

  @override
  JsonMap toJson() =>
      _$ConversationItemInputTranscriptionCompletedToJson(this)
        ..['type'] = type;
}

/// Input audio transcription delta.
@JsonSerializable(explicitToJson: true, includeIfNull: false)
class ConversationItemInputTranscriptionDelta implements RealtimeServerEvent {
  const ConversationItemInputTranscriptionDelta({
    @JsonKey(name: 'event_id') this.eventId,
    @JsonKey(name: 'item_id') required this.itemId,
    @JsonKey(name: 'content_index') required this.contentIndex,
    required this.delta,
    this.logprobs,
    this.obfuscation,
  });

  factory ConversationItemInputTranscriptionDelta.fromJson(JsonMap json) =>
      _$ConversationItemInputTranscriptionDeltaFromJson(json);

  static const String eventType =
      'conversation.item.input_audio_transcription.delta';

  @override
  @JsonKey(name: 'event_id')
  final String? eventId;

  @JsonKey(name: 'item_id')
  final String itemId;

  @JsonKey(name: 'content_index')
  final int contentIndex;

  final String delta;
  final List<dynamic>? logprobs;
  final String? obfuscation;

  @override
  String get type => eventType;

  @override
  JsonMap toJson() =>
      _$ConversationItemInputTranscriptionDeltaToJson(this)..['type'] = type;
}

/// Input audio transcription segment.
@JsonSerializable(explicitToJson: true, includeIfNull: false)
class ConversationItemInputTranscriptionSegment implements RealtimeServerEvent {
  const ConversationItemInputTranscriptionSegment({
    @JsonKey(name: 'event_id') this.eventId,
    @JsonKey(name: 'item_id') required this.itemId,
    @JsonKey(name: 'content_index') required this.contentIndex,
    required this.text,
    required this.id,
    required this.start,
    required this.end,
    this.speaker,
  });

  factory ConversationItemInputTranscriptionSegment.fromJson(JsonMap json) =>
      _$ConversationItemInputTranscriptionSegmentFromJson(json);

  static const String eventType =
      'conversation.item.input_audio_transcription.segment';

  @override
  @JsonKey(name: 'event_id')
  final String? eventId;

  @JsonKey(name: 'item_id')
  final String itemId;

  @JsonKey(name: 'content_index')
  final int contentIndex;

  final String text;
  final String id;
  final double start;
  final double end;
  final String? speaker;

  @override
  String get type => eventType;

  @override
  JsonMap toJson() =>
      _$ConversationItemInputTranscriptionSegmentToJson(this)..['type'] = type;
}

/// Input audio transcription failed.
@JsonSerializable(explicitToJson: true, includeIfNull: false)
class ConversationItemInputTranscriptionFailed implements RealtimeServerEvent {
  const ConversationItemInputTranscriptionFailed({
    @JsonKey(name: 'event_id') this.eventId,
    @JsonKey(name: 'item_id') required this.itemId,
    @JsonKey(name: 'content_index') required this.contentIndex,
    required this.error,
  });

  factory ConversationItemInputTranscriptionFailed.fromJson(JsonMap json) =>
      _$ConversationItemInputTranscriptionFailedFromJson(json);

  static const String eventType =
      'conversation.item.input_audio_transcription.failed';

  @override
  @JsonKey(name: 'event_id')
  final String? eventId;

  @JsonKey(name: 'item_id')
  final String itemId;

  @JsonKey(name: 'content_index')
  final int contentIndex;

  final RealtimeApiError error;

  @override
  String get type => eventType;

  @override
  JsonMap toJson() =>
      _$ConversationItemInputTranscriptionFailedToJson(this)..['type'] = type;
}

/// Assistant audio truncated by client.
@JsonSerializable(includeIfNull: false)
class ConversationItemTruncatedEvent implements RealtimeServerEvent {
  const ConversationItemTruncatedEvent({
    @JsonKey(name: 'event_id') this.eventId,
    @JsonKey(name: 'item_id') required this.itemId,
    @JsonKey(name: 'content_index') required this.contentIndex,
    @JsonKey(name: 'audio_end_ms') required this.audioEndMs,
  });

  factory ConversationItemTruncatedEvent.fromJson(JsonMap json) =>
      _$ConversationItemTruncatedEventFromJson(json);

  static const String eventType = 'conversation.item.truncated';

  @override
  @JsonKey(name: 'event_id')
  final String? eventId;

  @JsonKey(name: 'item_id')
  final String itemId;

  @JsonKey(name: 'content_index')
  final int contentIndex;

  @JsonKey(name: 'audio_end_ms')
  final int audioEndMs;

  @override
  String get type => eventType;

  @override
  JsonMap toJson() =>
      _$ConversationItemTruncatedEventToJson(this)..['type'] = type;
}

/// Conversation item deleted.
@JsonSerializable(includeIfNull: false)
class ConversationItemDeletedEvent implements RealtimeServerEvent {
  const ConversationItemDeletedEvent({
    @JsonKey(name: 'event_id') this.eventId,
    @JsonKey(name: 'item_id') required this.itemId,
  });

  factory ConversationItemDeletedEvent.fromJson(JsonMap json) =>
      _$ConversationItemDeletedEventFromJson(json);

  static const String eventType = 'conversation.item.deleted';

  @override
  @JsonKey(name: 'event_id')
  final String? eventId;

  @JsonKey(name: 'item_id')
  final String itemId;

  @override
  String get type => eventType;

  @override
  JsonMap toJson() =>
      _$ConversationItemDeletedEventToJson(this)..['type'] = type;
}

/// Input audio buffer committed (user message created).
@JsonSerializable(includeIfNull: false)
class InputAudioBufferCommittedEvent implements RealtimeServerEvent {
  const InputAudioBufferCommittedEvent({
    @JsonKey(name: 'event_id') this.eventId,
    @JsonKey(name: 'item_id') required this.itemId,
    @JsonKey(name: 'previous_item_id') this.previousItemId,
  });

  factory InputAudioBufferCommittedEvent.fromJson(JsonMap json) =>
      _$InputAudioBufferCommittedEventFromJson(json);

  static const String eventType = 'input_audio_buffer.committed';

  @override
  @JsonKey(name: 'event_id')
  final String? eventId;

  @JsonKey(name: 'item_id')
  final String itemId;

  @JsonKey(name: 'previous_item_id')
  final String? previousItemId;

  @override
  String get type => eventType;

  @override
  JsonMap toJson() =>
      _$InputAudioBufferCommittedEventToJson(this)..['type'] = type;
}

/// DTMF event received (SIP only).
@JsonSerializable(includeIfNull: false)
class InputAudioBufferDtmfEvent implements RealtimeServerEvent {
  const InputAudioBufferDtmfEvent({
    @JsonKey(name: 'event_id') this.eventId,
    required this.event,
    @JsonKey(name: 'received_at') required this.receivedAt,
  });

  factory InputAudioBufferDtmfEvent.fromJson(JsonMap json) =>
      _$InputAudioBufferDtmfEventFromJson(json);

  static const String eventType = 'input_audio_buffer.dtmf_event_received';

  @override
  @JsonKey(name: 'event_id')
  final String? eventId;

  /// Keypad value (0-9, *, #, A-D).
  final String event;

  /// UTC timestamp when received.
  @JsonKey(name: 'received_at')
  final int receivedAt;

  @override
  String get type => eventType;

  @override
  JsonMap toJson() => _$InputAudioBufferDtmfEventToJson(this)..['type'] = type;
}

/// Input audio buffer cleared.
@JsonSerializable(includeIfNull: false)
class InputAudioBufferClearedEvent implements RealtimeServerEvent {
  const InputAudioBufferClearedEvent({@JsonKey(name: 'event_id') this.eventId});

  factory InputAudioBufferClearedEvent.fromJson(JsonMap json) =>
      _$InputAudioBufferClearedEventFromJson(json);

  static const String eventType = 'input_audio_buffer.cleared';

  @override
  @JsonKey(name: 'event_id')
  final String? eventId;

  @override
  String get type => eventType;

  @override
  JsonMap toJson() =>
      _$InputAudioBufferClearedEventToJson(this)..['type'] = type;
}

/// Server detected speech start (server VAD).
@JsonSerializable(includeIfNull: false)
class InputAudioBufferSpeechStartedEvent implements RealtimeServerEvent {
  const InputAudioBufferSpeechStartedEvent({
    @JsonKey(name: 'event_id') this.eventId,
    @JsonKey(name: 'audio_start_ms') required this.audioStartMs,
    @JsonKey(name: 'item_id') required this.itemId,
  });

  factory InputAudioBufferSpeechStartedEvent.fromJson(JsonMap json) =>
      _$InputAudioBufferSpeechStartedEventFromJson(json);

  static const String eventType = 'input_audio_buffer.speech_started';

  @override
  @JsonKey(name: 'event_id')
  final String? eventId;

  @JsonKey(name: 'audio_start_ms')
  final int audioStartMs;

  @JsonKey(name: 'item_id')
  final String itemId;

  @override
  String get type => eventType;

  @override
  JsonMap toJson() =>
      _$InputAudioBufferSpeechStartedEventToJson(this)..['type'] = type;
}

/// Server detected speech stop (server VAD).
@JsonSerializable(includeIfNull: false)
class InputAudioBufferSpeechStoppedEvent implements RealtimeServerEvent {
  const InputAudioBufferSpeechStoppedEvent({
    @JsonKey(name: 'event_id') this.eventId,
    @JsonKey(name: 'audio_end_ms') required this.audioEndMs,
    @JsonKey(name: 'item_id') required this.itemId,
  });

  factory InputAudioBufferSpeechStoppedEvent.fromJson(JsonMap json) =>
      _$InputAudioBufferSpeechStoppedEventFromJson(json);

  static const String eventType = 'input_audio_buffer.speech_stopped';

  @override
  @JsonKey(name: 'event_id')
  final String? eventId;

  @JsonKey(name: 'audio_end_ms')
  final int audioEndMs;

  @JsonKey(name: 'item_id')
  final String itemId;

  @override
  String get type => eventType;

  @override
  JsonMap toJson() =>
      _$InputAudioBufferSpeechStoppedEventToJson(this)..['type'] = type;
}

/// Input buffer timeout triggered.
@JsonSerializable(includeIfNull: false)
class InputAudioBufferTimeoutTriggeredEvent implements RealtimeServerEvent {
  const InputAudioBufferTimeoutTriggeredEvent({
    @JsonKey(name: 'event_id') this.eventId,
    @JsonKey(name: 'audio_start_ms') required this.audioStartMs,
    @JsonKey(name: 'audio_end_ms') required this.audioEndMs,
    @JsonKey(name: 'item_id') required this.itemId,
  });

  factory InputAudioBufferTimeoutTriggeredEvent.fromJson(JsonMap json) =>
      _$InputAudioBufferTimeoutTriggeredEventFromJson(json);

  static const String eventType = 'input_audio_buffer.timeout_triggered';

  @override
  @JsonKey(name: 'event_id')
  final String? eventId;

  @JsonKey(name: 'audio_start_ms')
  final int audioStartMs;

  @JsonKey(name: 'audio_end_ms')
  final int audioEndMs;

  @JsonKey(name: 'item_id')
  final String itemId;

  @override
  String get type => eventType;

  @override
  JsonMap toJson() =>
      _$InputAudioBufferTimeoutTriggeredEventToJson(this)..['type'] = type;
}

/// Output audio buffer started (WebRTC/SIP).
@JsonSerializable(includeIfNull: false)
class OutputAudioBufferStartedEvent implements RealtimeServerEvent {
  const OutputAudioBufferStartedEvent({
    @JsonKey(name: 'event_id') this.eventId,
    @JsonKey(name: 'response_id') required this.responseId,
  });

  factory OutputAudioBufferStartedEvent.fromJson(JsonMap json) =>
      _$OutputAudioBufferStartedEventFromJson(json);

  static const String eventType = 'output_audio_buffer.started';

  @override
  @JsonKey(name: 'event_id')
  final String? eventId;

  @JsonKey(name: 'response_id')
  final String responseId;

  @override
  String get type => eventType;

  @override
  JsonMap toJson() =>
      _$OutputAudioBufferStartedEventToJson(this)..['type'] = type;
}

/// Output audio buffer drained (WebRTC/SIP).
@JsonSerializable(includeIfNull: false)
class OutputAudioBufferStoppedEvent implements RealtimeServerEvent {
  const OutputAudioBufferStoppedEvent({
    @JsonKey(name: 'event_id') this.eventId,
    @JsonKey(name: 'response_id') required this.responseId,
  });

  factory OutputAudioBufferStoppedEvent.fromJson(JsonMap json) =>
      _$OutputAudioBufferStoppedEventFromJson(json);

  static const String eventType = 'output_audio_buffer.stopped';

  @override
  @JsonKey(name: 'event_id')
  final String? eventId;

  @JsonKey(name: 'response_id')
  final String responseId;

  @override
  String get type => eventType;

  @override
  JsonMap toJson() =>
      _$OutputAudioBufferStoppedEventToJson(this)..['type'] = type;
}

/// Output audio buffer cleared (WebRTC/SIP).
@JsonSerializable(includeIfNull: false)
class OutputAudioBufferClearedEvent implements RealtimeServerEvent {
  const OutputAudioBufferClearedEvent({
    @JsonKey(name: 'event_id') this.eventId,
    @JsonKey(name: 'response_id') required this.responseId,
  });

  factory OutputAudioBufferClearedEvent.fromJson(JsonMap json) =>
      _$OutputAudioBufferClearedEventFromJson(json);

  static const String eventType = 'output_audio_buffer.cleared';

  @override
  @JsonKey(name: 'event_id')
  final String? eventId;

  @JsonKey(name: 'response_id')
  final String responseId;

  @override
  String get type => eventType;

  @override
  JsonMap toJson() =>
      _$OutputAudioBufferClearedEventToJson(this)..['type'] = type;
}

/// Response created.
@JsonSerializable(explicitToJson: true, includeIfNull: false)
class ResponseCreatedEvent implements RealtimeServerEvent {
  const ResponseCreatedEvent({
    @JsonKey(name: 'event_id') this.eventId,
    required this.response,
  });

  factory ResponseCreatedEvent.fromJson(JsonMap json) =>
      _$ResponseCreatedEventFromJson(json);

  static const String eventType = 'response.created';

  @override
  @JsonKey(name: 'event_id')
  final String? eventId;

  final RealtimeResponse response;

  @override
  String get type => eventType;

  @override
  JsonMap toJson() => _$ResponseCreatedEventToJson(this)..['type'] = type;
}

/// Response completed/cancelled/failed.
@JsonSerializable(explicitToJson: true, includeIfNull: false)
class ResponseDoneEvent implements RealtimeServerEvent {
  const ResponseDoneEvent({
    @JsonKey(name: 'event_id') this.eventId,
    required this.response,
  });

  factory ResponseDoneEvent.fromJson(JsonMap json) =>
      _$ResponseDoneEventFromJson(json);

  static const String eventType = 'response.done';

  @override
  @JsonKey(name: 'event_id')
  final String? eventId;

  final RealtimeResponse response;

  @override
  String get type => eventType;

  @override
  JsonMap toJson() => _$ResponseDoneEventToJson(this)..['type'] = type;
}

/// Output item created during response generation.
@JsonSerializable(explicitToJson: true, includeIfNull: false)
class ResponseOutputItemAddedEvent implements RealtimeServerEvent {
  const ResponseOutputItemAddedEvent({
    @JsonKey(name: 'event_id') this.eventId,
    @JsonKey(name: 'response_id') required this.responseId,
    @JsonKey(name: 'output_index') required this.outputIndex,
    required this.item,
  });

  factory ResponseOutputItemAddedEvent.fromJson(JsonMap json) =>
      _$ResponseOutputItemAddedEventFromJson(json);

  static const String eventType = 'response.output_item.added';

  @override
  @JsonKey(name: 'event_id')
  final String? eventId;

  @JsonKey(name: 'response_id')
  final String responseId;

  @JsonKey(name: 'output_index')
  final int outputIndex;

  final RealtimeItem item;

  @override
  String get type => eventType;

  @override
  JsonMap toJson() =>
      _$ResponseOutputItemAddedEventToJson(this)..['type'] = type;
}

/// Output item completed.
@JsonSerializable(explicitToJson: true, includeIfNull: false)
class ResponseOutputItemDoneEvent implements RealtimeServerEvent {
  const ResponseOutputItemDoneEvent({
    @JsonKey(name: 'event_id') this.eventId,
    @JsonKey(name: 'response_id') required this.responseId,
    @JsonKey(name: 'output_index') required this.outputIndex,
    required this.item,
  });

  factory ResponseOutputItemDoneEvent.fromJson(JsonMap json) =>
      _$ResponseOutputItemDoneEventFromJson(json);

  static const String eventType = 'response.output_item.done';

  @override
  @JsonKey(name: 'event_id')
  final String? eventId;

  @JsonKey(name: 'response_id')
  final String responseId;

  @JsonKey(name: 'output_index')
  final int outputIndex;

  final RealtimeItem item;

  @override
  String get type => eventType;

  @override
  JsonMap toJson() =>
      _$ResponseOutputItemDoneEventToJson(this)..['type'] = type;
}

/// Content part added to an assistant message.
@JsonSerializable(
  explicitToJson: true,
  includeIfNull: false,
  createFactory: false,
  createToJson: false,
)
class ResponseContentPartAddedEvent implements RealtimeServerEvent {
  const ResponseContentPartAddedEvent({
    @JsonKey(name: 'event_id') this.eventId,
    @JsonKey(name: 'response_id') required this.responseId,
    @JsonKey(name: 'item_id') required this.itemId,
    @JsonKey(name: 'output_index') required this.outputIndex,
    @JsonKey(name: 'content_index') required this.contentIndex,
    required this.part,
  });

  factory ResponseContentPartAddedEvent.fromJson(JsonMap json) {
    return ResponseContentPartAddedEvent(
      eventId: json['event_id'] as String?,
      responseId: json['response_id'] as String,
      itemId: json['item_id'] as String,
      outputIndex: json['output_index'] as int,
      contentIndex: json['content_index'] as int,
      part: RealtimeContent.fromJson(
        (json['part'] as Map).cast<String, dynamic>(),
      ),
    );
  }

  static const String eventType = 'response.content_part.added';

  @override
  @JsonKey(name: 'event_id')
  final String? eventId;

  @JsonKey(name: 'response_id')
  final String responseId;

  @JsonKey(name: 'item_id')
  final String itemId;

  @JsonKey(name: 'output_index')
  final int outputIndex;

  @JsonKey(name: 'content_index')
  final int contentIndex;

  final RealtimeContent part;

  @override
  String get type => eventType;

  @override
  JsonMap toJson() => {
    'type': type,
    if (eventId != null) 'event_id': eventId,
    'response_id': responseId,
    'item_id': itemId,
    'output_index': outputIndex,
    'content_index': contentIndex,
    'part': part.toJson(),
  };
}

/// Content part completed.
@JsonSerializable(
  explicitToJson: true,
  includeIfNull: false,
  createFactory: false,
  createToJson: false,
)
class ResponseContentPartDoneEvent implements RealtimeServerEvent {
  const ResponseContentPartDoneEvent({
    @JsonKey(name: 'event_id') this.eventId,
    @JsonKey(name: 'response_id') required this.responseId,
    @JsonKey(name: 'item_id') required this.itemId,
    @JsonKey(name: 'output_index') required this.outputIndex,
    @JsonKey(name: 'content_index') required this.contentIndex,
    required this.part,
  });

  factory ResponseContentPartDoneEvent.fromJson(JsonMap json) {
    return ResponseContentPartDoneEvent(
      eventId: json['event_id'] as String?,
      responseId: json['response_id'] as String,
      itemId: json['item_id'] as String,
      outputIndex: json['output_index'] as int,
      contentIndex: json['content_index'] as int,
      part: RealtimeContent.fromJson(
        (json['part'] as Map).cast<String, dynamic>(),
      ),
    );
  }

  static const String eventType = 'response.content_part.done';

  @override
  @JsonKey(name: 'event_id')
  final String? eventId;

  @JsonKey(name: 'response_id')
  final String responseId;

  @JsonKey(name: 'item_id')
  final String itemId;

  @JsonKey(name: 'output_index')
  final int outputIndex;

  @JsonKey(name: 'content_index')
  final int contentIndex;

  final RealtimeContent part;

  @override
  String get type => eventType;

  @override
  JsonMap toJson() => {
    'type': type,
    if (eventId != null) 'event_id': eventId,
    'response_id': responseId,
    'item_id': itemId,
    'output_index': outputIndex,
    'content_index': contentIndex,
    'part': part.toJson(),
  };
}

/// Text delta for output_text content.
@JsonSerializable(includeIfNull: false)
class ResponseOutputTextDeltaEvent implements RealtimeServerEvent {
  const ResponseOutputTextDeltaEvent({
    @JsonKey(name: 'event_id') this.eventId,
    @JsonKey(name: 'response_id') required this.responseId,
    @JsonKey(name: 'item_id') required this.itemId,
    @JsonKey(name: 'output_index') required this.outputIndex,
    @JsonKey(name: 'content_index') required this.contentIndex,
    required this.delta,
  });

  factory ResponseOutputTextDeltaEvent.fromJson(JsonMap json) =>
      _$ResponseOutputTextDeltaEventFromJson(json);

  static const String eventType = 'response.output_text.delta';

  @override
  @JsonKey(name: 'event_id')
  final String? eventId;

  @JsonKey(name: 'response_id')
  final String responseId;

  @JsonKey(name: 'item_id')
  final String itemId;

  @JsonKey(name: 'output_index')
  final int outputIndex;

  @JsonKey(name: 'content_index')
  final int contentIndex;

  final String delta;

  @override
  String get type => eventType;

  @override
  JsonMap toJson() =>
      _$ResponseOutputTextDeltaEventToJson(this)..['type'] = type;
}

/// Text content finished.
@JsonSerializable(includeIfNull: false)
class ResponseOutputTextDoneEvent implements RealtimeServerEvent {
  const ResponseOutputTextDoneEvent({
    @JsonKey(name: 'event_id') this.eventId,
    @JsonKey(name: 'response_id') required this.responseId,
    @JsonKey(name: 'item_id') required this.itemId,
    @JsonKey(name: 'output_index') required this.outputIndex,
    @JsonKey(name: 'content_index') required this.contentIndex,
    required this.text,
  });

  factory ResponseOutputTextDoneEvent.fromJson(JsonMap json) =>
      _$ResponseOutputTextDoneEventFromJson(json);

  static const String eventType = 'response.output_text.done';

  @override
  @JsonKey(name: 'event_id')
  final String? eventId;

  @JsonKey(name: 'response_id')
  final String responseId;

  @JsonKey(name: 'item_id')
  final String itemId;

  @JsonKey(name: 'output_index')
  final int outputIndex;

  @JsonKey(name: 'content_index')
  final int contentIndex;

  final String text;

  @override
  String get type => eventType;

  @override
  JsonMap toJson() =>
      _$ResponseOutputTextDoneEventToJson(this)..['type'] = type;
}

/// Output audio transcript delta.
@JsonSerializable(includeIfNull: false)
class ResponseOutputAudioTranscriptDeltaEvent implements RealtimeServerEvent {
  const ResponseOutputAudioTranscriptDeltaEvent({
    @JsonKey(name: 'event_id') this.eventId,
    @JsonKey(name: 'response_id') required this.responseId,
    @JsonKey(name: 'item_id') required this.itemId,
    @JsonKey(name: 'output_index') required this.outputIndex,
    @JsonKey(name: 'content_index') required this.contentIndex,
    required this.delta,
  });

  factory ResponseOutputAudioTranscriptDeltaEvent.fromJson(JsonMap json) =>
      _$ResponseOutputAudioTranscriptDeltaEventFromJson(json);

  static const String eventType = 'response.output_audio_transcript.delta';

  @override
  @JsonKey(name: 'event_id')
  final String? eventId;

  @JsonKey(name: 'response_id')
  final String responseId;

  @JsonKey(name: 'item_id')
  final String itemId;

  @JsonKey(name: 'output_index')
  final int outputIndex;

  @JsonKey(name: 'content_index')
  final int contentIndex;

  final String delta;

  @override
  String get type => eventType;

  @override
  JsonMap toJson() =>
      _$ResponseOutputAudioTranscriptDeltaEventToJson(this)..['type'] = type;
}

/// Output audio transcript completed.
@JsonSerializable(includeIfNull: false)
class ResponseOutputAudioTranscriptDoneEvent implements RealtimeServerEvent {
  const ResponseOutputAudioTranscriptDoneEvent({
    @JsonKey(name: 'event_id') this.eventId,
    @JsonKey(name: 'response_id') required this.responseId,
    @JsonKey(name: 'item_id') required this.itemId,
    @JsonKey(name: 'output_index') required this.outputIndex,
    @JsonKey(name: 'content_index') required this.contentIndex,
    required this.transcript,
  });

  factory ResponseOutputAudioTranscriptDoneEvent.fromJson(JsonMap json) =>
      _$ResponseOutputAudioTranscriptDoneEventFromJson(json);

  static const String eventType = 'response.output_audio_transcript.done';

  @override
  @JsonKey(name: 'event_id')
  final String? eventId;

  @JsonKey(name: 'response_id')
  final String responseId;

  @JsonKey(name: 'item_id')
  final String itemId;

  @JsonKey(name: 'output_index')
  final int outputIndex;

  @JsonKey(name: 'content_index')
  final int contentIndex;

  final String transcript;

  @override
  String get type => eventType;

  @override
  JsonMap toJson() =>
      _$ResponseOutputAudioTranscriptDoneEventToJson(this)..['type'] = type;
}

/// Output audio data delta.
@JsonSerializable(includeIfNull: false)
class ResponseOutputAudioDeltaEvent implements RealtimeServerEvent {
  const ResponseOutputAudioDeltaEvent({
    @JsonKey(name: 'event_id') this.eventId,
    @JsonKey(name: 'response_id') required this.responseId,
    @JsonKey(name: 'item_id') required this.itemId,
    @JsonKey(name: 'output_index') required this.outputIndex,
    @JsonKey(name: 'content_index') required this.contentIndex,
    required this.delta,
  });

  factory ResponseOutputAudioDeltaEvent.fromJson(JsonMap json) =>
      _$ResponseOutputAudioDeltaEventFromJson(json);

  static const String eventType = 'response.output_audio.delta';

  @override
  @JsonKey(name: 'event_id')
  final String? eventId;

  @JsonKey(name: 'response_id')
  final String responseId;

  @JsonKey(name: 'item_id')
  final String itemId;

  @JsonKey(name: 'output_index')
  final int outputIndex;

  @JsonKey(name: 'content_index')
  final int contentIndex;

  /// Base64-encoded audio data.
  final String delta;

  @override
  String get type => eventType;

  @override
  JsonMap toJson() =>
      _$ResponseOutputAudioDeltaEventToJson(this)..['type'] = type;
}

/// Output audio done.
@JsonSerializable(includeIfNull: false)
class ResponseOutputAudioDoneEvent implements RealtimeServerEvent {
  const ResponseOutputAudioDoneEvent({
    @JsonKey(name: 'event_id') this.eventId,
    @JsonKey(name: 'response_id') required this.responseId,
    @JsonKey(name: 'item_id') required this.itemId,
    @JsonKey(name: 'output_index') required this.outputIndex,
    @JsonKey(name: 'content_index') required this.contentIndex,
  });

  factory ResponseOutputAudioDoneEvent.fromJson(JsonMap json) =>
      _$ResponseOutputAudioDoneEventFromJson(json);

  static const String eventType = 'response.output_audio.done';

  @override
  @JsonKey(name: 'event_id')
  final String? eventId;

  @JsonKey(name: 'response_id')
  final String responseId;

  @JsonKey(name: 'item_id')
  final String itemId;

  @JsonKey(name: 'output_index')
  final int outputIndex;

  @JsonKey(name: 'content_index')
  final int contentIndex;

  @override
  String get type => eventType;

  @override
  JsonMap toJson() =>
      _$ResponseOutputAudioDoneEventToJson(this)..['type'] = type;
}

/// Function call arguments delta.
@JsonSerializable(includeIfNull: false)
class ResponseFunctionCallArgumentsDeltaEvent implements RealtimeServerEvent {
  const ResponseFunctionCallArgumentsDeltaEvent({
    @JsonKey(name: 'event_id') this.eventId,
    @JsonKey(name: 'response_id') required this.responseId,
    @JsonKey(name: 'item_id') required this.itemId,
    @JsonKey(name: 'output_index') required this.outputIndex,
    @JsonKey(name: 'call_id') required this.callId,
    required this.delta,
  });

  factory ResponseFunctionCallArgumentsDeltaEvent.fromJson(JsonMap json) =>
      _$ResponseFunctionCallArgumentsDeltaEventFromJson(json);

  static const String eventType = 'response.function_call_arguments.delta';

  @override
  @JsonKey(name: 'event_id')
  final String? eventId;

  @JsonKey(name: 'response_id')
  final String responseId;

  @JsonKey(name: 'item_id')
  final String itemId;

  @JsonKey(name: 'output_index')
  final int outputIndex;

  @JsonKey(name: 'call_id')
  final String callId;

  final String delta;

  @override
  String get type => eventType;

  @override
  JsonMap toJson() =>
      _$ResponseFunctionCallArgumentsDeltaEventToJson(this)..['type'] = type;
}

/// Function call arguments completed.
@JsonSerializable(includeIfNull: false)
class ResponseFunctionCallArgumentsDoneEvent implements RealtimeServerEvent {
  const ResponseFunctionCallArgumentsDoneEvent({
    @JsonKey(name: 'event_id') this.eventId,
    @JsonKey(name: 'response_id') required this.responseId,
    @JsonKey(name: 'item_id') required this.itemId,
    @JsonKey(name: 'output_index') required this.outputIndex,
    @JsonKey(name: 'call_id') required this.callId,
    required this.arguments,
  });

  factory ResponseFunctionCallArgumentsDoneEvent.fromJson(JsonMap json) =>
      _$ResponseFunctionCallArgumentsDoneEventFromJson(json);

  static const String eventType = 'response.function_call_arguments.done';

  @override
  @JsonKey(name: 'event_id')
  final String? eventId;

  @JsonKey(name: 'response_id')
  final String responseId;

  @JsonKey(name: 'item_id')
  final String itemId;

  @JsonKey(name: 'output_index')
  final int outputIndex;

  @JsonKey(name: 'call_id')
  final String callId;

  final String arguments;

  @override
  String get type => eventType;

  @override
  JsonMap toJson() =>
      _$ResponseFunctionCallArgumentsDoneEventToJson(this)..['type'] = type;
}

/// MCP tool call arguments delta.
@JsonSerializable(includeIfNull: false)
class ResponseMcpCallArgumentsDeltaEvent implements RealtimeServerEvent {
  const ResponseMcpCallArgumentsDeltaEvent({
    @JsonKey(name: 'event_id') this.eventId,
    @JsonKey(name: 'response_id') this.responseId,
    @JsonKey(name: 'item_id') required this.itemId,
    @JsonKey(name: 'output_index') required this.outputIndex,
    required this.delta,
    this.obfuscation,
  });

  factory ResponseMcpCallArgumentsDeltaEvent.fromJson(JsonMap json) =>
      _$ResponseMcpCallArgumentsDeltaEventFromJson(json);

  static const String eventType = 'response.mcp_call_arguments.delta';

  @override
  @JsonKey(name: 'event_id')
  final String? eventId;

  @JsonKey(name: 'response_id')
  final String? responseId;

  @JsonKey(name: 'item_id')
  final String itemId;

  @JsonKey(name: 'output_index')
  final int outputIndex;

  final String delta;
  final String? obfuscation;

  @override
  String get type => eventType;

  @override
  JsonMap toJson() =>
      _$ResponseMcpCallArgumentsDeltaEventToJson(this)..['type'] = type;
}

/// MCP tool call arguments done.
@JsonSerializable(includeIfNull: false)
class ResponseMcpCallArgumentsDoneEvent implements RealtimeServerEvent {
  const ResponseMcpCallArgumentsDoneEvent({
    @JsonKey(name: 'event_id') this.eventId,
    @JsonKey(name: 'response_id') this.responseId,
    @JsonKey(name: 'item_id') required this.itemId,
    @JsonKey(name: 'output_index') required this.outputIndex,
    required this.arguments,
  });

  factory ResponseMcpCallArgumentsDoneEvent.fromJson(JsonMap json) =>
      _$ResponseMcpCallArgumentsDoneEventFromJson(json);

  static const String eventType = 'response.mcp_call_arguments.done';

  @override
  @JsonKey(name: 'event_id')
  final String? eventId;

  @JsonKey(name: 'response_id')
  final String? responseId;

  @JsonKey(name: 'item_id')
  final String itemId;

  @JsonKey(name: 'output_index')
  final int outputIndex;

  final String arguments;

  @override
  String get type => eventType;

  @override
  JsonMap toJson() =>
      _$ResponseMcpCallArgumentsDoneEventToJson(this)..['type'] = type;
}

/// MCP tool call started/in progress.
@JsonSerializable(includeIfNull: false)
class ResponseMcpCallInProgressEvent implements RealtimeServerEvent {
  const ResponseMcpCallInProgressEvent({
    @JsonKey(name: 'event_id') this.eventId,
    @JsonKey(name: 'response_id') this.responseId,
    @JsonKey(name: 'item_id') required this.itemId,
    @JsonKey(name: 'output_index') required this.outputIndex,
  });

  factory ResponseMcpCallInProgressEvent.fromJson(JsonMap json) =>
      _$ResponseMcpCallInProgressEventFromJson(json);

  static const String eventType = 'response.mcp_call.in_progress';

  @override
  @JsonKey(name: 'event_id')
  final String? eventId;

  @JsonKey(name: 'response_id')
  final String? responseId;

  @JsonKey(name: 'item_id')
  final String itemId;

  @JsonKey(name: 'output_index')
  final int outputIndex;

  @override
  String get type => eventType;

  @override
  JsonMap toJson() =>
      _$ResponseMcpCallInProgressEventToJson(this)..['type'] = type;
}

/// MCP tool call completed.
@JsonSerializable(includeIfNull: false)
class ResponseMcpCallCompletedEvent implements RealtimeServerEvent {
  const ResponseMcpCallCompletedEvent({
    @JsonKey(name: 'event_id') this.eventId,
    @JsonKey(name: 'response_id') this.responseId,
    @JsonKey(name: 'item_id') required this.itemId,
    @JsonKey(name: 'output_index') required this.outputIndex,
  });

  factory ResponseMcpCallCompletedEvent.fromJson(JsonMap json) =>
      _$ResponseMcpCallCompletedEventFromJson(json);

  static const String eventType = 'response.mcp_call.completed';

  @override
  @JsonKey(name: 'event_id')
  final String? eventId;

  @JsonKey(name: 'response_id')
  final String? responseId;

  @JsonKey(name: 'item_id')
  final String itemId;

  @JsonKey(name: 'output_index')
  final int outputIndex;

  @override
  String get type => eventType;

  @override
  JsonMap toJson() =>
      _$ResponseMcpCallCompletedEventToJson(this)..['type'] = type;
}

/// MCP tool call failed.
@JsonSerializable(includeIfNull: false)
class ResponseMcpCallFailedEvent implements RealtimeServerEvent {
  const ResponseMcpCallFailedEvent({
    @JsonKey(name: 'event_id') this.eventId,
    @JsonKey(name: 'response_id') this.responseId,
    @JsonKey(name: 'item_id') required this.itemId,
    @JsonKey(name: 'output_index') required this.outputIndex,
  });

  factory ResponseMcpCallFailedEvent.fromJson(JsonMap json) =>
      _$ResponseMcpCallFailedEventFromJson(json);

  static const String eventType = 'response.mcp_call.failed';

  @override
  @JsonKey(name: 'event_id')
  final String? eventId;

  @JsonKey(name: 'response_id')
  final String? responseId;

  @JsonKey(name: 'item_id')
  final String itemId;

  @JsonKey(name: 'output_index')
  final int outputIndex;

  @override
  String get type => eventType;

  @override
  JsonMap toJson() => _$ResponseMcpCallFailedEventToJson(this)..['type'] = type;
}

/// MCP list tools in progress.
@JsonSerializable(includeIfNull: false)
class McpListToolsInProgressEvent implements RealtimeServerEvent {
  const McpListToolsInProgressEvent({
    @JsonKey(name: 'event_id') this.eventId,
    @JsonKey(name: 'item_id') required this.itemId,
  });

  factory McpListToolsInProgressEvent.fromJson(JsonMap json) =>
      _$McpListToolsInProgressEventFromJson(json);

  static const String eventType = 'mcp_list_tools.in_progress';

  @override
  @JsonKey(name: 'event_id')
  final String? eventId;

  @JsonKey(name: 'item_id')
  final String itemId;

  @override
  String get type => eventType;

  @override
  JsonMap toJson() =>
      _$McpListToolsInProgressEventToJson(this)..['type'] = type;
}

/// MCP list tools completed.
@JsonSerializable(includeIfNull: false)
class McpListToolsCompletedEvent implements RealtimeServerEvent {
  const McpListToolsCompletedEvent({
    @JsonKey(name: 'event_id') this.eventId,
    @JsonKey(name: 'item_id') required this.itemId,
  });

  factory McpListToolsCompletedEvent.fromJson(JsonMap json) =>
      _$McpListToolsCompletedEventFromJson(json);

  static const String eventType = 'mcp_list_tools.completed';

  @override
  @JsonKey(name: 'event_id')
  final String? eventId;

  @JsonKey(name: 'item_id')
  final String itemId;

  @override
  String get type => eventType;

  @override
  JsonMap toJson() => _$McpListToolsCompletedEventToJson(this)..['type'] = type;
}

/// MCP list tools failed.
@JsonSerializable(includeIfNull: false)
class McpListToolsFailedEvent implements RealtimeServerEvent {
  const McpListToolsFailedEvent({
    @JsonKey(name: 'event_id') this.eventId,
    @JsonKey(name: 'item_id') required this.itemId,
  });

  factory McpListToolsFailedEvent.fromJson(JsonMap json) =>
      _$McpListToolsFailedEventFromJson(json);

  static const String eventType = 'mcp_list_tools.failed';

  @override
  @JsonKey(name: 'event_id')
  final String? eventId;

  @JsonKey(name: 'item_id')
  final String itemId;

  @override
  String get type => eventType;

  @override
  JsonMap toJson() => _$McpListToolsFailedEventToJson(this)..['type'] = type;
}

/// Rate limits updated at start of response.
@JsonSerializable(explicitToJson: true, includeIfNull: false)
class RateLimitsUpdatedEvent implements RealtimeServerEvent {
  const RateLimitsUpdatedEvent({
    @JsonKey(name: 'event_id') this.eventId,
    @JsonKey(name: 'rate_limits') required this.rateLimits,
  });

  factory RateLimitsUpdatedEvent.fromJson(JsonMap json) =>
      _$RateLimitsUpdatedEventFromJson(json);

  static const String eventType = 'rate_limits.updated';

  @override
  @JsonKey(name: 'event_id')
  final String? eventId;

  @JsonKey(name: 'rate_limits')
  final List<RateLimit> rateLimits;

  @override
  String get type => eventType;

  @override
  JsonMap toJson() => _$RateLimitsUpdatedEventToJson(this)..['type'] = type;
}

/// Unknown server event wrapper.
class UnknownServerEvent implements RealtimeServerEvent {
  const UnknownServerEvent({required this.type, this.raw = const {}});

  @override
  final String type;

  /// Raw event payload.
  final JsonMap raw;

  @override
  String? get eventId => raw['event_id'] as String?;

  @override
  JsonMap toJson() => {...raw, 'type': type};
}

/// Error payload included in error events and transcription failures.
@JsonSerializable(includeIfNull: false)
class RealtimeApiError {
  const RealtimeApiError({
    required this.type,
    this.code,
    required this.message,
    this.param,
    @JsonKey(name: 'event_id') this.eventId,
  });

  factory RealtimeApiError.fromJson(JsonMap json) =>
      _$RealtimeApiErrorFromJson(json);

  final String type;
  final String? code;
  final String message;
  final String? param;

  @JsonKey(name: 'event_id')
  final String? eventId;

  JsonMap toJson() => _$RealtimeApiErrorToJson(this);
}
