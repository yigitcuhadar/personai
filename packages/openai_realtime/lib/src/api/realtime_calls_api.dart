import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';

import '../models/realtime_models.dart';

/// HTTP client for Realtime call REST endpoints.
class RealtimeCallsApi {
  RealtimeCallsApi({required this.accessToken, Uri? baseUrl, http.Client? httpClient, Logger? logger, this.logFullHttp = false})
    : baseUrl = baseUrl ?? Uri.parse('https://api.openai.com/v1'),
      httpClient = httpClient ?? http.Client(),
      logger = logger ?? Logger('RealtimeCallsApi');

  final String accessToken;
  final Uri baseUrl;
  final http.Client httpClient;
  final Logger logger;
  final bool logFullHttp;

  Uri _resolve(String path) => baseUrl.replace(path: '${baseUrl.path}$path');

  Map<String, String> get _authHeaders => {
    'Authorization': 'Bearer $accessToken',
    // Required for the Realtime API v1 GA endpoints.
    'OpenAI-Beta': 'realtime=v1',
  };

  /// The HTTP API for `POST /v1/realtime/calls` currently rejects some session
  /// fields (e.g., `output_modalities`). Strip those while keeping the shape
  /// aligned with the documented curl sample.
  JsonMap _sessionPayloadForCreate(RealtimeSessionConfig session) {
    final json = Map<String, dynamic>.from(session.toJson());
    json.remove('output_modalities');
    return json;
  }

  /// Create a new call by exchanging the WebRTC SDP offer for an answer.
  ///
  /// This follows the documented `POST /v1/realtime/calls` contract:
  /// - Multipart form body with an `sdp` part (application/sdp)
  /// - A `session` part (application/json) that must include the model
  Future<CallAnswer> createCall({
    required String offerSdp,
    required RealtimeSessionConfig session,
  }) async {
    final uri = _resolve('/realtime/calls');
    logger.info('🔄 Creating realtime call...');

    if (session.model == null || session.model!.isEmpty) {
      throw ArgumentError('Realtime session must include a model name.');
    }
    final normalizedSession =
        session.type == null ? session.copyWith(type: 'realtime') : session;

    final request = http.MultipartRequest('POST', uri);
    request.headers.addAll(_authHeaders);

    // Send both parts as form fields to exactly mirror the documented curl example.
    // The server accepts these as long as the names match.
    request.fields['sdp'] = offerSdp;
    request.fields['session'] = jsonEncode(_sessionPayloadForCreate(normalizedSession));

    _logMultipartRequest(request);
    final streamed = await httpClient.send(request);
    final response = await http.Response.fromStream(streamed);
    _logResponse(response);

    if (response.statusCode != 201) {
      logger.severe('❌ Call creation failed with status ${response.statusCode}');
      logger.severe('Response body: ${response.body}');
      throw http.ClientException(
        'Failed to create realtime call: ${response.statusCode} ${response.body}',
        uri,
      );
    }

    final location = response.headers['location'];
    final callId = location != null ? location.split('/').last : null;
    logger.info('✅ Call created successfully. Call ID: $callId');
    return CallAnswer(sdp: response.body, callId: callId);
  }

  /// Accept an incoming SIP call.
  Future<void> acceptCall(String callId, AcceptCallRequest request) async {
    final uri = _resolve('/realtime/calls/$callId/accept');
    final headers = {..._authHeaders, 'Content-Type': 'application/json'};
    final body = jsonEncode(request.toJson());
    _logRequest('POST', uri, headers, body: body);
    final response = await httpClient.post(uri, headers: headers, body: body);
    _logResponse(response);
    if (response.statusCode != 200) {
      throw http.ClientException('Failed to accept call $callId: ${response.statusCode} ${response.body}', uri);
    }
  }

  /// Reject an incoming SIP call.
  Future<void> rejectCall(String callId, RejectCallRequest request) async {
    final uri = _resolve('/realtime/calls/$callId/reject');
    final headers = {..._authHeaders, 'Content-Type': 'application/json'};
    final body = jsonEncode(request.toJson());
    _logRequest('POST', uri, headers, body: body);
    final response = await httpClient.post(uri, headers: headers, body: body);
    _logResponse(response);
    if (response.statusCode != 200) {
      throw http.ClientException('Failed to reject call $callId: ${response.statusCode} ${response.body}', uri);
    }
  }

  /// Transfer an active SIP call to another destination.
  Future<void> referCall(String callId, ReferCallRequest request) async {
    final uri = _resolve('/realtime/calls/$callId/refer');
    final headers = {..._authHeaders, 'Content-Type': 'application/json'};
    final body = jsonEncode(request.toJson());
    _logRequest('POST', uri, headers, body: body);
    final response = await httpClient.post(uri, headers: headers, body: body);
    _logResponse(response);
    if (response.statusCode != 200) {
      throw http.ClientException('Failed to refer call $callId: ${response.statusCode} ${response.body}', uri);
    }
  }

  /// Hang up an active call (WebRTC or SIP).
  Future<void> hangupCall(String callId) async {
    final uri = _resolve('/realtime/calls/$callId/hangup');
    _logRequest('POST', uri, _authHeaders);
    final response = await httpClient.post(uri, headers: _authHeaders);
    _logResponse(response);
    if (response.statusCode != 200) {
      throw http.ClientException('Failed to hang up call $callId: ${response.statusCode} ${response.body}', uri);
    }
  }

  void _logRequest(String method, Uri uri, Map<String, String> headers, {String? body}) {
    logger.fine('═══════════════════════════════════════════════════════');
    logger.fine('📤 HTTP REQUEST - $method');
    logger.fine('URL: $uri');
    logger.fine('─────────────────────────────────────────────────────');
    logger.fine('Headers:');
    _redact(headers).forEach((key, value) {
      logger.fine('  $key: $value');
    });
    if (body != null) {
      logger.fine('─────────────────────────────────────────────────────');
      logger.fine('Body:');
      _logBody(body);
    }
    logger.fine('═══════════════════════════════════════════════════════');
  }

  void _logMultipartRequest(http.MultipartRequest request) {
    logger.fine('═══════════════════════════════════════════════════════');
    logger.fine('📤 HTTP MULTIPART REQUEST - ${request.method}');
    logger.fine('URL: ${request.url}');
    logger.fine('─────────────────────────────────────────────────────');
    logger.fine('Headers:');
    _redact(request.headers).forEach((key, value) {
      logger.fine('  $key: $value');
    });

    if (request.fields.isNotEmpty) {
      logger.fine('─────────────────────────────────────────────────────');
      logger.fine('Fields:');
      request.fields.forEach((key, value) {
        final preview = value.length > 100 ? value.substring(0, 100) + '...' : value;
        logger.fine('  $key: $preview (${value.length} bytes)');
      });
    }

    if (request.files.isNotEmpty) {
      logger.fine('─────────────────────────────────────────────────────');
      logger.fine('Files:');
      for (final file in request.files) {
        logger.fine('  ${file.field}: ${file.filename} (${file.length} bytes)');
        if (logFullHttp && file.length < 1000) {
          logger.fine('    Content: ${file.toString()}');
        }
      }
    }
    logger.fine('═══════════════════════════════════════════════════════');
  }

  void _logResponse(http.Response response) {
    logger.fine('═══════════════════════════════════════════════════════');
    logger.fine('📥 HTTP RESPONSE');
    logger.fine('${response.request?.method} ${response.request?.url}');
    logger.fine('Status: ${response.statusCode}');
    logger.fine('─────────────────────────────────────────────────────');
    logger.fine('Headers:');
    _redact(response.headers).forEach((key, value) {
      logger.fine('  $key: $value');
    });

    if (response.body.isNotEmpty) {
      logger.fine('─────────────────────────────────────────────────────');
      logger.fine('Body:');
      _logBody(response.body);
    }
    logger.fine('═══════════════════════════════════════════════════════');
  }

  void _logBody(String body) {
    if (body.length > 500) {
      logger.fine('  ${body.substring(0, 500)}...');
      logger.fine('  (Total length: ${body.length} characters)');
    } else {
      logger.fine('  $body');
    }
  }

  Map<String, String> _redact(Map<String, String> headers) {
    final copy = Map<String, String>.from(headers);
    if (copy.containsKey('Authorization')) {
      copy['Authorization'] = 'Bearer ***';
    }
    return copy;
  }
}
