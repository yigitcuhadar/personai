import 'dart:async';

import 'package:authentication_repository/authentication_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'authentication_event.dart';
part 'authentication_state.dart';

class AuthenticationBloc extends Bloc<AuthenticationEvent, AuthenticationState> {
  final AuthenticationRepository repository;
  late final StreamSubscription<User?> user;

  AuthenticationBloc({required this.repository, required firstUser})
    : super(
        firstUser != null ? AuthenticatedState(user: firstUser) : UnauthenticatedState(),
      ) {
    user = repository.user.listen(_handleUserChanged);
    on<AuthenticationChangedEvent>(_handleAuthenticationChangedEvent);
  }

  Future<void> _handleUserChanged(User? user) async {
    add(AuthenticationChangedEvent(user: user));
  }

  Future<void> _handleAuthenticationChangedEvent(
    AuthenticationChangedEvent event,
    Emitter<AuthenticationState> emit,
  ) async {
    if (event.user != null) {
      emit(AuthenticatedState(user: event.user!));
    } else {
      emit(UnauthenticatedState());
    }
  }

  @override
  Future<void> close() {
    user.cancel();
    return super.close();
  }
}
