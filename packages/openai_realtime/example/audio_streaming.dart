import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:openai_realtime/openai_realtime.dart';

/// Minimal example that:
/// 1. Creates a WebRTC session with OpenAI Realtime.
/// 2. Sends a user text message.
/// 3. Listens for server events and logs model output.
///
/// Set the OPENAI_API_KEY environment variable before running.
Future<void> main() async {
  final apiKey = const String.fromEnvironment('OPENAI_API_KEY');
  if (apiKey.isEmpty) {
    throw StateError('Provide OPENAI_API_KEY via --define');
  }

  final client = OpenAIRealtimeClient(accessToken: apiKey, debug: true);

  // Subscribe to server events.
  final sub = client.serverEvents.listen((event) {
    switch (event) {
      case ResponseOutputTextDeltaEvent delta:
        print('Model: ${delta.delta}');
      case ResponseOutputAudioTranscriptDeltaEvent delta:
        print('Model (audio transcript): ${delta.delta}');
      default:
        print('Event: ${event.type}');
    }
  });

  await client.connect(
    model: 'gpt-realtime',
    session: const RealtimeSessionConfig(type: 'realtime'),
  );

  // Simple text turn.
  await client.sendText('Hi there! What can you do?');

  // If you want to stream audio manually, encode PCM/Opus bytes to base64 and
  // send with sendAudioChunk:
  final fakeAudioBytes = Uint8List.fromList(utf8.encode('placeholder'));
  await client.sendAudioChunk(fakeAudioBytes);

  // Clean up after a short delay.
  await Future<void>.delayed(const Duration(seconds: 5));
  await client.disconnect();
  await sub.cancel();
}
