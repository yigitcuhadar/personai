part of 'realtime_models.dart';

/// A single item within a realtime conversation or response output.
class RealtimeItem {
  RealtimeItem({
    this.id,
    this.object,
    required this.type,
    this.status,
    this.role,
    List<RealtimeContent>? content,
    this.metadata,

    // Tool / call related (function_call, function_call_output, mcp_call, etc.)
    this.name,
    this.callId,
    this.arguments,
    this.output,
    this.error,

    JsonMap? extra,
  })  : content = content ?? const [],
        extra = extra ?? const {};

  /// Item id.
  final String? id;

  /// Object name (commonly `realtime.item`).
  final String? object;

  /// Item type (e.g. `message`, `function_call`, `function_call_output`, `mcp_call`).
  final String type;

  /// Item status (e.g. `in_progress`, `completed`).
  final String? status;

  /// Item role such as `user` or `assistant` (applies to `message` items).
  final String? role;

  /// Content parts within the item (applies to `message` items).
  final List<RealtimeContent> content;

  /// Optional metadata supplied by the server.
  final JsonMap? metadata;

  // --- Tool/call specific fields (documented in examples & event flows) ---

  /// Function/MCP tool name (e.g. `generate_horoscope`) for `function_call` items.
  final String? name;

  /// Call id that correlates tool calls and outputs (e.g. `call_...`).
  /// Used by `function_call` and `function_call_output`, and may appear in other tool flows.
  final String? callId;

  /// JSON string arguments for tool calls (e.g. `{"sign":"Aquarius"}`).
  final String? arguments;

  /// JSON string output for tool results (e.g. `{"horoscope":"..."}`).
  final String? output;

  /// Optional error payload if the server includes an item-level error object.
  final JsonMap? error;

  /// Additional unparsed fields preserved from the wire payload.
  final JsonMap extra;

  factory RealtimeItem.fromJson(JsonMap json) {
    final copy = Map<String, dynamic>.from(json);

    final type = copy.remove('type') as String?;
    if (type == null) {
      throw ArgumentError('Item missing required "type" field.');
    }

    final content = RealtimeContent.listFromJson(copy.remove('content'));

    // Tool/call fields (present depending on item.type)
    final callId = copy.remove('call_id') as String?;
    final name = copy.remove('name') as String?;
    final arguments = copy.remove('arguments') as String?;
    final output = copy.remove('output') as String?;
    final error = (copy.remove('error') as Map?)?.cast<String, dynamic>();

    return RealtimeItem(
      id: copy.remove('id') as String?,
      object: copy.remove('object') as String?,
      type: type,
      status: copy.remove('status') as String?,
      role: copy.remove('role') as String?,
      content: content,
      metadata: (copy.remove('metadata') as Map?)?.cast<String, dynamic>(),
      name: name,
      callId: callId,
      arguments: arguments,
      output: output,
      error: error,
      extra: Map.unmodifiable(copy),
    );
  }

  JsonMap toJson() {
    final json = <String, dynamic>{
      'type': type,
      if (id != null) 'id': id,
      if (object != null) 'object': object,
      if (status != null) 'status': status,
      if (role != null) 'role': role,
      if (metadata != null) 'metadata': metadata,

      // Tool/call fields
      if (name != null) 'name': name,
      if (callId != null) 'call_id': callId,
      if (arguments != null) 'arguments': arguments,
      if (output != null) 'output': output,
      if (error != null) 'error': error,

      if (content.isNotEmpty) 'content': content.map((c) => c.toJson()).toList(),
    };

    // Preserve any unknown/forward-compatible fields from the wire.
    json.addAll(extra);
    return json;
  }
}

/// Represents a reference to an item within the conversation history.
@JsonSerializable(includeIfNull: false)
class RealtimeItemReference {
  const RealtimeItemReference({
    @JsonKey(name: 'type') this.type = 'item_reference',
    required this.id,
  });

  factory RealtimeItemReference.fromJson(JsonMap json) =>
      _$RealtimeItemReferenceFromJson(json);

  @JsonKey(name: 'type')
  final String type;
  final String id;

  JsonMap toJson() => _$RealtimeItemReferenceToJson(this);
}

/// Input entries accepted by `response.create`.
abstract class RealtimeResponseInput {
  String get type;

  JsonMap toJson();

  static RealtimeResponseInput fromJson(JsonMap json) {
    final type = json['type'] as String?;
    if (type == null) {
      throw ArgumentError('Response input missing "type" field.');
    }
    if (type == 'item_reference') {
      return ResponseItemReference(
        reference: RealtimeItemReference.fromJson(json),
      );
    }
    // Otherwise: raw inline item (e.g. message / function_call_output / etc.)
    return ResponseItem(item: RealtimeItem.fromJson(json));
  }
}

/// Response input pointing to an existing item.
class ResponseItemReference implements RealtimeResponseInput {
  ResponseItemReference({required this.reference});

  final RealtimeItemReference reference;

  @override
  String get type => reference.type;

  @override
  JsonMap toJson() => reference.toJson();
}

/// Response input providing an inline item.
class ResponseItem implements RealtimeResponseInput {
  ResponseItem({required this.item});

  final RealtimeItem item;

  @override
  String get type => item.type;

  @override
  JsonMap toJson() => item.toJson();
}