import 'package:formz/formz.dart';

enum ConfirmedPasswordValidationError { invalid, empty }

class ConfirmedPasswordForm extends FormzInput<String, ConfirmedPasswordValidationError> {
  final String password;

  const ConfirmedPasswordForm.pure({this.password = ''}) : super.pure('');

  const ConfirmedPasswordForm.dirty({required this.password, String value = ''}) : super.dirty(value);

  @override
  ConfirmedPasswordValidationError? validator(String value) {
    if (value.isEmpty) {
      return ConfirmedPasswordValidationError.empty;
    }
    return password == value ? null : ConfirmedPasswordValidationError.invalid;
  }
}
