import 'dart:convert';

import 'package:equatable/equatable.dart';

enum LogDirection { client, server }

class LogEventDetail extends Equatable {
  const LogEventDetail({
    required this.payload,
    required this.timestamp,
    required this.elapsedSinceSession,
    this.event,
  });

  final Map<String, dynamic> payload;
  final DateTime timestamp;
  final Duration? elapsedSinceSession;
  final Object? event;

  @override
  List<Object?> get props => [payload, timestamp, elapsedSinceSession, event];
}

class LogEntry extends Equatable {
  const LogEntry({
    required this.type,
    required this.direction,
    required this.details,
  });

  final String type;
  final LogDirection direction;
  final List<LogEventDetail> details;

  int get count => details.length;

  LogEventDetail get latest => details.last;

  LogEntry copyWith({List<LogEventDetail>? details}) {
    return LogEntry(
      type: type,
      direction: direction,
      details: details ?? this.details,
    );
  }

  @override
  List<Object?> get props => [type, direction, details, count];
}

String prettyPrintJson(Map<String, dynamic> value) {
  const encoder = JsonEncoder.withIndent('  ');
  return encoder.convert(value);
}

String formatElapsed(Duration? duration) {
  if (duration == null) return '—';
  final minutes = duration.inMinutes.toString().padLeft(2, '0');
  final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
  final milliseconds = duration.inMilliseconds.remainder(1000).toString().padLeft(3, '0');
  return '$minutes:$seconds:$milliseconds';
}
