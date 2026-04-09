import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:synq/features/auth/presentation/providers/auth_providers.dart';
import 'package:synq/core/utils/storage_repository.dart';
import 'package:synq/features/post/domain/entities/post_model.dart';
import 'package:synq/features/post/domain/repositories/post_repository.dart';
import 'package:synq/features/post/data/repositories/firebase_post_repository.dart';

final firebaseStorageProvider = Provider<FirebaseStorage>((ref) {
  return FirebaseStorage.instance;
});

final storageRepositoryProvider = Provider<FirebaseStorageRepository>((ref) {
  return FirebaseStorageRepository(storage: ref.read(firebaseStorageProvider));
});

final postRepositoryProvider = Provider<PostRepository>((ref) {
  return FirebasePostRepository(
    firestore: ref.read(firestoreProvider),
    storageRepository: ref.read(storageRepositoryProvider),
  );
});

final allPostsProvider = StreamProvider<List<PostModel>>((ref) {
  return ref.watch(postRepositoryProvider).fetchPosts();
});

final userPostsProvider = StreamProvider.family<List<PostModel>, String>((ref, uid) {
  return ref.watch(postRepositoryProvider).fetchUserPosts(uid);
});

final postControllerProvider = StateNotifierProvider<PostController, AsyncValue<void>>((ref) {
  return PostController(postRepository: ref.read(postRepositoryProvider));
});

class PostController extends StateNotifier<AsyncValue<void>> {
  final PostRepository _postRepository;

  PostController({required PostRepository postRepository})
      : _postRepository = postRepository,
        super(const AsyncValue.data(null));

  Future<void> createPost({
    required String ownerUid,
    required String username,
    required String userProfileImage,
    required String caption,
    required dynamic imageFile,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _postRepository.createPost(
          ownerUid: ownerUid,
          username: username,
          userProfileImage: userProfileImage,
          caption: caption,
          imageFile: imageFile,
        ));
  }
}
