import 'dart:io';
import '../entities/post_model.dart';

abstract class PostRepository {
  Future<void> createPost({
    required String ownerUid,
    required String username,
    required String userProfileImage,
    required String caption,
    required File imageFile,
  });

  Stream<List<PostModel>> fetchPosts();
  Stream<List<PostModel>> fetchUserPosts(String uid);
  Future<void> likePost(String postId, String uid);
  Future<void> unlikePost(String postId, String uid);
}
