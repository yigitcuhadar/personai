import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';

/// Enable verbose logging for this package and downstream users.
///
/// By default `logging` has no listeners and is set to `FINE`.
/// Call this early in your app to see detailed HTTP traces and client events.
void enableOpenAIRealtimeLogging() {
  // Set root logger level to the finest level for all loggers
  hierarchicalLoggingEnabled = true;
  Logger.root.level = Level.ALL;

  // Set specific package loggers to FINE level
  Logger('OpenAIRealtimeClient').level = Level.FINE;
  Logger('RealtimeCallsApi').level = Level.FINE;

  // Remove any existing listeners to prevent duplicate logs
  Logger.root.clearListeners();

  // Listen to all log records with default printer
  Logger.root.onRecord.listen(_defaultPrinter);
}

void _defaultPrinter(LogRecord record) {
  // ignore: avoid_print
  debugPrint(
    '${record.time.toIso8601String()} '
    '${record.level.name} ${record.loggerName}: ${record.message}', wrapWidth: 1024
  );
  if (record.error != null) {
    // ignore: avoid_print
    debugPrint('Error: ${record.error}', wrapWidth: 1024);
  }
  if (record.stackTrace != null) {
    // ignore: avoid_print
    debugPrint('Stack trace: ${record.stackTrace}', wrapWidth: 1024);
  }
}
