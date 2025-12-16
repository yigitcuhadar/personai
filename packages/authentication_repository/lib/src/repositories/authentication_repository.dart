import '../models/user.dart';

abstract class AuthenticationRepository {
  // TODO google sign up eklenecek
  // TODO e-posta onaylama eklenecek
  Stream<User?> get user;

  Future<void> signUp({required String email, required String password});

  Future<void> logInWithEmailAndPassword({required String email, required String password});

  Future<void> logOut();
}
