enum SignUpError { invalidEmail, userDisabled, emailAlreadyInUse, operationNotAllowed, weakPassword, unknown }

class SignUpException implements Exception {
  final SignUpError error;
  const SignUpException(this.error);
  factory SignUpException.fromCode([String? code]) {
    switch (code) {
      case 'invalid-email':
        return SignUpException(SignUpError.invalidEmail);
      case 'user-disabled':
        return SignUpException(SignUpError.userDisabled);
      case 'email-already-in-use':
        return SignUpException(SignUpError.emailAlreadyInUse);
      case 'operation-not-allowed':
        return SignUpException(SignUpError.operationNotAllowed);
      case 'weak-password':
        return SignUpException(SignUpError.weakPassword);
      default:
        return SignUpException(SignUpError.unknown);
    }
  }
}

enum LoginError { invalidEmail, userDisabled, userNotFound, wrongPassword, unknown }

class LoginException implements Exception {
  final LoginError error;
  const LoginException(this.error);
  factory LoginException.fromCode([String? code]) {
    switch (code) {
      case 'invalid-email':
        return LoginException(LoginError.invalidEmail);
      case 'user-disabled':
        return LoginException(LoginError.userDisabled);
      case 'user-not-found':
        return LoginException(LoginError.userNotFound);
      case 'wrong-password':
        return LoginException(LoginError.wrongPassword);
      default:
        return LoginException(LoginError.unknown);
    }
  }
}

class LogoutException implements Exception {
  const LogoutException();
}
