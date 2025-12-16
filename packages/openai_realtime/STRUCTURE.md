# Package Structure Overview

## File Organization

```
openai_realtime/
├── lib/
│   ├── openai_realtime.dart                 # Main export file
│   └── src/
│       ├── client/
│       │   └── realtime_client.dart        # Main client class
│       ├── connection/
│       │   └── webrtc_connection.dart      # WebRTC connection manager
│       ├── audio/
│       │   └── audio_processor.dart        # Audio handling & processing
│       └── models/
│           ├── realtime_models.dart        # All model definitions
│           └── realtime_models.g.dart      # JSON serialization (generated)
├── example/
│   ├── lib/
│   │   └── main.dart                       # Flutter UI example
│   ├── simple_chat.dart                    # Text chat example
│   ├── audio_streaming.dart                # Audio I/O example
│   └── function_calling.dart               # Function calling example
├── test/
│   └── openai_realtime_test.dart          # Unit tests
├── pubspec.yaml
├── README.md
├── CHANGELOG.md
└── analysis_options.yaml
```

## Module Descriptions

### Core Client (`lib/src/client/realtime_client.dart`)
- **OpenAIRealtimeClient**: Main interface for interacting with OpenAI Realtime API
- Manages connection lifecycle, message streams, and audio I/O
- Provides state management through streams
- Handles session configuration and updates

### Connection Manager (`lib/src/connection/webrtc_connection.dart`)
- **OpenAIRealtimeConnection**: Low-level WebRTC peer connection handling
- Manages SDP offer/answer exchange with OpenAI API
- Handles data channel communication
- Parses and emits server events
- Supports audio transmission over WebRTC

### Audio Processing (`lib/src/audio/audio_processor.dart`)
- **AudioProcessor**: Core audio manipulation utilities
  - PCM encoding/decoding
  - Audio normalization
  - Fade in/out effects
  - RMS (volume) calculation
  - Speech presence detection
- **InputAudioBuffer**: Input audio buffering with position tracking
- **OutputAudioBuffer**: Output audio buffering with playback support
- **VoiceActivityDetector**: Automatic speech detection with state notifications
- **AudioConstants**: Configuration constants (24kHz PCM format)

### Models (`lib/src/models/realtime_models.dart`)
Comprehensive data models for OpenAI Realtime API:

#### Session Models
- `RealtimeSession`: Complete session configuration
- `AudioConfig`, `AudioInput`, `AudioOutput`: Audio settings
- `AudioFormat`, `VoiceActivityDetection`: Detailed audio config
- `Tool`, `ToolParameters`: Function calling definitions

#### Event Models

**Client Events (sent to API):**
- `ClientEvent`: Base class
- `SessionUpdateEvent`
- `InputAudioBufferAppendEvent`, `InputAudioBufferCommitEvent`, etc.
- `ResponseCreateEvent`, `ResponseCancelEvent`
- `ConversationItemCreateEvent`

**Server Events (received from API):**
- `ServerEvent`: Base class
- `SessionCreatedEvent`, `SessionUpdatedEvent`
- `ResponseCreatedEvent`, `ResponseDoneEvent`
- `InputAudioBufferSpeechStartedEvent`, `InputAudioBufferSpeechStoppedEvent`
- `ConversationItemAddedEvent`, `ConversationItemDoneEvent`
- `ResponseOutputAudioDeltaEvent`, `ResponseOutputAudioDoneEvent`
- `OutputAudioBufferStartedEvent`, `OutputAudioBufferStoppedEvent`
- Plus many more specialized events

#### Conversation Models
- `ConversationItem`: Message/item in conversation
- `ItemContent`: Content part (text, audio, etc.)
- `RealtimeResponse`: Response from the model
- `TokenUsage`, `TokenUsageDetails`: Token tracking

### Main Export (`lib/openai_realtime.dart`)
Central point for exporting all public APIs:
- All model classes
- `OpenAIRealtimeClient`
- Audio processing utilities
- Connection management classes

## Key Features by Module

### Realtime Client
- ✅ Stream-based API for reactive programming
- ✅ Automatic state management
- ✅ Message and audio streams
- ✅ Session configuration updates
- ✅ Error handling and logging

### WebRTC Connection
- ✅ WebRTC peer connection with WebSocket fallback
- ✅ SDP offer/answer exchange
- ✅ Data channel for JSON event communication
- ✅ Audio track handling
- ✅ Event routing to client

### Audio Processing
- ✅ PCM 24kHz audio format handling
- ✅ Voice Activity Detection (VAD)
- ✅ Audio buffer management
- ✅ Audio effects (fade, normalization)
- ✅ Volume analysis

### Models
- ✅ Complete OpenAI Realtime API spec coverage
- ✅ JSON serialization for all models
- ✅ Type-safe event handling
- ✅ Builder pattern support

## Data Flow

```
┌─────────────┐
│   Flutter   │
│   App       │
└──────┬──────┘
       │
       │ User Input (text/audio)
       ▼
┌──────────────────────┐
│ OpenAIRealtimeClient │ ◄─── Main API
└──────┬───────────────┘
       │
       │ Events
       ▼
┌────────────────────────┐
│ OpenAIRealtimeConnection│ ◄─── WebRTC
└──────┬─────────────────┘
       │
       ▼
   WebRTC Peer
       │
       ▼
 OpenAI API Server
```

## Dependencies

- **flutter_webrtc**: WebRTC implementation
- **http**: REST API calls
- **web_socket_channel**: WebSocket support
- **logger**: Logging
- **json_serializable**: JSON serialization
- **crypto**: Cryptographic utilities

## Testing

Comprehensive unit tests in `test/openai_realtime_test.dart`:
- Audio processing calculations
- Buffer management
- Voice activity detection
- Model creation and serialization
- Session configuration

## Examples

1. **simple_chat.dart**: Basic text-based chat
2. **audio_streaming.dart**: Real-time audio I/O
3. **function_calling.dart**: Using AI tools/functions
4. **main.dart (Flutter)**: Complete UI example with chat interface

## Architecture Highlights

### Reactive Design
- Stream-based API using Dart Streams
- Event-driven architecture
- Non-blocking async/await patterns

### Separation of Concerns
- Client layer: High-level API
- Connection layer: Low-level WebRTC
- Audio layer: Pure audio utilities
- Models layer: Type-safe data

### Error Handling
- Comprehensive exception handling
- Error events with details
- State tracking for error recovery
- Logging at multiple levels

### Extensibility
- Base event classes for custom handling
- Modular audio processor components
- Pluggable logging system
- Configurable buffer sizes

## Protocol Support

- **WebRTC**: Primary connection protocol
- **SDP**: Session Description Protocol for offer/answer
- **Data Channel**: JSON event communication
- **RTP**: Audio streaming via WebRTC
- **PCM**: Audio codec (24kHz, 16-bit, mono)

## Version

Package Version: 0.0.1
OpenAI Realtime API Version: 2025-08-28
Flutter: >= 1.17.0
Dart: >= 3.10.4
