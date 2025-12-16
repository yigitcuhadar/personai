import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

import '../models/models.dart';
import 'repositories.dart';

class FirebaseAuthenticationRepository implements AuthenticationRepository {
  final firebase_auth.FirebaseAuth _firebaseAuth = firebase_auth.FirebaseAuth.instance;

  @override
  Stream<User?> get user => _firebaseAuth.authStateChanges().map((firebase_auth.User? user) => user?.toUser);

  @override
  Future<void> signUp({required String email, required String password}) async {
    try {
      await _firebaseAuth.createUserWithEmailAndPassword(email: email, password: password);
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw SignUpException.fromCode(e.code);
    } catch (_) {
      throw SignUpException.fromCode();
    }
  }

  @override
  Future<void> logInWithEmailAndPassword({required String email, required String password}) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw LoginException.fromCode(e.code);
    } catch (_) {
      throw LoginException.fromCode();
    }
  }

  @override
  Future<void> logOut() async {
    try {
      await _firebaseAuth.signOut();
    } catch (_) {
      throw LogoutException();
    }
  }
}

extension on firebase_auth.User {
  User get toUser => User(id: uid, email: email, name: displayName, photo: photoURL);
}
