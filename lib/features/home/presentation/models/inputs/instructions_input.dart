import 'package:formz/formz.dart';

class InstructionsInput extends FormzInput<String, String> {
  const InstructionsInput.pure([super.value = '']) : super.pure();
  const InstructionsInput.dirty([super.value = '']) : super.dirty();

  @override
  String? validator(String value) => null; // optional
}
