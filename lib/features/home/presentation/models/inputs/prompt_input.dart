import 'package:formz/formz.dart';

class PromptInput extends FormzInput<String, String> {
  const PromptInput.pure([super.value = '']) : super.pure();
  const PromptInput.dirty([super.value = '']) : super.dirty();

  @override
  String? validator(String value) => value.trim().isEmpty ? 'Prompt is required' : null;
}
