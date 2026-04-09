import 'package:firebase_auth/firebase_auth.dart' as firebase;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/auth_user.dart';
import '../../domain/repositories/auth_repository.dart';

class FirebaseAuthRepository implements AuthRepository {
  final firebase.FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  FirebaseAuthRepository({
    required firebase.FirebaseAuth auth,
    required FirebaseFirestore firestore,
  })  : _auth = auth,
        _firestore = firestore;

  @override
  Stream<AuthUser?> get authStateChanges => _auth.authStateChanges().map(
        (user) => user != null ? AuthUser.fromFirebase(user) : null,
      );

  @override
  Future<AuthUser?> get currentUser async {
    final user = _auth.currentUser;
    return user != null ? AuthUser.fromFirebase(user) : null;
  }

  @override
  Future<AuthUser?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential.user != null ? AuthUser.fromFirebase(credential.user!) : null;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<AuthUser?> signUp({
    required String email,
    required String password,
    required String username,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user;
      if (user != null) {
        // Create user document in Firestore
        await _firestore.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'email': email,
          'username': username,
          'displayName': username,
          'photoUrl': '',
          'bio': '',
          'followersCount': 0,
          'followingCount': 0,
          'postsCount': 0,
          'createdAt': FieldValue.serverTimestamp(),
        });
        
        await user.updateDisplayName(username);
        return AuthUser.fromFirebase(user);
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
