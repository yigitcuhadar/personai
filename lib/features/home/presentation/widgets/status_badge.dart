import 'package:flutter/material.dart';

import '../cubit/home_cubit.dart';

class StatusBadge extends StatelessWidget {
  const StatusBadge({
    super.key,
    required this.label,
    required this.color,
    this.showDot = true,
  });

  final String label;
  final Color color;
  final bool showDot;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withAlpha(28),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withAlpha(80)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showDot) ...[
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}

class StatusInfo {
  const StatusInfo(this.label, this.color);
  factory StatusInfo.fromStatus(HomeStatus status) {
    switch (status) {
      case HomeStatus.connected:
        return StatusInfo('Connected', Colors.green);
      case HomeStatus.connecting:
        return StatusInfo('Connecting', Colors.orange);
      case HomeStatus.initial:
        return StatusInfo('Ready', Colors.blueGrey);
      case HomeStatus.disconnecting:
        return StatusInfo('Disconnecting', Colors.pinkAccent);
      case HomeStatus.saving:
        return StatusInfo('Saving', Colors.yellow);
    }
  }

  final String label;
  final Color color;
}
