part of 'realtime_models.dart';

/// Represents a streamed or completed response from the server.
@JsonSerializable(explicitToJson: true, includeIfNull: false)
class RealtimeResponse {
  const RealtimeResponse({
    this.object,
    this.id,
    this.status,
    @JsonKey(name: 'status_details') this.statusDetails,
    this.output = const [],
    @JsonKey(name: 'conversation_id') this.conversationId,
    @JsonKey(name: 'output_modalities') this.outputModalities,
    @JsonKey(name: 'max_output_tokens') this.maxOutputTokens,
    this.audio,
    this.usage,
    this.metadata,
  });

  factory RealtimeResponse.fromJson(JsonMap json) =>
      _$RealtimeResponseFromJson(json);

  final String? object;
  final String? id;
  final String? status;

  @JsonKey(name: 'status_details')
  final JsonMap? statusDetails;

  final List<RealtimeItem> output;

  @JsonKey(name: 'conversation_id')
  final String? conversationId;

  @JsonKey(name: 'output_modalities')
  final List<String>? outputModalities;

  @JsonKey(name: 'max_output_tokens')
  final MaxOutputTokens? maxOutputTokens;

  /// Response audio settings (server echoes effective configuration).
  final RealtimeAudioConfig? audio;

  final RealtimeUsage? usage;

  final JsonMap? metadata;

  JsonMap toJson() => _$RealtimeResponseToJson(this);
}

/// Usage statistics associated with a response or transcription.
@JsonSerializable(explicitToJson: true, includeIfNull: false)
class RealtimeUsage {
  const RealtimeUsage({
    @JsonKey(name: 'total_tokens') this.totalTokens,
    @JsonKey(name: 'input_tokens') this.inputTokens,
    @JsonKey(name: 'output_tokens') this.outputTokens,
    @JsonKey(name: 'input_token_details') this.inputTokenDetails,
    @JsonKey(name: 'output_token_details') this.outputTokenDetails,
    this.type,
  });

  factory RealtimeUsage.fromJson(JsonMap json) => _$RealtimeUsageFromJson(json);

  final String? type;

  @JsonKey(name: 'total_tokens')
  final int? totalTokens;

  @JsonKey(name: 'input_tokens')
  final int? inputTokens;

  @JsonKey(name: 'output_tokens')
  final int? outputTokens;

  @JsonKey(name: 'input_token_details')
  final UsageTokenDetails? inputTokenDetails;

  @JsonKey(name: 'output_token_details')
  final UsageTokenDetails? outputTokenDetails;

  JsonMap toJson() => _$RealtimeUsageToJson(this);
}

/// Token details for input/output usage.
@JsonSerializable(explicitToJson: true, includeIfNull: false)
class UsageTokenDetails {
  const UsageTokenDetails({
    @JsonKey(name: 'text_tokens') this.textTokens,
    @JsonKey(name: 'audio_tokens') this.audioTokens,
    @JsonKey(name: 'image_tokens') this.imageTokens,
    @JsonKey(name: 'cached_tokens') this.cachedTokens,
    @JsonKey(name: 'cached_tokens_details') this.cachedTokensDetails,
  });

  factory UsageTokenDetails.fromJson(JsonMap json) =>
      _$UsageTokenDetailsFromJson(json);

  @JsonKey(name: 'text_tokens')
  final int? textTokens;

  @JsonKey(name: 'audio_tokens')
  final int? audioTokens;

  @JsonKey(name: 'image_tokens')
  final int? imageTokens;

  @JsonKey(name: 'cached_tokens')
  final int? cachedTokens;

  @JsonKey(name: 'cached_tokens_details')
  final CachedTokenDetails? cachedTokensDetails;

  JsonMap toJson() => _$UsageTokenDetailsToJson(this);
}

/// Cached token breakdown included in usage.
@JsonSerializable(explicitToJson: true, includeIfNull: false)
class CachedTokenDetails {
  const CachedTokenDetails({
    @JsonKey(name: 'text_tokens') this.textTokens,
    @JsonKey(name: 'audio_tokens') this.audioTokens,
    @JsonKey(name: 'image_tokens') this.imageTokens,
  });

  factory CachedTokenDetails.fromJson(JsonMap json) =>
      _$CachedTokenDetailsFromJson(json);

  @JsonKey(name: 'text_tokens')
  final int? textTokens;

  @JsonKey(name: 'audio_tokens')
  final int? audioTokens;

  @JsonKey(name: 'image_tokens')
  final int? imageTokens;

  JsonMap toJson() => _$CachedTokenDetailsToJson(this);
}

/// Rate limit summary emitted by the server.
@JsonSerializable(includeIfNull: false)
class RateLimit {
  const RateLimit({
    required this.name,
    required this.limit,
    required this.remaining,
    @JsonKey(name: 'reset_seconds') required this.resetSeconds,
  });

  factory RateLimit.fromJson(JsonMap json) => _$RateLimitFromJson(json);

  final String name;
  final int limit;
  final int remaining;

  @JsonKey(name: 'reset_seconds')
  final int resetSeconds;

  JsonMap toJson() => _$RateLimitToJson(this);
}
