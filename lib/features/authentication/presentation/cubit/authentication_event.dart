part of 'authentication_bloc.dart';

abstract class AuthenticationEvent extends Equatable {
  const AuthenticationEvent();

  @override
  List<Object> get props => [];
}

class AuthenticationChangedEvent extends AuthenticationEvent {
  final User? user;
  const AuthenticationChangedEvent({
    required this.user,
  });
}