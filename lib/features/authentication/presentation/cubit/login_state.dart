part of 'login_cubit.dart';

class LoginState extends Equatable {
  final EmailForm email;
  final PasswordForm password;
  final FormzSubmissionStatus status;
  final String? error;

  const LoginState({
    this.email = const EmailForm.pure(),
    this.password = const PasswordForm.pure(),
    this.status = FormzSubmissionStatus.initial,
    this.error,
  });

  bool get isValid => !email.isNotValid && !password.isNotValid;

  LoginState copyWith({
    EmailForm? email,
    PasswordForm? password,
    FormzSubmissionStatus? status,
    String? error,
  }) => LoginState(
    email: email ?? this.email,
    password: password ?? this.password,
    status: status ?? this.status,
    error: error,
  );

  @override
  List<Object?> get props => [email, password, status, error];
}
