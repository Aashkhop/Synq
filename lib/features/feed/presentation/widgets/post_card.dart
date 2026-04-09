import 'package:flutter/material.dart';
import 'package:synq/features/post/domain/entities/post_model.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';

class PostCard extends StatelessWidget {
  final PostModel post;

  const PostCard({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: theme.colorScheme.surfaceVariant,
                backgroundImage: post.userProfileImage.isNotEmpty
                    ? CachedNetworkImageProvider(post.userProfileImage)
                    : null,
                child: post.userProfileImage.isEmpty
                    ? const Icon(Icons.person, size: 20)
                    : null,
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    post.username,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const Text('Original Post', style: TextStyle(fontSize: 10, color: Colors.grey)),
                ],
              ),
              const Spacer(),
              IconButton(icon: const Icon(Icons.more_horiz), onPressed: () {}),
            ],
          ),
        ),

        // Post Image
        AspectRatio(
          aspectRatio: 1,
          child: CachedNetworkImage(
            imageUrl: post.imageUrl,
            fit: BoxFit.cover,
            placeholder: (context, url) => Container(color: theme.colorScheme.surfaceVariant),
            errorWidget: (context, url, error) => const Icon(Icons.error),
          ),
        ),

        // Action Buttons
        Row(
          children: [
            IconButton(icon: const Icon(Icons.favorite_border), onPressed: () {}),
            IconButton(icon: const Icon(Icons.chat_bubble_outline), onPressed: () {}),
            IconButton(icon: const Icon(Icons.send_outlined), onPressed: () {}),
            const Spacer(),
            IconButton(icon: const Icon(Icons.bookmark_border), onPressed: () {}),
          ],
        ),

        // Post Info
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${post.likesCount} likes',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              RichText(
                text: TextSpan(
                  style: theme.textTheme.bodyMedium,
                  children: [
                    TextSpan(
                      text: '${post.username} ',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(text: post.caption),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                DateFormat.yMMMd().format(post.createdAt),
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
