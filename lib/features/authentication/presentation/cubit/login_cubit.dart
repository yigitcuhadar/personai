import 'package:authentication_repository/authentication_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:form_inputs/form_inputs.dart';
import 'package:formz/formz.dart';

part 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  LoginCubit(this._authenticationRepository) : super(const LoginState());

  final AuthenticationRepository _authenticationRepository;

  void emailChanged(String v) {
    if (!isClosed) emit(state.copyWith(email: EmailForm.dirty(v)));
  }

  void passwordChanged(String v) {
    if (!isClosed) emit(state.copyWith(password: PasswordForm.dirty(v)));
  }

  Future<void> submitted() async {
    if (!state.isValid) return;
    if (!isClosed) emit(state.copyWith(status: FormzSubmissionStatus.inProgress));
    try {
      await _authenticationRepository.logInWithEmailAndPassword(
        email: state.email.value,
        password: state.password.value,
      );
      if (!isClosed) emit(state.copyWith(status: FormzSubmissionStatus.success));
    } on LoginException catch (e) {
      // TODO her error icin mesaj ayarlanacak
      if (!isClosed) emit(state.copyWith(status: FormzSubmissionStatus.failure, error: e.error.toString()));
    } catch (_) {
      if (!isClosed) emit(state.copyWith(status: FormzSubmissionStatus.failure, error: 'Login Error!'));
    }
  }
}
