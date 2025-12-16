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
    JsonMap? extra,
  }) : content = content ?? const [],
       extra = extra ?? const {};

  /// Item id.
  final String? id;

  /// Object name (commonly `realtime.item`).
  final String? object;

  /// Item type (e.g. `message`, `function_call`, `mcp_call`).
  final String type;

  /// Item status (e.g. `in_progress`, `completed`).
  final String? status;

  /// Item role such as `user` or `assistant`.
  final String? role;

  /// Content parts within the item.
  final List<RealtimeContent> content;

  /// Optional metadata supplied by the server.
  final JsonMap? metadata;

  /// Additional unparsed fields preserved from the wire payload.
  final JsonMap extra;

  factory RealtimeItem.fromJson(JsonMap json) {
    final copy = Map<String, dynamic>.from(json);
    final type = copy.remove('type') as String?;
    if (type == null) {
      throw ArgumentError('Item missing required "type" field.');
    }
    final content = RealtimeContent.listFromJson(copy.remove('content'));
    return RealtimeItem(
      id: copy.remove('id') as String?,
      object: copy.remove('object') as String?,
      type: type,
      status: copy.remove('status') as String?,
      role: copy.remove('role') as String?,
      content: content,
      metadata: (copy.remove('metadata') as Map?)?.cast<String, dynamic>(),
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
      if (content.isNotEmpty)
        'content': content.map((c) => c.toJson()).toList(),
    };
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
