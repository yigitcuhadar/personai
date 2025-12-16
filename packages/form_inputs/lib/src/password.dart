import 'package:formz/formz.dart';

enum PasswordValidationError { invalid, empty }

class PasswordForm extends FormzInput<String, PasswordValidationError> {
  const PasswordForm.pure([super.value = '']) : super.pure();

  const PasswordForm.dirty([super.value = '']) : super.dirty();

  static final _passwordRegex = RegExp(r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{8,}$');

  @override
  PasswordValidationError? validator(String value) {
    if (value.isEmpty) {
      return PasswordValidationError.empty;
    } else if (!_passwordRegex.hasMatch(value)) {
      return PasswordValidationError.invalid;
    }

    return null;
  }
}