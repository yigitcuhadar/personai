import 'package:formz/formz.dart';
import 'package:openai_realtime/openai_realtime.dart';

class VoiceInput extends FormzInput<String, String> {
  const VoiceInput.pure([super.value = 'marin']) : super.pure();
  const VoiceInput.dirty([super.value = 'marin']) : super.dirty();

  @override
  String? validator(String value) => realtimeVoiceNames.contains(value) ? null : 'Invalid voice';
}
