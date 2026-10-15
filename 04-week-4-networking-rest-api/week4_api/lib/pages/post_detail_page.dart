import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/network_errors.dart';
import '../data/paged_posts.dart';
import '../data/providers.dart';
import '../data/models/post.dart';

class PostDetailPage extends ConsumerWidget {
  const PostDetailPage({required this.id, super.key});

  final int id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cachedPosts = ref.watch(
      pagedPostsProvider.select((state) => state.items),
    );
    Post? cachedPost;
    for (final post in cachedPosts) {
      if (post.id == id) {
        cachedPost = post;
        break;
      }
    }

    if (cachedPost != null) {
      return _buildPostPage(cachedPost);
    }

    final postAsync = ref.watch(postDetailProvider(id));
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Post')),
      body: postAsync.when(
        data: _buildPostContent,
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(friendlyErrorMessage(error)),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () => ref.invalidate(postDetailProvider(id)),
                child: const Text('Coba lagi'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Scaffold _buildPostPage(Post post) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Post')),
      body: _buildPostContent(post),
    );
  }

  Widget _buildPostContent(Post post) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(post.title, style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 12),
          Text(post.body),
        ],
      ),
    );
  }
}
