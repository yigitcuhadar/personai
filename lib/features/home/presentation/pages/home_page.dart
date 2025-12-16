import 'dart:convert';
import 'dart:typed_data';

import 'package:authentication_repository/authentication_repository.dart';
import 'package:flutter/material.dart';
import 'package:openai_realtime/openai_realtime.dart';

import '../../../../app/di/injector.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  static Page<void> page() => const MaterialPage<void>(child: HomePage());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(onPressed: () => getIt<AuthenticationRepository>().logOut(), child: Text('Logout')),
            ElevatedButton(onPressed: () => _initializeRealtime(), child: Text('Test')),
          ],
        ),
      ),
    );
  }

  Future<void> _initializeRealtime() async {
    final apiKey =
        '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';

    final client = OpenAIRealtimeClient(
      accessToken: apiKey,
      debug: true,
    );
    enableOpenAIRealtimeLogging();
    // Subscribe to server events.
    final sub = client.events.listen((event) {
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
      session: const RealtimeSessionConfig(
        type: 'realtime',
        model: 'gpt-realtime',
        outputModalities: ['audio'],
      ),
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
}
