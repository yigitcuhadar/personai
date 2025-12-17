part of 'realtime_models.dart';

/// Base class for client-originated events.
sealed class RealtimeClientEvent {
  String get type;
  String? get eventId;

  JsonMap toJson();

  static RealtimeClientEvent fromJson(JsonMap json) {
    final type = json['type'] as String?;
    if (type == null) {
      throw ArgumentError('Client event missing "type" field.');
    }
    switch (type) {
      case SessionUpdateEvent.eventType:
        return SessionUpdateEvent.fromJson(json);
      case InputAudioBufferAppendEvent.eventType:
        return InputAudioBufferAppendEvent.fromJson(json);
      case InputAudioBufferCommitEvent.eventType:
        return InputAudioBufferCommitEvent.fromJson(json);
      case InputAudioBufferClearEvent.eventType:
        return InputAudioBufferClearEvent.fromJson(json);
      case ConversationItemCreateEvent.eventType:
        return ConversationItemCreateEvent.fromJson(json);
      case ConversationItemRetrieveEvent.eventType:
        return ConversationItemRetrieveEvent.fromJson(json);
      case ConversationItemTruncateEvent.eventType:
        return ConversationItemTruncateEvent.fromJson(json);
      case ConversationItemDeleteEvent.eventType:
        return ConversationItemDeleteEvent.fromJson(json);
      case ResponseCreateEvent.eventType:
        return ResponseCreateEvent.fromJson(json);
      case ResponseCancelEvent.eventType:
        return ResponseCancelEvent.fromJson(json);
      case OutputAudioBufferClearEvent.eventType:
        return OutputAudioBufferClearEvent.fromJson(json);
      default:
        throw ArgumentError('Unsupported client event type: $type');
    }
  }
}

@JsonSerializable(explicitToJson: true, includeIfNull: false)
class SessionUpdateEvent implements RealtimeClientEvent {
  const SessionUpdateEvent({this.eventId, required this.session});

  factory SessionUpdateEvent.fromJson(JsonMap json) =>
      _$SessionUpdateEventFromJson(json);

  static const String eventType = 'session.update';

  @override
  @JsonKey(name: 'event_id')
  final String? eventId;

  final RealtimeSessionConfig session;

  @override
  String get type => eventType;

  @override
  JsonMap toJson() => _$SessionUpdateEventToJson(this)..['type'] = type;
}

@JsonSerializable(includeIfNull: false)
class InputAudioBufferAppendEvent implements RealtimeClientEvent {
  const InputAudioBufferAppendEvent({this.eventId, required this.audio});

  factory InputAudioBufferAppendEvent.fromJson(JsonMap json) =>
      _$InputAudioBufferAppendEventFromJson(json);

  static const String eventType = 'input_audio_buffer.append';

  @override
  @JsonKey(name: 'event_id')
  final String? eventId;

  /// Base64-encoded audio bytes.
  final String audio;

  @override
  String get type => eventType;

  @override
  JsonMap toJson() =>
      _$InputAudioBufferAppendEventToJson(this)..['type'] = type;
}

@JsonSerializable(includeIfNull: false)
class InputAudioBufferCommitEvent implements RealtimeClientEvent {
  const InputAudioBufferCommitEvent({this.eventId});

  factory InputAudioBufferCommitEvent.fromJson(JsonMap json) =>
      _$InputAudioBufferCommitEventFromJson(json);

  static const String eventType = 'input_audio_buffer.commit';

  @override
  @JsonKey(name: 'event_id')
  final String? eventId;

  @override
  String get type => eventType;

  @override
  JsonMap toJson() =>
      _$InputAudioBufferCommitEventToJson(this)..['type'] = type;
}

@JsonSerializable(includeIfNull: false)
class InputAudioBufferClearEvent implements RealtimeClientEvent {
  const InputAudioBufferClearEvent({this.eventId});

  factory InputAudioBufferClearEvent.fromJson(JsonMap json) =>
      _$InputAudioBufferClearEventFromJson(json);

  static const String eventType = 'input_audio_buffer.clear';

  @override
  @JsonKey(name: 'event_id')
  final String? eventId;

  @override
  String get type => eventType;

  @override
  JsonMap toJson() => _$InputAudioBufferClearEventToJson(this)..['type'] = type;
}

@JsonSerializable(explicitToJson: true, includeIfNull: false)
class ConversationItemCreateEvent implements RealtimeClientEvent {
  const ConversationItemCreateEvent({
    this.eventId,
    required this.item,
    @JsonKey(name: 'previous_item_id') this.previousItemId,
  });

  factory ConversationItemCreateEvent.fromJson(JsonMap json) =>
      _$ConversationItemCreateEventFromJson(json);

  static const String eventType = 'conversation.item.create';

  @override
  @JsonKey(name: 'event_id')
  final String? eventId;

  final RealtimeItem item;

  @JsonKey(name: 'previous_item_id')
  final String? previousItemId;

  @override
  String get type => eventType;

  @override
  JsonMap toJson() =>
      _$ConversationItemCreateEventToJson(this)..['type'] = type;
}

@JsonSerializable(includeIfNull: false)
class ConversationItemRetrieveEvent implements RealtimeClientEvent {
  const ConversationItemRetrieveEvent({this.eventId, required this.itemId});

  factory ConversationItemRetrieveEvent.fromJson(JsonMap json) =>
      _$ConversationItemRetrieveEventFromJson(json);

  static const String eventType = 'conversation.item.retrieve';

  @override
  @JsonKey(name: 'event_id')
  final String? eventId;

  @JsonKey(name: 'item_id')
  final String itemId;

  @override
  String get type => eventType;

  @override
  JsonMap toJson() =>
      _$ConversationItemRetrieveEventToJson(this)..['type'] = type;
}

@JsonSerializable(includeIfNull: false)
class ConversationItemTruncateEvent implements RealtimeClientEvent {
  const ConversationItemTruncateEvent({
    this.eventId,
    @JsonKey(name: 'item_id') required this.itemId,
    @JsonKey(name: 'content_index') required this.contentIndex,
    @JsonKey(name: 'audio_end_ms') required this.audioEndMs,
  });

  factory ConversationItemTruncateEvent.fromJson(JsonMap json) =>
      _$ConversationItemTruncateEventFromJson(json);

  static const String eventType = 'conversation.item.truncate';

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
      _$ConversationItemTruncateEventToJson(this)..['type'] = type;
}

@JsonSerializable(includeIfNull: false)
class ConversationItemDeleteEvent implements RealtimeClientEvent {
  const ConversationItemDeleteEvent({
    this.eventId,
    @JsonKey(name: 'item_id') required this.itemId,
  });

  factory ConversationItemDeleteEvent.fromJson(JsonMap json) =>
      _$ConversationItemDeleteEventFromJson(json);

  static const String eventType = 'conversation.item.delete';

  @override
  @JsonKey(name: 'event_id')
  final String? eventId;

  @JsonKey(name: 'item_id')
  final String itemId;

  @override
  String get type => eventType;

  @override
  JsonMap toJson() =>
      _$ConversationItemDeleteEventToJson(this)..['type'] = type;
}

@JsonSerializable(explicitToJson: true, includeIfNull: false)
class ResponseCreateEvent implements RealtimeClientEvent {
  const ResponseCreateEvent({this.eventId, this.response});

  factory ResponseCreateEvent.fromJson(JsonMap json) =>
      _$ResponseCreateEventFromJson(json);

  static const String eventType = 'response.create';

  @override
  @JsonKey(name: 'event_id')
  final String? eventId;

  /// Optional overrides for this response.
  final ResponseParameters? response;

  @override
  String get type => eventType;

  @override
  JsonMap toJson() => _$ResponseCreateEventToJson(this)..['type'] = type;
}

/// Per-response inference parameters.
@JsonSerializable(
  explicitToJson: true,
  includeIfNull: false,
  createFactory: false,
)
class ResponseParameters {
  const ResponseParameters({
    this.instructions,
    this.tools,
    this.toolChoice,
    this.conversation,
    @JsonKey(name: 'output_modalities') this.outputModalities,
    this.metadata,
    this.input,
  });

  factory ResponseParameters.fromJson(JsonMap json) {
    return ResponseParameters(
      instructions: json['instructions'] as String?,
      tools: (json['tools'] as List?)
          ?.map(
            (tool) =>
                RealtimeTool.fromJson((tool as Map).cast<String, dynamic>()),
          )
          .toList(),
      toolChoice: ToolChoice.fromJson(json['tool_choice']),
      conversation: json['conversation'],
      outputModalities: (json['output_modalities'] as List?)?.cast<String>(),
      metadata: (json['metadata'] as Map?)?.cast<String, dynamic>(),
      input: (json['input'] as List?)
          ?.map(
            (entry) => RealtimeResponseInput.fromJson(
              (entry as Map).cast<String, dynamic>(),
            ),
          )
          .toList(),
    );
  }

  /// Overrides session instructions.
  final String? instructions;

  /// Overrides tools for this response.
  final List<RealtimeTool>? tools;

  /// Overrides tool choice for this response.
  final ToolChoice? toolChoice;

  /// Conversation target. `"none"` disables writing to the default conversation.
  final dynamic conversation;

  @JsonKey(name: 'output_modalities')
  final List<String>? outputModalities;

  /// Metadata attached to the response.
  final JsonMap? metadata;

  /// Input items (inline or references).
  final List<RealtimeResponseInput>? input;

  JsonMap toJson() {
    final json = _$ResponseParametersToJson(this);
    if (toolChoice != null) {
      json['tool_choice'] = toolChoice!.toJson();
    }
    if (input != null) {
      json['input'] = input!.map((i) => i.toJson()).toList();
    }
    return json;
  }
}

@JsonSerializable(includeIfNull: false)
class ResponseCancelEvent implements RealtimeClientEvent {
  const ResponseCancelEvent({
    this.eventId,
    @JsonKey(name: 'response_id') this.responseId,
  });

  factory ResponseCancelEvent.fromJson(JsonMap json) =>
      _$ResponseCancelEventFromJson(json);

  static const String eventType = 'response.cancel';

  @override
  @JsonKey(name: 'event_id')
  final String? eventId;

  @JsonKey(name: 'response_id')
  final String? responseId;

  @override
  String get type => eventType;

  @override
  JsonMap toJson() => _$ResponseCancelEventToJson(this)..['type'] = type;
}

@JsonSerializable(includeIfNull: false)
class OutputAudioBufferClearEvent implements RealtimeClientEvent {
  const OutputAudioBufferClearEvent({this.eventId});

  factory OutputAudioBufferClearEvent.fromJson(JsonMap json) =>
      _$OutputAudioBufferClearEventFromJson(json);

  static const String eventType = 'output_audio_buffer.clear';

  @override
  @JsonKey(name: 'event_id')
  final String? eventId;

  @override
  String get type => eventType;

  @override
  JsonMap toJson() =>
      _$OutputAudioBufferClearEventToJson(this)..['type'] = type;
}
