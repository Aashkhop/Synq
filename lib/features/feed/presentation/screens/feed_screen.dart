import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:synq/core/theme/app_theme.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:synq/features/post/presentation/providers/post_providers.dart';
import 'package:synq/features/feed/presentation/widgets/post_card.dart';

class FeedScreen extends ConsumerWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postsAsync = ref.watch(allPostsProvider);

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: Text(
          'SynQ',
          style: GoogleFonts.outfit(
            color: AppTheme.primary,
            fontWeight: FontWeight.bold,
            fontSize: 28,
            letterSpacing: -1,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_box_outlined, color: AppTheme.textDark),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.chat_bubble_outline, color: AppTheme.textDark),
            onPressed: () {},
          ),
        ],
      ),
      body: postsAsync.when(
        data: (posts) {
          return RefreshIndicator(
            onRefresh: () async => ref.refresh(allPostsProvider),
            child: ListView.builder(
              padding: const EdgeInsets.only(bottom: 100),
              itemCount: posts.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) return _buildStories();
                final post = posts[index - 1];
                return PostCard(post: post);
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildStories() {
    return Container(
      height: 110,
      margin: const EdgeInsets.only(bottom: 10),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 15),
        itemCount: 10,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(right: 15),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [AppTheme.primary, AppTheme.brandAccent],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: CircleAvatar(
                    radius: 32,
                    backgroundColor: Colors.white,
                    child: CircleAvatar(
                      radius: 30,
                      backgroundImage: NetworkImage('https://i.pravatar.cc/150?u=$index'),
                    ),
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  index == 0 ? 'Your Story' : 'user_$index',
                  style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
