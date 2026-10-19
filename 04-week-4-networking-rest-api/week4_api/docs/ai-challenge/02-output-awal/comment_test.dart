import 'package:flutter_test/flutter_test.dart';
import 'package:week4_api/data/models/comment.dart';

void main() {
  // Field yang tidak tersedia harus menghasilkan nilai bawaan, bukan kegagalan.
  test('fromJson memberi nilai bawaan saat semua field hilang', () {
    final comment = Comment.fromJson(const {});

    expect(comment.postId, 0);
    expect(comment.id, 0);
    expect(comment.name, '');
    expect(comment.email, '');
    expect(comment.body, '');
  });
}
