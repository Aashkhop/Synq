import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:go_router/go_router.dart';
import 'package:synq/features/auth/presentation/providers/auth_providers.dart';
import 'package:synq/features/profile/presentation/providers/user_providers.dart';
import 'package:synq/features/post/presentation/providers/post_providers.dart';
import 'package:synq/core/theme/app_theme.dart';
import 'package:google_fonts/google_fonts.dart';

class AddPostScreen extends ConsumerStatefulWidget {
  const AddPostScreen({super.key});

  @override
  ConsumerState<AddPostScreen> createState() => _AddPostScreenState();
}

class _AddPostScreenState extends ConsumerState<AddPostScreen> {
  File? _image;
  final _captionController = TextEditingController();

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  void _sharePost() async {
    if (_image == null) return;
    
    final currentUser = ref.read(currentUserDataProvider).value;
    if (currentUser == null) return;

    await ref.read(postControllerProvider.notifier).createPost(
          ownerUid: currentUser.uid,
          username: currentUser.username,
          userProfileImage: currentUser.photoUrl,
          caption: _captionController.text.trim(),
          imageFile: _image!,
        );

    final state = ref.read(postControllerProvider);
    if (!state.hasError && mounted) {
      context.go('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    final postState = ref.watch(postControllerProvider);

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: const Text('New Post'),
        actions: [
          if (_image != null)
            TextButton(
              onPressed: postState.isLoading ? null : _sharePost,
              child: const Text('Share', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            if (postState.isLoading)
              const LinearProgressIndicator(),
            
            const SizedBox(height: 20),
            
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                width: MediaQuery.of(context).size.width - 40,
                height: MediaQuery.of(context).size.width - 40,
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20)
                  ],
                ),
                child: _image == null
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_photo_alternate_outlined, size: 64, color: AppTheme.primary.withOpacity(0.5)),
                          const SizedBox(height: 12),
                          const Text('Choose from Gallery', style: TextStyle(color: Colors.grey)),
                        ],
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: Image.file(_image!, fit: BoxFit.cover),
                      ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                controller: _captionController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Write a caption...',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
