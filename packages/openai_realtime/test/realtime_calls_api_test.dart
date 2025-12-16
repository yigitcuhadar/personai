import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:logging/logging.dart';
import 'package:openai_realtime/openai_realtime.dart';

void main() {
  test('createCall posts SDP and session JSON as multipart', () async {
    http.Request? captured;
    final mock = MockClient((request) async {
      captured = request;
      return http.Response(
        'answer-sdp',
        201,
        headers: {'location': 'https://api.openai.com/v1/realtime/calls/call_42'},
      );
    });

    final api = RealtimeCallsApi(
      accessToken: 'token',
      httpClient: mock,
      logger: Logger('RealtimeCallsApiTest'),
      logFullHttp: false,
    );

    final answer = await api.createCall(
      offerSdp: 'offer-sdp',
      session: const RealtimeSessionConfig(
        type: 'realtime',
        model: 'gpt-realtime',
        outputModalities: ['text'],
      ),
    );

    expect(answer.sdp, 'answer-sdp');
    expect(answer.callId, 'call_42');
    final request = captured!;
    expect(request.url.path, '/v1/realtime/calls');
    expect(request.headers['content-type'], contains('multipart/form-data'));

    final body = utf8.decode(request.bodyBytes);
    expect(body, contains('name="sdp"'));
    expect(body, contains('offer-sdp'));
    expect(body, contains('name="session"'));
    expect(body, contains('"model":"gpt-realtime"'));
    expect(body.contains('output_modalities'), isFalse,
        reason: 'output_modalities should be stripped for createCall');
  });

  test('createCall guards against missing model', () async {
    final mock = MockClient((_) async => http.Response('ignored', 201));
    final api = RealtimeCallsApi(
      accessToken: 'token',
      httpClient: mock,
      logger: Logger('RealtimeCallsApiTest'),
      logFullHttp: false,
    );

    expect(
      () => api.createCall(
        offerSdp: 'offer-sdp',
        session: const RealtimeSessionConfig(type: 'realtime'),
      ),
      throwsArgumentError,
    );
  });
}
