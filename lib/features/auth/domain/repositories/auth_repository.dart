import '../entities/auth_user.dart';

abstract class AuthRepository {
  Stream<AuthUser?> get authStateChanges;
  
  Future<AuthUser?> signUp({
    required String email,
    required String password,
    required String username,
  });

  Future<AuthUser?> signIn({
    required String email,
    required String password,
  });

  Future<void> signOut();
  
  Future<AuthUser?> get currentUser;
}
