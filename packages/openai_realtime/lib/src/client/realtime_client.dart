import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:logging/logging.dart';

import '../api/realtime_calls_api.dart';
import '../logging.dart';
import '../models/realtime_models.dart';

/// High level WebRTC client for the OpenAI Realtime API.
///
/// This client orchestrates the WebRTC peer connection, maintains the Realtime
/// data channel used for JSON events, and exposes typed event streams for the
/// application to consume.
class OpenAIRealtimeClient {
  OpenAIRealtimeClient({
    required String accessToken,
    Uri? baseUrl,
    Map<String, dynamic>? rtcConfiguration,
    RealtimeCallsApi? callsApi,
    Logger? logger,
    bool debug = false,
  }) : _logger = logger ?? Logger('OpenAIRealtimeClient'),
       _rtcConfiguration =
           rtcConfiguration ??
           {
             'iceServers': [
               {'urls': 'stun:stun.l.google.com:19302'},
             ],
           },
       callsApi = callsApi ?? RealtimeCallsApi(accessToken: accessToken, baseUrl: baseUrl, logFullHttp: debug) {
    if (debug) {
      enableOpenAIRealtimeLogging();
    }
  }

  final Logger _logger;
  final Map<String, dynamic> _rtcConfiguration;
  final RealtimeCallsApi callsApi;

  final _serverEvents = StreamController<RealtimeServerEvent>.broadcast();
  final _clientEvents = StreamController<RealtimeClientEvent>.broadcast();
  final _remoteAudioTracks = StreamController<MediaStreamTrack>.broadcast();
  bool _responseInProgress = false;
  final List<Completer<void>> _responseIdleWaiters = <Completer<void>>[];

  RTCPeerConnection? _peerConnection;
  RTCDataChannel? _eventChannel;
  String? _callId;
  MediaStream? _localStream;
  MediaStreamTrack? _localAudioTrack;
  RTCRtpSender? _localAudioSender;

  /// Stream of parsed server events delivered over the data channel.
  Stream<RealtimeServerEvent> get serverEvents => _serverEvents.stream;

  /// Stream of client-originated events sent over the data channel.
  Stream<RealtimeClientEvent> get clientEvents => _clientEvents.stream;

  /// Stream of remote audio tracks. Attach to an audio renderer to play output
  /// audio produced by the model.
  Stream<MediaStreamTrack> get remoteAudioTracks => _remoteAudioTracks.stream;

  /// Current call id if available.
  String? get callId => _callId;

  /// Whether the client has an active peer connection.
  bool get isConnected =>
      _peerConnection != null && _peerConnection!.connectionState != RTCPeerConnectionState.RTCPeerConnectionStateClosed;

  /// Establish the WebRTC connection and Realtime data channel.
  Future<void> connect({required String model, RealtimeSessionConfig? session}) async {
    _logger.info('🔄 Initiating WebRTC connection...');
    await _disposePeer();
    await _createPeerConnection();
    await _prepareDataChannel();
    await _exchangeOffer(model, session);
    _logger.info('✅ WebRTC connection established successfully');
  }

  /// Sends a client event over the data channel.
  Future<void> sendEvent(RealtimeClientEvent event) async {
    if (_eventChannel == null || _eventChannel!.state != RTCDataChannelState.RTCDataChannelOpen) {
      throw StateError('Data channel is not open.');
    }
    final payload = jsonEncode(event.toJson());
    _logSendingEvent(event, payload);
    _clientEvents.add(event);
    await _eventChannel!.send(RTCDataChannelMessage(payload));
  }

  /// Convenience helper to append base64-encoded audio to the input buffer.
  Future<void> sendAudioChunk(Uint8List bytes, {String? eventId}) {
    _logger.fine('🎤 Sending audio chunk: ${bytes.length} bytes');
    final encoded = base64Encode(bytes);
    return sendEvent(InputAudioBufferAppendEvent(eventId: eventId, audio: encoded));
  }

  /// Create a user text message item and request a response.
  Future<void> sendText(String text, {String? eventId}) async {
    _logger.fine('💬 Sending user message: $text');
    if (_responseInProgress) {
      _logger.fine('⏹ Cancelling active response before new user input');
      await sendEvent(const ResponseCancelEvent());
      await sendEvent(const OutputAudioBufferClearEvent());
      await _waitForResponsesToFinish();
    }
    final create = ConversationItemCreateEvent(
      eventId: eventId,
      item: RealtimeItem(
        type: 'message',
        role: 'user',
        content: [InputTextContent(text: text)],
      ),
    );
    await sendEvent(create);
    await sendEvent(const ResponseCreateEvent());
  }

  /// Gracefully hang up the call and close the peer connection.
  Future<void> disconnect({bool hangup = true}) async {
    _logger.info('🔌 Disconnecting from realtime session...');
    await _cancelActiveResponseBeforeDisconnect();
    if (hangup && _callId != null) {
      try {
        _logger.fine('Hanging up call: $_callId');
        await callsApi.hangupCall(_callId!);
        _logger.info('✅ Call hung up successfully');
      } catch (err) {
        _logger.warning('❌ Hangup failed: $err');
      }
    }
    await _disposePeer();
    _logger.info('✅ Disconnected from realtime session');
  }

  Future<void> _createPeerConnection() async {
    _peerConnection = await createPeerConnection(_rtcConfiguration);
    _logger.fine('✅ Peer connection created');

    _peerConnection!.onTrack = (event) {
      final track = event.track;
      _logger.fine('📺 Received media track: ${track.kind}');
      if (track.kind == 'audio') {
        _logger.fine('🔊 Audio track added to stream');
        _remoteAudioTracks.add(track);
      }
    };
    _peerConnection!.onConnectionState = (state) {
      _logger.info('🔌 Peer connection state changed: $state');
    };

    _logger.fine('Adding audio transceiver (send/receive)...');
    await _peerConnection!.addTransceiver(
      kind: RTCRtpMediaType.RTCRtpMediaTypeAudio,
      init: RTCRtpTransceiverInit(direction: TransceiverDirection.SendRecv),
    );
  }

  /// Acquire the microphone and add an upstream audio track to the peer connection.
  Future<MediaStreamTrack> enableMicrophone({bool echoCancellation = true, bool noiseSuppression = true}) async {
    _logger.fine('🎤 Requesting microphone access...');
    _logger.fine('  Echo cancellation: $echoCancellation');
    _logger.fine('  Noise suppression: $noiseSuppression');

    if (_localAudioTrack != null) {
      _localAudioTrack!.enabled = true;
      return _localAudioTrack!;
    }
    if (_peerConnection == null) {
      throw StateError('Peer connection is not available. Call connect() first.');
    }
    final pc = _peerConnection!;

    final constraints = {
      'audio': {'echoCancellation': echoCancellation, 'noiseSuppression': noiseSuppression},
      'video': false,
    };
    _localStream = await navigator.mediaDevices.getUserMedia(constraints);
    final track = _localStream!.getAudioTracks().first;
    _localAudioSender = await pc.addTrack(track, _localStream!);
    _localAudioTrack = track;
    _logger.info('✅ Microphone enabled');
    return track;
  }

  /// Stop the microphone and remove the upstream audio track.
  Future<void> disableMicrophone() async {
    if (_localStream == null && _localAudioTrack == null) return;
    _logger.fine('🎤 Disabling microphone...');
    try {
      _localAudioTrack?.enabled = false;
      _localAudioTrack?.stop();
      if (_localAudioSender != null && _peerConnection != null) {
        await _peerConnection!.removeTrack(_localAudioSender!);
      }
      await _localStream?.dispose();
    } finally {
      _localStream = null;
      _localAudioTrack = null;
      _localAudioSender = null;
    }
    _logger.info('✅ Microphone disabled');
  }

  Future<void> _prepareDataChannel() async {
    if (_peerConnection == null) {
      throw StateError('Peer connection must exist before creating a data channel.');
    }
    _logger.fine('Creating data channel: oai-events');
    _eventChannel = await _peerConnection!.createDataChannel(
      'oai-events',
      RTCDataChannelInit()
        ..ordered = true
        ..maxRetransmits = -1
        ..binaryType = 'binary',
    );
    _eventChannel!.onMessage = _handleMessage;
    _eventChannel!.onDataChannelState = (state) {
      _logger.info('📡 Data channel state: $state');
    };
    _logger.fine('✅ Data channel created');
  }

  Future<void> _exchangeOffer(String model, RealtimeSessionConfig? session) async {
    if (_peerConnection == null) {
      throw StateError('Peer connection is not available.');
    }
    _logger.fine('Creating WebRTC offer...');
    final offer = await _peerConnection!.createOffer({'offerToReceiveAudio': 1});
    await _peerConnection!.setLocalDescription(offer);
    _logger.fine('✅ Local description set');

    await _waitForIceGatheringComplete(_peerConnection!);
    final localDescription = await _peerConnection!.getLocalDescription();
    if (localDescription?.sdp == null) {
      throw StateError('Local description missing SDP.');
    }

    _logger.fine('Local SDP length: ${localDescription!.sdp!.length} characters');
    final sessionConfig = _prepareSessionConfig(model, session);
    final answer = await callsApi.createCall(offerSdp: localDescription.sdp!, session: sessionConfig);
    _callId = answer.callId;
    _logger.info('✅ Call created. Call ID: $_callId');

    _logger.fine('Setting remote description (answer)...');
    await _peerConnection!.setRemoteDescription(RTCSessionDescription(answer.sdp, 'answer'));

    if (_eventChannel != null) {
      await _waitForDataChannelOpen(_eventChannel!);
    }
  }

  Future<void> _disposePeer() async {
    _logger.fine('🧹 Disposing peer connection resources...');
    await disableMicrophone();
    await _eventChannel?.close();
    _eventChannel = null;
    await _peerConnection?.close();
    _peerConnection = null;
    _callId = null;
    _responseInProgress = false;
    _notifyResponsesIdle();
    _logger.fine('✅ Resources disposed');
  }

  void _handleMessage(RTCDataChannelMessage message) {
    if (message.isBinary) {
      _logger.warning('⚠️ Received binary data channel message of length ${message.binary.length}');
      return;
    }
    try {
      _logReceivedMessage(message.text);
      final json = jsonDecode(message.text) as Map<String, dynamic>;
      final event = RealtimeServerEvent.fromJson(json);
      if (event is UnknownServerEvent) {
        _logger.warning('❌ Unknown Server Event: ${event.type}');
        print('Unknown Server Event: ${event.type}');
      }
      _logger.fine('Event type: ${event.type}');
      _logger.fine('═══════════════════════════════════════════════════════');
      _trackResponseLifecycle(event);
      _serverEvents.add(event);
    } catch (err, stack) {
      _logger.warning('❌ Failed to decode server event: $err', err, stack);
      _logger.warning('Raw message: ${message.text}');
      _serverEvents.add(UnknownServerEvent(type: 'unknown', raw: {'error': err.toString(), 'payload': message.text}));
    }
  }

  void _trackResponseLifecycle(RealtimeServerEvent event) {
    switch (event) {
      case ResponseCreatedEvent _:
        if (!_responseInProgress) {
          _logger.fine('🟢 Tracking active response');
        }
        _responseInProgress = true;
        break;
      case ResponseDoneEvent _:
        if (_responseInProgress) {
          _logger.fine('⚪️ Response finished');
        }
        _responseInProgress = false;
        break;
      default:
        break;
    }
    _notifyResponsesIdle();
  }

  Future<void> _waitForResponsesToFinish({Duration timeout = const Duration(seconds: 5)}) {
    if (!_responseInProgress) return Future.value();
    final completer = Completer<void>();
    _responseIdleWaiters.add(completer);
    _logger.fine('⏳ Waiting for active response(s) to finish before sending new item...');
    return completer.future.timeout(
      timeout,
      onTimeout: () {
        _logger.warning('⚠️ Timed out waiting for response to finish.');
      },
    );
  }

  void _notifyResponsesIdle() {
    if (_responseInProgress) return;
    if (_responseIdleWaiters.isEmpty) return;
    for (final waiter in List<Completer<void>>.from(_responseIdleWaiters)) {
      if (!waiter.isCompleted) {
        waiter.complete();
      }
    }
    _responseIdleWaiters.clear();
  }

  Future<void> _cancelActiveResponseBeforeDisconnect() async {
    if (!_responseInProgress) return;
    if (_eventChannel == null || _eventChannel!.state != RTCDataChannelState.RTCDataChannelOpen) {
      _logger.fine('Response in progress but data channel is closed; skipping cancel.');
      return;
    }
    try {
      _logger.fine('⏹ Cancelling active response before disconnect');
      await sendEvent(const ResponseCancelEvent());
      await sendEvent(const OutputAudioBufferClearEvent());
      await _waitForResponsesToFinish(timeout: const Duration(seconds: 2));
    } catch (err, stack) {
      _logger.warning('⚠️ Failed to cancel response before disconnect: $err', err, stack);
    }
  }

  void _logEventPayload(String payload) {
    if (payload.length > 500) {
      _logger.fine('  ${payload.substring(0, 500)}...');
      _logger.fine('  (Total length: ${payload.length} characters)');
    } else {
      _logger.fine('  $payload');
    }
  }

  void _logSendingEvent(RealtimeClientEvent event, String payload) {
    _logger.fine('═══════════════════════════════════════════════════════');
    _logger.fine('📤 SENDING EVENT - ${event.runtimeType}');
    _logger.fine('Event type: ${event.type}');
    _logger.fine('─────────────────────────────────────────────────────');
    _logger.fine('Payload:');
    _logEventPayload(payload);
    _logger.fine('═══════════════════════════════════════════════════════');
  }

  void _logReceivedMessage(String payload) {
    _logger.fine('═══════════════════════════════════════════════════════');
    _logger.fine('📥 RECEIVED MESSAGE');
    _logger.fine('─────────────────────────────────────────────────────');
    _logEventPayload(payload);
  }

  Future<void> _waitForIceGatheringComplete(RTCPeerConnection pc) async {
    if (pc.iceGatheringState == RTCIceGatheringState.RTCIceGatheringStateComplete) {
      _logger.fine('✅ ICE gathering already complete');
      return;
    }
    _logger.fine('⏳ Waiting for ICE gathering to complete...');
    final completer = Completer<void>();
    pc.onIceGatheringState = (state) {
      _logger.fine('ICE gathering state: $state');
      if (state == RTCIceGatheringState.RTCIceGatheringStateComplete && !completer.isCompleted) {
        _logger.fine('✅ ICE gathering complete');
        completer.complete();
      }
    };
    try {
      await completer.future.timeout(const Duration(seconds: 5));
    } catch (_) {
      _logger.warning('⚠️ ICE gathering timed out after 5 seconds.');
    }
  }

  RealtimeSessionConfig _prepareSessionConfig(String model, RealtimeSessionConfig? session) {
    final provided = session ?? const RealtimeSessionConfig();
    if (provided.model != null && provided.model != model) {
      throw ArgumentError('connect() model "$model" does not match provided session model "${provided.model}".');
    }
    final type = provided.type ?? 'realtime';
    return provided.copyWith(model: model, type: type);
  }

  Future<void> _waitForDataChannelOpen(RTCDataChannel channel) async {
    if (channel.state == RTCDataChannelState.RTCDataChannelOpen) {
      _logger.fine('✅ Data channel already open');
      return;
    }

    final completer = Completer<void>();
    channel.onDataChannelState = (state) {
      _logger.info('📡 Data channel state: $state');
      if (state == RTCDataChannelState.RTCDataChannelOpen && !completer.isCompleted) {
        completer.complete();
      }
    };

    await completer.future.timeout(
      const Duration(seconds: 10),
      onTimeout: () {
        throw TimeoutException('Timed out waiting for data channel to open.');
      },
    );
  }

  /// Dispose resources.
  Future<void> dispose() async {
    await disconnect();
    await _serverEvents.close();
    await _clientEvents.close();
    await _remoteAudioTracks.close();
  }
}
