import 'package:authentication_repository/authentication_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:formz/formz.dart';

import '../models/inputs/confirmed_password.dart';
import '../models/inputs/email.dart';
import '../models/inputs/password.dart';

part 'sign_up_state.dart';

class SignUpCubit extends Cubit<SignUpState> {
  SignUpCubit(this._authenticationRepository) : super(const SignUpState());

  final AuthenticationRepository _authenticationRepository;

  void emailChanged(String v) {
    if (!isClosed) emit(state.copyWith(email: EmailForm.dirty(v)));
  }

  void passwordChanged(String v) {
    if (!isClosed) {
      emit(
        state.copyWith(
          password: PasswordForm.dirty(v),
          confirmPassword: ConfirmedPasswordForm.dirty(password: v, value: state.confirmPassword.value),
        ),
      );
    }
  }

  void confirmPasswordChanged(String v) {
    if (!isClosed) {
      emit(
        state.copyWith(
          confirmPassword: ConfirmedPasswordForm.dirty(password: state.password.value, value: v),
        ),
      );
    }
  }

  Future<void> submitted() async {
    if (!state.isValid) return;
    if (!isClosed) emit(state.copyWith(status: FormzSubmissionStatus.inProgress));
    try {
      await _authenticationRepository.signUp(
        email: state.email.value,
        password: state.password.value,
      );
      if (!isClosed) emit(state.copyWith(status: FormzSubmissionStatus.success));
    } on SignUpException catch (e) {
      // TODO her error icin mesaj ayarlanacak
      if (!isClosed) emit(state.copyWith(status: FormzSubmissionStatus.failure, error: e.error.toString()));
    } catch (_) {
      if (!isClosed) emit(state.copyWith(status: FormzSubmissionStatus.failure, error: 'Sign Up Error!'));
    }
  }
}
