# OpenAI Realtime Flutter Package

A comprehensive Flutter package for integrating OpenAI's Realtime API with WebRTC support. This package enables real-time voice conversations and text interactions with GPT-Realtime models.

## Features

- ✅ **WebRTC Support**: Direct peer-to-peer connection with OpenAI Realtime API
- ✅ **Real-time Audio**: Send and receive audio streams with 24kHz PCM format
- ✅ **Voice Activity Detection (VAD)**: Built-in speech detection
- ✅ **Audio Processing**: PCM encoding/decoding, normalization, fade effects
- ✅ **Session Management**: Full session configuration and control
- ✅ **Error Handling**: Comprehensive error handling and logging
- ✅ **Stream-based API**: Reactive streams for events and audio
- ✅ **Tool/Function Support**: Integration with OpenAI function calling
- ✅ **Token Usage Tracking**: Monitor API token consumption

## Installation

Add this to your `pubspec.yaml`:

```yaml
dependencies:
  openai_realtime: ^0.0.1
```

Then run:

```bash
flutter pub get
```

## Requirements

- Flutter >= 1.17.0
- Dart >= 3.10.4
- OpenAI API key with Realtime API access
- WebRTC enabled on your device

## Quick Start

### 1. Initialize the Client

```dart
import 'package:openai_realtime/openai_realtime.dart';

final client = OpenAIRealtimeClient(
  apiKey: 'your-openai-api-key',
);
```

### 2. Connect to the API

```dart
await client.connect(
  model: 'gpt-realtime-2025-08-28',
  instructions: 'You are a helpful assistant.',
  outputModalities: ['audio', 'text'],
);
```

### 3. Send Messages

#### Text Message
```dart
await client.sendMessage('Hello, how are you?');
```

#### Audio Input
```dart
// Send audio data (PCM 16-bit, 24kHz, mono)
Uint8List audioData = ...; // Your audio data
await client.sendAudio(audioData);
await client.commitAudio(); // Commit the audio buffer
```

### 4. Receive Messages

```dart
client.messageStream.listen((message) {
  print('${message.role}: ${message.content}');
});
```

### 5. Handle Audio Output

```dart
client.audioOutputStream.listen((audioChunk) {
  // Process audio output (24kHz PCM)
  Uint8List data = audioChunk.data;
  int durationMs = audioChunk.duration;
});
```

### 6. Monitor Connection State

```dart
client.stateStream.listen((state) {
  switch (state) {
    case RealtimeClientState.connected:
      print('Connected to OpenAI Realtime');
      break;
    case RealtimeClientState.listening:
      print('Server is listening for input');
      break;
    case RealtimeClientState.responseInProgress:
      print('Server is processing response');
      break;
    default:
      break;
  }
});
```

## Audio Format

The package uses **PCM 16-bit, 24kHz, Mono** audio format as per OpenAI Realtime API specification:

- **Sample Rate**: 24,000 Hz
- **Bit Depth**: 16-bit signed
- **Channels**: 1 (Mono)
- **Encoding**: PCM (Linear)

### Audio Processing Utilities

The package provides audio processing utilities:

```dart
final processor = AudioProcessor();

// Calculate audio volume (RMS)
double rms = processor.calculateRMS(audioData);

// Detect speech presence
bool hasSpeech = processor.isSpeechPresent(audioData);

// Normalize audio
Uint8List normalized = processor.normalize(audioData);

// Fade in/out effects
Uint8List fadeIn = processor.fadeIn(audioData, fadeDurationMs: 100);
Uint8List fadeOut = processor.fadeOut(audioData, fadeDurationMs: 100);
```

## Voice Activity Detection (VAD)

Built-in VAD for automatic speech detection:

```dart
final vad = VoiceActivityDetector(
  threshold: 500,           // RMS threshold
  minSpeechDurationMs: 200,
  silenceDurationMs: 1000,
);

vad.voiceStateStream.listen((isSpeaking) {
  print('Speech detected: $isSpeaking');
});

bool speaking = vad.processAudio(audioData, timestamp);
```

## Session Configuration

### Update Instructions and Tools

```dart
await client.updateSession(
  instructions: 'You are a helpful assistant for customer support.',
  tools: [
    Tool(
      type: 'function',
      name: 'get_weather',
      description: 'Get the current weather',
      parameters: ToolParameters(
        type: 'object',
        properties: {
          'location': {'type': 'string'},
        },
        required: ['location'],
      ),
    ),
  ],
  toolChoice: 'auto',
  outputModalities: ['audio'],
);
```

### Configure Audio Settings

The package automatically configures audio with:
- Server-side Voice Activity Detection (VAD)
- Noise reduction
- Transcription enabled
- 24kHz PCM format

## Error Handling

The package provides comprehensive error handling:

```dart
try {
  await client.connect();
} on Exception catch (e) {
  print('Connection error: $e');
}

// Listen to error events
client.stateStream
    .where((state) => state == RealtimeClientState.error)
    .listen((_) {
  print('An error occurred');
});
```

## Complete Example

See the [example/lib/main.dart](example/lib/main.dart) for a complete chat application example.

## API Reference

### OpenAIRealtimeClient

Main client class for interacting with OpenAI Realtime API.

#### Methods

- `connect()` - Establish connection
- `disconnect()` - Close connection
- `sendMessage(String text)` - Send text message
- `sendAudio(Uint8List data)` - Send audio data
- `commitAudio()` - Commit audio buffer
- `clearAudio()` - Clear audio buffer
- `cancelResponse()` - Cancel current response
- `updateSession()` - Update session configuration

#### Properties

- `isConnected` - Connection status
- `state` - Current client state
- `messageStream` - Incoming messages
- `audioOutputStream` - Audio output chunks
- `stateStream` - State change events

### Models

#### RealtimeSession
Session configuration for the Realtime API session.

#### ChatMessage
Represents a message in the conversation.

```dart
class ChatMessage {
  final ChatRole role;        // user or assistant
  final String content;
  final DateTime timestamp;
}
```

#### AudioChunk
Represents a chunk of audio output.

```dart
class AudioChunk {
  final Uint8List data;
  final int duration;         // in milliseconds
}
```

## Best Practices

1. **API Key Security**: Never hardcode your API key. Use environment variables or secure storage.
   
2. **Audio Format**: Always use 24kHz PCM 16-bit mono audio. Convert if necessary.

3. **Connection Lifecycle**:
   ```dart
   // Always connect before using
   await client.connect();
   
   // Always disconnect when done
   await client.disconnect();
   ```

4. **Error Handling**: Implement proper error handling for network issues.

5. **Memory Management**: Close streams and dispose resources properly.

6. **Audio Buffer Management**: 
   - Clear buffers between conversations
   - Don't send incomplete audio frames

## Platform Support

- ✅ iOS (WebRTC support required)
- ✅ Android (WebRTC support required)
- ⚠️ Web (Experimental - check flutter_webrtc compatibility)
- ⚠️ macOS (WebRTC support required)
- ⚠️ Windows (WebRTC support required)
- ⚠️ Linux (WebRTC support required)

## Dependencies

- `flutter_webrtc`: WebRTC implementation
- `web_socket_channel`: WebSocket support
- `http`: HTTP client
- `logger`: Logging utilities
- `json_serializable`: JSON serialization

## Troubleshooting

### Connection Fails
- Check API key validity
- Verify OpenAI account has Realtime API access
- Check network connectivity
- Ensure WebRTC is properly configured on your device

### Audio Issues
- Verify audio format (24kHz PCM 16-bit mono)
- Check microphone permissions
- Monitor VAD threshold settings
- Check buffer sizes

### State Not Updating
- Ensure streams are being listened to
- Check error logs for issues
- Verify connection state before operations

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This package is licensed under the MIT License - see the LICENSE file for details.

## Support

For issues, questions, or feature requests, please open an issue on GitHub.

## References

- [OpenAI Realtime API Documentation](https://platform.openai.com/docs/guides/realtime)
- [OpenAI API Reference](https://platform.openai.com/docs/api-reference)
- [WebRTC Documentation](https://webrtc.org/)
- [Flutter WebRTC Plugin](https://pub.dev/packages/flutter_webrtc)

## Disclaimer

This is an unofficial package for OpenAI's Realtime API. Please refer to OpenAI's official documentation and terms of service for proper usage.
