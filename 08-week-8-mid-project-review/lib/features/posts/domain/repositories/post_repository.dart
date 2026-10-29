import '../../../../core/failures.dart';
import '../entities/post.dart';

abstract interface class PostRepository {
  Future<({List<Post> posts, DateTime? cachedAt, Failure? failure})>
  readCached();

  Future<({List<Post> posts, Failure? failure})> fetchRemote();

  Future<Failure?> saveCache(List<Post> posts);
}
