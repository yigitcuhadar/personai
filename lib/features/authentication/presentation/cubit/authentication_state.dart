part of 'authentication_bloc.dart';

abstract class AuthenticationState extends Equatable {
  const AuthenticationState();

  @override
  List<Object> get props => [];
}

final class AuthenticatedState extends AuthenticationState {
  final User user;
  const AuthenticatedState({
    required this.user,
  });

  AuthenticatedState copyWith({
    User? user,
  }) {
    return AuthenticatedState(
      user: user ?? this.user,
    );
  }

  @override
  List<Object> get props => [user];
}

final class UnauthenticatedState extends AuthenticationState {}
