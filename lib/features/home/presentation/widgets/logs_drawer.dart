import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/home_cubit.dart';
import '../models/log_entry.dart';

class LogsDrawer extends StatelessWidget {
  const LogsDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return Drawer(
      width: 380,
      elevation: 14,
      child: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFF7F9FB), Color(0xFFE9F2FF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                top: -60,
                right: -20,
                child: _blurCircle(color: const Color(0x33A5BEE5), size: 160),
              ),
              Positioned(
                bottom: -50,
                left: -10,
                child: _blurCircle(color: const Color(0x33C6ECD9), size: 140),
              ),
              Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.fromLTRB(16, 12, 16, 10),
                    child: _DrawerHeader(),
                  ),
                  Expanded(
                    child: BlocBuilder<HomeCubit, HomeState>(
                      buildWhen: (p, c) => p.logs != c.logs || p.logsReversed != c.logsReversed,
                      builder: (context, state) {
                        final logs = state.logsReversed ? state.logs.reversed.toList() : state.logs;
                        final hasLogs = logs.isNotEmpty;
                        final bottomPadding = bottomInset > 0 ? bottomInset + 20.0 : 24.0;
                        return SingleChildScrollView(
                          padding: EdgeInsets.fromLTRB(16, 0, 16, bottomPadding),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.9),
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(color: Colors.white.withAlpha(160)),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withAlpha(12),
                                  blurRadius: 16,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _LogsHeader(
                                    isReversed: state.logsReversed,
                                    hasLogs: hasLogs,
                                    onToggleOrder: context.read<HomeCubit>().toggleLogsOrder,
                                    onClear: context.read<HomeCubit>().clearLogs,
                                  ),
                                  const SizedBox(height: 12),
                                  if (!hasLogs)
                                    const Center(
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(vertical: 20),
                                        child: Text('No events yet.'),
                                      ),
                                    )
                                  else
                                    ...[
                                      for (var i = 0; i < logs.length; i++) ...[
                                        _LogEntryTile(
                                          entry: logs[i],
                                          isReversed: state.logsReversed,
                                        ),
                                        if (i != logs.length - 1) const SizedBox(height: 10),
                                      ],
                                    ],
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DrawerHeader extends StatelessWidget {
  const _DrawerHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withAlpha(180)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(12),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFE6F0FF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.receipt_long_outlined,
              color: Color(0xFF2563EB),
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Logs', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                SizedBox(height: 4),
                Text(
                  'Inspect realtime events.',
                  style: TextStyle(fontSize: 12, color: Colors.black54),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LogsHeader extends StatelessWidget {
  const _LogsHeader({
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
            'Logs',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
          ),
        ),
        IconButton(
          tooltip: 'Reverse order',
          icon: Icon(isReversed ? Icons.arrow_downward : Icons.arrow_upward),
          onPressed: onToggleOrder,
        ),
        IconButton(
          tooltip: 'Clear',
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
            tilePadding: const EdgeInsets.symmetric(horizontal: 4),
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

Widget _blurCircle({required Color color, required double size}) {
  return Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      color: color,
      shape: BoxShape.circle,
    ),
  );
}
