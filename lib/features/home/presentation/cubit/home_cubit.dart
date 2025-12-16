import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:formz/formz.dart';
import 'package:openai_realtime/openai_realtime.dart';

part 'home_state.dart';

class ApiKeyInput extends FormzInput<String, String> {
  const ApiKeyInput.pure([super.value = '']) : super.pure();
  const ApiKeyInput.dirty([super.value = '']) : super.dirty();

  @override
  String? validator(String value) => value.trim().isEmpty ? 'API anahtarı gerekli' : null;
}

class ModelInput extends FormzInput<String, String> {
  const ModelInput.pure([super.value = 'gpt-realtime']) : super.pure();
  const ModelInput.dirty([super.value = '']) : super.dirty();

  @override
  String? validator(String value) => value.trim().isEmpty ? 'Model gerekli' : null;
}

class PromptInput extends FormzInput<String, String> {
  const PromptInput.pure([super.value = '']) : super.pure();
  const PromptInput.dirty([super.value = '']) : super.dirty();

  @override
  String? validator(String value) => value.trim().isEmpty ? 'Prompt gerekli' : null;
}

class HomeCubit extends Cubit<HomeState> {
  HomeCubit() : super(const HomeState());

  OpenAIRealtimeClient? _client;
  StreamSubscription<RealtimeServerEvent>? _eventSub;

  void onApiKeyChanged(String value) {
    emit(state.copyWith(apiKey: ApiKeyInput.dirty(value), clearError: true));
  }

  void onModelChanged(String value) {
    emit(state.copyWith(model: ModelInput.dirty(value), clearError: true));
  }

  void onPromptChanged(String value) {
    emit(state.copyWith(prompt: PromptInput.dirty(value), clearError: true));
  }

  void setDebugLogging(bool value) {
    if (state.status == HomeStatus.connecting || state.status == HomeStatus.connected) return;
    emit(state.copyWith(debugLogging: value, clearError: true));
  }

  Future<void> connect() async {
    if (state.status == HomeStatus.connecting || state.status == HomeStatus.connected) return;

    final apiKey = ApiKeyInput.dirty(state.apiKey.value.trim());
    final model = ModelInput.dirty(state.model.value.trim());
    final validated = Formz.validate([apiKey, model]);
    if (!validated) {
      emit(state.copyWith(apiKey: apiKey, model: model, lastError: 'API anahtarı ve model gerekli.'));
      return;
    }

    emit(state.copyWith(status: HomeStatus.connecting, apiKey: apiKey, model: model, clearError: true));

    final client = OpenAIRealtimeClient(accessToken: apiKey.value, debug: state.debugLogging);
    if (state.debugLogging) {
      enableOpenAIRealtimeLogging();
    }

    _eventSub?.cancel();
    _eventSub = client.events.listen(
      _handleEvent,
      onError: (err, stack) {
        _appendLog('Hata: $err');
      },
    );

    try {
      await client.connect(
        model: model.value,
        session: const RealtimeSessionConfig(type: 'realtime'),
      );
      _client = client;
      emit(
        state.copyWith(
          status: HomeStatus.connected,
          callId: client.callId,
          clearError: true,
        ),
      );
      _appendLog('Bağlanıldı (callId: ${client.callId ?? 'bilinmiyor'})');
    } catch (err) {
      await _eventSub?.cancel();
      _eventSub = null;
      await client.dispose();
      emit(state.copyWith(status: HomeStatus.error, callId: null, lastError: '$err'));
      _appendLog('Bağlantı hatası: $err');
    }
  }

  Future<void> disconnect() async {
    final client = _client;
    if (client == null) return;
    emit(state.copyWith(status: HomeStatus.disconnecting, clearError: true));
    await client.disconnect();
    await _eventSub?.cancel();
    _eventSub = null;
    _client = null;
    emit(state.copyWith(status: HomeStatus.initial, callId: null, clearError: true));
    _appendLog('Bağlantı kapatıldı');
  }

  Future<void> sendPrompt() async {
    if (!state.prompt.isValid) return;
    final prompt = state.prompt.value.trim();

    final client = _client;
    if (client == null) {
      emit(state.copyWith(lastError: 'Önce bağlanın.'));
      return;
    }
    await client.sendText(prompt);
    _appendLog('👤 $prompt');
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
    final updated = List<String>.from(state.logs)..add(message);
    emit(state.copyWith(logs: updated));
  }

  @override
  Future<void> close() async {
    await _eventSub?.cancel();
    await _client?.dispose();
    return super.close();
  }
}
