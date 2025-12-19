part of 'realtime_models.dart';

/// Base class for conversation content parts.
abstract class RealtimeContent {
  String get type;

  JsonMap toJson();

  static RealtimeContent fromJson(JsonMap json) {
    final type = json['type'] as String?;
    if (type == null) {
      throw ArgumentError('Content part missing required "type" field.');
    }
    switch (type) {
      case 'input_text':
        return InputTextContent.fromJson(json);
      case 'output_text':
      case 'text':
        return OutputTextContent.fromJson(json);
      case 'output_audio':
        return OutputAudioContent.fromJson(json);
      case 'audio':
        return AudioContent.fromJson(json);
      default:
        return UnknownContent(type: type, raw: json);
    }
  }

  static List<RealtimeContent> listFromJson(dynamic json) {
    if (json == null) return const [];
    if (json is List) {
      return json
          .map(
            (entry) => RealtimeContent.fromJson(
              (entry as Map).cast<String, dynamic>(),
            ),
          )
          .toList();
    }
    throw ArgumentError('Expected list for content array, got $json');
  }

  void operator [](String other) {}
}

/// Represents user-supplied text.
@JsonSerializable(includeIfNull: false)
class InputTextContent implements RealtimeContent {
  const InputTextContent({
    @JsonKey(name: 'type') this.type = 'input_text',
    required this.text,
  });

  factory InputTextContent.fromJson(JsonMap json) =>
      _$InputTextContentFromJson(json);

  @override
  @JsonKey(name: 'type')
  final String type;

  final String text;

  @override
  JsonMap toJson() => _$InputTextContentToJson(this);
}

/// Represents model-generated text output.
@JsonSerializable(includeIfNull: false)
class OutputTextContent implements RealtimeContent {
  const OutputTextContent({
    @JsonKey(name: 'type') this.type = 'output_text',
    required this.text,
  });

  factory OutputTextContent.fromJson(JsonMap json) =>
      _$OutputTextContentFromJson(json);

  @override
  @JsonKey(name: 'type')
  final String type;

  final String text;

  @override
  JsonMap toJson() => _$OutputTextContentToJson(this);
}

/// Represents audio produced by the assistant, usually containing transcript.
@JsonSerializable(includeIfNull: false)
class OutputAudioContent implements RealtimeContent {
  const OutputAudioContent({
    @JsonKey(name: 'type') this.type = 'output_audio',
    this.transcript,
  });

  factory OutputAudioContent.fromJson(JsonMap json) =>
      _$OutputAudioContentFromJson(json);

  @override
  @JsonKey(name: 'type')
  final String type;

  final String? transcript;

  @override
  JsonMap toJson() => _$OutputAudioContentToJson(this);
}

/// Represents raw audio content, commonly for retrieved user audio.
@JsonSerializable(includeIfNull: false)
class AudioContent implements RealtimeContent {
  const AudioContent({
    @JsonKey(name: 'type') this.type = 'audio',
    this.transcript,
    this.audio,
    this.format,
  });

  factory AudioContent.fromJson(JsonMap json) => _$AudioContentFromJson(json);

  @override
  @JsonKey(name: 'type')
  final String type;

  final String? transcript;
  final String? audio;
  final String? format;

  @override
  JsonMap toJson() => _$AudioContentToJson(this);
}

/// Fallback content holder for forward compatibility.
class UnknownContent implements RealtimeContent {
  const UnknownContent({required this.type, this.raw = const {}});

  @override
  final String type;

  /// Original JSON payload.
  final JsonMap raw;

  @override
  JsonMap toJson() => {...raw, 'type': type};
}
