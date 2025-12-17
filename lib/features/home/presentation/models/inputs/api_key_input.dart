import 'package:formz/formz.dart';

class ApiKeyInput extends FormzInput<String, String> {
  const ApiKeyInput.pure([super.value = '']) : super.pure();
  const ApiKeyInput.dirty([super.value = '']) : super.dirty();

  @override
  String? validator(String value) => value.trim().isEmpty ? 'API key is required' : null;
}
