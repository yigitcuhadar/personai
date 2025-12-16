import 'dart:async';

import 'package:authentication_repository/authentication_repository.dart';
import 'package:flutter/material.dart';
import 'package:openai_realtime/openai_realtime.dart';

import '../../../../app/di/injector.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  static Page<void> page() => const MaterialPage<void>(child: HomePage());

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _apiKeyController = TextEditingController(text: const String.fromEnvironment('OPENAI_API_KEY'));
  final _modelController = TextEditingController(text: 'gpt-realtime');
  final _promptController = TextEditingController(text: 'Say hello in one short sentence.');
  final _logs = <String>[];

  OpenAIRealtimeClient? _client;
  StreamSubscription<RealtimeServerEvent>? _eventSub;
  bool _connecting = false;
  bool _debugLogging = false;

  bool get _connected => _client != null;

  @override
  void dispose() {
    _eventSub?.cancel();
    final client = _client;
    if (client != null) {
      unawaited(client.dispose());
    }
    _apiKeyController.dispose();
    _modelController.dispose();
    _promptController.dispose();
    super.dispose();
  }

  Future<void> _connect() async {
    if (_connecting || _connected) return;
    final apiKey = _apiKeyController.text.trim();
    final model = _modelController.text.trim();
    if (apiKey.isEmpty || model.isEmpty) {
      _showSnack('API anahtarı ve model gerekli.');
      return;
    }

    setState(() => _connecting = true);
    final client = OpenAIRealtimeClient(accessToken: apiKey, debug: _debugLogging);
    if (_debugLogging) {
      enableOpenAIRealtimeLogging();
    }

    _eventSub?.cancel();
    _eventSub = client.events.listen(_handleEvent, onError: (err, stack) {
      _appendLog('Hata: $err');
      // ignore: avoid_print
      print(stack);
    });

    try {
      await client.connect(
        model: model,
        session: const RealtimeSessionConfig(
          type: 'realtime',
        ),
      );
      setState(() {
        _client = client;
      });
      _appendLog('Bağlanıldı (callId: ${client.callId ?? 'bilinmiyor'})');
    } catch (err, stack) {
      await client.dispose();
      _appendLog('Bağlantı hatası: $err');
      _showSnack('Bağlantı kurulamadı: $err');
      // ignore: avoid_print
      print(stack);
    } finally {
      if (mounted) {
        setState(() => _connecting = false);
      }
    }
  }

  Future<void> _disconnect() async {
    final client = _client;
    if (client == null) return;
    await client.disconnect();
    await _eventSub?.cancel();
    setState(() {
      _client = null;
      _eventSub = null;
    });
    _appendLog('Bağlantı kapatıldı');
  }

  Future<void> _sendPrompt() async {
    final client = _client;
    if (client == null) {
      _showSnack('Önce bağlanın.');
      return;
    }
    final text = _promptController.text.trim();
    if (text.isEmpty) {
      _showSnack('Gönderilecek bir metin yazın.');
      return;
    }
    await client.sendText(text);
    _appendLog('👤 $text');
    FocusScope.of(context).unfocus();
  }

  void _handleEvent(RealtimeServerEvent event) {
    switch (event) {
      case ResponseOutputTextDeltaEvent delta:
        _appendLog('🤖 ${delta.delta}');
      case ResponseOutputAudioTranscriptDeltaEvent delta:
        _appendLog('🎙️ ${delta.delta}');
      default:
        _appendLog('ℹ️ ${event.type}');
    }
  }

  void _appendLog(String message) {
    setState(() {
      _logs.add(message);
    });
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Realtime Playground'),
        actions: [
          TextButton(
            onPressed: () => getIt<AuthenticationRepository>().logOut(),
            child: const Text('Logout'),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _ConnectionCard(
                apiKeyController: _apiKeyController,
                modelController: _modelController,
                debugLogging: _debugLogging,
                connecting: _connecting,
                connected: _connected,
                onToggleDebug: (value) => setState(() => _debugLogging = value),
                onConnect: _connect,
                onDisconnect: _disconnect,
              ),
              const SizedBox(height: 12),
              _PromptCard(
                controller: _promptController,
                onSend: _sendPrompt,
                connected: _connected,
              ),
              const SizedBox(height: 12),
              Expanded(child: _LogPane(logs: _logs)),
            ],
          ),
        ),
      ),
    );
  }
}

class _ConnectionCard extends StatelessWidget {
  const _ConnectionCard({
    required this.apiKeyController,
    required this.modelController,
    required this.debugLogging,
    required this.connecting,
    required this.connected,
    required this.onToggleDebug,
    required this.onConnect,
    required this.onDisconnect,
  });

  final TextEditingController apiKeyController;
  final TextEditingController modelController;
  final bool debugLogging;
  final bool connecting;
  final bool connected;
  final ValueChanged<bool> onToggleDebug;
  final VoidCallback onConnect;
  final VoidCallback onDisconnect;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: apiKeyController,
              decoration: const InputDecoration(
                labelText: 'OpenAI API Key',
                hintText: 'sk-...',
              ),
              obscureText: true,
              autofillHints: const [AutofillHints.password],
            ),
            const SizedBox(height: 8),
            TextField(
              controller: modelController,
              decoration: const InputDecoration(
                labelText: 'Model',
                hintText: 'gpt-realtime',
              ),
            ),
            SwitchListTile(
              value: debugLogging,
              contentPadding: EdgeInsets.zero,
              title: const Text('Verbose logging'),
              subtitle: const Text('SDK, HTTP ve event trafiğini yazdır'),
              onChanged: (connecting || connected) ? null : onToggleDebug,
            ),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: connecting || connected ? null : onConnect,
                    icon: const Icon(Icons.play_arrow),
                    label: Text(connecting ? 'Connecting...' : 'Connect'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: connected ? onDisconnect : null,
                    icon: const Icon(Icons.stop),
                    label: const Text('Disconnect'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PromptCard extends StatelessWidget {
  const _PromptCard({
    required this.controller,
    required this.onSend,
    required this.connected,
  });

  final TextEditingController controller;
  final VoidCallback onSend;
  final bool connected;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: controller,
              minLines: 2,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Prompt',
                hintText: 'Bugün hava nasıl?',
              ),
              onSubmitted: (_) => onSend(),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                onPressed: connected ? onSend : null,
                icon: const Icon(Icons.send),
                label: const Text('Send'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LogPane extends StatelessWidget {
  const _LogPane({required this.logs});

  final List<String> logs;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: logs.isEmpty
            ? const Center(child: Text('Henüz etkinlik yok.'))
            : ListView.builder(
                itemCount: logs.length,
                itemBuilder: (context, index) {
                  final entry = logs[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Text(entry),
                  );
                },
              ),
      ),
    );
  }
}
