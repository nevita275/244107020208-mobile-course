import 'package:flutter/material.dart';

import '../data/models/post.dart';

// Baris post bersama dengan opsi untuk menampilkan isi post.
class PostTile extends StatelessWidget {
  const PostTile({
    required this.post,
    this.showBody = true,
    this.onTap,
    super.key,
  });

  final Post post;
  final bool showBody;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: CircleAvatar(child: Text(post.id.toString())),
      title: Text(
        post.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: showBody
          ? Text(
              post.body,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            )
          : null,
    );
  }
}
