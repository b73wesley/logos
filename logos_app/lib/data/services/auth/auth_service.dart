import 'package:firebase_auth/firebase_auth.dart';

abstract interface class AuthService {
  Future<UserCredential> signInWithEmailAndPassword(String email, String password);
  Future<UserCredential> signUpWithEmailAndPassword(String email, String password);
  Future<UserCredential> signInWithGoogle();
  Future<void> signOut();
  User? get currentUser;
  Future<void> updateDisplayName(String name);
}
