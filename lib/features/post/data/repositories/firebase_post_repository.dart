import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'package:synq/core/utils/storage_repository.dart';
import 'package:synq/features/post/domain/entities/post_model.dart';
import 'package:synq/features/post/domain/repositories/post_repository.dart';

class FirebasePostRepository implements PostRepository {
  final FirebaseFirestore _firestore;
  final FirebaseStorageRepository _storageRepository;

  FirebasePostRepository({
    required FirebaseFirestore firestore,
    required FirebaseStorageRepository storageRepository,
  })  : _firestore = firestore,
        _storageRepository = storageRepository;

  @override
  Future<void> createPost({
    required String ownerUid,
    required String username,
    required String userProfileImage,
    required String caption,
    required File imageFile,
  }) async {
    try {
      final postId = const Uuid().v4();
      
      // 1. Upload the image to storage
      final imageUrl = await _storageRepository.uploadImage(
        path: 'posts',
        id: postId,
        file: imageFile,
      );

      final post = PostModel(
        postId: postId,
        ownerUid: ownerUid,
        username: username,
        userProfileImage: userProfileImage,
        imageUrl: imageUrl,
        caption: caption,
        likesCount: 0,
        commentsCount: 0,
        createdAt: DateTime.now(),
      );

      // 2. Save post document
      await _firestore.collection('posts').doc(postId).set(post.toMap());
      
      // 3. Increment posts count for user (atomically)
      await _firestore.collection('users').doc(ownerUid).update({
        'postsCount': FieldValue.increment(1),
      });

    } catch (e) {
      rethrow;
    }
  }

  @override
  Stream<List<PostModel>> fetchPosts() {
    return _firestore
        .collection('posts')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => PostModel.fromMap(doc.data()))
            .toList());
  }

  @override
  Stream<List<PostModel>> fetchUserPosts(String uid) {
    return _firestore
        .collection('posts')
        .where('ownerUid', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => PostModel.fromMap(doc.data()))
            .toList());
  }

  @override
  Future<void> likePost(String postId, String uid) async {
    final likeDoc = _firestore.collection('posts').doc(postId).collection('likes').doc(uid);
    
    if (!(await likeDoc.get()).exists) {
      await likeDoc.set({'uid': uid, 'createdAt': FieldValue.serverTimestamp()});
      await _firestore.collection('posts').doc(postId).update({'likesCount': FieldValue.increment(1)});
    }
  }

  @override
  Future<void> unlikePost(String postId, String uid) async {
    final likeDoc = _firestore.collection('posts').doc(postId).collection('likes').doc(uid);
    if ((await likeDoc.get()).exists) {
      await likeDoc.delete();
      await _firestore.collection('posts').doc(postId).update({'likesCount': FieldValue.increment(-1)});
    }
  }
}
