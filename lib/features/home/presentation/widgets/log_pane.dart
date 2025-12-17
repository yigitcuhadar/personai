import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/home_cubit.dart';
import '../models/log_entry.dart';

class LogPane extends StatelessWidget {
  const LogPane({
    super.key,
    this.scrollController,
    this.isScrollable = false,
    this.showCard = true,
    this.showHandle = false,
    this.onExpand,
  });

  final ScrollController? scrollController;
  final bool isScrollable;
  final bool showCard;
  final bool showHandle;
  final VoidCallback? onExpand;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      buildWhen: (p, c) => p.logs != c.logs || p.logsReversed != c.logsReversed,
      builder: (context, state) {
        final logs = state.logsReversed ? state.logs.reversed.toList() : state.logs;
        final onToggleOrder = context.read<HomeCubit>().toggleLogsOrder;
        final onClear = context.read<HomeCubit>().clearLogs;
        final header = _LogPaneHeader(
          isReversed: state.logsReversed,
          hasLogs: logs.isNotEmpty,
          onToggleOrder: onToggleOrder,
          onClear: onClear,
        );
        final content = isScrollable
            ? _ScrollableLogContent(
                scrollController: scrollController,
                logs: logs,
                isReversed: state.logsReversed,
                hasLogs: logs.isNotEmpty,
                onToggleOrder: onToggleOrder,
                onClear: onClear,
                showHandle: showHandle,
                onExpand: onExpand,
              )
            : _StaticLogContent(
                logs: logs,
                isReversed: state.logsReversed,
                header: header,
              );

        if (!showCard) {
          return content;
        }
        return Card(elevation: 2, child: content);
      },
    );
  }
}

class LogSheet extends StatefulWidget {
  const LogSheet({
    super.key,
    this.minChildSize = 0.12,
    this.initialChildSize = 0.2,
    this.maxChildSize = 0.65,
  });

  final double minChildSize;
  final double initialChildSize;
  final double maxChildSize;

  @override
  State<LogSheet> createState() => _LogSheetState();
}

class _LogSheetState extends State<LogSheet> {
  late final DraggableScrollableController _controller;

  @override
  void initState() {
    super.initState();
    _controller = DraggableScrollableController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _expandSheet() {
    if (!_controller.isAttached) return;
    final target = widget.maxChildSize;
    if (_controller.size >= target - 0.01) return;
    _controller.animateTo(
      target,
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      controller: _controller,
      minChildSize: widget.minChildSize,
      initialChildSize: widget.initialChildSize,
      maxChildSize: widget.maxChildSize,
      builder: (context, scrollController) {
        return Material(
          elevation: 8,
          color: Colors.transparent,
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
            ),
            child: LogPane(
              scrollController: scrollController,
              isScrollable: true,
              showCard: false,
              showHandle: true,
              onExpand: _expandSheet,
            ),
          ),
        );
      },
    );
  }
}

class _SheetHandle extends StatelessWidget {
  const _SheetHandle();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 4,
      decoration: BoxDecoration(
        color: Colors.grey.shade400,
        borderRadius: BorderRadius.circular(999),
      ),
    );
  }
}

class _TapHandle extends StatelessWidget {
  const _TapHandle({this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: const SizedBox(
        height: 22,
        child: Center(child: _SheetHandle()),
      ),
    );
  }
}

class _LogPaneHeaderDelegate extends SliverPersistentHeaderDelegate {
  _LogPaneHeaderDelegate({
    required this.isReversed,
    required this.hasLogs,
    required this.onToggleOrder,
    required this.onClear,
    required this.showHandle,
    required this.onExpand,
  });

  final bool isReversed;
  final bool hasLogs;
  final VoidCallback onToggleOrder;
  final VoidCallback onClear;
  final bool showHandle;
  final VoidCallback? onExpand;

  static const double _headerRowHeight = 40;
  static const double _handleHeight = 22;
  static const double _spacing = 6;

  @override
  double get minExtent => (showHandle ? _handleHeight + _spacing : 0) + _headerRowHeight;

  @override
  double get maxExtent => minExtent;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Material(
      color: Colors.white,
      child: Column(
        children: [
          if (showHandle) ...[
            const SizedBox(height: 4),
            _TapHandle(onTap: onExpand),
            const SizedBox(height: 2),
          ],
          SizedBox(
            height: _headerRowHeight,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: _LogPaneHeader(
                isReversed: isReversed,
                hasLogs: hasLogs,
                onToggleOrder: onToggleOrder,
                onClear: onClear,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _LogPaneHeaderDelegate oldDelegate) {
    return isReversed != oldDelegate.isReversed ||
        hasLogs != oldDelegate.hasLogs ||
        showHandle != oldDelegate.showHandle ||
        onToggleOrder != oldDelegate.onToggleOrder ||
        onClear != oldDelegate.onClear ||
        onExpand != oldDelegate.onExpand;
  }
}

class _ScrollableLogContent extends StatelessWidget {
  const _ScrollableLogContent({
    required this.scrollController,
    required this.logs,
    required this.isReversed,
    required this.hasLogs,
    required this.onToggleOrder,
    required this.onClear,
    required this.showHandle,
    required this.onExpand,
  });

  final ScrollController? scrollController;
  final List<LogEntry> logs;
  final bool isReversed;
  final bool hasLogs;
  final VoidCallback onToggleOrder;
  final VoidCallback onClear;
  final bool showHandle;
  final VoidCallback? onExpand;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: CustomScrollView(
        controller: scrollController,
        slivers: [
          SliverPersistentHeader(
            pinned: true,
            delegate: _LogPaneHeaderDelegate(
              isReversed: isReversed,
              hasLogs: hasLogs,
              onToggleOrder: onToggleOrder,
              onClear: onClear,
              showHandle: showHandle,
              onExpand: onExpand,
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 8)),
          if (logs.isEmpty)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: Center(child: Text('No events yet.')),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  if (index.isOdd) {
                    return const SizedBox(height: 8);
                  }
                  final entry = logs[index ~/ 2];
                  return _LogEntryTile(
                    entry: entry,
                    isReversed: isReversed,
                  );
                },
                childCount: logs.length * 2 - 1,
              ),
            ),
        ],
      ),
    );
  }
}

class _StaticLogContent extends StatelessWidget {
  const _StaticLogContent({
    required this.logs,
    required this.isReversed,
    required this.header,
  });

  final List<LogEntry> logs;
  final bool isReversed;
  final Widget header;

  @override
  Widget build(BuildContext context) {
    final list = logs.isEmpty
        ? const Center(child: Text('No events yet.'))
        : ListView.separated(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: logs.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final entry = logs[index];
              return _LogEntryTile(
                entry: entry,
                isReversed: isReversed,
              );
            },
          );

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          header,
          const SizedBox(height: 8),
          list,
        ],
      ),
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
