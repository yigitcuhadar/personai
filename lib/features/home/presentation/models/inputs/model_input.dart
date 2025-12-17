import 'package:formz/formz.dart';

class ModelInput extends FormzInput<String, String> {
  const ModelInput.pure([super.value = 'gpt-realtime']) : super.pure();
  const ModelInput.dirty([super.value = 'gpt-realtime']) : super.dirty();

  @override
  String? validator(String value) => value.trim().isEmpty ? 'Model is required' : null;
}
