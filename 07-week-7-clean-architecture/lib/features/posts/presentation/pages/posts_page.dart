import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/format.dart';
import '../../domain/entities/post.dart';
import '../providers/posts_providers.dart';

// Menampilkan posts dari cache lebih dahulu, lalu hasil refresh jaringan.
class PostsPage extends ConsumerWidget {
  const PostsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postsState = ref.watch(postsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Posts'),
        actions: [
          IconButton(
            tooltip: 'Muat ulang',
            onPressed: () => ref.read(postsProvider.notifier).refresh(),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: postsState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(error.toString(), textAlign: TextAlign.center),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: () => ref.read(postsProvider.notifier).refresh(),
                  child: const Text('Coba lagi'),
                ),
              ],
            ),
          ),
        ),
        data: (result) {
          if (result.posts.isEmpty) {
            return const Center(child: Text('Belum ada posts'));
          }

          return Column(
            children: [
              _PostsStatus(result: result),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () => ref.read(postsProvider.notifier).refresh(),
                  child: ListView.builder(
                    itemCount: result.posts.length,
                    itemBuilder: (context, index) =>
                        _PostTile(post: result.posts[index]),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// Banner menjelaskan sumber data dan waktu cache pada daftar.
class _PostsStatus extends StatelessWidget {
  const _PostsStatus({required this.result});

  final PostsResult result;

  @override
  Widget build(BuildContext context) {
    final cachedAt = result.cachedAt == null
        ? null
        : formatDateTime(result.cachedAt!);
    final message =
        result.refreshFailure?.message ??
        (result.fromCache
            ? 'Menampilkan data tersimpan (cache)'
            : 'Data terbaru dari jaringan');

    return Material(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            Expanded(
              child: Text(
                cachedAt == null ? message : '$message · $cachedAt',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (result.refreshing) ...[
              const SizedBox(width: 8),
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// Tile ringkas untuk membaca title dan body dari tiap post.
class _PostTile extends StatelessWidget {
  const _PostTile({required this.post});

  final Post post;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(child: Text('${post.id}')),
      title: Text(post.title),
      subtitle: Text(post.body),
    );
  }
}
