import 'package:formz/formz.dart';

enum EmailValidationError { invalid, empty }

class EmailForm extends FormzInput<String, EmailValidationError> {
  const EmailForm.pure([super.value = '']) : super.pure();

  const EmailForm.dirty([super.value = '']) : super.dirty();

  static final _emailRegExp = RegExp(r'^[a-zA-Z0-9.!#$%&’*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)*$');

  @override
  EmailValidationError? validator(String value) {
    if (value.isEmpty) {
      return EmailValidationError.empty;
    } else if (!_emailRegExp.hasMatch(value)) {
      return EmailValidationError.invalid;
    }
    return null;
  }
}
