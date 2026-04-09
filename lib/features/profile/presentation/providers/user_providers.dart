import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:synq/features/auth/presentation/providers/auth_providers.dart';
import 'package:synq/features/profile/domain/entities/user_model.dart';
import 'package:synq/features/profile/domain/repositories/user_repository.dart';
import 'package:synq/features/profile/data/repositories/firebase_user_repository.dart';

final userRepositoryProvider = Provider<UserRepository>((ref) {
  return FirebaseUserRepository(firestore: ref.read(firestoreProvider));
});

final currentUserDataProvider = StreamProvider<UserModel?>((ref) {
  final authUser = ref.watch(authStateProvider).value;
  if (authUser == null) return Stream.value(null);
  return ref.watch(userRepositoryProvider).watchUser(authUser.uid);
});

final userDataProvider = StreamProvider.family<UserModel, String>((ref, uid) {
  return ref.watch(userRepositoryProvider).watchUser(uid);
});
