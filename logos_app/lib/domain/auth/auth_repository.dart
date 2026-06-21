import 'package:logos_app/domain/auth/user_model.dart';

abstract interface class AuthRepository {
  Future<UserModel> signInWithEmailAndPassword(String email, String password);
  Future<UserModel> signUpWithEmailAndPassword(String name, String email, String password);
  Future<UserModel> signInWithGoogle();
  Future<void> signOut();
  UserModel? get currentUser;
}
