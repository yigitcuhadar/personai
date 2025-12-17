part of 'realtime_models.dart';

/// Represents the session configuration that can be provided when creating or
/// updating a realtime session.
@JsonSerializable(explicitToJson: true, includeIfNull: false)
class RealtimeSessionConfig {
  const RealtimeSessionConfig({
    this.type,
    this.object,
    this.id,
    this.model,
    @JsonKey(name: 'modalities') this.modalities,
    @JsonKey(name: 'output_modalities') this.outputModalities,
    this.instructions,
    this.tools,
    @JsonKey(name: 'tool_choice') this.toolChoice,
    @JsonKey(name: 'max_output_tokens') this.maxOutputTokens,
    this.tracing,
    this.truncation,
    this.prompt,
    @JsonKey(name: 'expires_at') this.expiresAt,
    @Deprecated('Use top-level voice/input_audio_format/output_audio_format fields') @JsonKey(includeToJson: false)
    this.audio,
    this.voice,
    @JsonKey(name: 'input_audio_format') this.inputAudioFormat,
    @JsonKey(name: 'output_audio_format') this.outputAudioFormat,
    @JsonKey(name: 'input_audio_transcription') this.inputAudioTranscription,
    @JsonKey(name: 'turn_detection') this.turnDetection,
    this.include,
  });

  /// The session type. The docs describe `realtime` and `transcription`.
  final String? type;

  /// Object identifier returned by the server (e.g. `realtime.session`).
  final String? object;

  /// Server-assigned session id.
  final String? id;

  /// Realtime model name.
  final String? model;

  /// Desired input/output modalities (e.g. `["audio", "text"]`).
  @JsonKey(name: 'modalities')
  final List<String>? modalities;

  /// Permitted output modalities for the model (e.g. `["audio"]` or `["text"]`).
  @JsonKey(name: 'output_modalities')
  final List<String>? outputModalities;

  /// System instructions applied to the session.
  final String? instructions;

  /// Tools available to the model.
  final List<RealtimeTool>? tools;

  /// How the model should choose tools. May be a string mode or structured map.
  @JsonKey(name: 'tool_choice')
  final ToolChoice? toolChoice;

  /// Maximum output tokens as integer or `"inf"`.
  @JsonKey(name: 'max_output_tokens')
  final MaxOutputTokens? maxOutputTokens;

  /// Tracing configuration. Represented as a raw map to remain forward
  /// compatible with server-provided fields.
  final JsonMap? tracing;

  /// Truncation configuration. Represented as a raw map or string.
  final dynamic truncation;

  /// Optional prompt reference.
  final RealtimePromptReference? prompt;

  /// Expiration timestamp, seconds since epoch.
  @JsonKey(name: 'expires_at')
  final int? expiresAt;

  /// Input/output audio configuration.
  @Deprecated('Use voice/input_audio_format/output_audio_format instead')
  final RealtimeAudioConfig? audio;

  /// Voice to use for audio output (top-level Realtime v1 field).
  final String? voice;

  /// Input audio format (e.g. `pcm16`).
  @JsonKey(name: 'input_audio_format')
  final String? inputAudioFormat;

  /// Output audio format (e.g. `pcm16`).
  @JsonKey(name: 'output_audio_format')
  final String? outputAudioFormat;

  /// Transcription settings for input audio.
  @JsonKey(name: 'input_audio_transcription')
  final JsonMap? inputAudioTranscription;

  /// Voice activity detection / turn detection settings.
  @JsonKey(name: 'turn_detection')
  final RealtimeTurnDetection? turnDetection;

  /// Additional response fields to include from the server.
  final List<String>? include;

  factory RealtimeSessionConfig.fromJson(JsonMap json) =>
      _$RealtimeSessionConfigFromJson(json);

  JsonMap toJson() => _$RealtimeSessionConfigToJson(this);

  RealtimeSessionConfig copyWith({
    String? type,
    String? object,
    String? id,
    String? model,
    List<String>? modalities,
    List<String>? outputModalities,
    String? instructions,
    List<RealtimeTool>? tools,
    ToolChoice? toolChoice,
    MaxOutputTokens? maxOutputTokens,
    JsonMap? tracing,
    dynamic truncation,
    RealtimePromptReference? prompt,
    int? expiresAt,
    RealtimeAudioConfig? audio,
    String? voice,
    String? inputAudioFormat,
    String? outputAudioFormat,
    JsonMap? inputAudioTranscription,
    RealtimeTurnDetection? turnDetection,
    List<String>? include,
  }) {
    return RealtimeSessionConfig(
      type: type ?? this.type,
      object: object ?? this.object,
      id: id ?? this.id,
      model: model ?? this.model,
      modalities: modalities ?? this.modalities,
      outputModalities: outputModalities ?? this.outputModalities,
      instructions: instructions ?? this.instructions,
      tools: tools ?? this.tools,
      toolChoice: toolChoice ?? this.toolChoice,
      maxOutputTokens: maxOutputTokens ?? this.maxOutputTokens,
      tracing: tracing ?? this.tracing,
      truncation: truncation ?? this.truncation,
      prompt: prompt ?? this.prompt,
      expiresAt: expiresAt ?? this.expiresAt,
      audio: audio ?? this.audio,
      voice: voice ?? this.voice,
      inputAudioFormat: inputAudioFormat ?? this.inputAudioFormat,
      outputAudioFormat: outputAudioFormat ?? this.outputAudioFormat,
      inputAudioTranscription: inputAudioTranscription ?? this.inputAudioTranscription,
      turnDetection: turnDetection ?? this.turnDetection,
      include: include ?? this.include,
    );
  }
}

/// Union wrapper for `max_output_tokens`, which accepts integers or `"inf"`.
class MaxOutputTokens {
  const MaxOutputTokens._(this.value, this.isInfinite);

  /// Numeric value when finite.
  final int? value;

  /// Whether `"inf"` was specified.
  final bool isInfinite;

  factory MaxOutputTokens.fromJson(dynamic json) {
    if (json == null) return const MaxOutputTokens._(null, false);
    if (json is String && json.toLowerCase() == 'inf') {
      return const MaxOutputTokens._(null, true);
    }
    if (json is int) {
      return MaxOutputTokens._(json, false);
    }
    throw ArgumentError('Unsupported max_output_tokens: $json');
  }

  dynamic toJson() => isInfinite ? 'inf' : value;
}

/// Audio configuration for the session.
@JsonSerializable(explicitToJson: true, includeIfNull: false)
class RealtimeAudioConfig {
  const RealtimeAudioConfig({this.input, this.output});

  final RealtimeAudioInputConfig? input;
  final RealtimeAudioOutputConfig? output;

  factory RealtimeAudioConfig.fromJson(JsonMap json) =>
      _$RealtimeAudioConfigFromJson(json);

  JsonMap toJson() => _$RealtimeAudioConfigToJson(this);
}

/// Input audio settings for realtime sessions.
@JsonSerializable(explicitToJson: true, includeIfNull: false)
class RealtimeAudioInputConfig {
  const RealtimeAudioInputConfig({
    this.format,
    this.transcription,
    @JsonKey(name: 'noise_reduction') this.noiseReduction,
    @JsonKey(name: 'turn_detection') this.turnDetection,
  });

  final RealtimeAudioFormat? format;

  /// Transcription configuration. Treated as a raw map for forward
  /// compatibility.
  final JsonMap? transcription;

  /// Optional noise reduction configuration.
  @JsonKey(name: 'noise_reduction')
  final JsonMap? noiseReduction;

  /// Voice activity detection configuration.
  @JsonKey(name: 'turn_detection')
  final RealtimeTurnDetection? turnDetection;

  factory RealtimeAudioInputConfig.fromJson(JsonMap json) =>
      _$RealtimeAudioInputConfigFromJson(json);

  JsonMap toJson() => _$RealtimeAudioInputConfigToJson(this);
}

/// Output audio settings for realtime sessions.
@JsonSerializable(explicitToJson: true, includeIfNull: false)
class RealtimeAudioOutputConfig {
  const RealtimeAudioOutputConfig({this.format, this.voice, this.speed});

  final RealtimeAudioFormat? format;
  final String? voice;
  final double? speed;

  factory RealtimeAudioOutputConfig.fromJson(JsonMap json) =>
      _$RealtimeAudioOutputConfigFromJson(json);

  JsonMap toJson() => _$RealtimeAudioOutputConfigToJson(this);
}

/// Audio format descriptor.
@JsonSerializable(explicitToJson: true, includeIfNull: false)
class RealtimeAudioFormat {
  const RealtimeAudioFormat({this.type, this.rate});

  /// MIME-like format identifier (e.g. `audio/pcm`).
  final String? type;

  /// Sample rate in Hz.
  final int? rate;

  factory RealtimeAudioFormat.fromJson(JsonMap json) =>
      _$RealtimeAudioFormatFromJson(json);

  JsonMap toJson() => _$RealtimeAudioFormatToJson(this);
}

/// Server-side VAD settings.
@JsonSerializable(explicitToJson: true, includeIfNull: false)
class RealtimeTurnDetection {
  const RealtimeTurnDetection({
    this.type,
    this.threshold,
    @JsonKey(name: 'prefix_padding_ms') this.prefixPaddingMs,
    @JsonKey(name: 'silence_duration_ms') this.silenceDurationMs,
    @JsonKey(name: 'idle_timeout_ms') this.idleTimeoutMs,
    @JsonKey(name: 'create_response') this.createResponse,
    @JsonKey(name: 'interrupt_response') this.interruptResponse,
  });

  final String? type;
  final double? threshold;
  @JsonKey(name: 'prefix_padding_ms')
  final int? prefixPaddingMs;
  @JsonKey(name: 'silence_duration_ms')
  final int? silenceDurationMs;
  @JsonKey(name: 'idle_timeout_ms')
  final int? idleTimeoutMs;
  @JsonKey(name: 'create_response')
  final bool? createResponse;
  @JsonKey(name: 'interrupt_response')
  final bool? interruptResponse;

  factory RealtimeTurnDetection.fromJson(JsonMap json) =>
      _$RealtimeTurnDetectionFromJson(json);

  JsonMap toJson() => _$RealtimeTurnDetectionToJson(this);
}

/// Tool definition supplied to the model.
class RealtimeTool {
  const RealtimeTool({
    required this.type,
    this.name,
    this.description,
    this.parameters,
    this.extra = const {},
  });

  /// Tool type, e.g. `function` or MCP variants.
  final String type;
  final String? name;
  final String? description;
  final JsonMap? parameters;

  /// Unrecognized or vendor-specific properties preserved from the wire payload.
  @JsonKey(ignore: true)
  final JsonMap extra;

  factory RealtimeTool.fromJson(JsonMap json) {
    final copy = Map<String, dynamic>.from(json);
    final type = copy.remove('type') as String?;
    if (type == null) {
      throw ArgumentError('Tool is missing required field "type".');
    }
    return RealtimeTool(
      type: type,
      name: copy.remove('name') as String?,
      description: copy.remove('description') as String?,
      parameters: (copy.remove('parameters') as Map?)?.cast<String, dynamic>(),
      extra: Map.unmodifiable(copy),
    );
  }

  JsonMap toJson() {
    final json = <String, dynamic>{
      'type': type,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (parameters != null) 'parameters': parameters,
    };
    json.addAll(extra);
    return json;
  }
}

/// Prompt reference wrapper.
@JsonSerializable(explicitToJson: true, includeIfNull: false)
class RealtimePromptReference {
  const RealtimePromptReference({this.id, this.metadata});

  /// Prompt template id.
  final String? id;

  /// Variables or metadata passed alongside the prompt.
  final JsonMap? metadata;

  factory RealtimePromptReference.fromJson(JsonMap json) =>
      _$RealtimePromptReferenceFromJson(json);

  JsonMap toJson() => _$RealtimePromptReferenceToJson(this);
}

/// Tool choice can be a string mode or a structured object.
class ToolChoice {
  const ToolChoice._(this.mode, this.details);

  final String? mode;
  final JsonMap? details;

  factory ToolChoice.fromJson(dynamic json) {
    if (json == null) return const ToolChoice._(null, null);
    if (json is String) return ToolChoice._(json, null);
    if (json is Map<String, dynamic>) return ToolChoice._(null, json);
    throw ArgumentError('Unsupported tool_choice: $json');
  }

  dynamic toJson() => details ?? mode;
}
