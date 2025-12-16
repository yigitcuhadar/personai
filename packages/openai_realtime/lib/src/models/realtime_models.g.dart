// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'realtime_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RealtimeSessionConfig _$RealtimeSessionConfigFromJson(
  Map<String, dynamic> json,
) => RealtimeSessionConfig(
  type: json['type'] as String?,
  object: json['object'] as String?,
  id: json['id'] as String?,
  model: json['model'] as String?,
  outputModalities: (json['output_modalities'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  instructions: json['instructions'] as String?,
  tools: (json['tools'] as List<dynamic>?)
      ?.map((e) => RealtimeTool.fromJson(e as Map<String, dynamic>))
      .toList(),
  toolChoice: json['tool_choice'] == null
      ? null
      : ToolChoice.fromJson(json['tool_choice']),
  maxOutputTokens: json['max_output_tokens'] == null
      ? null
      : MaxOutputTokens.fromJson(json['max_output_tokens']),
  tracing: json['tracing'] as Map<String, dynamic>?,
  truncation: json['truncation'],
  prompt: json['prompt'] == null
      ? null
      : RealtimePromptReference.fromJson(
          json['prompt'] as Map<String, dynamic>,
        ),
  expiresAt: (json['expires_at'] as num?)?.toInt(),
  audio: json['audio'] == null
      ? null
      : RealtimeAudioConfig.fromJson(json['audio'] as Map<String, dynamic>),
  include: (json['include'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
);

Map<String, dynamic> _$RealtimeSessionConfigToJson(
  RealtimeSessionConfig instance,
) => <String, dynamic>{
  'type': ?instance.type,
  'object': ?instance.object,
  'id': ?instance.id,
  'model': ?instance.model,
  'output_modalities': ?instance.outputModalities,
  'instructions': ?instance.instructions,
  'tools': ?instance.tools?.map((e) => e.toJson()).toList(),
  'tool_choice': ?instance.toolChoice?.toJson(),
  'max_output_tokens': ?instance.maxOutputTokens?.toJson(),
  'tracing': ?instance.tracing,
  'truncation': ?instance.truncation,
  'prompt': ?instance.prompt?.toJson(),
  'expires_at': ?instance.expiresAt,
  'audio': ?instance.audio?.toJson(),
  'include': ?instance.include,
};

RealtimeAudioConfig _$RealtimeAudioConfigFromJson(Map<String, dynamic> json) =>
    RealtimeAudioConfig(
      input: json['input'] == null
          ? null
          : RealtimeAudioInputConfig.fromJson(
              json['input'] as Map<String, dynamic>,
            ),
      output: json['output'] == null
          ? null
          : RealtimeAudioOutputConfig.fromJson(
              json['output'] as Map<String, dynamic>,
            ),
    );

Map<String, dynamic> _$RealtimeAudioConfigToJson(
  RealtimeAudioConfig instance,
) => <String, dynamic>{
  'input': ?instance.input?.toJson(),
  'output': ?instance.output?.toJson(),
};

RealtimeAudioInputConfig _$RealtimeAudioInputConfigFromJson(
  Map<String, dynamic> json,
) => RealtimeAudioInputConfig(
  format: json['format'] == null
      ? null
      : RealtimeAudioFormat.fromJson(json['format'] as Map<String, dynamic>),
  transcription: json['transcription'] as Map<String, dynamic>?,
  noiseReduction: json['noise_reduction'] as Map<String, dynamic>?,
  turnDetection: json['turn_detection'] == null
      ? null
      : RealtimeTurnDetection.fromJson(
          json['turn_detection'] as Map<String, dynamic>,
        ),
);

Map<String, dynamic> _$RealtimeAudioInputConfigToJson(
  RealtimeAudioInputConfig instance,
) => <String, dynamic>{
  'format': ?instance.format?.toJson(),
  'transcription': ?instance.transcription,
  'noise_reduction': ?instance.noiseReduction,
  'turn_detection': ?instance.turnDetection?.toJson(),
};

RealtimeAudioOutputConfig _$RealtimeAudioOutputConfigFromJson(
  Map<String, dynamic> json,
) => RealtimeAudioOutputConfig(
  format: json['format'] == null
      ? null
      : RealtimeAudioFormat.fromJson(json['format'] as Map<String, dynamic>),
  voice: json['voice'] as String?,
  speed: (json['speed'] as num?)?.toDouble(),
);

Map<String, dynamic> _$RealtimeAudioOutputConfigToJson(
  RealtimeAudioOutputConfig instance,
) => <String, dynamic>{
  'format': ?instance.format?.toJson(),
  'voice': ?instance.voice,
  'speed': ?instance.speed,
};

RealtimeAudioFormat _$RealtimeAudioFormatFromJson(Map<String, dynamic> json) =>
    RealtimeAudioFormat(
      type: json['type'] as String?,
      rate: (json['rate'] as num?)?.toInt(),
    );

Map<String, dynamic> _$RealtimeAudioFormatToJson(
  RealtimeAudioFormat instance,
) => <String, dynamic>{'type': ?instance.type, 'rate': ?instance.rate};

RealtimeTurnDetection _$RealtimeTurnDetectionFromJson(
  Map<String, dynamic> json,
) => RealtimeTurnDetection(
  type: json['type'] as String?,
  threshold: (json['threshold'] as num?)?.toDouble(),
  prefixPaddingMs: (json['prefix_padding_ms'] as num?)?.toInt(),
  silenceDurationMs: (json['silence_duration_ms'] as num?)?.toInt(),
  idleTimeoutMs: (json['idle_timeout_ms'] as num?)?.toInt(),
  createResponse: json['create_response'] as bool?,
  interruptResponse: json['interrupt_response'] as bool?,
);

Map<String, dynamic> _$RealtimeTurnDetectionToJson(
  RealtimeTurnDetection instance,
) => <String, dynamic>{
  'type': ?instance.type,
  'threshold': ?instance.threshold,
  'prefix_padding_ms': ?instance.prefixPaddingMs,
  'silence_duration_ms': ?instance.silenceDurationMs,
  'idle_timeout_ms': ?instance.idleTimeoutMs,
  'create_response': ?instance.createResponse,
  'interrupt_response': ?instance.interruptResponse,
};

RealtimePromptReference _$RealtimePromptReferenceFromJson(
  Map<String, dynamic> json,
) => RealtimePromptReference(
  id: json['id'] as String?,
  metadata: json['metadata'] as Map<String, dynamic>?,
);

Map<String, dynamic> _$RealtimePromptReferenceToJson(
  RealtimePromptReference instance,
) => <String, dynamic>{'id': ?instance.id, 'metadata': ?instance.metadata};

InputTextContent _$InputTextContentFromJson(Map<String, dynamic> json) =>
    InputTextContent(
      type: json['type'] as String? ?? 'input_text',
      text: json['text'] as String,
    );

Map<String, dynamic> _$InputTextContentToJson(InputTextContent instance) =>
    <String, dynamic>{'type': instance.type, 'text': instance.text};

OutputTextContent _$OutputTextContentFromJson(Map<String, dynamic> json) =>
    OutputTextContent(
      type: json['type'] as String? ?? 'output_text',
      text: json['text'] as String,
    );

Map<String, dynamic> _$OutputTextContentToJson(OutputTextContent instance) =>
    <String, dynamic>{'type': instance.type, 'text': instance.text};

OutputAudioContent _$OutputAudioContentFromJson(Map<String, dynamic> json) =>
    OutputAudioContent(
      type: json['type'] as String? ?? 'output_audio',
      transcript: json['transcript'] as String?,
    );

Map<String, dynamic> _$OutputAudioContentToJson(OutputAudioContent instance) =>
    <String, dynamic>{
      'type': instance.type,
      'transcript': ?instance.transcript,
    };

AudioContent _$AudioContentFromJson(Map<String, dynamic> json) => AudioContent(
  type: json['type'] as String? ?? 'audio',
  transcript: json['transcript'] as String?,
  audio: json['audio'] as String?,
  format: json['format'] as String?,
);

Map<String, dynamic> _$AudioContentToJson(AudioContent instance) =>
    <String, dynamic>{
      'type': instance.type,
      'transcript': ?instance.transcript,
      'audio': ?instance.audio,
      'format': ?instance.format,
    };

RealtimeItemReference _$RealtimeItemReferenceFromJson(
  Map<String, dynamic> json,
) => RealtimeItemReference(
  type: json['type'] as String? ?? 'item_reference',
  id: json['id'] as String,
);

Map<String, dynamic> _$RealtimeItemReferenceToJson(
  RealtimeItemReference instance,
) => <String, dynamic>{'type': instance.type, 'id': instance.id};

RealtimeResponse _$RealtimeResponseFromJson(Map<String, dynamic> json) =>
    RealtimeResponse(
      object: json['object'] as String?,
      id: json['id'] as String?,
      status: json['status'] as String?,
      statusDetails: json['status_details'] as Map<String, dynamic>?,
      output:
          (json['output'] as List<dynamic>?)
              ?.map((e) => RealtimeItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      conversationId: json['conversation_id'] as String?,
      outputModalities: (json['output_modalities'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      maxOutputTokens: json['max_output_tokens'] == null
          ? null
          : MaxOutputTokens.fromJson(json['max_output_tokens']),
      audio: json['audio'] == null
          ? null
          : RealtimeAudioConfig.fromJson(json['audio'] as Map<String, dynamic>),
      usage: json['usage'] == null
          ? null
          : RealtimeUsage.fromJson(json['usage'] as Map<String, dynamic>),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$RealtimeResponseToJson(RealtimeResponse instance) =>
    <String, dynamic>{
      'object': ?instance.object,
      'id': ?instance.id,
      'status': ?instance.status,
      'status_details': ?instance.statusDetails,
      'output': instance.output.map((e) => e.toJson()).toList(),
      'conversation_id': ?instance.conversationId,
      'output_modalities': ?instance.outputModalities,
      'max_output_tokens': ?instance.maxOutputTokens?.toJson(),
      'audio': ?instance.audio?.toJson(),
      'usage': ?instance.usage?.toJson(),
      'metadata': ?instance.metadata,
    };

RealtimeUsage _$RealtimeUsageFromJson(Map<String, dynamic> json) =>
    RealtimeUsage(
      totalTokens: (json['total_tokens'] as num?)?.toInt(),
      inputTokens: (json['input_tokens'] as num?)?.toInt(),
      outputTokens: (json['output_tokens'] as num?)?.toInt(),
      inputTokenDetails: json['input_token_details'] == null
          ? null
          : UsageTokenDetails.fromJson(
              json['input_token_details'] as Map<String, dynamic>,
            ),
      outputTokenDetails: json['output_token_details'] == null
          ? null
          : UsageTokenDetails.fromJson(
              json['output_token_details'] as Map<String, dynamic>,
            ),
      type: json['type'] as String?,
    );

Map<String, dynamic> _$RealtimeUsageToJson(RealtimeUsage instance) =>
    <String, dynamic>{
      'type': ?instance.type,
      'total_tokens': ?instance.totalTokens,
      'input_tokens': ?instance.inputTokens,
      'output_tokens': ?instance.outputTokens,
      'input_token_details': ?instance.inputTokenDetails?.toJson(),
      'output_token_details': ?instance.outputTokenDetails?.toJson(),
    };

UsageTokenDetails _$UsageTokenDetailsFromJson(Map<String, dynamic> json) =>
    UsageTokenDetails(
      textTokens: (json['text_tokens'] as num?)?.toInt(),
      audioTokens: (json['audio_tokens'] as num?)?.toInt(),
      imageTokens: (json['image_tokens'] as num?)?.toInt(),
      cachedTokens: (json['cached_tokens'] as num?)?.toInt(),
      cachedTokensDetails: json['cached_tokens_details'] == null
          ? null
          : CachedTokenDetails.fromJson(
              json['cached_tokens_details'] as Map<String, dynamic>,
            ),
    );

Map<String, dynamic> _$UsageTokenDetailsToJson(UsageTokenDetails instance) =>
    <String, dynamic>{
      'text_tokens': ?instance.textTokens,
      'audio_tokens': ?instance.audioTokens,
      'image_tokens': ?instance.imageTokens,
      'cached_tokens': ?instance.cachedTokens,
      'cached_tokens_details': ?instance.cachedTokensDetails?.toJson(),
    };

CachedTokenDetails _$CachedTokenDetailsFromJson(Map<String, dynamic> json) =>
    CachedTokenDetails(
      textTokens: (json['text_tokens'] as num?)?.toInt(),
      audioTokens: (json['audio_tokens'] as num?)?.toInt(),
      imageTokens: (json['image_tokens'] as num?)?.toInt(),
    );

Map<String, dynamic> _$CachedTokenDetailsToJson(CachedTokenDetails instance) =>
    <String, dynamic>{
      'text_tokens': ?instance.textTokens,
      'audio_tokens': ?instance.audioTokens,
      'image_tokens': ?instance.imageTokens,
    };

RateLimit _$RateLimitFromJson(Map<String, dynamic> json) => RateLimit(
  name: json['name'] as String,
  limit: (json['limit'] as num).toInt(),
  remaining: (json['remaining'] as num).toInt(),
  resetSeconds: (json['reset_seconds'] as num).toInt(),
);

Map<String, dynamic> _$RateLimitToJson(RateLimit instance) => <String, dynamic>{
  'name': instance.name,
  'limit': instance.limit,
  'remaining': instance.remaining,
  'reset_seconds': instance.resetSeconds,
};

SessionUpdateEvent _$SessionUpdateEventFromJson(Map<String, dynamic> json) =>
    SessionUpdateEvent(
      eventId: json['event_id'] as String?,
      session: RealtimeSessionConfig.fromJson(
        json['session'] as Map<String, dynamic>,
      ),
    );

Map<String, dynamic> _$SessionUpdateEventToJson(SessionUpdateEvent instance) =>
    <String, dynamic>{
      'event_id': ?instance.eventId,
      'session': instance.session.toJson(),
    };

InputAudioBufferAppendEvent _$InputAudioBufferAppendEventFromJson(
  Map<String, dynamic> json,
) => InputAudioBufferAppendEvent(
  eventId: json['event_id'] as String?,
  audio: json['audio'] as String,
);

Map<String, dynamic> _$InputAudioBufferAppendEventToJson(
  InputAudioBufferAppendEvent instance,
) => <String, dynamic>{'event_id': ?instance.eventId, 'audio': instance.audio};

InputAudioBufferCommitEvent _$InputAudioBufferCommitEventFromJson(
  Map<String, dynamic> json,
) => InputAudioBufferCommitEvent(eventId: json['event_id'] as String?);

Map<String, dynamic> _$InputAudioBufferCommitEventToJson(
  InputAudioBufferCommitEvent instance,
) => <String, dynamic>{'event_id': ?instance.eventId};

InputAudioBufferClearEvent _$InputAudioBufferClearEventFromJson(
  Map<String, dynamic> json,
) => InputAudioBufferClearEvent(eventId: json['event_id'] as String?);

Map<String, dynamic> _$InputAudioBufferClearEventToJson(
  InputAudioBufferClearEvent instance,
) => <String, dynamic>{'event_id': ?instance.eventId};

ConversationItemCreateEvent _$ConversationItemCreateEventFromJson(
  Map<String, dynamic> json,
) => ConversationItemCreateEvent(
  eventId: json['event_id'] as String?,
  item: RealtimeItem.fromJson(json['item'] as Map<String, dynamic>),
  previousItemId: json['previous_item_id'] as String?,
);

Map<String, dynamic> _$ConversationItemCreateEventToJson(
  ConversationItemCreateEvent instance,
) => <String, dynamic>{
  'event_id': ?instance.eventId,
  'item': instance.item.toJson(),
  'previous_item_id': ?instance.previousItemId,
};

ConversationItemRetrieveEvent _$ConversationItemRetrieveEventFromJson(
  Map<String, dynamic> json,
) => ConversationItemRetrieveEvent(
  eventId: json['event_id'] as String?,
  itemId: json['item_id'] as String,
);

Map<String, dynamic> _$ConversationItemRetrieveEventToJson(
  ConversationItemRetrieveEvent instance,
) => <String, dynamic>{
  'event_id': ?instance.eventId,
  'item_id': instance.itemId,
};

ConversationItemTruncateEvent _$ConversationItemTruncateEventFromJson(
  Map<String, dynamic> json,
) => ConversationItemTruncateEvent(
  eventId: json['event_id'] as String?,
  itemId: json['item_id'] as String,
  contentIndex: (json['content_index'] as num).toInt(),
  audioEndMs: (json['audio_end_ms'] as num).toInt(),
);

Map<String, dynamic> _$ConversationItemTruncateEventToJson(
  ConversationItemTruncateEvent instance,
) => <String, dynamic>{
  'event_id': ?instance.eventId,
  'item_id': instance.itemId,
  'content_index': instance.contentIndex,
  'audio_end_ms': instance.audioEndMs,
};

ConversationItemDeleteEvent _$ConversationItemDeleteEventFromJson(
  Map<String, dynamic> json,
) => ConversationItemDeleteEvent(
  eventId: json['event_id'] as String?,
  itemId: json['item_id'] as String,
);

Map<String, dynamic> _$ConversationItemDeleteEventToJson(
  ConversationItemDeleteEvent instance,
) => <String, dynamic>{
  'event_id': ?instance.eventId,
  'item_id': instance.itemId,
};

ResponseCreateEvent _$ResponseCreateEventFromJson(Map<String, dynamic> json) =>
    ResponseCreateEvent(
      eventId: json['event_id'] as String?,
      response: json['response'] == null
          ? null
          : ResponseParameters.fromJson(
              json['response'] as Map<String, dynamic>,
            ),
    );

Map<String, dynamic> _$ResponseCreateEventToJson(
  ResponseCreateEvent instance,
) => <String, dynamic>{
  'event_id': ?instance.eventId,
  'response': ?instance.response?.toJson(),
};

Map<String, dynamic> _$ResponseParametersToJson(ResponseParameters instance) =>
    <String, dynamic>{
      'instructions': ?instance.instructions,
      'tools': ?instance.tools?.map((e) => e.toJson()).toList(),
      'toolChoice': ?instance.toolChoice?.toJson(),
      'conversation': ?instance.conversation,
      'output_modalities': ?instance.outputModalities,
      'metadata': ?instance.metadata,
      'input': ?instance.input?.map((e) => e.toJson()).toList(),
    };

ResponseCancelEvent _$ResponseCancelEventFromJson(Map<String, dynamic> json) =>
    ResponseCancelEvent(
      eventId: json['event_id'] as String?,
      responseId: json['response_id'] as String?,
    );

Map<String, dynamic> _$ResponseCancelEventToJson(
  ResponseCancelEvent instance,
) => <String, dynamic>{
  'event_id': ?instance.eventId,
  'response_id': ?instance.responseId,
};

OutputAudioBufferClearEvent _$OutputAudioBufferClearEventFromJson(
  Map<String, dynamic> json,
) => OutputAudioBufferClearEvent(eventId: json['event_id'] as String?);

Map<String, dynamic> _$OutputAudioBufferClearEventToJson(
  OutputAudioBufferClearEvent instance,
) => <String, dynamic>{'event_id': ?instance.eventId};

ServerErrorEvent _$ServerErrorEventFromJson(Map<String, dynamic> json) =>
    ServerErrorEvent(
      eventId: json['event_id'] as String?,
      error: RealtimeApiError.fromJson(json['error'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ServerErrorEventToJson(ServerErrorEvent instance) =>
    <String, dynamic>{
      'event_id': ?instance.eventId,
      'error': instance.error.toJson(),
    };

SessionCreatedEvent _$SessionCreatedEventFromJson(Map<String, dynamic> json) =>
    SessionCreatedEvent(
      eventId: json['event_id'] as String?,
      session: RealtimeSessionConfig.fromJson(
        json['session'] as Map<String, dynamic>,
      ),
    );

Map<String, dynamic> _$SessionCreatedEventToJson(
  SessionCreatedEvent instance,
) => <String, dynamic>{
  'event_id': ?instance.eventId,
  'session': instance.session.toJson(),
};

SessionUpdatedEvent _$SessionUpdatedEventFromJson(Map<String, dynamic> json) =>
    SessionUpdatedEvent(
      eventId: json['event_id'] as String?,
      session: RealtimeSessionConfig.fromJson(
        json['session'] as Map<String, dynamic>,
      ),
    );

Map<String, dynamic> _$SessionUpdatedEventToJson(
  SessionUpdatedEvent instance,
) => <String, dynamic>{
  'event_id': ?instance.eventId,
  'session': instance.session.toJson(),
};

ConversationItemAddedEvent _$ConversationItemAddedEventFromJson(
  Map<String, dynamic> json,
) => ConversationItemAddedEvent(
  eventId: json['event_id'] as String?,
  item: RealtimeItem.fromJson(json['item'] as Map<String, dynamic>),
  previousItemId: json['previous_item_id'] as String?,
);

Map<String, dynamic> _$ConversationItemAddedEventToJson(
  ConversationItemAddedEvent instance,
) => <String, dynamic>{
  'event_id': ?instance.eventId,
  'item': instance.item.toJson(),
  'previous_item_id': ?instance.previousItemId,
};

ConversationItemDoneEvent _$ConversationItemDoneEventFromJson(
  Map<String, dynamic> json,
) => ConversationItemDoneEvent(
  eventId: json['event_id'] as String?,
  item: RealtimeItem.fromJson(json['item'] as Map<String, dynamic>),
  previousItemId: json['previous_item_id'] as String?,
);

Map<String, dynamic> _$ConversationItemDoneEventToJson(
  ConversationItemDoneEvent instance,
) => <String, dynamic>{
  'event_id': ?instance.eventId,
  'item': instance.item.toJson(),
  'previous_item_id': ?instance.previousItemId,
};

ConversationItemRetrievedEvent _$ConversationItemRetrievedEventFromJson(
  Map<String, dynamic> json,
) => ConversationItemRetrievedEvent(
  eventId: json['event_id'] as String?,
  item: RealtimeItem.fromJson(json['item'] as Map<String, dynamic>),
);

Map<String, dynamic> _$ConversationItemRetrievedEventToJson(
  ConversationItemRetrievedEvent instance,
) => <String, dynamic>{
  'event_id': ?instance.eventId,
  'item': instance.item.toJson(),
};

ConversationItemInputTranscriptionCompleted
_$ConversationItemInputTranscriptionCompletedFromJson(
  Map<String, dynamic> json,
) => ConversationItemInputTranscriptionCompleted(
  eventId: json['event_id'] as String?,
  itemId: json['item_id'] as String,
  contentIndex: (json['content_index'] as num).toInt(),
  transcript: json['transcript'] as String,
  usage: json['usage'] == null
      ? null
      : RealtimeUsage.fromJson(json['usage'] as Map<String, dynamic>),
  logprobs: json['logprobs'] as List<dynamic>?,
);

Map<String, dynamic> _$ConversationItemInputTranscriptionCompletedToJson(
  ConversationItemInputTranscriptionCompleted instance,
) => <String, dynamic>{
  'event_id': ?instance.eventId,
  'item_id': instance.itemId,
  'content_index': instance.contentIndex,
  'transcript': instance.transcript,
  'usage': ?instance.usage?.toJson(),
  'logprobs': ?instance.logprobs,
};

ConversationItemInputTranscriptionDelta
_$ConversationItemInputTranscriptionDeltaFromJson(Map<String, dynamic> json) =>
    ConversationItemInputTranscriptionDelta(
      eventId: json['event_id'] as String?,
      itemId: json['item_id'] as String,
      contentIndex: (json['content_index'] as num).toInt(),
      delta: json['delta'] as String,
      logprobs: json['logprobs'] as List<dynamic>?,
      obfuscation: json['obfuscation'] as String?,
    );

Map<String, dynamic> _$ConversationItemInputTranscriptionDeltaToJson(
  ConversationItemInputTranscriptionDelta instance,
) => <String, dynamic>{
  'event_id': ?instance.eventId,
  'item_id': instance.itemId,
  'content_index': instance.contentIndex,
  'delta': instance.delta,
  'logprobs': ?instance.logprobs,
  'obfuscation': ?instance.obfuscation,
};

ConversationItemInputTranscriptionSegment
_$ConversationItemInputTranscriptionSegmentFromJson(
  Map<String, dynamic> json,
) => ConversationItemInputTranscriptionSegment(
  eventId: json['event_id'] as String?,
  itemId: json['item_id'] as String,
  contentIndex: (json['content_index'] as num).toInt(),
  text: json['text'] as String,
  id: json['id'] as String,
  start: (json['start'] as num).toDouble(),
  end: (json['end'] as num).toDouble(),
  speaker: json['speaker'] as String?,
);

Map<String, dynamic> _$ConversationItemInputTranscriptionSegmentToJson(
  ConversationItemInputTranscriptionSegment instance,
) => <String, dynamic>{
  'event_id': ?instance.eventId,
  'item_id': instance.itemId,
  'content_index': instance.contentIndex,
  'text': instance.text,
  'id': instance.id,
  'start': instance.start,
  'end': instance.end,
  'speaker': ?instance.speaker,
};

ConversationItemInputTranscriptionFailed
_$ConversationItemInputTranscriptionFailedFromJson(Map<String, dynamic> json) =>
    ConversationItemInputTranscriptionFailed(
      eventId: json['event_id'] as String?,
      itemId: json['item_id'] as String,
      contentIndex: (json['content_index'] as num).toInt(),
      error: RealtimeApiError.fromJson(json['error'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ConversationItemInputTranscriptionFailedToJson(
  ConversationItemInputTranscriptionFailed instance,
) => <String, dynamic>{
  'event_id': ?instance.eventId,
  'item_id': instance.itemId,
  'content_index': instance.contentIndex,
  'error': instance.error.toJson(),
};

ConversationItemTruncatedEvent _$ConversationItemTruncatedEventFromJson(
  Map<String, dynamic> json,
) => ConversationItemTruncatedEvent(
  eventId: json['event_id'] as String?,
  itemId: json['item_id'] as String,
  contentIndex: (json['content_index'] as num).toInt(),
  audioEndMs: (json['audio_end_ms'] as num).toInt(),
);

Map<String, dynamic> _$ConversationItemTruncatedEventToJson(
  ConversationItemTruncatedEvent instance,
) => <String, dynamic>{
  'event_id': ?instance.eventId,
  'item_id': instance.itemId,
  'content_index': instance.contentIndex,
  'audio_end_ms': instance.audioEndMs,
};

ConversationItemDeletedEvent _$ConversationItemDeletedEventFromJson(
  Map<String, dynamic> json,
) => ConversationItemDeletedEvent(
  eventId: json['event_id'] as String?,
  itemId: json['item_id'] as String,
);

Map<String, dynamic> _$ConversationItemDeletedEventToJson(
  ConversationItemDeletedEvent instance,
) => <String, dynamic>{
  'event_id': ?instance.eventId,
  'item_id': instance.itemId,
};

InputAudioBufferCommittedEvent _$InputAudioBufferCommittedEventFromJson(
  Map<String, dynamic> json,
) => InputAudioBufferCommittedEvent(
  eventId: json['event_id'] as String?,
  itemId: json['item_id'] as String,
  previousItemId: json['previous_item_id'] as String?,
);

Map<String, dynamic> _$InputAudioBufferCommittedEventToJson(
  InputAudioBufferCommittedEvent instance,
) => <String, dynamic>{
  'event_id': ?instance.eventId,
  'item_id': instance.itemId,
  'previous_item_id': ?instance.previousItemId,
};

InputAudioBufferDtmfEvent _$InputAudioBufferDtmfEventFromJson(
  Map<String, dynamic> json,
) => InputAudioBufferDtmfEvent(
  eventId: json['event_id'] as String?,
  event: json['event'] as String,
  receivedAt: (json['received_at'] as num).toInt(),
);

Map<String, dynamic> _$InputAudioBufferDtmfEventToJson(
  InputAudioBufferDtmfEvent instance,
) => <String, dynamic>{
  'event_id': ?instance.eventId,
  'event': instance.event,
  'received_at': instance.receivedAt,
};

InputAudioBufferClearedEvent _$InputAudioBufferClearedEventFromJson(
  Map<String, dynamic> json,
) => InputAudioBufferClearedEvent(eventId: json['event_id'] as String?);

Map<String, dynamic> _$InputAudioBufferClearedEventToJson(
  InputAudioBufferClearedEvent instance,
) => <String, dynamic>{'event_id': ?instance.eventId};

InputAudioBufferSpeechStartedEvent _$InputAudioBufferSpeechStartedEventFromJson(
  Map<String, dynamic> json,
) => InputAudioBufferSpeechStartedEvent(
  eventId: json['event_id'] as String?,
  audioStartMs: (json['audio_start_ms'] as num).toInt(),
  itemId: json['item_id'] as String,
);

Map<String, dynamic> _$InputAudioBufferSpeechStartedEventToJson(
  InputAudioBufferSpeechStartedEvent instance,
) => <String, dynamic>{
  'event_id': ?instance.eventId,
  'audio_start_ms': instance.audioStartMs,
  'item_id': instance.itemId,
};

InputAudioBufferSpeechStoppedEvent _$InputAudioBufferSpeechStoppedEventFromJson(
  Map<String, dynamic> json,
) => InputAudioBufferSpeechStoppedEvent(
  eventId: json['event_id'] as String?,
  audioEndMs: (json['audio_end_ms'] as num).toInt(),
  itemId: json['item_id'] as String,
);

Map<String, dynamic> _$InputAudioBufferSpeechStoppedEventToJson(
  InputAudioBufferSpeechStoppedEvent instance,
) => <String, dynamic>{
  'event_id': ?instance.eventId,
  'audio_end_ms': instance.audioEndMs,
  'item_id': instance.itemId,
};

InputAudioBufferTimeoutTriggeredEvent
_$InputAudioBufferTimeoutTriggeredEventFromJson(Map<String, dynamic> json) =>
    InputAudioBufferTimeoutTriggeredEvent(
      eventId: json['event_id'] as String?,
      audioStartMs: (json['audio_start_ms'] as num).toInt(),
      audioEndMs: (json['audio_end_ms'] as num).toInt(),
      itemId: json['item_id'] as String,
    );

Map<String, dynamic> _$InputAudioBufferTimeoutTriggeredEventToJson(
  InputAudioBufferTimeoutTriggeredEvent instance,
) => <String, dynamic>{
  'event_id': ?instance.eventId,
  'audio_start_ms': instance.audioStartMs,
  'audio_end_ms': instance.audioEndMs,
  'item_id': instance.itemId,
};

OutputAudioBufferStartedEvent _$OutputAudioBufferStartedEventFromJson(
  Map<String, dynamic> json,
) => OutputAudioBufferStartedEvent(
  eventId: json['event_id'] as String?,
  responseId: json['response_id'] as String,
);

Map<String, dynamic> _$OutputAudioBufferStartedEventToJson(
  OutputAudioBufferStartedEvent instance,
) => <String, dynamic>{
  'event_id': ?instance.eventId,
  'response_id': instance.responseId,
};

OutputAudioBufferStoppedEvent _$OutputAudioBufferStoppedEventFromJson(
  Map<String, dynamic> json,
) => OutputAudioBufferStoppedEvent(
  eventId: json['event_id'] as String?,
  responseId: json['response_id'] as String,
);

Map<String, dynamic> _$OutputAudioBufferStoppedEventToJson(
  OutputAudioBufferStoppedEvent instance,
) => <String, dynamic>{
  'event_id': ?instance.eventId,
  'response_id': instance.responseId,
};

OutputAudioBufferClearedEvent _$OutputAudioBufferClearedEventFromJson(
  Map<String, dynamic> json,
) => OutputAudioBufferClearedEvent(
  eventId: json['event_id'] as String?,
  responseId: json['response_id'] as String,
);

Map<String, dynamic> _$OutputAudioBufferClearedEventToJson(
  OutputAudioBufferClearedEvent instance,
) => <String, dynamic>{
  'event_id': ?instance.eventId,
  'response_id': instance.responseId,
};

ResponseCreatedEvent _$ResponseCreatedEventFromJson(
  Map<String, dynamic> json,
) => ResponseCreatedEvent(
  eventId: json['event_id'] as String?,
  response: RealtimeResponse.fromJson(json['response'] as Map<String, dynamic>),
);

Map<String, dynamic> _$ResponseCreatedEventToJson(
  ResponseCreatedEvent instance,
) => <String, dynamic>{
  'event_id': ?instance.eventId,
  'response': instance.response.toJson(),
};

ResponseDoneEvent _$ResponseDoneEventFromJson(Map<String, dynamic> json) =>
    ResponseDoneEvent(
      eventId: json['event_id'] as String?,
      response: RealtimeResponse.fromJson(
        json['response'] as Map<String, dynamic>,
      ),
    );

Map<String, dynamic> _$ResponseDoneEventToJson(ResponseDoneEvent instance) =>
    <String, dynamic>{
      'event_id': ?instance.eventId,
      'response': instance.response.toJson(),
    };

ResponseOutputItemAddedEvent _$ResponseOutputItemAddedEventFromJson(
  Map<String, dynamic> json,
) => ResponseOutputItemAddedEvent(
  eventId: json['event_id'] as String?,
  responseId: json['response_id'] as String,
  outputIndex: (json['output_index'] as num).toInt(),
  item: RealtimeItem.fromJson(json['item'] as Map<String, dynamic>),
);

Map<String, dynamic> _$ResponseOutputItemAddedEventToJson(
  ResponseOutputItemAddedEvent instance,
) => <String, dynamic>{
  'event_id': ?instance.eventId,
  'response_id': instance.responseId,
  'output_index': instance.outputIndex,
  'item': instance.item.toJson(),
};

ResponseOutputItemDoneEvent _$ResponseOutputItemDoneEventFromJson(
  Map<String, dynamic> json,
) => ResponseOutputItemDoneEvent(
  eventId: json['event_id'] as String?,
  responseId: json['response_id'] as String,
  outputIndex: (json['output_index'] as num).toInt(),
  item: RealtimeItem.fromJson(json['item'] as Map<String, dynamic>),
);

Map<String, dynamic> _$ResponseOutputItemDoneEventToJson(
  ResponseOutputItemDoneEvent instance,
) => <String, dynamic>{
  'event_id': ?instance.eventId,
  'response_id': instance.responseId,
  'output_index': instance.outputIndex,
  'item': instance.item.toJson(),
};

ResponseOutputTextDeltaEvent _$ResponseOutputTextDeltaEventFromJson(
  Map<String, dynamic> json,
) => ResponseOutputTextDeltaEvent(
  eventId: json['event_id'] as String?,
  responseId: json['response_id'] as String,
  itemId: json['item_id'] as String,
  outputIndex: (json['output_index'] as num).toInt(),
  contentIndex: (json['content_index'] as num).toInt(),
  delta: json['delta'] as String,
);

Map<String, dynamic> _$ResponseOutputTextDeltaEventToJson(
  ResponseOutputTextDeltaEvent instance,
) => <String, dynamic>{
  'event_id': ?instance.eventId,
  'response_id': instance.responseId,
  'item_id': instance.itemId,
  'output_index': instance.outputIndex,
  'content_index': instance.contentIndex,
  'delta': instance.delta,
};

ResponseOutputTextDoneEvent _$ResponseOutputTextDoneEventFromJson(
  Map<String, dynamic> json,
) => ResponseOutputTextDoneEvent(
  eventId: json['event_id'] as String?,
  responseId: json['response_id'] as String,
  itemId: json['item_id'] as String,
  outputIndex: (json['output_index'] as num).toInt(),
  contentIndex: (json['content_index'] as num).toInt(),
  text: json['text'] as String,
);

Map<String, dynamic> _$ResponseOutputTextDoneEventToJson(
  ResponseOutputTextDoneEvent instance,
) => <String, dynamic>{
  'event_id': ?instance.eventId,
  'response_id': instance.responseId,
  'item_id': instance.itemId,
  'output_index': instance.outputIndex,
  'content_index': instance.contentIndex,
  'text': instance.text,
};

ResponseOutputAudioTranscriptDeltaEvent
_$ResponseOutputAudioTranscriptDeltaEventFromJson(Map<String, dynamic> json) =>
    ResponseOutputAudioTranscriptDeltaEvent(
      eventId: json['event_id'] as String?,
      responseId: json['response_id'] as String,
      itemId: json['item_id'] as String,
      outputIndex: (json['output_index'] as num).toInt(),
      contentIndex: (json['content_index'] as num).toInt(),
      delta: json['delta'] as String,
    );

Map<String, dynamic> _$ResponseOutputAudioTranscriptDeltaEventToJson(
  ResponseOutputAudioTranscriptDeltaEvent instance,
) => <String, dynamic>{
  'event_id': ?instance.eventId,
  'response_id': instance.responseId,
  'item_id': instance.itemId,
  'output_index': instance.outputIndex,
  'content_index': instance.contentIndex,
  'delta': instance.delta,
};

ResponseOutputAudioTranscriptDoneEvent
_$ResponseOutputAudioTranscriptDoneEventFromJson(Map<String, dynamic> json) =>
    ResponseOutputAudioTranscriptDoneEvent(
      eventId: json['event_id'] as String?,
      responseId: json['response_id'] as String,
      itemId: json['item_id'] as String,
      outputIndex: (json['output_index'] as num).toInt(),
      contentIndex: (json['content_index'] as num).toInt(),
      transcript: json['transcript'] as String,
    );

Map<String, dynamic> _$ResponseOutputAudioTranscriptDoneEventToJson(
  ResponseOutputAudioTranscriptDoneEvent instance,
) => <String, dynamic>{
  'event_id': ?instance.eventId,
  'response_id': instance.responseId,
  'item_id': instance.itemId,
  'output_index': instance.outputIndex,
  'content_index': instance.contentIndex,
  'transcript': instance.transcript,
};

ResponseOutputAudioDeltaEvent _$ResponseOutputAudioDeltaEventFromJson(
  Map<String, dynamic> json,
) => ResponseOutputAudioDeltaEvent(
  eventId: json['event_id'] as String?,
  responseId: json['response_id'] as String,
  itemId: json['item_id'] as String,
  outputIndex: (json['output_index'] as num).toInt(),
  contentIndex: (json['content_index'] as num).toInt(),
  delta: json['delta'] as String,
);

Map<String, dynamic> _$ResponseOutputAudioDeltaEventToJson(
  ResponseOutputAudioDeltaEvent instance,
) => <String, dynamic>{
  'event_id': ?instance.eventId,
  'response_id': instance.responseId,
  'item_id': instance.itemId,
  'output_index': instance.outputIndex,
  'content_index': instance.contentIndex,
  'delta': instance.delta,
};

ResponseOutputAudioDoneEvent _$ResponseOutputAudioDoneEventFromJson(
  Map<String, dynamic> json,
) => ResponseOutputAudioDoneEvent(
  eventId: json['event_id'] as String?,
  responseId: json['response_id'] as String,
  itemId: json['item_id'] as String,
  outputIndex: (json['output_index'] as num).toInt(),
  contentIndex: (json['content_index'] as num).toInt(),
);

Map<String, dynamic> _$ResponseOutputAudioDoneEventToJson(
  ResponseOutputAudioDoneEvent instance,
) => <String, dynamic>{
  'event_id': ?instance.eventId,
  'response_id': instance.responseId,
  'item_id': instance.itemId,
  'output_index': instance.outputIndex,
  'content_index': instance.contentIndex,
};

ResponseFunctionCallArgumentsDeltaEvent
_$ResponseFunctionCallArgumentsDeltaEventFromJson(Map<String, dynamic> json) =>
    ResponseFunctionCallArgumentsDeltaEvent(
      eventId: json['event_id'] as String?,
      responseId: json['response_id'] as String,
      itemId: json['item_id'] as String,
      outputIndex: (json['output_index'] as num).toInt(),
      callId: json['call_id'] as String,
      delta: json['delta'] as String,
    );

Map<String, dynamic> _$ResponseFunctionCallArgumentsDeltaEventToJson(
  ResponseFunctionCallArgumentsDeltaEvent instance,
) => <String, dynamic>{
  'event_id': ?instance.eventId,
  'response_id': instance.responseId,
  'item_id': instance.itemId,
  'output_index': instance.outputIndex,
  'call_id': instance.callId,
  'delta': instance.delta,
};

ResponseFunctionCallArgumentsDoneEvent
_$ResponseFunctionCallArgumentsDoneEventFromJson(Map<String, dynamic> json) =>
    ResponseFunctionCallArgumentsDoneEvent(
      eventId: json['event_id'] as String?,
      responseId: json['response_id'] as String,
      itemId: json['item_id'] as String,
      outputIndex: (json['output_index'] as num).toInt(),
      callId: json['call_id'] as String,
      arguments: json['arguments'] as String,
    );

Map<String, dynamic> _$ResponseFunctionCallArgumentsDoneEventToJson(
  ResponseFunctionCallArgumentsDoneEvent instance,
) => <String, dynamic>{
  'event_id': ?instance.eventId,
  'response_id': instance.responseId,
  'item_id': instance.itemId,
  'output_index': instance.outputIndex,
  'call_id': instance.callId,
  'arguments': instance.arguments,
};

ResponseMcpCallArgumentsDeltaEvent _$ResponseMcpCallArgumentsDeltaEventFromJson(
  Map<String, dynamic> json,
) => ResponseMcpCallArgumentsDeltaEvent(
  eventId: json['event_id'] as String?,
  responseId: json['response_id'] as String?,
  itemId: json['item_id'] as String,
  outputIndex: (json['output_index'] as num).toInt(),
  delta: json['delta'] as String,
  obfuscation: json['obfuscation'] as String?,
);

Map<String, dynamic> _$ResponseMcpCallArgumentsDeltaEventToJson(
  ResponseMcpCallArgumentsDeltaEvent instance,
) => <String, dynamic>{
  'event_id': ?instance.eventId,
  'response_id': ?instance.responseId,
  'item_id': instance.itemId,
  'output_index': instance.outputIndex,
  'delta': instance.delta,
  'obfuscation': ?instance.obfuscation,
};

ResponseMcpCallArgumentsDoneEvent _$ResponseMcpCallArgumentsDoneEventFromJson(
  Map<String, dynamic> json,
) => ResponseMcpCallArgumentsDoneEvent(
  eventId: json['event_id'] as String?,
  responseId: json['response_id'] as String?,
  itemId: json['item_id'] as String,
  outputIndex: (json['output_index'] as num).toInt(),
  arguments: json['arguments'] as String,
);

Map<String, dynamic> _$ResponseMcpCallArgumentsDoneEventToJson(
  ResponseMcpCallArgumentsDoneEvent instance,
) => <String, dynamic>{
  'event_id': ?instance.eventId,
  'response_id': ?instance.responseId,
  'item_id': instance.itemId,
  'output_index': instance.outputIndex,
  'arguments': instance.arguments,
};

ResponseMcpCallInProgressEvent _$ResponseMcpCallInProgressEventFromJson(
  Map<String, dynamic> json,
) => ResponseMcpCallInProgressEvent(
  eventId: json['event_id'] as String?,
  responseId: json['response_id'] as String?,
  itemId: json['item_id'] as String,
  outputIndex: (json['output_index'] as num).toInt(),
);

Map<String, dynamic> _$ResponseMcpCallInProgressEventToJson(
  ResponseMcpCallInProgressEvent instance,
) => <String, dynamic>{
  'event_id': ?instance.eventId,
  'response_id': ?instance.responseId,
  'item_id': instance.itemId,
  'output_index': instance.outputIndex,
};

ResponseMcpCallCompletedEvent _$ResponseMcpCallCompletedEventFromJson(
  Map<String, dynamic> json,
) => ResponseMcpCallCompletedEvent(
  eventId: json['event_id'] as String?,
  responseId: json['response_id'] as String?,
  itemId: json['item_id'] as String,
  outputIndex: (json['output_index'] as num).toInt(),
);

Map<String, dynamic> _$ResponseMcpCallCompletedEventToJson(
  ResponseMcpCallCompletedEvent instance,
) => <String, dynamic>{
  'event_id': ?instance.eventId,
  'response_id': ?instance.responseId,
  'item_id': instance.itemId,
  'output_index': instance.outputIndex,
};

ResponseMcpCallFailedEvent _$ResponseMcpCallFailedEventFromJson(
  Map<String, dynamic> json,
) => ResponseMcpCallFailedEvent(
  eventId: json['event_id'] as String?,
  responseId: json['response_id'] as String?,
  itemId: json['item_id'] as String,
  outputIndex: (json['output_index'] as num).toInt(),
);

Map<String, dynamic> _$ResponseMcpCallFailedEventToJson(
  ResponseMcpCallFailedEvent instance,
) => <String, dynamic>{
  'event_id': ?instance.eventId,
  'response_id': ?instance.responseId,
  'item_id': instance.itemId,
  'output_index': instance.outputIndex,
};

McpListToolsInProgressEvent _$McpListToolsInProgressEventFromJson(
  Map<String, dynamic> json,
) => McpListToolsInProgressEvent(
  eventId: json['event_id'] as String?,
  itemId: json['item_id'] as String,
);

Map<String, dynamic> _$McpListToolsInProgressEventToJson(
  McpListToolsInProgressEvent instance,
) => <String, dynamic>{
  'event_id': ?instance.eventId,
  'item_id': instance.itemId,
};

McpListToolsCompletedEvent _$McpListToolsCompletedEventFromJson(
  Map<String, dynamic> json,
) => McpListToolsCompletedEvent(
  eventId: json['event_id'] as String?,
  itemId: json['item_id'] as String,
);

Map<String, dynamic> _$McpListToolsCompletedEventToJson(
  McpListToolsCompletedEvent instance,
) => <String, dynamic>{
  'event_id': ?instance.eventId,
  'item_id': instance.itemId,
};

McpListToolsFailedEvent _$McpListToolsFailedEventFromJson(
  Map<String, dynamic> json,
) => McpListToolsFailedEvent(
  eventId: json['event_id'] as String?,
  itemId: json['item_id'] as String,
);

Map<String, dynamic> _$McpListToolsFailedEventToJson(
  McpListToolsFailedEvent instance,
) => <String, dynamic>{
  'event_id': ?instance.eventId,
  'item_id': instance.itemId,
};

RateLimitsUpdatedEvent _$RateLimitsUpdatedEventFromJson(
  Map<String, dynamic> json,
) => RateLimitsUpdatedEvent(
  eventId: json['event_id'] as String?,
  rateLimits: (json['rate_limits'] as List<dynamic>)
      .map((e) => RateLimit.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$RateLimitsUpdatedEventToJson(
  RateLimitsUpdatedEvent instance,
) => <String, dynamic>{
  'event_id': ?instance.eventId,
  'rate_limits': instance.rateLimits.map((e) => e.toJson()).toList(),
};

RealtimeApiError _$RealtimeApiErrorFromJson(Map<String, dynamic> json) =>
    RealtimeApiError(
      type: json['type'] as String,
      code: json['code'] as String?,
      message: json['message'] as String,
      param: json['param'] as String?,
      eventId: json['event_id'] as String?,
    );

Map<String, dynamic> _$RealtimeApiErrorToJson(RealtimeApiError instance) =>
    <String, dynamic>{
      'type': instance.type,
      'code': ?instance.code,
      'message': instance.message,
      'param': ?instance.param,
      'event_id': ?instance.eventId,
    };

AcceptCallRequest _$AcceptCallRequestFromJson(Map<String, dynamic> json) =>
    AcceptCallRequest(
      type: json['type'] as String? ?? 'realtime',
      audio: json['audio'] == null
          ? null
          : RealtimeAudioConfig.fromJson(json['audio'] as Map<String, dynamic>),
      include: (json['include'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      instructions: json['instructions'] as String?,
      maxOutputTokens: json['max_output_tokens'] == null
          ? null
          : MaxOutputTokens.fromJson(json['max_output_tokens']),
      model: json['model'] as String?,
      outputModalities: (json['output_modalities'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      prompt: json['prompt'] == null
          ? null
          : RealtimePromptReference.fromJson(
              json['prompt'] as Map<String, dynamic>,
            ),
      toolChoice: json['tool_choice'] == null
          ? null
          : ToolChoice.fromJson(json['tool_choice']),
      tools: (json['tools'] as List<dynamic>?)
          ?.map((e) => RealtimeTool.fromJson(e as Map<String, dynamic>))
          .toList(),
      tracing: json['tracing'],
      truncation: json['truncation'],
    );

Map<String, dynamic> _$AcceptCallRequestToJson(AcceptCallRequest instance) =>
    <String, dynamic>{
      'type': instance.type,
      'audio': ?instance.audio?.toJson(),
      'include': ?instance.include,
      'instructions': ?instance.instructions,
      'max_output_tokens': ?instance.maxOutputTokens?.toJson(),
      'model': ?instance.model,
      'output_modalities': ?instance.outputModalities,
      'prompt': ?instance.prompt?.toJson(),
      'tool_choice': ?instance.toolChoice?.toJson(),
      'tools': ?instance.tools?.map((e) => e.toJson()).toList(),
      'tracing': ?instance.tracing,
      'truncation': ?instance.truncation,
    };

RejectCallRequest _$RejectCallRequestFromJson(Map<String, dynamic> json) =>
    RejectCallRequest(statusCode: (json['status_code'] as num?)?.toInt());

Map<String, dynamic> _$RejectCallRequestToJson(RejectCallRequest instance) =>
    <String, dynamic>{'status_code': ?instance.statusCode};

ReferCallRequest _$ReferCallRequestFromJson(Map<String, dynamic> json) =>
    ReferCallRequest(targetUri: json['target_uri'] as String);

Map<String, dynamic> _$ReferCallRequestToJson(ReferCallRequest instance) =>
    <String, dynamic>{'target_uri': instance.targetUri};
