import '../../../../core/failures.dart';
import '../entities/post.dart';
import '../repositories/post_repository.dart';

class RefreshPosts {
  const RefreshPosts(this._repository);

  final PostRepository _repository;

  Future<({List<Post> posts, Failure? failure})> call() async {
    final remote = await _repository.fetchRemote();
    if (remote.failure != null) {
      return (posts: const <Post>[], failure: remote.failure);
    }

    final failure = await _repository.saveCache(remote.posts);
    if (failure != null) {
      return (posts: const <Post>[], failure: failure);
    }
    return (posts: remote.posts, failure: null);
  }
}
