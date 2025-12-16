part of 'realtime_models.dart';

/// Body for accepting an incoming SIP call.
@JsonSerializable(explicitToJson: true, includeIfNull: false)
class AcceptCallRequest {
  const AcceptCallRequest({
    this.type = 'realtime',
    this.audio,
    this.include,
    this.instructions,
    @JsonKey(name: 'max_output_tokens') this.maxOutputTokens,
    this.model,
    @JsonKey(name: 'output_modalities') this.outputModalities,
    this.prompt,
    @JsonKey(name: 'tool_choice') this.toolChoice,
    this.tools,
    this.tracing,
    this.truncation,
  });

  factory AcceptCallRequest.fromJson(JsonMap json) =>
      _$AcceptCallRequestFromJson(json);

  /// Session type. The API requires `realtime`.
  final String type;

  /// Input/output audio configuration.
  final RealtimeAudioConfig? audio;

  /// Additional fields to include in server outputs.
  final List<String>? include;

  /// System instructions for the call.
  final String? instructions;

  /// Maximum output tokens as integer or `"inf"`.
  @JsonKey(name: 'max_output_tokens')
  final MaxOutputTokens? maxOutputTokens;

  /// Realtime model to use.
  final String? model;

  /// Desired output modalities.
  @JsonKey(name: 'output_modalities')
  final List<String>? outputModalities;

  /// Prompt reference.
  final RealtimePromptReference? prompt;

  /// Tool choice strategy.
  @JsonKey(name: 'tool_choice')
  final ToolChoice? toolChoice;

  /// Tool definitions available to the model.
  final List<RealtimeTool>? tools;

  /// Tracing configuration.
  final dynamic tracing;

  /// Truncation configuration.
  final dynamic truncation;

  JsonMap toJson() => _$AcceptCallRequestToJson(this);
}

/// Request body for rejecting an incoming call.
@JsonSerializable(includeIfNull: false)
class RejectCallRequest {
  const RejectCallRequest({@JsonKey(name: 'status_code') this.statusCode});

  factory RejectCallRequest.fromJson(JsonMap json) =>
      _$RejectCallRequestFromJson(json);

  @JsonKey(name: 'status_code')
  final int? statusCode;

  JsonMap toJson() => _$RejectCallRequestToJson(this);
}

/// Request body for transferring an active call.
@JsonSerializable(includeIfNull: false)
class ReferCallRequest {
  const ReferCallRequest({
    @JsonKey(name: 'target_uri') required this.targetUri,
  });

  factory ReferCallRequest.fromJson(JsonMap json) =>
      _$ReferCallRequestFromJson(json);

  @JsonKey(name: 'target_uri')
  final String targetUri;

  JsonMap toJson() => _$ReferCallRequestToJson(this);
}

/// SDP answer returned by `POST /v1/realtime/calls`.
class CallAnswer {
  const CallAnswer({required this.sdp, this.callId});

  /// SDP answer string.
  final String sdp;

  /// Extracted call id from the Location header, when available.
  final String? callId;
}
