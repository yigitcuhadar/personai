part of 'sign_up_cubit.dart';

final class SignUpState extends Equatable {
  final EmailForm email;
  final PasswordForm password;
  final ConfirmedPasswordForm confirmPassword;
  final FormzSubmissionStatus status;
  final String? error;

  const SignUpState({
    this.email = const EmailForm.pure(),
    this.password = const PasswordForm.pure(),
    this.confirmPassword = const ConfirmedPasswordForm.pure(),
    this.status = FormzSubmissionStatus.initial,
    this.error,
  });

  bool get isValid => !email.isNotValid && !password.isNotValid && !confirmPassword.isNotValid;

  SignUpState copyWith({
    EmailForm? email,
    PasswordForm? password,
    ConfirmedPasswordForm? confirmPassword,
    FormzSubmissionStatus? status,
    String? error,
  }) => SignUpState(
    email: email ?? this.email,
    password: password ?? this.password,
    confirmPassword: confirmPassword ?? this.confirmPassword,
    status: status ?? this.status,
    error: error,
  );

  @override
  List<Object?> get props => [email, password, confirmPassword, status, error];
}
