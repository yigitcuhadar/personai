import 'package:equatable/equatable.dart';

import 'log_entry.dart';

class MessageEntry extends Equatable {
  const MessageEntry({
    required this.id,
    required this.direction,
    required this.text,
  });

  final String id;
  final LogDirection direction;
  final String text;

  MessageEntry copyWith({String? text}) {
    return MessageEntry(
      id: id,
      direction: direction,
      text: text ?? this.text,
    );
  }

  @override
  List<Object?> get props => [id, direction, text];
}
