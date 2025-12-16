import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/home_cubit.dart';
import '../models/log_entry.dart';

class LogPane extends StatelessWidget {
  const LogPane({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      buildWhen: (p, c) => p.logs != c.logs || p.logsReversed != c.logsReversed,
      builder: (context, state) {
        final logs = state.logsReversed ? state.logs.reversed.toList() : state.logs;
        return Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _LogPaneHeader(
                  isReversed: state.logsReversed,
                  hasLogs: logs.isNotEmpty,
                  onToggleOrder: context.read<HomeCubit>().toggleLogsOrder,
                  onClear: context.read<HomeCubit>().clearLogs,
                ),
                const SizedBox(height: 8),
                if (logs.isEmpty)
                  const Center(child: Text('Henüz etkinlik yok.'))
                else
                  ListView.separated(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: logs.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final entry = logs[index];
                      return _LogEntryTile(
                        entry: entry,
                        isReversed: state.logsReversed,
                      );
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

class _LogPaneHeader extends StatelessWidget {
  const _LogPaneHeader({
    required this.isReversed,
    required this.hasLogs,
    required this.onToggleOrder,
    required this.onClear,
  });

  final bool isReversed;
  final bool hasLogs;
  final VoidCallback onToggleOrder;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: Text(
            'Loglar',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
        IconButton(
          tooltip: 'Sırayı ters çevir',
          icon: Icon(isReversed ? Icons.arrow_downward : Icons.arrow_upward),
          onPressed: onToggleOrder,
        ),
        IconButton(
          tooltip: 'Temizle',
          icon: const Icon(Icons.delete_outline),
          onPressed: hasLogs ? onClear : null,
        ),
      ],
    );
  }
}

class _LogEntryTile extends StatelessWidget {
  const _LogEntryTile({
    required this.entry,
    required this.isReversed,
  });

  final LogEntry entry;
  final bool isReversed;

  @override
  Widget build(BuildContext context) {
    final isServer = entry.direction == LogDirection.server;
    final alignment = isServer ? Alignment.centerLeft : Alignment.centerRight;
    final color = isServer ? Colors.blue.shade50 : Colors.green.shade50;
    final borderColor = Colors.grey.shade300;

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
          child: ExpansionTile(
            tilePadding: const EdgeInsets.symmetric(
              horizontal: 4,
            ),
            childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            title: _LogEntryHeader(entry: entry),
            trailing: Icon(Icons.expand_more, color: Colors.grey.shade700),
            children: _buildDetails(),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildDetails() {
    final details = isReversed ? entry.details.reversed.toList() : entry.details;
    final items = <Widget>[];
    for (var i = 0; i < details.length; i++) {
      final detail = details[i];
      if (entry.count > 1) {
        items.add(
          Text(
            'Event ${i + 1} • ${formatElapsed(detail.elapsedSinceSession)}',
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 10),
          ),
        );
      }
      items.add(
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: SelectableText(
            prettyPrintJson(detail.payload),
            style: const TextStyle(fontFamily: 'monospace', fontSize: 10),
          ),
        ),
      );
      if (i != details.length - 1) {
        items.add(const SizedBox(height: 12));
      }
    }
    return items;
  }
}

class _LogEntryHeader extends StatelessWidget {
  const _LogEntryHeader({required this.entry});

  final LogEntry entry;

  @override
  Widget build(BuildContext context) {
    final label = entry.count > 1 ? '${entry.type} (${entry.count})' : entry.type;
    final elapsed = formatElapsed(entry.latest.elapsedSinceSession);
    String directionLabel;
    Color directionColor;
    switch (entry.direction) {
      case LogDirection.server:
        directionLabel = 'Server';
        directionColor = Colors.blue;
        break;
      case LogDirection.client:
        directionLabel = 'Client';
        directionColor = Colors.green;
        break;
    }

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: directionColor.withAlpha(30),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            directionLabel,
            style: TextStyle(
              color: directionColor,
              fontWeight: FontWeight.w600,
              fontSize: 10,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 9,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          elapsed,
          style: TextStyle(
            color: Colors.grey.shade700,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
