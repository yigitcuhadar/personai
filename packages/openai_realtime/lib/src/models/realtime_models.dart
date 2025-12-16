library openai_realtime_models;

import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:json_annotation/json_annotation.dart';

part 'realtime_models.g.dart';
part 'session.dart';
part 'content.dart';
part 'conversation.dart';
part 'responses.dart';
part 'events_client.dart';
part 'events_server.dart';
part 'calls.dart';

/// Convenient alias for JSON-like maps.
typedef JsonMap = Map<String, dynamic>;
