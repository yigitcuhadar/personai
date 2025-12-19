import 'package:equatable/equatable.dart';

import 'log_entry.dart';

class MessageEntry extends Equatable {
  const MessageEntry({
    required this.id,
    required this.direction,
    required this.text,
    this.isStreaming = false,
  });

  final String id;
  final LogDirection direction;
  final String text;
  final bool isStreaming;

  MessageEntry copyWith({String? text, bool? isStreaming}) {
    return MessageEntry(
      id: id,
      direction: direction,
      text: text ?? this.text,
      isStreaming: isStreaming ?? this.isStreaming,
    );
  }

  @override
  List<Object?> get props => [id, direction, text, isStreaming];
}
