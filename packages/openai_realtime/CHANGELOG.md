## 0.0.1 - Initial Release

### Features
- **WebRTC Support**: Direct peer-to-peer connection with OpenAI Realtime API
- **Real-time Audio**: Send and receive audio streams with 24kHz PCM format
- **Voice Activity Detection (VAD)**: Built-in speech detection with configurable thresholds
- **Audio Processing**: 
  - PCM encoding/decoding
  - Audio normalization
  - Fade in/out effects
  - RMS (volume) calculation
  - Speech presence detection
- **Session Management**: Full session configuration and control
- **Error Handling**: Comprehensive error handling and logging
- **Stream-based API**: Reactive streams for events and audio output
- **Tool/Function Support**: Integration with OpenAI function calling
- **Token Usage Tracking**: Monitor API token consumption
- **Chat Message Stream**: Receive both user and assistant messages
- **Audio Output Stream**: Stream audio chunks for playback

### Models
- `RealtimeSession`: Session configuration
- `AudioConfig`: Audio input/output configuration
- `ChatMessage`: Conversation messages
- `AudioChunk`: Audio output chunks
- `ServerEvent`: Base class for all server events
- Multiple specific server event types (error, session.created, response.done, etc.)
- `Tool` and `ToolParameters`: Function calling support

### Audio Processing Utilities
- `AudioProcessor`: Audio encoding/decoding, normalization, effects
- `InputAudioBuffer`: Manage input audio buffering
- `OutputAudioBuffer`: Manage output audio buffering
- `VoiceActivityDetector`: Automatic speech detection

### Client API
- `OpenAIRealtimeClient`: Main client class
- Stream-based event handling
- Automatic state management
- Connection lifecycle management

### Supported Platforms
- iOS (with WebRTC support)
- Android (with WebRTC support)
- Web (experimental)
- macOS, Windows, Linux (WebRTC support required)

### Known Limitations
- Requires Flutter and Dart 3.10.4+
- WebRTC must be properly configured on the target platform
- Some functionality may vary across platforms due to WebRTC implementation differences

