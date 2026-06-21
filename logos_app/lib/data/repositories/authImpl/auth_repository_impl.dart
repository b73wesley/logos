import 'package:logos_app/data/services/auth/auth_service.dart';
import 'package:logos_app/domain/auth/auth_repository.dart';
import 'package:logos_app/domain/auth/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthService _service;

  AuthRepositoryImpl(this._service);

  @override
  UserModel? get currentUser {
    final user = _service.currentUser;
    if (user == null) return null;
    return UserModel(uid: user.uid, name: user.displayName, email: user.email, photoUrl: user.photoURL);
  }

  @override
  Future<UserModel> signInWithEmailAndPassword(String email, String password) async {
    final result = await _service.signInWithEmailAndPassword(email, password);
    final user = result.user!;
    return UserModel(uid: user.uid, name: user.displayName, email: user.email, photoUrl: user.photoURL);
  }

  @override
  Future<UserModel> signUpWithEmailAndPassword(String name, String email, String password) async {
    final result = await _service.signUpWithEmailAndPassword(email, password);
    await _service.updateDisplayName(name);
    final user = result.user!;
    return UserModel(uid: user.uid, name: name, email: user.email, photoUrl: user.photoURL);
  }

  @override
  Future<UserModel> signInWithGoogle() async {
    final result = await _service.signInWithGoogle();
    final user = result.user!;
    return UserModel(uid: user.uid, name: user.displayName, email: user.email, photoUrl: user.photoURL);
  }

  @override
  Future<void> signOut() => _service.signOut();
}
