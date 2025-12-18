import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:openai_realtime/openai_realtime.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const RealtimeMicExampleApp());
}

class RealtimeMicExampleApp extends StatelessWidget {
  const RealtimeMicExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Realtime Mic Example',
      theme: ThemeData.from(colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple)),
      home: const RealtimeMicExamplePage(),
    );
  }
}

class RealtimeMicExamplePage extends StatefulWidget {
  const RealtimeMicExamplePage({super.key});

  @override
  State<RealtimeMicExamplePage> createState() => _RealtimeMicExamplePageState();
}

class _RealtimeMicExamplePageState extends State<RealtimeMicExamplePage> {
  final _apiKeyController = TextEditingController();
  final _modelController = TextEditingController(text: 'gpt-4o-mini');
  final _messageController = TextEditingController();
  final _logs = <String>[];
  OpenAIRealtimeClient? _client;
  StreamSubscription<RealtimeServerEvent>? _eventSubscription;
  StreamSubscription<MediaStreamTrack>? _audioSubscription;
  bool _isBusy = false;
  bool _micEnabled = false;

  bool get _isConnected => _client?.isConnected == true;

  @override
  void dispose() {
    _messageController.dispose();
    _apiKeyController.dispose();
    _modelController.dispose();
    _eventSubscription?.cancel();
    _audioSubscription?.cancel();
    _client?.dispose();
    super.dispose();
  }

  void _recordLog(String message) {
    final timestamp = DateTime.now().toIso8601String().split('T').last.replaceAll('Z', '');
    setState(() {
      _logs.add('[$timestamp] $message');
      if (_logs.length > 40) {
        _logs.removeRange(0, _logs.length - 40);
      }
    });
  }

  Future<void> _connect() async {
    if (_isBusy || _isConnected) return;
    final apiKey = _apiKeyController.text.trim();
    final model = _modelController.text.trim();
    if (apiKey.isEmpty || model.isEmpty) {
      _recordLog('API key and model are required before connecting.');
      return;
    }

    setState(() {
      _isBusy = true;
    });
    OpenAIRealtimeClient? client;
    try {
      client = OpenAIRealtimeClient(accessToken: apiKey, debug: true);
      await client.connect(model: model);
      _eventSubscription = client.serverEvents.listen((event) {
        _recordLog('[server] ${event.type}');
      });
      _audioSubscription = client.remoteAudioTracks.listen((track) {
        _recordLog('[audio] Remote ${track.kind} track ${track.id}');
      });
      setState(() {
        _client = client;
        _micEnabled = false;
      });
      _recordLog('Connected to $model');
    } catch (err) {
      _recordLog('Connection failed: $err');
      await client?.dispose();
    } finally {
      setState(() {
        _isBusy = false;
      });
    }
  }

  Future<void> _disconnect() async {
    if (_isBusy || _client == null) return;
    setState(() {
      _isBusy = true;
    });
    try {
      await _eventSubscription?.cancel();
      await _audioSubscription?.cancel();
      _eventSubscription = null;
      _audioSubscription = null;
      await _client?.disconnect();
      await _client?.dispose();
      setState(() {
        _client = null;
        _micEnabled = false;
      });
      _recordLog('Disconnected');
    } catch (err) {
      _recordLog('Disconnect failed: $err');
    } finally {
      setState(() {
        _isBusy = false;
      });
    }
  }

  Future<void> _sendText() async {
    if (!_isConnected || _isBusy) {
      _recordLog('Connect before sending text.');
      return;
    }
    final message = _messageController.text.trim();
    if (message.isEmpty) {
      _recordLog('Type a message before sending.');
      return;
    }

    setState(() => _isBusy = true);
    try {
      await _client!.sendText(message);
      _recordLog('Sent text: $message');
      _messageController.clear();
    } catch (err) {
      _recordLog('Send failed: $err');
    } finally {
      setState(() => _isBusy = false);
    }
  }

  Future<void> _toggleMicrophone() async {
    if (!_isConnected || _isBusy) {
      _recordLog('Connect before toggling the microphone.');
      return;
    }

    setState(() => _isBusy = true);
    try {
      if (_micEnabled) {
        await _client?.disableMicrophone();
        _recordLog('Microphone muted.');
      } else {
        await _client?.enableMicrophone();
        _recordLog('Microphone enabled and streaming.');
      }
      setState(() {
        _micEnabled = !_micEnabled;
      });
    } catch (err) {
      _recordLog('Microphone error: $err');
    } finally {
      setState(() => _isBusy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Realtime Mic Controls')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Bu demo, mikrofondan gelen sesi OpenAI Realtime API tarafından işlenmesi için WebRTC üzerinden gönderir.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _apiKeyController,
              decoration: const InputDecoration(
                labelText: 'OPENAI API Key',
                border: OutlineInputBorder(),
                helperText: 'Bu alanı dotenv veya flutter run --dart-define ile doldurun.',
              ),
              obscureText: true,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _modelController,
              decoration: const InputDecoration(
                labelText: 'Model',
                border: OutlineInputBorder(),
                helperText: 'Örnek: gpt-4o-mini',
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(onPressed: (_isBusy || _isConnected) ? null : _connect, child: const Text('Bağlan')),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(onPressed: (_isBusy || !_isConnected) ? null : _disconnect, child: const Text('Kes')),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: (_isBusy || !_isConnected) ? null : _toggleMicrophone,
                    icon: Icon(_micEnabled ? Icons.mic_off : Icons.mic),
                    label: Text(_micEnabled ? 'Mikrofonu Kapat' : 'Mikrofonu Aç'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: (_isBusy || !_isConnected) ? null : _sendText,
                    child: const Text('Yazı Gönder'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _messageController,
              decoration: const InputDecoration(labelText: 'Model’e gönderilecek metin', border: OutlineInputBorder()),
              minLines: 1,
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            Text('Etkinlik Günlüğü (${_logs.length})', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Expanded(
              child: Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: _logs.isEmpty
                      ? const Center(child: Text('Henüz olay yok'))
                      : ListView.separated(
                          itemCount: _logs.length,
                          separatorBuilder: (context, index) => const Divider(height: 8),
                          itemBuilder: (context, index) {
                            return Text(_logs[index], style: const TextStyle(fontFamily: 'monospace'));
                          },
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
