import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:openai_realtime/openai_realtime.dart';

void main() {
  test('decodes session.created event', () {
    final json =
        jsonDecode(r'''
{
  "type": "session.created",
  "event_id": "event_1",
  "session": {
    "type": "realtime",
    "object": "realtime.session",
    "id": "sess_123",
    "model": "gpt-realtime",
    "output_modalities": ["audio"],
    "instructions": "Hello world",
    "tools": [],
    "tool_choice": "auto",
    "max_output_tokens": "inf",
    "tracing": null,
    "prompt": null,
    "expires_at": 1756324625,
    "audio": {
      "input": {
        "format": {
          "type": "audio/pcm",
          "rate": 24000
        },
        "turn_detection": {
          "type": "server_vad",
          "threshold": 0.5,
          "prefix_padding_ms": 300,
          "silence_duration_ms": 200,
          "idle_timeout_ms": null,
          "create_response": true,
          "interrupt_response": true
        }
      },
      "output": {
        "format": {
          "type": "audio/pcm",
          "rate": 24000
        },
        "voice": "marin",
        "speed": 1
      }
    },
    "include": null
  }
}
''')
            as Map<String, dynamic>;

    final event = RealtimeServerEvent.fromJson(json);
    expect(event, isA<SessionCreatedEvent>());
    final created = event as SessionCreatedEvent;
    expect(created.session.model, equals('gpt-realtime'));
    expect(created.session.outputModalities, contains('audio'));
    expect(created.session.audio?.input?.format?.rate, equals(24000));
  });

  test('encodes response.create client event', () {
    final event = ResponseCreateEvent(
      response: ResponseParameters(
        instructions: 'Short answer',
        outputModalities: const ['text'],
        input: [
          ResponseItem(
            item: RealtimeItem(
              type: 'message',
              role: 'user',
              content: const [InputTextContent(text: 'ping')],
            ),
          ),
        ],
      ),
    );

    final encoded = event.toJson();
    expect(encoded['type'], equals('response.create'));
    expect(encoded['response'], isA<Map>());
    final response = encoded['response'] as Map;
    expect(response['instructions'], 'Short answer');
    expect(response['output_modalities'], contains('text'));
  });
}
