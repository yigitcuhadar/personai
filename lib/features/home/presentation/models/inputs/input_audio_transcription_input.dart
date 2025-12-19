import 'package:formz/formz.dart';
import 'package:openai_realtime/openai_realtime.dart';

class InputAudioTranscriptionInput extends FormzInput<String, String> {
  const InputAudioTranscriptionInput.pure([super.value = 'whisper-1'])
    : super.pure();
  const InputAudioTranscriptionInput.dirty([super.value = 'whisper-1'])
    : super.dirty();

  @override
  String? validator(String value) =>
      realtimeTranscriptionModelNames.contains(value)
      ? null
      : 'Invalid transcription model';
}
