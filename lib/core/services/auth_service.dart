import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final _auth = FirebaseAuth.instance;

  Future<User?> signup(String email, String password) async {
    try {
      final authCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (authCredential.user != null) {
        log("User created successfully - in the auth_service signUp ");
        return authCredential.user!;
      }
    } on FirebaseAuthException catch (e) {
      log("Error creating user: ${e.message}");
      rethrow;
    } catch (e) {
      log("Error creating user: ${e.toString()}");
      rethrow;
    }
    return null;
  }

  Future<User?> login(String email, String password) async {
    try {
      final authCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (authCredential.user != null) {
        log("User logged in successfully");
        log("Login creadiential: ${authCredential.user}");
        return authCredential.user!;
      }
    } on FirebaseAuthException catch (e) {
      log("Error logging in user: ${e.message}");
      rethrow;
    } catch (e) {
      log("Error logging in user: ${e.toString()}");
      rethrow;
    }
    return null;
  }

  Future<void> logout() async {
    try {
      await _auth.signOut();
    } catch (e) {
      log('Error: ${e.toString()}');
    }
  }
}
