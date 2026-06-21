import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:logos_app/domain/auth/auth_repository.dart';
import 'package:logos_app/domain/auth/user_model.dart';

enum AuthStatus { idle, loading, success, error }

class AuthViewModel extends ChangeNotifier {
  final AuthRepository _repository;

  AuthViewModel(this._repository);

  AuthStatus _status = AuthStatus.idle;
  AuthStatus get status => _status;

  UserModel? _user;
  UserModel? get user => _user;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  bool get isLoading => _status == AuthStatus.loading;

  // --- Login com email/senha ---
  Future<void> signInWithEmailAndPassword(String email, String password) async {
    _setLoading();
    try {
      _user = await _repository.signInWithEmailAndPassword(email, password);
      _setSuccess();
    } on FirebaseAuthException catch (e) {
      _setError(_mapFirebaseError(e.code));
    } catch (_) {
      _setError(null);
    }
  }

  // --- Cadastro com email/senha ---
  Future<void> signUpWithEmailAndPassword(String name, String email, String password) async {
    _setLoading();
    try {
      _user = await _repository.signUpWithEmailAndPassword(name, email, password);
      _setSuccess();
    } on FirebaseAuthException catch (e) {
      _setError(_mapFirebaseError(e.code));
    } catch (_) {
      _setError(null);
    }
  }

  // --- Login com Google ---
  Future<void> signInWithGoogle() async {
    _setLoading();
    try {
      _user = await _repository.signInWithGoogle();
      _setSuccess();
    } on FirebaseAuthException catch (e) {
      _setError(_mapFirebaseError(e.code));
    } catch (_) {
      _setError(null);
    }
  }

  // --- Sign out ---
  Future<void> signOut() async {
    await _repository.signOut();
    _user = null;
    _status = AuthStatus.idle;
    notifyListeners();
  }

  void resetStatus() {
    _status = AuthStatus.idle;
    _errorMessage = null;
    notifyListeners();
  }

  // --- Helpers ---
  void _setLoading() {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();
  }

  void _setSuccess() {
    _status = AuthStatus.success;
    notifyListeners();
  }

  void _setError(String? message) {
    _status = AuthStatus.error;
    _errorMessage = message;
    notifyListeners();
  }

  String? _mapFirebaseError(String code) {
    switch (code) {
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'invalid_credentials_error';
      case 'email-already-in-use':
        return 'email_already_in_use_error';
      case 'weak-password':
        return 'password_too_short_error';
      case 'invalid-email':
        return 'invalid_email_error';
      case 'network-request-failed':
        return 'network_error_retry';
      default:
        return 'server_connection_error';
    }
  }
}
