import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/home_cubit.dart';
import '../models/log_entry.dart';
import '../models/message_entry.dart';

class MessagePane extends StatelessWidget {
  const MessagePane({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      buildWhen: (p, c) => p.messages != c.messages,
      builder: (context, state) {
        final messages = state.messages;
        return Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Mesajlar',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                if (messages.isEmpty)
                  const Center(child: Text('Henüz mesaj yok.'))
                else
                  ListView.separated(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: messages.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      return _MessageBubble(entry: messages[index]);
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.entry});

  final MessageEntry entry;

  @override
  Widget build(BuildContext context) {
    final isServer = entry.direction == LogDirection.server;
    final alignment = isServer ? Alignment.centerLeft : Alignment.centerRight;
    final color = isServer ? Colors.blue.shade50 : Colors.green.shade50;
    final borderColor = Colors.grey.shade300;
    final label = isServer ? 'Server' : 'Sen';
    final labelColor = isServer ? Colors.blue : Colors.green;

    return Align(
      alignment: alignment,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: borderColor),
          ),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: isServer ? CrossAxisAlignment.start : CrossAxisAlignment.end,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: labelColor,
                  ),
                ),
                const SizedBox(height: 4),
                SelectableText(
                  entry.text,
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
