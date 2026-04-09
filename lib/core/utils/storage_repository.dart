import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class FirebaseStorageRepository {
  final FirebaseStorage _storage;

  FirebaseStorageRepository({required FirebaseStorage storage})
      : _storage = storage;

  Future<String> uploadImage({
    required String path,
    required String id,
    required File file,
  }) async {
    final ref = _storage.ref().child(path).child(id);
    final uploadTask = ref.putFile(file);
    final snapshot = await uploadTask;
    return await snapshot.ref.getDownloadURL();
  }
}
