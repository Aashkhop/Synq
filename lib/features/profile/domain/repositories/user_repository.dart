import '../entities/user_model.dart';

abstract class UserRepository {
  Future<UserModel?> getUserData(String uid);
  Future<void> updateProfile({
    required String uid,
    String? displayName,
    String? bio,
    String? photoUrl,
  });
  Stream<UserModel> watchUser(String uid);
}
